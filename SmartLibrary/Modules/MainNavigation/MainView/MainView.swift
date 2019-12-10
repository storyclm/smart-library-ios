//
//  MainView.swift
//  SmartLibrary
//
//  Created by Sergey Ryazanov on 10.12.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit

final class MainView: UIView {

    private lazy var gradientLayer: CAGradientLayer = {
           let gradientLayer = CAGradientLayer()
           gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
           gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
           gradientLayer.colors = [ UIColor(red: 0.99, green: 0.99, blue: 1, alpha: 1).cgColor, UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1).cgColor ]
           return gradientLayer
       }()

    var loader = SLLoaderView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    private func setup() {
        self.layer.insertSublayer(self.gradientLayer, at: 0)
        self.addSubview(loader)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        self.gradientLayer.frame = self.bounds

        self.loader.frame = {
            var rect = CGRect.zero
            rect.size = CGSize(width: 350.0, height: 225.0)
            rect.origin.x = (self.frame.width - rect.width) * 0.5
            rect.origin.y = (self.frame.height - rect.height) * 0.5
            return rect
        }()
    }
}
