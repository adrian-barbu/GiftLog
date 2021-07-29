//
//  EventInfoTableViewCell.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/13/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

let EventInfoTableViewCellIdentifier = "EventInfoTableViewCell"
let EventInfoTableViewCellHeight: CGFloat = 315.0

protocol EventInfoTableViewCellDelegate: class {
    func startDateButtonDidTouchFrom(_ cell: EventInfoTableViewCell)
    func endDateButtonDidTouchFrom(_ cell: EventInfoTableViewCell)
    func descriptionButtonDidTouchFrom(_ cell: EventInfoTableViewCell)
    func textFieldFinishedInputWith(_ text: String?, textFieldType: EventInfoTableViewCell.TextFieldType)
    func hostingTypeSegmentedChangedValue(_ value: Int)
}

class EventInfoTableViewCell: UITableViewCell {
    
    enum TextFieldType: Int {
        case eventTitle = 0
        case eventType
        case description
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var startsButton: UIButton!
    @IBOutlet weak var endsButton: UIButton!
    @IBOutlet weak var eventTypeTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionButton: UIButton!
    @IBOutlet weak var hostingTypeSegmentedControl: UISegmentedControl!
    
    // MARK: - Variables
    
    weak var delegate: EventInfoTableViewCellDelegate?
    
    // MARK: - Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()   
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Custom methods

    func setContentFromService(_ eventService: EventService) {
        eventTitleTextField.text = eventService.eventTitle
        if let dateStart = eventService.dateStart {
            startsButton.setTitle(Date(timeIntervalSince1970: TimeInterval(dateStart)).formattedDateAndTimeString(), for: .normal)
        }
        if let dateEnd = eventService.dateEnd {
            endsButton.setTitle(Date(timeIntervalSince1970: TimeInterval(dateEnd)).formattedDateAndTimeString(), for: .normal)
        }
        eventTypeTextField.text = eventService.eventType
        descriptionTextView.text = eventService.description
        hostingTypeSegmentedControl.selectedSegmentIndex = eventService.hostingType.rawValue
        if eventService.dateStart != nil {
            startsButton.setTitleColor(.black, for: .normal)
        } else {
            startsButton.setTitleColor(UIColor.textFieldPlaceHolderColor, for: .normal)
        }
        if eventService.dateEnd != nil {
            endsButton.setTitleColor(.black, for: .normal)
        } else {
            endsButton.setTitleColor(UIColor.textFieldPlaceHolderColor, for: .normal)
        }
        if (descriptionTextView.text == "") {
            descriptionTextView.text = "Description of the event"
            descriptionTextView.textColor = UIColor.textFieldPlaceHolderColor
        } else {
            descriptionTextView.textColor = UIColor.black
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func startsButtonDidTouch(_ sender: Any) {
        delegate?.startDateButtonDidTouchFrom(self)
    }
    
    @IBAction func endsButtonDidTouch(_ sender: Any) {
        delegate?.endDateButtonDidTouchFrom(self)
    }
    
    @IBAction func descriptionButtonDidTouch(_ sender: Any) {
        delegate?.descriptionButtonDidTouchFrom(self)
    }
    
    @IBAction func hostingSegmentedValueChanged(_ sender: UISegmentedControl) {
        delegate?.hostingTypeSegmentedChangedValue(sender.selectedSegmentIndex)
    }
}

extension EventInfoTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldFinishedInputWith(textField.text, textFieldType: TextFieldType(rawValue: textField.tag)!)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == self.eventTitleTextField {
            let maxLength = 20
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
}

