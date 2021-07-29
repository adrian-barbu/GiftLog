//
//  OneActionTableViewCell.swift
//  GiftLogApp
//
//  Created by Webs The Word on 5/2/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

let OneActionTableViewCellIdentifier = "OneActionTableViewCell"

protocol OneActionTableViewCellDelegate: class {
    func actionButtonTappedFromCell(_ cell: OneActionTableViewCell)
    func secondActionButtonTappedFromCell(_ cell: OneActionTableViewCell)
}

class OneActionTableViewCell: UITableViewCell {

    // MARK: Views
    
    @IBOutlet weak var actionTitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    // MARK: Vars
    
    weak var delegate: OneActionTableViewCellDelegate?
    
    // MARK: Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setContentFrom(_ giftService: GiftService) {
        if giftService.thankYouSent {
            actionButton.setTitle("Yes", for: .normal)
            actionButton.setTitle("Yes", for: .highlighted)
        } else {
            actionButton.setTitle("No", for: .normal)
            actionButton.setTitle("No", for: .highlighted)
        }
    }
    
    // MARK: IBActions
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        delegate?.actionButtonTappedFromCell(self)
    }
    
    @IBAction func secondActionButtonTapped(_ sender: Any) {
        delegate?.secondActionButtonTappedFromCell(self)
    }
}
