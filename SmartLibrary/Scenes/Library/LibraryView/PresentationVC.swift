//
//  PresentationVC.swift
//  SmartLibrary
//
//  Created by Alexander Yolkin on 1/29/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import WebKit
import ContentComponent

protocol PresentationVCProtocol: class {
    func presentationVCWillClose()
}

class PresentationVC: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate, SCLMBridgeProtocol, SCLMBridgeViewerModuleProtocol, SCLMBridgeBaseModuleProtocol, SCLMBridgeUIModuleProtocol, SCLMBridgePresentationModuleProtocol {

    weak var delegate: PresentationVCProtocol?
    
    @IBOutlet weak var webView: SCLMWebView!
    @IBOutlet weak var mediaButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    
    private var bridge: SCLMBridge?
    private weak var currentPresentation: Presentation!
    private weak var currentSlide: Slide!
    
    private var previousSlideName = ""
    private var nextSlideName = ""
    private var backForwardList = [String]()
    private var backForwardPresList = [String]()
    private var navigationData = ["":""]
    
    private var mediaPlaybackRequiresUserAction = false
    private var controlsTimer: Timer?
    private var isControlsHidden = false
    
    deinit {
        print("PresentationVC deinit")
    }
    
    override var prefersStatusBarHidden: Bool {
        return StatusBarInfo.isToHiddenStatus
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let _ = currentPresentation else {
            fatalError("presentation should be settled befor viewDidLoad")
        }
        
        if let contentId = currentPresentation.presentationId {
            bridge = SCLMBridge(presenter: webView, presentation: currentPresentation, contentId: contentId, delegate: self)
        } else {
            AlertController.showAlert(title: "Ошибка", message: "Целостность данных нарушена. Функционал моста не может быть подключен.", presentedFor: self, buttonLeft: .ok, buttonRight: nil, buttonLeftHandler: nil, buttonRightHandler: nil)
        }
        tapGesture.delegate = self
        webView.navigationDelegate = self
        
        setupWebViewConfiguration()
        setupUI()
        
        if let sourcesFolderUrl = currentPresentation.sourcesFolderUrl() {
            let filePathURL = sourcesFolderUrl.appendingPathComponent("index.html")
            webView.loadFileURL(filePathURL, allowingReadAccessTo: sourcesFolderUrl)
        }
         
    }
    
    // MARK: - Setup
    
    private func setupWebViewConfiguration() {
        
        webView.configuration.processPool = WKProcessPool()
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.suppressesIncrementalRendering = true
        webView.configuration.requiresUserActionForMediaPlayback = mediaPlaybackRequiresUserAction
        webView.configuration.allowsPictureInPictureMediaPlayback = true
        webView.configuration.selectionGranularity = .character
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        webView.configuration.preferences = preferences
        
    }
    
    private func setupUI() {
        self.mediaButton.isHidden = currentPresentation.mediaFiles?.count == 0
    }
    
    // MARK: - Actions
    
    @IBAction func tapGestureHandler() {
        dismissControls()
    }
    
