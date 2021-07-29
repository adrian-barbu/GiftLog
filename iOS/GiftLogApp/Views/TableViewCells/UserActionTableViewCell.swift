//
//  UserActionTableViewCell.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/25/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

let UserActionTableViewCellIdentifier = "UserActionTableViewCell"

@objc protocol UserActionTableViewCellDelegate: class {
    @objc optional func logOutButtonDidTouchFrom(_ cell: UserActionTableViewCell)
    @objc optional func deleteButtonDidTouchFrom(_ cell: UserActionTableViewCell)
    @objc optional func csvButtonDidTouchFrom(_ cell: UserActionTableViewCell)
    @objc optional func notificationsButtonDidTouchFrom(_ cell: UserActionTableViewCell)
}

class UserActionTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var csvButton: UIButton!
    @IBOutlet weak var notificationsSegmentedControl: UISegmentedControl!
    
    // MARK: - Variables
    
    weak var delegate: UserActionTableViewCellDelegate?
    
    // MARK: - Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UserDefaultsManager.shared.areLocalNotificationsUsed {
            notificationsSegmentedControl.selectedSegmentIndex = 0
        } else {
            notificationsSegmentedControl.selectedSegmentIndex = 1
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Custom methods
    
    func setUnderlineButtonsWith(text logout: String, delete: String, csv: String) {
        logOutButton.setAttributedTitle(SSHelperManager.shared.setUnderlinedAttributed(logout, with: Constants.appVioletColor, fontSize: 12.0, font: nil), for: .normal)
        deleteButton.setAttributedTitle(SSHelperManager.shared.setUnderlinedAttributed(delete, with: Constants.appVioletColor, fontSize: 12.0, font: nil), for: .normal)
        csvButton.setAttributedTitle(SSHelperManager.shared.setUnderlinedAttributed(csv, with: Constants.appVioletColor, fontSize: 12.0, font: nil), for: .normal)
    }
    
    // MARK: - IBActions
    
    @IBAction func logOutButtonDidTouch(_ sender: Any) {
        delegate?.logOutButtonDidTouchFrom?(self)
    }
    
    @IBAction func deleteButtonDidTouch(_ sender: Any) {
        delegate?.deleteButtonDidTouchFrom?(self)
    }
    
    @IBAction func csvButtonDidTouch(_ sender: Any) {
        delegate?.csvButtonDidTouchFrom?(self)
    }
    
    @IBAction func notificationsSegmentedControlChanged(_ sender: UISegmentedControl) {
        delegate?.notificationsButtonDidTouchFrom?(self)
    }
}
