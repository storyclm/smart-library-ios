//
//  LoginViewModel.swift
//  SmartLibrary
//
//  Created by Oleksandr Yolkin on 3/22/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation
import ContentComponent
import SwiftKeychainWrapper

enum KeychainKeys: String {
    case email = "email"
    case password = "password"
}

class LoginViewModel {
    
    init() {
        if AppDelegate.shared().isFirstLaunch() {
            KeychainWrapper.standard.removeObject(forKey: KeychainKeys.email.rawValue)
            KeychainWrapper.standard.removeObject(forKey: KeychainKeys.password.rawValue)
            AppDelegate.shared().setIsFirstLaunchDone()
        }
        
    }
    
    public func isLogged() -> Bool {
        if let _ = KeychainWrapper.standard.string(forKey: KeychainKeys.email.rawValue), let _ = KeychainWrapper.standard.string(forKey: KeychainKeys.password.rawValue), AppDelegate.shared().isFirstLaunch() == false {
            return true
        }
        return false
    }
    
    public func login(username: String, password: String, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        
        SCLMAuthService.shared.auth(username: username, password: password, success: { (token) in
            self.saveToKeychain(username, password)
            success()
            
        }) { (error) in
            failure(error)
            
        }
        
    }
    
    // Keychain
    
    private func saveToKeychain(_ email: String, _ password: String) {
        KeychainWrapper.standard.set(email, forKey: KeychainKeys.email.rawValue)
        KeychainWrapper.standard.set(password, forKey: KeychainKeys.password.rawValue)
    }
    
    public func loadFromKeychain() -> (username: String?, password: String?) {
        if let email = KeychainWrapper.standard.string(forKey: KeychainKeys.email.rawValue), let pass = KeychainWrapper.standard.string(forKey: KeychainKeys.password.rawValue) {
            return (email, pass)
            
        }
        return (nil, nil)
    }
    
}
