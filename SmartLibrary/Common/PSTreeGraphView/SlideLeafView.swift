//
//  SlideLeafView.swift
//  StoryCLM
//
//  Created by Oleksandr Yolkin on 4/4/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit

class SlideLeafView: PSBaseLeafView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dotView: UIImageView!
    
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    
    func configureDefaults() {
        // Initialize ivars directly.  As a rule, it's best to avoid invoking accessors from an -init...
        // method, since they may wrongly expect the instance to be fully formed.
        
        //333333
        //_borderColor = [AVHexColor colorWithHexString:@"#c8c8c8"];
        self.borderWidth = 2.0
        //_cornerRadius = 8.0;
        //_fillColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0];
        self.selectionColor = UIColor.red
        self.isShowingSelected = false
    }
    
    func updateLayerAppearanceToMatchContainerView() {
        // // Disable implicit animations during these layer property changes, to make them take effect immediately.
        
        let actionsWereDisabled = CATransaction.disableActions
        CATransaction.setDisableActions(true)
        
        // Apply the ContainerView's appearance properties to its backing layer.
        // Important: While UIView metrics are conventionally expressed in points, CALayer metrics are
        // expressed in pixels.  To produce the correct borderWidth and cornerRadius to apply to the
        // layer, we must multiply by the window's userSpaceScaleFactor (which is normally 1.0, but may
        // be larger on a higher-resolution display) to yield pixel units.
        
        //CGFloat scaleFactor = [[self window] userSpaceScaleFactor];
        let scaleFactor = 1.0
        
        let layer = self.imageView.layer
        
        layer.borderWidth = (self.borderWidth * CGFloat(scaleFactor))
        
        if self.borderWidth > 0.0 {
            layer.borderColor = self.borderColor.cgColor
        }
        
        if self.isShowingSelected {
            layer.borderColor = self.selectionColor.cgColor
            self.dotView.isHidden = false
        
        } else {
            layer.borderColor = UIColor.clear.cgColor
            self.dotView.isHidden = true
        }
        
        // // Disable implicit animations during these layer property changes
        CATransaction.setDisableActions(actionsWereDisabled())
    }
    
}
