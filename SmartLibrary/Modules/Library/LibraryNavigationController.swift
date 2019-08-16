//
//  LibraryNavigationController.swift
//  SmartLibrary
//
//  Created by Oleksandr Yolkin on 3/21/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import ContentComponent
import SwiftKeychainWrapper

class LibraryNavigationController: UINavigationController {

    class func get() -> LibraryNavigationController {
        let sb = UIStoryboard(name: "Library", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "LibraryNC") as! LibraryNavigationController
        return vc
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let loginViewModel = LoginViewModel()
        if loginViewModel.isLogged()  {
            if let _ = loginViewModel.loadFromKeychain().username, let _ = loginViewModel.loadFromKeychain().password {
                self.pushLibraryVC()
                
            } else {
                self.pushLoginVC()
                
            }
            
        } else {
            self.pushLoginVC()
            
        }
        
        SCLMAuthService.shared.logoutHandler = { [weak self] in
            let loginVC = LoginViewController.get()
            loginVC.viewModel.logout()
            self?.pushViewController(loginVC, animated: false)
        }
    }
    
    func pushLibraryVC() {
        let libraryVC = LibraryViewController.get()
        self.pushViewController(libraryVC, animated: false)
    }
    
    func pushLoginVC() {
        let loginVC = LoginViewController.get()
        self.pushViewController(loginVC, animated: false)
    }

}
