//
//  SLProgressView.swift
//  SmartLibrary
//
//  Created by Alexander Yolkin on 1/30/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation
import UIKit

class SLProgressView: UIProgressView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.forEach { subview in
            subview.layer.masksToBounds = true
            subview.layer.cornerRadius = 2.0
        }
    }
    
}
