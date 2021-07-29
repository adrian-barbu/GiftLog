//
//  DatePickerViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/14/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

protocol DatePickerViewControllerDelegate: class {
    func datePickerViewControllerSelectedValue(_ value: Date)
}

class DatePickerViewController: BaseViewController {

    // MARK: - Constraints
    
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelBigButton: UIButton!
    
    // MARK: - Variables
    
    private let animationInterval: Double = 0.33
    
    var titleLabelValue: String!
    var components = [AnyObject]()
    var initialDate: Date!
    var minimumDate: Date?
    var minuteInterval: Int = 1
    weak var delegate: DatePickerViewControllerDelegate?
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.minuteInterval = minuteInterval
        datePicker.date = initialDate
        if let minimumDate = minimumDate {
            datePicker.minimumDate = minimumDate
        }
        titleLabel.text = titleLabelValue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.containerBottomConstraint.constant = -containerHeightConstraint.constant
        showViewWithAnimation()
    }
    
    // MARK: - Methods
    
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
    
    // MARK: - IBActions
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        hideViewWithAnimation { [unowned self] in
            self.dismiss(animated: false, completion: {
            })
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        hideViewWithAnimation { [unowned self] in
            self.dismiss(animated: false, completion: {
                self.delegate?.datePickerViewControllerSelectedValue(self.datePicker.date)
            })
        }
    }
}
