//
//  ContactDateTableViewCell.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/13/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit
import MGSwipeTableCell

let ContactDateTableViewCellIdentifier = "ContactDateTableViewCell"
protocol ContactDateTableViewCellDelegate: class {
    func dateButtonTappedFromCell(_ cell: ContactDateTableViewCell)
}
class ContactDateTableViewCell: MGSwipeTableCell {

    // MARK: Views
    
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    
    // MARK: Vars
    
    weak var ownDelegate: ContactDateTableViewCellDelegate?
    
    // MARK: Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setContentFrom(_ contactDate: ContactDate) {
        dateTitleLabel.text = contactDate.name
        let date = Date(timeIntervalSince1970: TimeInterval(contactDate.timestamp))
        dateButton.setTitle(date.formattedDateString(), for: .normal)
        dateButton.setTitle(date.formattedDateString(), for: .highlighted)
    }
    
    // MARK: IBActions
    
    @IBAction func dateButtonTapped(_ sender: Any) {
        ownDelegate?.dateButtonTappedFromCell(self)
    }
}
