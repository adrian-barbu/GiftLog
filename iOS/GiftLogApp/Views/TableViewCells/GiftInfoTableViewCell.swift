//
//  GiftInfoTableViewCell.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/28/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

let GiftInfoTableViewCellIdentifier = "GiftInfoTableViewCell"

protocol GiftInfoTableViewCellDelegate: class {
    func descriptionButtonDidTouchFrom(_ cell: GiftInfoTableViewCell)
    func textFieldFinishedInputWith(_ text: String?, textFieldType: GiftInfoTableViewCell.TextFieldType)
    func inOutSegmentedControlChangedValue(_ value: Int)
    func recieptSegmentedControlChangedValue(_ value: Int)
    func typeButtonDidTouchFrom(_ cell: GiftInfoTableViewCell)
    func statusButtonDidTouchFrom(_ cell: GiftInfoTableViewCell)
    func imagesCollectionViewDidSelectImageAtIndex(_ index: Int)
}


class GiftInfoTableViewCell: UITableViewCell {

    // MARK: Enums
    
    enum TextFieldType: Int {
        case giftName = 0
        case giftPrice
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var inOutSegmentedControl: UISegmentedControl!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var recieptSegmentedControl: UISegmentedControl!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var imageCollectionView: ImagesCollectionView!
    
    // MARK: Variables
    
    weak var delegate: GiftInfoTableViewCellDelegate?
    
    // MARK: Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageCollectionView.delegate = self
        setToolBarForPhoneKeyboard()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    deinit {
        imageCollectionView.removeFromSuperview()
        imageCollectionView = nil
    }
    
    // MARK: Custom methods
    
    func setContentFromService(_ giftService: GiftService) {
        nameTextField.text = giftService.name
        inOutSegmentedControl.selectedSegmentIndex = giftService.inOutType
        if let type = giftService.type {
            typeButton.setTitle(Gift.Category(rawValue: type)!.description, for: .normal)
            typeButton.setTitle(Gift.Category(rawValue: type)!.description, for: .highlighted)
            typeButton.setTitleColor(.black, for: .normal)
        } else {
            typeButton.setTitle("Select", for: .normal)
            typeButton.setTitle("Select", for: .highlighted)
            typeButton.setTitleColor(UIColor.textFieldPlaceHolderColor, for: .normal)
        }
        descriptionTextView.text = giftService.description
        if (descriptionTextView.text == "") {
            descriptionTextView.text = "Description of the gift"
            descriptionTextView.textColor = UIColor.textFieldPlaceHolderColor
        } else {
            descriptionTextView.textColor = UIColor.black
        }
        if let price = giftService.price {
            priceTextField.text = price
        } else {
            priceTextField.text = nil
        }
        recieptSegmentedControl.selectedSegmentIndex = giftService.recieptType
        if let type = giftService.status {
            statusButton.setTitle(Gift.Status(rawValue: type)!.description, for: .normal)
            statusButton.setTitle(Gift.Status(rawValue: type)!.description, for: .highlighted)
            statusButton.setTitleColor(.black, for: .normal)
        } else {
            statusButton.setTitle("Select", for: .normal)
            statusButton.setTitle("Select", for: .highlighted)
            statusButton.setTitleColor(UIColor.textFieldPlaceHolderColor, for: .normal)
        }
        imageCollectionView.giftImages = giftService.images
        imageCollectionView.collectionView.reloadData()
        imageCollectionView.collectionView.scrollToItem(at: IndexPath(row: giftService.images.count, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
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
        priceTextField.inputAccessoryView = toolbarDone
    }
    
    func textfieldDoneButtonTapped() {
        priceTextField.resignFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction func descriptionButtonTapped(_ sender: Any) {
        delegate?.descriptionButtonDidTouchFrom(self)
    }
    
    @IBAction func inOutSegmentedControlTapped(_ sender: UISegmentedControl) {
        delegate?.inOutSegmentedControlChangedValue(sender.selectedSegmentIndex)
    }
    
    @IBAction func typeButtonTapped(_ sender: Any) {
        delegate?.typeButtonDidTouchFrom(self)
    }
    
    @IBAction func recipetSegmentedControlTapped(_ sender: UISegmentedControl) {
        delegate?.recieptSegmentedControlChangedValue(sender.selectedSegmentIndex)
    }
    
    @IBAction func statusButtonTapped(_ sender: Any) {
        delegate?.statusButtonDidTouchFrom(self)
    }
}

extension GiftInfoTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldFinishedInputWith(textField.text, textFieldType: GiftInfoTableViewCell.TextFieldType(rawValue: textField.tag)!)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == self.nameTextField {
            let maxLength = 20
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
}

extension GiftInfoTableViewCell: ImagesCollectionViewDelegate {
    func imagesCollectionViewDidSelectImageAtIndex(_ index: Int) {
        delegate?.imagesCollectionViewDidSelectImageAtIndex(index)
    }
}
