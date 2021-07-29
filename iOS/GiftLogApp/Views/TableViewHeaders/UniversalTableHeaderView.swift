//
//  UniversalTableHeaderView.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/10/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

class UniversalTableHeaderView: UIView {

    // MARK: Views
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var arrowIconImageView: UIImageView!
    @IBOutlet weak var bottomLineView: UIView!
    

    class func instanceFromNib() -> UniversalTableHeaderView {
        return UINib(nibName: "UniversalTableHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UniversalTableHeaderView
    }
    
    func setArrowImageViewFromState(_ opened: Bool) {
        if opened {
            arrowIconImageView.image = UIImage(named: "arrowUp")?.withRenderingMode(.alwaysTemplate)
            arrowIconImageView.tintColor = UIColor(white: 1.0, alpha: 1)
            
        } else {
            arrowIconImageView.image = UIImage(named: "arrowDown")?.withRenderingMode(.alwaysTemplate)
            arrowIconImageView.tintColor = UIColor(white: 1.0, alpha: 1)
        }
    }
}
