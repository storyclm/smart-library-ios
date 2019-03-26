//
//  SLPlayerViewController.swift
//  SmartLibrary
//
//  Created by Oleksandr Yolkin on 2/26/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import AVKit

class SLPlayerViewController: AVPlayerViewController {

    override var prefersStatusBarHidden: Bool {
        return StatusBarInfo.isToHiddenStatus
    }
    
}
