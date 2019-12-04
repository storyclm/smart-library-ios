//
//  LoginViewController.swift
//  SmartLibrary
//
//  Created by Oleksandr Yolkin on 3/20/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import StoryContent
import SVProgressHUD

class LoginViewController: UIViewController {

    let viewModel = LoginViewModel()
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    
    class func get() -> LoginViewController {
        let sb = UIStoryboard(name: "Library", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        return vc
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.text = viewModel.loadFromKeychain().username
        passwordField.text = viewModel.loadFromKeychain().password
        
        emailField.delegate = self
        passwordField.delegate = self
        passwordField.isSecureTextEntry = true
        
        emailField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Actions
    
    @IBAction func signinButtonPressed() {
        if isValidEmail(email: emailField.text) == false {
            showInvalidEmailAlert()
            return
        }
        if isPasswordNotEmpty(pass: passwordField.text) == false {
            showEmptyPasswordAlert()
            return
        }
        login()
    }
    
    @IBAction func signinAsServiceButtonPressed() {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Login...")
        SCLMAuthService.shared.authAsService(success: {
            SVProgressHUD.dismiss()
            
            let libraryVC = LibraryViewController.get()
            self.navigationController?.pushViewController(libraryVC, animated: true)
            
        }) { (error) in
            SVProgressHUD.dismiss()
            AlertController.showAlert(title: "Error",
                                      message: error.localizedDescription,
                                      presentedFor: self, buttonLeft: .ok, buttonRight: nil, buttonLeftHandler: nil, buttonRightHandler: nil)
        }
    }
    
    // MARK: - Helpers
    
    func isValidEmail(email: String?) -> Bool {
        #if DEBUG
        return true
        #else
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
        #endif
    }
    
    func isPasswordNotEmpty(pass: String?) -> Bool {
        if let pass = pass {
            return pass.count > 0
        }
        return false
    }
    
    func showInvalidEmailAlert() {
        AlertController.showAlert(title: "Error", message: "Email address seems invalid", presentedFor: self, buttonLeft: .ok, buttonRight: nil, buttonLeftHandler: nil, buttonRightHandler: nil)
    }
    
    func showEmptyPasswordAlert() {
        AlertController.showAlert(title: "Error", message: "Password can't be empty", presentedFor: self, buttonLeft: .ok, buttonRight: nil, buttonLeftHandler: nil, buttonRightHandler: nil)
    }
    
    // MARK: - API calls
    
    private func login() {
        guard let user = emailField.text, let pass = passwordField.text else {
            AlertController.showAlert(title: "Error", message: "Wrong email or password", presentedFor: self, buttonLeft: .ok, buttonRight: nil, buttonLeftHandler: nil, buttonRightHandler: nil)
            return
        }
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Login...")
        
        viewModel.login(username: user, password: pass, success: {
            SVProgressHUD.dismiss()
            
            let libraryVC = LibraryViewController.get()
            self.navigationController?.pushViewController(libraryVC, animated: true)
        }) { error in
            SVProgressHUD.dismiss()
            AlertController.showAlert(title: "Error",
                                      message: error.localizedDescription,
                                      presentedFor: self, buttonLeft: .ok, buttonRight: nil, buttonLeftHandler: nil, buttonRightHandler: nil)
        }
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            if isValidEmail(email: textField.text) {
                passwordField.becomeFirstResponder()
            } else {
                showInvalidEmailAlert()
            }
        }
        
        if textField == passwordField {
            view.endEditing(true)
        }
        
        return true
    }
    
}
