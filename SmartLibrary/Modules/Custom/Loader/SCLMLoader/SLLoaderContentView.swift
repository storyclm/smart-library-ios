//
//  SLLoaderContentView.swift
//  StoryCLM
//
//  Created by Sergey Ryazanov on 17.10.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import Lottie

final class SLLoaderContentView: UIView {

    private let blurImageView = UIImageView(image: UIImage(named: "img_loader_background"))

    let animationView = AnimationView(name: "loader", animationCache: LRUAnimationCache.sharedCache)

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
        self.clipsToBounds = true

        self.addSubview(blurImageView)
        self.addSubview(animationView)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        self.calculateFrames()
    }

    func calculateFrames() {
        self.blurImageView.frame = {
            var rect = CGRect.zero
            rect.size = CGSize(width: 175.0, height: 175.0)
            rect.origin.x = (self.frame.width - rect.size.width) * 0.5
            rect.origin.y = (self.frame.height - rect.size.height) * 0.5
            return rect.integral
        }()

        self.animationView.frame = {
            var rect = CGRect.zero
            rect.size = CGSize(width: 320, height: 320)
            rect.origin.x = (self.frame.width - rect.size.width) * 0.5
            rect.origin.y = (self.frame.height - rect.size.height) * 0.5
            return rect.integral
        }()
    }
}
