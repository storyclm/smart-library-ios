//
//  BatchLoaderView.swift
//  StoryCLM
//
//  Created by Sergey Ryazanov on 28.11.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation
import StoryContent

class BatchLoaderView: UIView {

    private let loader = SLLoaderView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    private func setup() {
        self.addSubview(self.loader)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.loader.frame = {
            var rect = CGRect.zero
            rect.size = CGSize(width: 350.0, height: 225.0)
            rect.origin.x = (self.frame.width - rect.width) * 0.5
            rect.origin.y = (self.frame.height - rect.height) * 0.5
            return rect
        }()
    }
}

extension BatchLoaderView {

    var preferredSize: CGSize {
        return CGSize(width: 350.0, height: 225.0)
    }

    func startLoading() {
        self.loader.play(state: SLLoaderView.AnimationState.start)
    }

    func stopLoading() {
        self.loader.play(state: SLLoaderView.AnimationState.end)
    }

}
