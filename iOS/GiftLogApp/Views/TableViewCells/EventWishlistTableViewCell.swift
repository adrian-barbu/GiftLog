//
//  EventWishlistTableViewCell.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/13/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

let EventWishlistTableViewCellIdentifier = "EventWishlistTableViewCell"

protocol EventWishlistTableViewCellDelegate: class {
    func likeButtonDidTouchFrom(_ cell: EventWishlistTableViewCell)
    func dislikeButtonDidTouchFrom(_ cell: EventWishlistTableViewCell)
    func shareButtonDidTouchFrom(_ cell: EventWishlistTableViewCell)
}

class EventWishlistTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var likesTextView: UITextView!
    @IBOutlet weak var dislikesTextView: UITextView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    // MARK: - Variables
    
    weak var delegate: EventWishlistTableViewCellDelegate?
    
    // MARK: - Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Methods
    
    func setContentFromService(_ eventService: EventService) {
        likesTextView.text = eventService.likes
        dislikesTextView.text = eventService.dislikes
        if (likesTextView.text == "") {
            likesTextView.text = "Write about things you like"
            likesTextView.textColor = UIColor.textFieldPlaceHolderColor
        } else {
            likesTextView.textColor = UIColor.black
        }
        if (dislikesTextView.text == "") {
            dislikesTextView.text = "Write about things you don't like"
            dislikesTextView.textColor = UIColor.textFieldPlaceHolderColor
        } else {
            dislikesTextView.textColor = UIColor.black
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func likeButtonDidTouch(_ sender: Any) {
        delegate?.likeButtonDidTouchFrom(self)
    }
    
    @IBAction func dislikeButtonDidTouch(_ sender: Any) {
        delegate?.dislikeButtonDidTouchFrom(self)
    }
    
    @IBAction func shareButtonDidTouch(_ sender: Any) {
        delegate?.shareButtonDidTouchFrom(self)
    }
    
}

extension EventWishlistTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
