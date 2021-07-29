//
//  TextPickerViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/18/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

protocol TextPickerViewControllerDelegate: class {
    func textPickerViewControllerSelected(_ text: String)
}

class TextPickerViewController: BaseViewController, UITextViewDelegate {
    
    // MARK: - Constraints
    
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var cancelBigButton: UIButton!
    
    // MARK: - Variables
    
    var titleLabelValue: String!
    var initialText: String?
    private let animationInterval: Double = 0.33
    weak var delegate: TextPickerViewControllerDelegate?
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        if let initialText = initialText {
            textView.text = initialText
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
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
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if(text == "\n") {
//            textView.resignFirstResponder()
//            return false
//        }
//        return true
//    }
    
    // MARK: - IBActions
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        hideKeyboard()
        self.dismiss(animated: true, completion: {
        })
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        hideKeyboard()
        self.dismiss(animated: true, completion: {
            self.delegate?.textPickerViewControllerSelected(self.textView.text)
        })
    }
}
