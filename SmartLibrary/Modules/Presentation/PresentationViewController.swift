//
//  PresentationViewController.swift
//  StoryCLM
//
//  Created by Alexander Yolkin on 1/29/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import WebKit
import StoryContent
import CoreLocation

protocol PresentationViewControllerDelegate: class {
    func presentationViewControllerWillClose()
}

class PresentationViewController: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate, SCLMBridgeProtocol, SCLMBridgeMediaFilesModuleProtocol, SCLMBridgeBaseModuleProtocol, SCLMBridgeUIModuleProtocol, SCLMBridgeCustomEventsModuleProtocol, SCLMBridgePresentationModuleProtocol, SCLMBridgeSessionsModuleProtocol, SCLMBridgeMapModuleProtocol, MapViewControllerProtocol {
    
    weak var delegate: PresentationViewControllerDelegate?
    
    @IBOutlet weak var webView: SCLMWebView!
    @IBOutlet weak var mediaButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    
    private var bridge: SCLMBridge?
    private var currentPresentation: Presentation!
    private var currentSlide: Slide!
    
    private var navigationMethod: String?
    private var slideStartTime: CFTimeInterval = 0
    private var slideInactiveTime: CFTimeInterval = 0
    
    private var previousSlide: Slide?
    private var nextSlide: Slide?
    private var backForwardList = [String]()
    private var backForwardPresList = [Presentation]()
    private var navigationData = ["":""]
    
    private var mediaPlaybackRequiresUserAction = false
    private var controlsTimer: Timer?
    private var isControlsHidden = false

    private(set) weak var mainPresentation: Presentation?

    deinit {
        print("PresentationViewController deinit")
    }
    
    override var prefersStatusBarHidden: Bool {
        return StatusBarInfo.isToHiddenStatus
    }
    
    // MARK: -
    
    class func get() -> PresentationViewController {
        let sb = UIStoryboard(name: "Library", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "PresentationVC") as! PresentationViewController
        return vc
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObservers()
        
        UserDefaults.standard.removeObject(forKey: "applicationWillResignActiveStartTime")
        
        guard currentPresentation != nil else {
            fatalError("presentation should be settled befor viewDidLoad")
        }
        
        bridge = SCLMBridge(presenter: webView, presentation: currentPresentation, delegate: self)
        self.addCustomBridgeModule()

        tapGesture.delegate = self
        webView.navigationDelegate = self
//        webView.scrollView.isScrollEnabled = false
        
        setupWebViewConfiguration()
        setupUI()
        
        createOrRestoreSessionIfNeed()
        
        
        if let startUpSlide = currentPresentation.startUpSlide() {
            currentSlide = startUpSlide
            slideStartTime = CACurrentMediaTime();
            slideInactiveTime = 0
            navigationMethod = "in"
            loadSlide(startUpSlide)
        }
        
        
        // BackForwardLists
        if let presentation = currentPresentation {
            backForwardPresList.append(presentation)
        }
        if let slideName = currentSlide.name {
            backForwardList.append(slideName)
        }

        self.updateCloseButtonVisibility()
    }
    
    // MARK: - Observers
    
    private func addObservers() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    @objc func applicationWillResignActive() {
        print("applicationWillResignActive")
        UserDefaults.standard.set(CACurrentMediaTime(), forKey: "applicationWillResignActiveStartTime")
    }
    
