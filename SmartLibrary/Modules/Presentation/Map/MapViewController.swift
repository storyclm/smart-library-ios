//
//  MapViewController.swift
//  StoryCLM
//
//  Created by Oleksandr Yolkin on 4/4/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import StoryContent

protocol MapViewControllerProtocol: class {
    func decodeAndLoadSlide(_ slide: Slide)
}

class MapViewController: UIViewController, UIViewControllerTransitioningDelegate, PSTreeGraphDelegate {

    var mapPC: MapPresentationController?
    weak var delegate: MapViewControllerProtocol?
    
    @IBOutlet weak var treeGraphView: PSBaseTreeGraphView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var heightConstraints = [NSLayoutConstraint]()
    var widthConstraints = [NSLayoutConstraint]()
    var viewDictionary = [String: UIView]()
    
    var startUpSlide: Slide?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let startUpSlide = startUpSlide else {
            assertionFailure("startUpSlide should be injected before viewDidLoad")
            return
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        view.backgroundColor = UIColor.clear
        
        scrollView.delegate = self
        scrollView.backgroundColor = .lightGray
        treeGraphView.backgroundColor = .lightGray
        setupMapView(startUpSlide: startUpSlide)
    }
    
    deinit {
        print("MapViewController deinit")
    }
    
    // MARK: - Setup
    
    func setupMapView(startUpSlide: Slide) {

        treeGraphView.delegate = self
        treeGraphView.nodeViewNibName = "SlideLeafNodeView"
        treeGraphView.treeGraphOrientation = .horizontal
        treeGraphView.connectingLineColor = UIColor.white
        treeGraphView.contentMargin = UIEdgeInsets(top: 12.0, left: 26.0, bottom: 6.0, right: 26.0)
        treeGraphView.parentChildSpacing = 15.0
        treeGraphView.siblingSpacing = 15.0
        
        treeGraphView.modelRoot = SlideModelNode.wrapperForSlide(startUpSlide)
        treeGraphView.selectedModelNodes = NSSet(objects: treeGraphView.modelRoot) as? Set<AnyHashable>
        treeGraphView.scrollSelectedModelNodesToVisible(animated: true)

        treeGraphView.resizesToFillEnclosingScrollView = false
        
        var mapContentSize = treeGraphView.minimumFrameSize
        if mapContentSize.height > self.view.frame.height {
            mapContentSize.height = self.view.frame.height - 100.0
        }
        mapPC?.minimumFrameSize = mapContentSize
        scrollView.contentSize = treeGraphView.minimumFrameSize
        scrollView.contentOffset = CGPoint.zero
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapGestureHandler(_:)))
        singleTap.numberOfTapsRequired = 1
        treeGraphView.addGestureRecognizer(singleTap)
        
    }
    
    // MARK: - Actions
    
    @objc func singleTapGestureHandler(_ sender: UITapGestureRecognizer) {
        if sender.state == .recognized {
            
            let point = sender.location(in: treeGraphView)
            if let selectedNode = treeGraphView.modelNode(at: point) as? SlideModelNode {
                
                treeGraphView.selectedModelNodes = NSSet(object: selectedNode) as? Set<AnyHashable>
                treeGraphView.scrollSelectedModelNodesToVisible(animated: true)
                
                if let slide = selectedNode.slide {
                    delegate?.decodeAndLoadSlide(slide)
                }
                
            }

        }
    }
    
    // MARK: - Helpers
    
    func decodeAndLoadPage(slide: Slide, contentsUrl: URL) {

    }
    
    @objc func orientationDidChange() {
        dismiss()
    }
    
    func dismiss() {
        dismiss(animated: true, completion: {
            self.mapPC = nil
        })
    }

    // MARK: - UIViewControllerTransitioningDelegate
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        mapPC = MapPresentationController(presentedViewController: presented, presenting: presenting)
        mapPC?.dissmissHanler = { [weak self] in
            self?.dismiss()
        }
        return mapPC
    }
    
    // MARK: - PSTreeGraphDelegate
    
    func configureNodeView(_ nodeView: UIView!, with modelNode: PSTreeGraphModelNode!) {
        guard let nodeView = nodeView, let modelNode = modelNode else {
            return
        }
        
        let slideNode = modelNode as! SlideModelNode
        let leafView = nodeView as! SlideLeafView
        
        if let imagePath = slideNode.imagePath {
            let leafImg = UIImage(contentsOfFile: imagePath)
            leafView.imageView.image = leafImg
        }
        
        leafView.dotView.isHidden = true
        
    }
    

}

extension MapViewController {
    func inject(startUpSlide: Slide) {
        self.startUpSlide = startUpSlide
    }
}

extension MapViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -150.0 {
            dismiss()
        }
    }

}
