//
//  UniversalDetailTableViewCell.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/18/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit
import APAddressBook
import MGSwipeTableCell

let UniversalDetailTableViewCellIdentifier = "UniversalDetailTableViewCell"

@objc protocol UniversalDetailTableViewCellDelegate: class {
    @objc optional func shareButtonTappedFromCell(_ cell: UniversalDetailTableViewCell)
}

class UniversalDetailTableViewCell: MGSwipeTableCell {
    
    
    // MARK: Views
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var violetIconImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    
    // MARK: Vars
    
    weak var ownDelegate: UniversalDetailTableViewCellDelegate?
    
    
    // MARK: Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Custom methods
    
    func setContentFromPhoneBookContact(_ contact: APContact) {
        iconImageView.image = UIImage(named: "contactThumb")
        mainTitleLabel.text = (contact.name?.firstName ?? "") + " " + (contact.name?.lastName ?? "")
        subtitleLabel.text = ContactsManager.getFormattedStringFromNumber(contact.phones?.first?.number)
    }
    
    func setContentFromUserContact(_ contact: Contact) {
        if let url = contact.avatarUrl {
            iconImageView.kf.setImage(with: url, placeholder: UIImage(named: "contactThumb"), options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            iconImageView.image = UIImage(named: "contactThumb")
        }
        mainTitleLabel.text = contact.fullName
        subtitleLabel.text = contact.phoneNumber ?? ""
        violetIconImageView.isHidden = !contact.isContactHasOwnAccount
        shareButton.isHidden = contact.isContactHasOwnAccount
    }
    
    func setEventContentFrom(_ event: Event) {
        if let url = event.imageUrl {
            iconImageView.kf.setImage(with: url, placeholder: UIImage(named: "eventThumb"), options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            iconImageView.image = UIImage(named: "eventThumb")
        }
        mainTitleLabel.text = event.eventTitle
        if let date = event.dateStart {
            subtitleLabel.text = Date(timeIntervalSince1970: TimeInterval(date)).formattedDateAndTimeString()
        }
        violetIconImageView.isHidden = true
        shareButton.isHidden = true
    }
    
    func setGiftContentFrom(_ gift: Gift) {
        if let url = gift.imageUrl {
            iconImageView.kf.setImage(with: url, placeholder: UIImage(named: "giftThumb"), options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            iconImageView.image = UIImage(named: "giftThumb")
        }
        mainTitleLabel.text = gift.name
        var inoutString = ""
        let giftInOutType = Gift.InOutType(rawValue: gift.inOutType)!
        if giftInOutType == .given {
            inoutString = "By"
        } else {
            inoutString = "From"
        }
        var notDeletedContacts = [Contact]()
        for preloadContact in gift.contacts {
            if let contact = UserContactsManager.shared.getContactById(preloadContact.identifier) {
                notDeletedContacts.append(contact)
            }
        }
        if notDeletedContacts.isEmpty {
            subtitleLabel.text = ""
        } else if notDeletedContacts.count > 1 {
            subtitleLabel.text = "\(inoutString) \(notDeletedContacts.first!.fullName) and other(s)"
        } else {
            subtitleLabel.text = "\(inoutString) \(notDeletedContacts.first!.fullName)"
        }
        violetIconImageView.isHidden = true
        shareButton.isHidden = true
    }
    
    // MARK: IBActions
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        ownDelegate?.shareButtonTappedFromCell?(self)
    }
}

