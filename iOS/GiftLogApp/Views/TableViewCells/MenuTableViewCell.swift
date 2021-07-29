//
//  MenuTableViewCell.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/30/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

let MenuTableViewCellIdentifier = "MenuTableViewCell"

class MenuTableViewCell: UITableViewCell {

    // MARK: Views
    
    @IBOutlet weak var menuIconImageView: UIImageView!
    @IBOutlet weak var menuTitleLabel: UILabel!
    
    // MARK: Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
