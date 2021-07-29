//
//  ForgotPasswordViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/27/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {

    // MARK: Views
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var textfieldsContainerView: UIView!
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerControllerForKeyboardNotifications()
        addTapGestureRecognizerForKeyboardDissmiss()
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
        let delta = sendButton.frame.maxY - keyboardY
        if delta > 0 {
            self.backButton.alpha = 0
            self.view.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.origin.y - delta - Constants.extraMarginFromKeyboard)
        }
    }
    
    func keyboardWillHide(notification:NSNotification){
        self.backButton.alpha = 1
        self.view.frame.origin = CGPoint.zero
    }
    
    // MARK: UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            if !SSHelperManager.shared.isValidEmail(textField.text!) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UIAlertController.showAlertWithTitle("", message: "Email format is wrong")
                }
                
            }
        }
        return textField.resignFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        self.hideKeyboard()
        if !SSHelperManager.shared.areAllTextFieldsEnteredInView(textfieldsContainerView) {
            return UIAlertController.showAlertWithTitle("Not all fields are entered", message: "Please enter all fields")
        }
        FirebaseManager.shared.resetPasswordFromEmail(emailTextField.text!, completion: { (success) in
            if success {
                let _ = self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
}
