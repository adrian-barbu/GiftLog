//
//  ContactInfoTableViewCell.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/13/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

let ContactInfoTableViewCellIdentifier = "ContactInfoTableViewCell"
let ContactInfoTableViewCellHeight: CGFloat = 308.0
let UserContactInfoTableViewCellHeight: CGFloat = 259.0

protocol ContactInfoTableViewCellDelegate: class {
    func inviteButtonTappedFromCell(_ cell: ContactInfoTableViewCell)
    func textFieldFinishedInputWith(_ text: String?, textFieldType: ContactInfoTableViewCell.TextFieldType)
}

class ContactInfoTableViewCell: UITableViewCell {

    
    // MARK: Enums
    
    enum TextFieldType: Int {
        case firstName = 0
        case lastName
        case nickName
        case email
        case phone
    }
    
    
    // MARK: IBOutlets
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var inviteView: UIView!
    
    
    // MARK: Vars
    
    weak var delegate: ContactInfoTableViewCellDelegate?
    
    
    // MARK: Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setToolBarForPhoneKeyboard()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
   
    
    // MARK: Custom methods
    
    func setContentFromService(_ contactService: ContactService) {
        firstNameTextField.text = contactService.firstName
        lastNameTextField.text = contactService.lastName
        nickNameTextField.text = contactService.nickName
        emailTextField.text = contactService.email
        phoneTextField.text = contactService.phoneNumber
    }
    
    func setUserContentFromService(_ userService: UserService) {
        firstNameTextField.text = userService.firstName
        lastNameTextField.text = userService.lastName
        nickNameTextField.text = userService.nickName
        emailTextField.text = userService.email
        phoneTextField.text = userService.phoneNumber
        inviteView.isHidden = true
    }
    
    func setToolBarForPhoneKeyboard() {
        //Add done button to numeric pad keyboard
        let toolbarDone = UIToolbar.init()
        toolbarDone.backgroundColor = UIColor.white
        toolbarDone.tintColor = Constants.appGreenColor
        toolbarDone.sizeToFit()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done,
                                              target: self,
                                              action: #selector(self.textfieldDoneButtonTapped))
        toolbarDone.items = [barBtnDone] // You can even add cancel button too
        phoneTextField.inputAccessoryView = toolbarDone
    }
    
    func textfieldDoneButtonTapped() {
        phoneTextField.resignFirstResponder()
    }
    
    
    // MARK: IBActions
    
    @IBAction func inviteButtonTapped(_ sender: Any) {
        delegate?.inviteButtonTappedFromCell(self)
    }
}

extension ContactInfoTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField {
            if let text = textField.text {
                if !SSHelperManager.shared.isValidEmail(text) {
                    UIAlertController.showAlertWithTitle("Email format is wrong", message: "Please enter another ")
                    textField.text = nil
                }
            }
        }
        delegate?.textFieldFinishedInputWith(textField.text, textFieldType: TextFieldType(rawValue: textField.tag)!)
    }
}
