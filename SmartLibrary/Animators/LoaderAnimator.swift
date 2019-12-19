//
//  LoaderAnimator.swift
//  SmartLibrary
//
//  Created by Sergey Ryazanov on 17.12.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import StoryContent

final class LoaderAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    var duration: TimeInterval = 1.0
    var isPresenting: Bool = true

    var dismissCompletion: (() -> Void)?

    init(isPresenting: Bool) {
        super.init()
        self.isPresenting = isPresenting
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)

        guard let mainVC = self.mainVC(from: isPresenting ? fromVC : toVC) else {
            transitionContext.completeTransition(false)
            return
        }

        if self.isPresenting {
            self.animation(transitionContext: transitionContext, mainViewController: mainVC) { success in
                transitionContext.completeTransition(success)
            }
        } else {
            self.animation(transitionContext: transitionContext, to: mainVC) { success in
                transitionContext.completeTransition(success)
                self.dismissCompletion?()
            }
        }
    }

    // MARK: - Animations

    private func animation(transitionContext: UIViewControllerContextTransitioning, mainViewController: MainViewController, completion: @escaping (Bool) -> Void) {
        let container = transitionContext.containerView

        guard let toView = transitionContext.view(forKey: .to) else {
            completion(false)
            return
        }

        container.addSubview(toView)
        container.bringSubviewToFront(toView)
        toView.alpha = 0.0

        let loaderViewSnap = mainViewController.mainView.loader.snapshotView(afterScreenUpdates: true)
        loaderViewSnap?.frame = mainViewController.mainView.loader.frame
        if let loaderSnap = loaderViewSnap {
            container.addSubview(loaderSnap)
        }

        mainViewController.mainView.loader.alpha = 0.0

        UIView.animate(withDuration: 0.5, animations: {
            loaderViewSnap?.center = CGPoint(x: loaderViewSnap?.center.x ?? 0, y: container.frame.height * 0.25 - 6.0)
        }) { (_) in
            UIView.animate(withDuration: 0.5, animations: {
                toView.alpha = 1.0
            }) { (_) in
                mainViewController.mainView.loader.alpha = 1.0
                loaderViewSnap?.removeFromSuperview()
                completion(true)
            }
        }
    }

    private func animation(transitionContext: UIViewControllerContextTransitioning, to mainViewController: MainViewController, completion: @escaping (Bool) -> Void) {
        let container = transitionContext.containerView

        guard let toView = transitionContext.view(forKey: .to) else {
            completion(false)
            return
        }
        container.addSubview(toView)

        let fromView = transitionContext.view(forKey: .from)
        if let fView = fromView {
            container.bringSubviewToFront(fView)
        }

        let loaderViewSnap = mainViewController.mainView.loader.snapshotView(afterScreenUpdates: true)
        loaderViewSnap?.frame = mainViewController.mainView.loader.frame
        if let loaderSnap = loaderViewSnap {
            container.addSubview(loaderSnap)
            loaderSnap.center = CGPoint(x: loaderViewSnap?.center.x ?? 0, y: container.frame.height * 0.25 - 6.0)
        }

        mainViewController.mainView.loader.alpha = 0.0

        UIView.animate(withDuration: 0.5, animations: {
            fromView?.alpha = 0.0
        }) { (_) in
            UIView.animate(withDuration: 0.5, animations: {
                loaderViewSnap?.center = mainViewController.mainView.loader.center
            }) { (_) in
                fromView?.alpha = 1.0
                mainViewController.mainView.loader.alpha = 1.0

                loaderViewSnap?.removeFromSuperview()
                completion(true)
            }
        }
    }

    // MARK: - View controllers

    private func mainVC(from viewController: UIViewController?) -> MainViewController? {
        guard let viewController = viewController else { return nil }
        guard let navigationController = viewController as? UINavigationController else { return viewController as? MainViewController }
        guard let mainVC = navigationController.viewControllers.last as? MainViewController else { return nil }

        return mainVC
    }

    private func loaderVC(from viewController: UIViewController?) -> SCLMBatchLoadingViewController? {
        return viewController as? SCLMBatchLoadingViewController
    }

}