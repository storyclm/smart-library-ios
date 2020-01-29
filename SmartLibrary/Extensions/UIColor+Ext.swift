//
//  UIColor+Ext.swift
//  SmartLibrary
//
//  Created by Oleksandr Yolkin on 2/26/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation
import UIKit

/// Usege
/// let color = UIColor(red: 0xFF, green: 0xFF, blue: 0xFF)
/// let color2 = UIColor(rgb: 0xFFFFFF)
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    static var backgroundColor: UIColor {
        return UIColor(red: 0.99, green: 0.99, blue: 1, alpha: 1)
    }
}
