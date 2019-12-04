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
        
        let libraryNC = LibraryNavigationController.get()
        AppDelegate.shared().window?.rootViewController = libraryNC
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
         if isFirstLaunch() == false { setIsFirstLaunchDone() }
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            return .all
        } else {
            return .portrait
        }
    }
    
    
    // MARK: - Helpers
    
    func setupServicesWithAuthCredentials() {
        
        guard let plistURL = Bundle.main.url(forResource: "AuthCredentials", withExtension: "plist"), let dict = NSDictionary(contentsOf: plistURL),
            let clientId = dict["clientId"] as? String,
            let clientSecret = dict["clientSecret"] as? String,
            let appId = dict["appId"] as? String,
            let appSecret = dict["appSecret"] as? String,
            let authEndpoint = dict["authEndpoint"] as? String,
            let apiEndpoint = dict["apiEndpoint"] as? String else {
                
                fatalError("You don't have AuthCredentials.plist or it has wrong data")
            }
            
            SCLMAuthService.shared.setClientId(clientId)
            SCLMAuthService.shared.setClientSecret(clientSecret)

            SCLMAuthService.shared.setAppId(appId)
            SCLMAuthService.shared.setAppSecret(appSecret)
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

