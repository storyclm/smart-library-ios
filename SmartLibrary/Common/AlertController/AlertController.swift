//
//  AlertController.swift
//  SmartLibrary
//
//  Created by Alexander Yolkin on 1/30/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation
import UIKit

enum AlertControllerButtonType {
    case ok, yes, no, cancel
    
    func description() -> String {
        switch self {
        case .ok:
            return "ОК"
        case .yes:
            return "Да"
        case .no:
            return "Нет"
        case .cancel:
            return "Отмена"
        }
    }
    
    func style() -> UIAlertAction.Style {
        switch self {
        case .ok:
            return .default
        case .yes:
            return .default
        case .no:
            return .cancel
        case .cancel:
            return .cancel
        }
    }
}

class AlertController {
    
    /// Construct and show Alert with custom parameters
    class func showAlert(title: String?, message: String?, presentedFor vc: UIViewController, buttonLeftTitle: String?, buttonLeftStyle: UIAlertAction.Style?, buttonRightTitle: String?, buttonRightStyle: UIAlertAction.Style?, buttonLeftHandler:((UIAlertAction) -> Void)?, buttonRightHandler:((UIAlertAction) -> Void)?) {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let buttonLeft = UIAlertAction(title: buttonLeftTitle, style: buttonLeftStyle ?? .default, handler: buttonLeftHandler)
            let buttonRight = UIAlertAction(title: buttonRightTitle, style: buttonRightStyle ?? .default, handler: buttonRightHandler)
            
            alertController.addAction(buttonLeft)
            alertController.addAction(buttonRight)
            
            vc.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    /// Construct and show Alert with AlertControllerButtonType
    class func showAlert(title: String?, message: String?, presentedFor vc: UIViewController, buttonLeft: AlertControllerButtonType?, buttonRight: AlertControllerButtonType?, buttonLeftHandler:((UIAlertAction) -> Void)?, buttonRightHandler:((UIAlertAction) -> Void)?) {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            if let buttonLeft = buttonLeft {
                let buttonLeft = UIAlertAction(title: buttonLeft.description(), style: buttonLeft.style(), handler: buttonLeftHandler)
                alertController.addAction(buttonLeft)
            }
            
            if let buttonRight = buttonRight {
                let buttonRight = UIAlertAction(title: buttonRight.description(), style: buttonRight.style(), handler: buttonRightHandler)
                alertController.addAction(buttonRight)
            }
            
            vc.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
}