    @IBAction func closeButtonPressed() {
        willClose()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MediaSegue" {
            let mediaVC = segue.destination as! MediaVC
            mediaVC.inject(presentation: currentPresentation)
        }
    }
    
    // MARK: - Helpers
    
    @objc func dismissControls() {
        self.closeButton.alpha = isControlsHidden ? 0.0 : 1.0
        self.mediaButton.alpha = isControlsHidden ? 0.0 : 1.0
        self.tapGesture.delegate = nil
        
        if let controlsTimer = controlsTimer, controlsTimer.isValid {
            controlsTimer.invalidate()
        }
        
        if isControlsHidden {
            controlsTimer = Timer(timeInterval: 5.0, target: self, selector: #selector(dismissControls), userInfo: nil, repeats: false)
        }
        
        let alpha = isControlsHidden ? 1.0 : 0.0
        isControlsHidden = !isControlsHidden
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.closeButton.alpha = CGFloat(alpha)
            self?.mediaButton.alpha = CGFloat(alpha)
        }) { [weak self] (success) in
            self?.tapGesture.delegate = self
        }
    }
    
    func willClose() {
        currentPresentation.setOpendState()
        SCLMSyncManager.shared.saveContext()
        delegate?.presentationVCWillClose()
        
        webView.navigationDelegate = nil
        if webView.isLoading {
            webView.stopLoading()
        }
        controlsTimer?.invalidate()
        mediaButton.isHidden = true
        closeButton.isHidden = true
        
    }

    // MARK: - SCLMWebViewProtocol
    
    func webViewDidStartLoad(webView: SCLMWebView) {
        
    }
    
    func webViewDidFinishLoad(webView: SCLMWebView) {
        
    }
    
    func webView(_ webView: SCLMWebView, didFailLoadWith error: NSError) {
        
    }
    
    
    func webViewShouldStartLoad(with request: NSURLRequest, navigationType: SLWebViewNavigationType) -> Bool {
        
        guard let requestUrl = request.url, let scheme = requestUrl.scheme else {
            return true
        }
        
        if scheme == "file" {
            
            if let slide = currentPresentation.slides?.filter({ $0.name == requestUrl.lastPathComponent }).first, let currentSlide = currentSlide {
                
                if currentSlide.slideId?.intValue != slide.slideId?.intValue {
                    if let backForwardListLast = backForwardList.last, backForwardListLast != currentSlide.name {
                        if let currentSlideName = currentSlide.name {
                            backForwardList.append(currentSlideName)
                        }
                    }
                    // TODO: - [self updateBackgroundView];
                }
                
            }
            
            return true
            
        } else if scheme == SCLMBridgeConstants.Scheme.rawValue {
            
            let args = requestUrl.absoluteString.components(separatedBy: ":")
            let command = args[1]
            
            print("command: \(command)")

            if command == SCLMBridgeConstants.Queue.rawValue {
                bridge?.handleJavaScriptRequest()
            }
        
            return false
            
        }
        
        return true
    }
    
    // MARK: - WKNavigationDelegate
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        print("navigationAction url - \(url)")
        
        if let scheme = url.scheme, scheme == "tel" {
            openUrl(url, errorMessage: "Ваше устройство не может совершмть звонки")
            decisionHandler(.cancel)
            
        } else if let scheme = url.scheme, scheme == "mailto" {
            openUrl(url, errorMessage: "Невозможно открыть URL")
            decisionHandler(.cancel)
            
        } else {
            
            if webViewShouldStartLoad(with: navigationAction.request as NSURLRequest, navigationType: .other) {
                decisionHandler(.allow)
            
            } else {
                decisionHandler(.cancel)
                
            }
            
        }
   
    }
    

    private func openUrl(_ url: URL, errorMessage: String) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            AlertController.showAlert(title: "Ошибка", message: errorMessage, presentedFor: self, buttonLeft: .ok, buttonRight: nil, buttonLeftHandler: nil, buttonRightHandler: nil)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - SCLMBridgeViewerModuleProtocol
    func openMediaFile() {
        print("openMediaFile")
    }
    func openMediaFilesController() {
        print("openMediaFilesController")
    }
    func showMediaFilesControllerButton() {
        print("showMediaFilesControllerButton")
        mediaButton.isHidden = false
        
    }
    func hideMediaFilesControllerButton() {
        print("hideMediaFilesControllerButton")
        mediaButton.isHidden = true
    }
    
    // MARK: - SCLMBridgeBaseModuleProtocol
    
    func gotToSlide(_ slide: Slide, with data: Any) {
        print("")
    }
    
    func getNavigationData() -> Any {
        return navigationData
    }
    
    // MARK: - SCLMBridgeUIModuleProtocol
    
    func hideCloseBtn() {
        DispatchQueue.main.async {
            self.closeButton.isHidden = true
        }
    }
    
    func hideMediaLibraryBtn() {
        DispatchQueue.main.async {
            self.mediaButton.isHidden = true
        }
    }
    
    func hideSystemBtns() {
        self.hideCloseBtn()
    }
    
    func hideMapBtn() {
        // reserved
    }
    
    // MARK: - SCLMBridgePresentationModuleProtocol
    
    func closePresentation() {
        DispatchQueue.main.async {
            self.willClose()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - SCLMBridgeProtocol
    
    func getPreviousSlide() -> String {
        return ""
    }
    
    func getNextSlide() -> String {
        return ""
    }
    
    func getBackForwardList() -> Array<String> {
        return [""]
    }
    
    func getBackForwardPresList() -> Array<String> {
        return [""]
    }
    
    func getCurrentSlideName() -> String {
        return ""
    }
    
//    func gotToSlide(_ slide: Slide, with data: Any) {
//
//    }
//
//    func getNavigationData() -> Any {
//        return navigationData
//    }
    
    func openMediaFile(_ mediaFile: MediaFile) {
        
    }
    
    func openPresentation(_ presentation: Presentation, with slideName: String, and data: Any) {
        
    }
    
//    func closePresentation() {
//
//    }
    
    func setPresentationComplete() {
        
    }
    
    func setEventKey(_ key: String, and value: Any) {
        
    }
    
    func openMediaLibrary() {
        
    }
    
}

extension PresentationVC {
    func inject(presentation: Presentation) {
        self.currentPresentation = presentation
    }
}
