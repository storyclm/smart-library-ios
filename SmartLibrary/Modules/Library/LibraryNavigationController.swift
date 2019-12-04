//
//  LibraryNavigationController.swift
//  SmartLibrary
//
//  Created by Oleksandr Yolkin on 3/21/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import StoryContent
import SwiftKeychainWrapper

class LibraryNavigationController: UINavigationController {

    class func get() -> LibraryNavigationController {
        let sb = UIStoryboard(name: "Library", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "LibraryNC") as! LibraryNavigationController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.login()
        
        SCLMAuthService.shared.logoutHandler = { [weak self] in
            self?.login()
        }
    }

    // MARK: - Controllers

    func pushLibraryIfNeeded() {
        let libraryVC = self.viewControllers.first { (vc) -> Bool in
            return vc is LibraryViewController
        }
        if libraryVC == nil {
            self.pushLibraryVC()
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

    // MARK: - Login

    private func login() {
        let loginViewModel = LoginViewModel()
        if loginViewModel.isLogged() {
            self.pushLibraryIfNeeded()
        } else {
            self.apiLogin { (error) in
                self.pushLibraryIfNeeded()
            }
        }
    }

    private func apiLogin(completion: ((_ error: Error?) -> Void)?) {
        SCLMAuthService.shared.authAsService(success: {
            completion?(nil)
        }) { (error) in
            completion?(error)
        }
    }

}
