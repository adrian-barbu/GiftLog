//
//  ContactWishlistTableViewCell.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/13/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

let ContactWishlistTableViewCellIdentifier = "ContactWishlistTableViewCell"

protocol ContactWishlistTableViewCellDelegate: class {
    func likeButtonDidTouchFrom(_ cell: ContactWishlistTableViewCell)
    func dislikeButtonDidTouchFrom(_ cell: ContactWishlistTableViewCell)
}

class ContactWishlistTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    
    @IBOutlet weak var likesTextView: UITextView!
    @IBOutlet weak var dislikesTextView: UITextView!
   
    // MARK: Vars
    
    weak var delegate: ContactWishlistTableViewCellDelegate?
    
    // MARK: Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setContentFromService(_ contactService: ContactService) {
        likesTextView.text = contactService.likes
        dislikesTextView.text = contactService.dislikes
        if (likesTextView.text == "") {
            likesTextView.text = "Enter things this person would like"
            likesTextView.textColor = UIColor.textFieldPlaceHolderColor
        } else {
            likesTextView.textColor = UIColor.black
        }
        if (dislikesTextView.text == "") {
            dislikesTextView.text = "Enter things this person would not like"
            dislikesTextView.textColor = UIColor.textFieldPlaceHolderColor
        } else {
            dislikesTextView.textColor = UIColor.black
        }
    }
    
    func setUserContentFromService(_ userService: UserService) {
        likesTextView.text = userService.likes
        dislikesTextView.text = userService.dislikes
        if (likesTextView.text == "") {
            likesTextView.text = "Write about things you like"
            likesTextView.textColor = .lightGray
        } else {
            likesTextView.textColor = UIColor.black
        }
        if (dislikesTextView.text == "") {
            dislikesTextView.text = "Write about things you don't like"
            dislikesTextView.textColor = .lightGray
        } else {
            dislikesTextView.textColor = UIColor.black
        }
    }
    
    @IBAction func likesButtonTapped(_ sender: Any) {
        delegate?.likeButtonDidTouchFrom(self)
    }
    
    @IBAction func dislikesButtonTapped(_ sender: Any) {
        delegate?.dislikeButtonDidTouchFrom(self)
    }
}
