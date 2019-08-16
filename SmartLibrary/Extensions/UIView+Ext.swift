//
//  UIView+Ext.swift
//  SmartLibrary
//
//  Created by Oleksandr Yolkin on 8/16/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowRadius = 8
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
