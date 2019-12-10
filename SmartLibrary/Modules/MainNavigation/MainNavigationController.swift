//
//  MainNavigationController.swift
//  SmartLibrary
//
//  Created by Sergey Ryazanov on 10.12.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import StoryContent

final class MainNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarHidden(true, animated: false)
        
        self.login()

        SCLMAuthService.shared.logoutHandler = {[weak self] in
            self?.login()
        }
    }

    // MARK: - Navigation

    func pushMainViewController() {
        let mainViewController = MainViewController()
        self.pushViewControllerIfNeeded(mainViewController, animated: true)
    }

    private func pushViewControllerIfNeeded(_ viewController: UIViewController, animated: Bool) {
        let oldViewController = self.viewControllers.first (where: { (vc) -> Bool in
            return vc is MainViewController
        })

        if oldViewController == nil {
            self.pushViewController(viewController, animated: animated)
        }
    }

    // MARK: - Login

    private func login() {
        let loginViewModel = LoginViewModel()
        if loginViewModel.isLogged() {
            self.pushMainViewController()
        } else {
            self.apiLogin { (error) in
                self.pushMainViewController()
            }
        }
    }

    private func apiLogin(completion: ((_ error: Error?) -> Void)? ) {
        SCLMAuthService.shared.authAsService(success: {
            completion?(nil)
        }) { (error) in
            completion?(error)
        }
    }

}


