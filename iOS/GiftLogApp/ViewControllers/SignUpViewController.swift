//
//  SignUpViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/27/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

class SignUpViewController: BaseViewController {

    // MARK: Views
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var textfieldsContainerView: UIView!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googlePlusButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureRecognizerForKeyboardDissmiss()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerControllerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Keyboard notifications
    
    func registerControllerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification:NSNotification){
        let keyboardFrame:CGRect = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardY = UIScreen.main.bounds.size.height - keyboardFrame.size.height
        let delta = signUpButton.frame.maxY - keyboardY
        if delta > 0 {
            self.backButton.alpha = 0
            self.view.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.origin.y - delta - Constants.extraMarginFromKeyboard)
        }
    }
    
    func keyboardWillHide(notification:NSNotification){
        self.backButton.alpha = 1
        self.view.frame.origin = CGPoint.zero
    }
    
    // MARK: Custom methods
    
    func hideKeyboardIfNeeded() {
        hideKeyboard()
    }
    
    func arePasswordsTheSame(_ originPassword: String, confirmPassword: String) -> Bool {
        if originPassword == confirmPassword {
            return true
        }
        return false
    }
    
    // MARK: UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            if !SSHelperManager.shared.isValidEmail(textField.text!) {
                UIAlertController.showAlertWithTitle("", message: "Email format is wrong")
                return false
            }
        } else if textField == passwordTextField {
            if !SSHelperManager.shared.isPasswordValid(textField.text!) {
                textField.text = ""
                UIAlertController.showAlertWithTitle("Password format is wrong", message: "Minimum password's length should be 6 symbols")
                return false
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
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        hideKeyboardIfNeeded()
        if !SSHelperManager.shared.areAllTextFieldsEnteredInView(textfieldsContainerView) {
            return UIAlertController.showAlertWithTitle("Not all fields are entered", message: "Please enter all fields")
        }
        if !arePasswordsTheSame(passwordTextField.text!, confirmPassword: confirmPasswordTextField.text!) {
            return UIAlertController.showAlertWithTitle("Passwords are different", message: "Confirm password should match initial password")
        }
        AuthManager.shared.signUpUserWithEmail(emailTextField.text!, password: passwordTextField.text!)
    }
    
    @IBAction func termsAndConditionsButtonTapped(_ sender: Any) {
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        hideKeyboardIfNeeded()
        let _ = self.navigationController?.popViewController(animated: true)
    }

}
