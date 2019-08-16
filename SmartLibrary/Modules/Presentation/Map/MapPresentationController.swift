//
//  MapPresentationCotroller.swift
//  StoryCLM
//
//  Created by Oleksandr Yolkin on 4/4/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit

class MapPresentationController: UIPresentationController {

    var dimmingView: UIView!
    var minimumFrameSize = CGSize.zero
    
    var dissmissHanler: (() -> Void)?
    
    deinit {
        print("MapPresentationController deinit")
    }
    
    override func presentationTransitionWillBegin() {
        
        if dimmingView == nil, let containerView = self.containerView {
            dimmingView = UIView(frame: containerView.bounds)
            dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
            dimmingView.addGestureRecognizer(tapGesture)
            
            
            dimmingView.frame = containerView.bounds
            dimmingView.alpha = 0.0
            
            containerView.addSubview(dimmingView)
            
            presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
                self.dimmingView.alpha = 1.0
            }, completion: nil)
            
        }
        
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed == false {
            dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = 0.0
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            if let containerView = self.containerView {
                return CGRect(x: 0.0, y: containerView.frame.size.height - minimumFrameSize.height, width: containerView.frame.size.width, height: minimumFrameSize.height)
            } else {
                return CGRect.zero
            }
        }
    }
    
    @objc func handleTapGesture() {
        dissmissHanler?()
    }
    
}