    @objc func applicationDidBecomeActive() {
        print("applicationDidBecomeActive")
        if let time = UserDefaults.standard.object(forKey: "applicationWillResignActiveStartTime") as? CFTimeInterval {
            slideInactiveTime = CACurrentMediaTime() - time
            print("Inactive time is \(slideInactiveTime)")
            UserDefaults.standard.removeObject(forKey: "applicationWillResignActiveStartTime")
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
        
        if let mapEnabled = self.currentPresentation.mapEnabled?.boolValue, mapEnabled == true {
            self.mapButton.isHidden = false
        } else {
            self.mapButton.isHidden = true
        }
    }
    
    private func createOrRestoreSessionIfNeed() {
        guard let bridge = bridge else { return }
        
        let unfinishedSession = bridge.sessions.isUnfinishedSessionExist()
        if unfinishedSession.isExist {
            AlertController.showAlert(title: "Восстановление", message: "Восстановить предыдущую сессию?", presentedFor: self, buttonLeft: .no, buttonRight: .yes, buttonLeftHandler: { (action) in
                bridge.sessions.updateStateForSession(withSessionId: unfinishedSession.session?.sessionId ?? "noId", state: .isTest)
                bridge.sessions.addNewSession()
                
                
            }) { (action) in
                bridge.sessions.restoreUnfinishedSession()
                if let lastOpenedSlideId = bridge.sessions.lastOpenedSlideId() {
                    if let lastOpenedSlide = SCLMSyncManager.shared.getSlide(withId: lastOpenedSlideId) {
                        self.loadSlide(lastOpenedSlide)
                        self.currentSlide = lastOpenedSlide
                    }
                    
                }
                
            }
            
        } else {
            bridge.sessions.addNewSession()
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func tapGestureHandler() {
        dismissControls()
    }
    
    @IBAction func closeButtonPressed() {
        self.closeIfNeeded(mode: .closeDefault)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MediaSegue" {
            let mediaVC = segue.destination as! MediaViewController
            mediaVC.inject(presentation: currentPresentation)
            mediaVC.inject(bridge: bridge)
        }
        
        if segue.identifier == "MapSegue" {
            let mapVC = segue.destination as! MapViewController
            mapVC.inject(startUpSlide: currentSlide)
            mapVC.delegate = self
        }
    }
    
    // MARK: - Helpers
    
    func loadSlide(_ slide: Slide) {
        if let sourcesFolderUrl = currentPresentation.sourcesFolderUrl(), let slideName = slide.name {
            let contentDirUrl =  sourcesFolderUrl.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            let filePathURL = sourcesFolderUrl.appendingPathComponent(slideName)
            DispatchQueue.main.async {
                self.webView.loadFileURL(filePathURL, allowingReadAccessTo: contentDirUrl)
            }
        }
    }
    
    func slideDuration() -> CFTimeInterval {
        return CACurrentMediaTime() - slideStartTime - slideInactiveTime
    }
    
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

    private func closeIfNeeded(mode: ClosePresentationMode) {
        if let mainPresentation = self.mainPresentation {
            if self.currentPresentation != mainPresentation {
                self.openPresentation(mainPresentation, with: nil, and: nil)
            } else {
                // Нельзя закрывать главную (main) презентацию
            }
        } else {
            DispatchQueue.main.async {
                self.close(mode: mode) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func close(mode: ClosePresentationMode, completion: @escaping () -> Void) {
        
        if mode == .closeDefault {
            
            if let needConfirmation = currentPresentation.needConfirmation?.boolValue, needConfirmation == true {
                
                let ac = UIAlertController(title: "Закрыть", message: "Сохранить и выйти?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action) in
                    self.willClose()
                    self.bridge?.sessions.updateStateForCurrentSession(state: .isComplete)
                    completion()
                }))
                ac.addAction(UIAlertAction(title: "Нет", style: .default, handler: { (action) in
                    self.willClose()
                    self.bridge?.sessions.updateStateForCurrentSession(state: .isTest)
                    completion()
                }))
                ac.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                
                self.present(ac, animated: true, completion: nil)
                
            } else {
                
                let ac = UIAlertController(title: "Закрыть", message: "Сохранить и выйти?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action) in
                    self.willClose()
                    self.bridge?.sessions.updateStateForCurrentSession(state: .isComplete)
                    completion()
                }))
                ac.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                
                self.present(ac, animated: true, completion: nil)
                
            }
            
        } else if mode == .closeSessionComplete {
            self.willClose()
            self.bridge?.sessions.updateStateForCurrentSession(state: .isComplete)
            completion()
            
        } else if mode == .closeSessionTest {
            self.willClose()
            self.bridge?.sessions.updateStateForCurrentSession(state: .isTest)
            completion()
            
        }
        
    }
    
    func willClose() {
        
        bridge?.sessions.logAction(.close, slide: currentSlide, duration: slideDuration(), navigationMethod: navigationMethod ?? "")
        bridge?.sessions.updateSlidesForCurrentSession(withSlide: self.currentSlide, duration: slideDuration())
        bridge?.sessions.logAction(.close, presentation: currentPresentation)
        
        
        currentPresentation.setOpendState()
        SCLMSyncManager.shared.saveContext()
        delegate?.presentationViewControllerWillClose()
        
        webView.navigationDelegate = nil
        if webView.isLoading {
            webView.stopLoading()
        }
        controlsTimer?.invalidate()
        mediaButton.isHidden = true
        closeButton.isHidden = true
    }

    private func updateCloseButtonVisibility() {
        self.closeButton.isHidden = (currentPresentation == mainPresentation)
    }
    
    // MARK: - SCLMWebViewProtocol
    
    func webViewDidStartLoad(webView: SCLMWebView) {
        // RESERVED
    }
    
    func webViewDidFinishLoad(webView: SCLMWebView) {
        // RESERVED
    }
    
    func webView(_ webView: SCLMWebView, didFailLoadWith error: NSError) {
        // RESERVED
    }
    
    
    func webViewShouldStartLoad(with request: NSURLRequest, navigationType: SLWebViewNavigationType) -> Bool {
        
        guard let requestUrl = request.url, let scheme = requestUrl.scheme else {
            return true
        }
        
        if scheme == "file" {
            
            if let slide = currentPresentation.slides?.filter({ $0.name == requestUrl.lastPathComponent }).first, let currentSlide = self.currentSlide {
                
                if currentSlide.slideId?.intValue != slide.slideId?.intValue {
                    if let backForwardListLast = backForwardList.last, backForwardListLast != currentSlide.name {
                        if let currentSlideName = currentSlide.name {
                            backForwardList.append(currentSlideName)
                        }
                    }
                    
                    bridge?.sessions.logAction(.close, slide: self.currentSlide, duration: slideDuration(), navigationMethod: "in")
                    bridge?.sessions.updateSlidesForCurrentSession(withSlide: self.currentSlide, duration: slideDuration())
                    
                    slideStartTime = CACurrentMediaTime()
                    slideInactiveTime = 0
                    navigationMethod = "in"
                    
                    self.previousSlide = self.currentSlide
                    self.currentSlide = slide
                    
                    
                    bridge?.sessions.updateLastOpenedSlideId(self.currentSlide.slideId?.int32Value)
                    bridge?.sessions.incrementSlidesCountForCurrentSession()
                    
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
            openUrl(url, errorMessage: "Ваше устройство не может совершать звонки")
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
    
    // MARK: - SCLMBridgeBaseModuleProtocol
    
    func goToSlide(_ slide: Slide, with data: Any) {
        bridge?.sessions.logAction(.close, slide: self.currentSlide, duration: slideDuration(), navigationMethod: navigationMethod ?? "")
        bridge?.sessions.updateSlidesForCurrentSession(withSlide: self.currentSlide, duration: slideDuration())
        
        
        slideStartTime = CACurrentMediaTime()
        slideInactiveTime = 0
        navigationMethod = "in"
        
        self.previousSlide = self.currentSlide
        self.currentSlide = slide
        
        bridge?.sessions.updateLastOpenedSlideId(self.currentSlide.slideId?.int32Value)
        bridge?.sessions.incrementSlidesCountForCurrentSession()
        
        self.loadSlide(slide)
        self.currentSlide = slide
        
    }
    
    func getNavigationData() -> Any {
        return navigationData
    }
    
    //MARK: - SCLMBridgePresentationModuleProtocol
    
    func openPresentation(_ presentation: Presentation, with slideName: String?, and data: Any?) {
        
        bridge?.sessions.logAction(.close, slide: self.currentSlide, duration: slideDuration(), navigationMethod: navigationMethod ?? "")
        bridge?.sessions.updateSlidesForCurrentSession(withSlide: self.currentSlide, duration: slideDuration())
        
        bridge?.sessions.logAction(.close, presentation: self.currentPresentation)
        
        
        if presentation.sclmIsIndexExist() {
            bridge?.sessions.createNewSession(forPresentation: presentation)
            self.currentPresentation = presentation
            
            backForwardPresList.append(presentation)
            if let navigationData = data as? [String : String] {
                self.navigationData = navigationData
            }
            
            if let name = slideName, name.count > 0 {
                self.currentSlide = presentation.slides?.filter({$0.name == name}).first
            } else {
                self.currentSlide = presentation.startUpSlide()
            }
            
            if let currentSlide = self.currentSlide {
                backForwardList.removeAll()
                if let slideName = currentSlide.name {
                    backForwardList.append(slideName)
                }
                self.loadSlide(currentSlide)
            }

            self.updateCloseButtonVisibility()
        } else {
            AlertController.showAlert(title: "Открытие презентации", message: "Вы пытаетесь открыть презентацию \(presentation.name ?? ""), контент которой не загружен. Загрузите контент и попробуйте еще раз.", presentedFor: self, buttonLeft: .ok, buttonRight: nil, buttonLeftHandler: nil, buttonRightHandler: nil)
        }
    }
    
    func getPreviousSlide() -> Slide? {
        return previousSlide
    }
    
    func getNextSlide() -> Slide? {
        return nextSlide
    }
    
    func getCurrentSlideName() -> String? {
        return currentSlide.name
    }
    
    func getBackForwardList() -> [SlideName]? {
        return backForwardList
    }
    
    func getBackForwardPresList() -> [Presentation]? {
        return backForwardPresList
    }
    
    func closePresentation(mode: ClosePresentationMode) {
        self.closeIfNeeded(mode: mode)
    }
    
    // MARK: - SCLMBridgeUIModuleProtocol
    
    func hideCloseBtn() {
        closeButton.hide()
    }
    
    func hideSystemBtns() {
        mediaButton.hide()
        closeButton.hide()
        mapButton.hide()
    }
    
    // MARK: - SCLMBridgeSessionsModuleProtocol
    
    func setSessionComplete() {
        bridge?.sessions.logAction(.complete, presentation: self.currentPresentation)
    }
    
    // MARK: - SCLMBridgeCustomEventsModuleProtocol
    
    func setEventKey(_ key: String, and value: Any) {
        bridge?.sessions.logEventKey(key, value: value, presentation: currentPresentation)
    }
    
    // MARK: - SCLMBridgeMediaFilesModuleProtocol
    
    func openMediaFile(_ fileName: String) {
        DispatchQueue.main.async {
            let mediaVC = MediaViewController.get()
            mediaVC.inject(presentation: self.currentPresentation)
            mediaVC.inject(bridge: self.bridge)
            mediaVC.inject(mediaFileNameToOpenAtLaunch: fileName)
            self.present(mediaVC, animated: true, completion: nil)
        }
    }
    
    func openMediaLibrary() {
        DispatchQueue.main.async {
            let mediaVC = MediaViewController.get()
            mediaVC.inject(presentation: self.currentPresentation)
            mediaVC.inject(bridge: self.bridge)
            self.present(mediaVC, animated: true, completion: nil)
        }
    }
    
    func showMediaLibraryBtn() {
        mediaButton.show()
        
    }
    
    func hideMediaLibraryBtn() {
        mediaButton.hide()
    }
    
    // MARK: - SCLMBridgeMapModuleProtocol
    
    func hideMapBtn() {
        mapButton.hide()
    }
    
    func showMapBtn() {
        mapButton.show()
    }
    
    // MARK: - MapViewControllerProtocol
    
    func decodeAndLoadSlide(_ slide: Slide) {
        
        bridge?.sessions.logAction(.close, slide: currentSlide, duration: slideDuration(), navigationMethod: navigationMethod ?? "")
        bridge?.sessions.updateSlidesForCurrentSession(withSlide: self.currentSlide, duration: slideDuration())
        
        slideStartTime = CACurrentMediaTime()
        slideInactiveTime = 0
        navigationMethod = "out"
        previousSlide = currentSlide
        currentSlide = slide
        
        bridge?.sessions.updateLastOpenedSlideId(self.currentSlide.slideId?.int32Value)
        bridge?.sessions.incrementSlidesCountForCurrentSession()
        
        loadSlide(slide)
    }

    // MARK: - CustomBridgeModule

    func addCustomBridgeModule() {
        if let bridge = self.bridge {
            let customBridgeModule = CustomBridgeModule(presenter: webView, session: bridge.sessions.session, presentation: currentPresentation, settings: nil, environments: nil, delegate: nil)
            customBridgeModule.delegate = self

            bridge.subscribe(module: customBridgeModule, toCommands: CustomBridgeModule.Commands.allCommands)
            bridge.addBridgeModule(customBridgeModule)
        }
    }
}

extension PresentationViewController: CustomBridgeModuleDelegate {

    func customBridgeModuleDelegateCallback(command: String, params: Any) {
        print("CustomBridgeModuleDelegate command: \(command) with params: \(params)")
    }
}

extension PresentationViewController {
    func inject(presentation: Presentation, isMain: Bool) {
        self.currentPresentation = presentation
        self.mainPresentation = presentation
    }
}

extension PresentationViewController: SCLMLocationManagerProtocol {
    func authorizationStatusNoAccess() {
        AlertController.showAlert(title: "Нет доступа к геопозиции", message: "Перейдите в настройки, чтобы предоставить доступ.", presentedFor: self, buttonLeft: nil, buttonRight: .ok, buttonLeftHandler: nil) { (action) in
            
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
    }
    
    func locationServicesDisabled() {
        AlertController.showAlert(title: "Службы геолокации отключены", message: "Перейдите в Настройки -> Конфиденциальность, чтобы включить службы геолокации.", presentedFor: self, buttonLeft: nil, buttonRight: .ok, buttonLeftHandler: nil, buttonRightHandler: nil)
        
    }
    
    func authorizationStatusAccessGranted() {
        print("authorizationStatusAccessGranted")
    }
    
    func autoLocationRecieved() {
        // RESERVED
    }
    
    
}

extension PresentationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // RESERVED
    }
}

extension UIView {
    func show() {
        DispatchQueue.main.async {
            self.isHidden = false
        }
    }
    func hide() {
        DispatchQueue.main.async {
            self.isHidden = true
        }
    }
}

