//
//  SLLoader.swift
//  StoryCLM
//
//  Created by Sergey Ryazanov on 15.10.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import Lottie

final class SLLoader {

    private var view: UIView?
    private(set) var loader: SLLoaderView?

    private var isNeedToHideAtComplete = false
    private var hideCompletion: (() -> Void)?
    private var isStartAnimationDone: Bool = false

    init(view: UIView) {
        self.view = view
    }

    // MARK: - Animation

    func showAnimation(isFullScreen: Bool = false, positionFix: CGPoint = CGPoint.zero) {
        self.hideAnimation(isAnimated: false, completion: nil)

        guard let view = self.view else { return }

        let loaderView = self.addLoaderView(on: view, isFullScreen: isFullScreen)
        loaderView.contentFixOffset = positionFix

        loaderView.play(state: SLLoaderView.AnimationState.start) {
            self.startAnimationDone()
        }
    }

    func hideAnimation(isAnimated: Bool = true, completion: (() -> Void)? = nil) {
        guard isAnimated else {
            self.resetFlags()
            self.removeLoader()

            completion?()
            return
        }

        guard isStartAnimationDone else {
            self.isNeedToHideAtComplete = true
            self.hideCompletion = completion
            return
        }

        self.resetFlags()

        if let loader = self.loader {
            loader.play(state: SLLoaderView.AnimationState.end) {
                self.removeLoader()
                completion?()
            }
        } else {
            completion?()
        }
    }

    // MARK: - Views helper

    private func removeViewAnimated(_ view: UIView, completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.5, animations: {
            view.alpha = 0
        }) { (_) in
            view.removeFromSuperview()
            completion?()
        }
    }

    private func addLoaderView(on view: UIView, isFullScreen: Bool) -> SLLoaderView {
        self.removeLoader()

        let loaderView = SLLoaderView(on: view, isFullScreen: isFullScreen)
        self.loader = loaderView

        return loaderView
    }

    // MARK: - Helpers

    private func removeLoader() {
        if let loader = self.loader {
            loader.removeFromSuperview()
            self.loader = nil
        }
    }

    private func resetFlags() {
        self.isStartAnimationDone = false
        self.isNeedToHideAtComplete = false
        self.hideCompletion = nil
    }

    private func startAnimationDone() {
        self.isStartAnimationDone = true
        if isNeedToHideAtComplete {
            self.hideAnimation(isAnimated: true, completion: hideCompletion)
        }
    }

}
