//
//  ImageCollectionViewCell.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/27/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

let ImageCollectionViewCellIdentifier = "ImageCollectionViewCell"

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var giftImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
