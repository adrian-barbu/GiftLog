//
//  ValuePickerViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/28/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

protocol ValuePickerViewControllerDelegate: class {
    func valuePickerViewControllerWasSelectedAtIndex(_ index: Int)
}

class ValuePickerViewController: BaseViewController {
    
    // MARK: - Constraints
    
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var cancelBigButton: UIButton!
    
    // MARK: - Variables
    
    var titleLabelValue: String!
    var values = [String]()
    var selectedIndex: Int = 0
    
    private let animationInterval: Double = 0.33
    weak var delegate: ValuePickerViewControllerDelegate?
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleLabelValue
        pickerView.reloadAllComponents()
        pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
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
                self.delegate?.valuePickerViewControllerWasSelectedAtIndex(self.pickerView.selectedRow(inComponent: 0))
            })
        }
    }
}

extension ValuePickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
}
