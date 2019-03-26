//
//  LibraryNC.swift
//  SmartLibrary
//
//  Created by Oleksandr Yolkin on 3/21/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import ContentComponent
import SwiftKeychainWrapper

class LibraryNC: UINavigationController {

    class func get() -> LibraryNC {
        let sbName = UI_USER_INTERFACE_IDIOM() == .pad ? "Library_iPad" : "Library_iPhone"
        let sb = UIStoryboard(name: sbName, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "LibraryNC") as! LibraryNC
        return vc
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let loginViewModel = LoginViewModel()
        if loginViewModel.isLogged()  {
            if let username = loginViewModel.loadFromKeychain().username, let password = loginViewModel.loadFromKeychain().password {
                
                loginViewModel.login(username: username, password: password, success: {
                    self.pushLibraryVC()
                    
                }) { (error) in
                    self.pushLoginVC()
                    
                }
                
            } else {
                self.pushLoginVC()
                
            }
            
            
        } else {
            self.pushLoginVC()
        }
        
        SCLMAuthService.shared.logoutHandler = { [weak self] in
            let loginVC = LoginVC.get()
            self?.pushViewController(loginVC, animated: false)
        }
    }
    
    func pushLibraryVC() {
        let libraryVC = LibraryVC.get()
        self.pushViewController(libraryVC, animated: false)
    }
    
    func pushLoginVC() {
        let loginVC = LoginVC.get()
        self.pushViewController(loginVC, animated: false)
    }

}
