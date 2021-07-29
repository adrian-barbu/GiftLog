//
//  MGSwipeService.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/26/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import Foundation
import MGSwipeTableCell

class MGSwipeService {
 
    class func copyButton() -> MGSwipeButton {
        let copyButton = MGSwipeButton(title: "", icon: UIImage(named: "copyCircle"), backgroundColor: nil)
        copyButton.buttonWidth = 80.0
        copyButton.imageView?.contentMode = .center
        copyButton.backgroundColor = Constants.appGreenColor
        copyButton.imageView!.contentMode = .scaleAspectFit
        return copyButton
    }
    
    class func deleteButton() -> MGSwipeButton {
        let deleteButton = MGSwipeButton(title: "", icon: UIImage(named:"deleteCircle"), backgroundColor: nil)
        deleteButton.buttonWidth = 80.0
        deleteButton.imageView?.contentMode = .center
        deleteButton.backgroundColor = Constants.appVioletColor
        deleteButton.imageView!.contentMode = .scaleAspectFit
        return deleteButton
    }
}
