//
//  Router.swift
//  SmartLibrary
//
//  Created by Sergey Ryazanov on 10.12.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import StoryContent

final class Router {

    private(set) var navigationController: UINavigationController?

    // MARK: - Init

    init() {
        SCLMAuthService.shared.logoutHandler = {[weak self] in
            self?.checkLogin(completion: { (success) in
                // Do nothing?
            })
        }
    }

    func start() {
        self.pushMainViewController()
    }

    // MARK: - Navigation

    func pushMainViewController() {
        let navigationController = UINavigationController(rootViewController: MainViewController(with: self))
        navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController = navigationController

        AppDelegate.shared().window?.rootViewController = navigationController
    }

    // MARK: - Login

    func checkLogin(completion: @escaping ((_ success: Bool) -> Void)) {
        let loginViewModel = LoginViewModel()

        if loginViewModel.isLogged() {
            completion(true)
        } else {
            self.apiLogin { (error) in
                completion(error == nil)
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
