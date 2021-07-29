//
//  DateAndTitlePickerViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/14/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

protocol DateAndTitlePickerViewControllerDelegate: class {
    func datePickerViewControllerSelectedValue(_ value: Date, _ title: String)
}


class DateAndTitlePickerViewController: BaseViewController, UITextFieldDelegate {

    // MARK: Constraints
    
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    
    // MARK: Views
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelBigButton: UIButton!
    @IBOutlet weak var dateTextField: UITextField!
    
    // MARK: Vars
    
    internal var titleLabelValue: String!
    internal var components = [AnyObject]()
    internal var initialDate: Date!
    internal var pickerMode: UIDatePickerMode?
    
    private let animationInterval: Double = 0.33
    weak var delegate: DateAndTitlePickerViewControllerDelegate?
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.date = initialDate
        datePicker.datePickerMode = pickerMode ?? .dateAndTime
        if !titleLabelValue.isEmpty {
            dateTextField.text = titleLabelValue
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.containerBottomConstraint.constant = -containerHeightConstraint.constant
        showViewWithAnimation()
    }
    
    func showViewWithAnimation() {
        self.view.layoutIfNeeded()
        self.containerBottomConstraint.constant = 0
        UIView.animate(withDuration: animationInterval, animations: { [unowned self] in
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.cancelBigButton.alpha = 1
            self.cancelBigButton.isUserInteractionEnabled = true
        })
    }
    
    func hideViewWithAnimation(completion: @escaping () -> Void) {
        self.containerBottomConstraint.constant = -containerHeightConstraint.constant
        self.cancelBigButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: animationInterval, animations: { [unowned self] in
            self.view.layoutIfNeeded()
            self.cancelBigButton.alpha = 0
            }, completion: { (finished) in
                completion()
        })
    }
    
    // MARK: UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        hideViewWithAnimation { [unowned self] in
            self.dismiss(animated: false, completion: {
            })
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        hideViewWithAnimation { [unowned self] in
            self.dismiss(animated: false, completion: { [unowned self] in
                self.delegate?.datePickerViewControllerSelectedValue(self.datePicker.date, self.dateTextField.text ?? "")
            })
        }
    }
}
