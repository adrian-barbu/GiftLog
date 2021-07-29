//
//  UniversalAddingTableViewCell.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/13/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

let UniversalAddingTableViewCellIdentifier = "UniversalAddingTableViewCell"

@objc protocol UniversalAddingTableViewCellDelegate: class {
    @objc optional func addingButtonDidTouchFrom(_ cell: UniversalAddingTableViewCell)
}

class UniversalAddingTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleButton: UIButton!
    
    // MARK: - Variables
    
    weak var delegate: UniversalAddingTableViewCellDelegate?
    
    // MARK: - Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Custom methods
    
    func setUnderlineTitleButton(_ text: String) {
        let attributedTitle = SSHelperManager.shared.setUnderlinedAttributed(text, with: Constants.appVioletColor, fontSize: 12.0, font: nil)
        titleButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func setAddButtonBackground(_ section: Int) {
        switch section {
        case 0:
            titleButton.backgroundColor = Constants.appVioletColor
        case 1:
            titleButton.backgroundColor = Constants.appPurpleColor
        case 2:
            titleButton.backgroundColor = Constants.appBlueColor
        case 3:
            titleButton.backgroundColor = Constants.appGreenColor
        default:
            break
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func addingButtonDidTouch(_ sender: Any) {
        delegate?.addingButtonDidTouchFrom?(self)
    }
}
