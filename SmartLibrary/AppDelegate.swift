//
//  AppDelegate.swift
//  SmartLibrary
//
//  Created by Alexander Yolkin on 1/22/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import AlamofireNetworkActivityLogger
import StoryContent

struct StatusBarInfo {
    static var isToHiddenStatus = false
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var router = Router()

    class func shared() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NetworkActivityLogger.shared.level = .info
        NetworkActivityLogger.shared.startLogging()
        
        if #available(iOS 11.0, *) {
            if (window?.safeAreaInsets.top)! > CGFloat(0.0) || window?.safeAreaInsets != .zero {
                print("iPhone X")
                StatusBarInfo.isToHiddenStatus = true
            }
            else {
                StatusBarInfo.isToHiddenStatus = true
                print("Not iPhone X")
            }
        }
        
        setupServicesWithAuthCredentials()
        
        SLSessionsSyncManager.shared.startTimer()

        self.router.start()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
         if isFirstLaunch() == false { setIsFirstLaunchDone() }
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }
    
    
    // MARK: - Helpers
    
    func setupServicesWithAuthCredentials() {
        
        guard let plistURL = Bundle.main.url(forResource: "AuthCredentials", withExtension: "plist"), let dict = NSDictionary(contentsOf: plistURL),
            let clientId = dict["clientId"] as? String,
            let clientSecret = dict["clientSecret"] as? String,
            let authEndpoint = dict["authEndpoint"] as? String,
            let apiEndpoint = dict["apiEndpoint"] as? String else {
                
                fatalError("You don't have AuthCredentials.plist or it has wrong data")
            }
            
            SCLMAuthService.shared.setClientId(clientId)
            SCLMAuthService.shared.setClientSecret(clientSecret)

            SCLMAuthService.shared.setAuthEndpoint(authEndpoint)
            SCLMSyncService.shared.setApiEndpoint(apiEndpoint)
        
    }
    
    func isFirstLaunch() -> Bool {
        if let _ = UserDefaults.standard.value(forKey: "isFirstLaunchDone") {
            return false
        }
        return true
    }
    
    func setIsFirstLaunchDone() {
        UserDefaults.standard.set(true, forKey: "isFirstLaunchDone")
    }
}

