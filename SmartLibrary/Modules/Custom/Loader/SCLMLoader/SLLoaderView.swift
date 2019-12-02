//
//  SLLoaderView.swift
//  StoryCLM
//
//  Created by Sergey Ryazanov on 17.10.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import Lottie

final class SLLoaderView: UIView {

    enum AnimationState {
        case start
        case end
    }

    private(set) var animationState: AnimationState?
    
    var contentFixOffset = CGPoint.zero

    let contentView = SLLoaderContentView()

    init(on view: UIView) {
        super.init(frame: view.bounds)
        view.addSubview(self)
        
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
        
        self.addSubview(contentView)
        self.calculateContentFrame()
        self.contentView.calculateFrames()
    }

    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.calculateContentFrame()
    }
    
    private func calculateContentFrame() {
        self.contentView.frame = {
            var rect = CGRect.zero
            rect.size = CGSize(width: 350.0, height: 225.0)
            rect.origin.x = (self.frame.width - rect.size.width) * 0.5 + contentFixOffset.x
            rect.origin.y = (self.frame.height - rect.size.height) * 0.5 + contentFixOffset.y
            return rect.integral
        }()
    }

    // MARK: - Play

       func play(state: AnimationState, completion: (() -> Void)? = nil) {
           self.animationState = state

           switch state {
           case AnimationState.start:
            self.contentView.animationView.animationSpeed = 1.0
            self.contentView.animationView.play(fromFrame: 0, toFrame: 17, loopMode: LottieLoopMode.playOnce) {[weak self] _ in
                self?.contentView.animationView.animationSpeed = 0.60
                self?.contentView.animationView.play(fromFrame: 17, toFrame: 30, loopMode: LottieLoopMode.loop, completion: nil)
                   completion?()
               }
           case AnimationState.end:
            self.contentView.animationView.animationSpeed = 0.60
            self.contentView.animationView.play(toFrame: self.contentView.animationView.animation?.endFrame ?? 0, loopMode: LottieLoopMode.playOnce) { _ in
                   completion?()
               }
           }
       }
}
