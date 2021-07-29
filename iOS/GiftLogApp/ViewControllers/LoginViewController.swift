//
//  LoginViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/27/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: BaseViewController, GIDSignInUIDelegate, UITextFieldDelegate {

    // MARK: Views
    
    @IBOutlet weak var textfieldsContainerView: UIView!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googlePlusButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    // MARK: Custom methods
    
    func hideKeyboardIfNeeded() {
        hideKeyboard()
    }
    
    // MARK: UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            if !SSHelperManager.shared.isValidEmail(textField.text!) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UIAlertController.showAlertWithTitle("", message: "Email format is wrong")
                }
                return textField.resignFirstResponder()
            }
        } else if textField == passwordTextField {
            if !SSHelperManager.shared.isPasswordValid(textField.text!) {
                textField.text = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UIAlertController.showAlertWithTitle("Password format is wrong", message: "Minimum password's length should be 6 symbols")
                }
                return textField.resignFirstResponder()
            }
        }
        // Try to find next responder
        if let nextField = textfieldsContainerView.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        }
        return textField.resignFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction func facebookSignInButtonTapped(_ sender: Any) {
        hideKeyboardIfNeeded()
        AuthManager.shared.signUserWithFacebookFromController(self)
    }
    
    @IBAction func googlePlusSignInButtonTapped(_ sender: Any) {
        hideKeyboardIfNeeded()
        AuthManager.shared.signUserWithGooglePlus()
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        hideKeyboardIfNeeded()
        if !SSHelperManager.shared.areAllTextFieldsEnteredInView(textfieldsContainerView) {
            return UIAlertController.showAlertWithTitle("Not all fields are entered", message: "Please enter all fields")
        }
        AuthManager.shared.signInUserWithEmail(emailTextField.text!, password: passwordTextField.text!)
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        hideKeyboardIfNeeded()
        NavigationManager.shared.showForgotPasswordViewControllerFromController(self)
    }

    @IBAction func registerAccountButtonTapped(_ sender: Any) {
        NavigationManager.shared.showSignUpViewControllerFromController(self)
    }
}
