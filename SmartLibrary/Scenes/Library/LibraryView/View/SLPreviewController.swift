//
//  SLPreviewController.swift
//  SmartLibrary
//
//  Created by Oleksandr Yolkin on 2/26/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import QuickLook

class SLPreviewController: QLPreviewController {

    override var prefersStatusBarHidden: Bool {
        return StatusBarInfo.isToHiddenStatus
    }
    
}
