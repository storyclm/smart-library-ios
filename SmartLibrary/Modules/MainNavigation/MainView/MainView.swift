//
//  MainView.swift
//  SmartLibrary
//
//  Created by Sergey Ryazanov on 10.12.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit

final class MainView: UIView {

    let logoImageView = UIImageView(image: UIImage(named: "img_launch_logo"))

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
        self.backgroundColor = UIColor.backgroundColor
        self.addSubview(logoImageView)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        self.logoImageView.sizeToFit()
        self.logoImageView.center = self.center
    }
}
