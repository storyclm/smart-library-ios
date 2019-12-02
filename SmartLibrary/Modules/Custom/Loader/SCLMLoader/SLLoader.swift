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

    private var loaderView: SLLoaderView?

    private var hideCompletion: (() -> Void)?
    private var isHideAwaits = false
    private var isStartAnimationDone: Bool = false {
        didSet {
            if self.isStartAnimationDone && isHideAwaits {
                self.hideAnimation(completion: hideCompletion)
            }
        }
    }

    static let instance = SLLoader()

    private init() {}

    // MARK: - Animation

    func showAnimation(on view: UIView, positionFix: CGPoint = CGPoint.zero) {
        let loaderView = self.addLoaderView(on: view)
        loaderView.contentFixOffset = positionFix

        loaderView.play(state: SLLoaderView.AnimationState.start) {
            self.isStartAnimationDone = true
        }
    }

    func hideAnimation(completion: (() -> Void)? = nil) {
        guard isStartAnimationDone else {
            isHideAwaits = true
            self.hideCompletion = completion
            return
        }

        self.resetFlags()

        if let loaderView = self.loaderView {
            loaderView.play(state: SLLoaderView.AnimationState.end) {
                self.removeViewAnimated(loaderView) {
                    self.loaderView = nil
                    completion?()
                }
            }
        } else {
            completion?()
        }
    }

    func hideAnimationInstantly() {
        self.resetFlags()

        self.loaderView?.removeFromSuperview()
        self.loaderView = nil
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

    private func addLoaderView(on view: UIView) -> SLLoaderView {
        if let loader = self.loaderView {
            loader.removeFromSuperview()
            self.loaderView = nil
        }

        let loaderView = SLLoaderView(on: view)
        self.loaderView = loaderView

        return loaderView
    }

    // MARK: - Helpers

    private func resetFlags() {
        self.isStartAnimationDone = false
        self.isHideAwaits = false
        self.hideCompletion = nil
    }

}
