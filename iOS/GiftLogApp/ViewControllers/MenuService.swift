//
//  MenuService.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/30/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import Foundation
import UIKit

class MenuService {
    
    // MARK: Constants
    
    let arrayOfMenuActionIcons =
        ["gift","calendar","contact","idea","faq_menu_icon","shareApp","emailGiftData","lock","list","contactUsMenuIcon", "power"]
    let arrayOfMenuTitles = ["GIFTS","EVENTS","CONTACTS","GIFT IDEAS","FAQ","SHARE APP","EMAIL GIFT DATA","PRIVACY POLICY","TERMS & CONDITIONS","CONTACT US", "LOG OUT"]
    
    // MARK: Vars
    
    static var shared = MenuService()
    var selectedMenuActionIndexPath = IndexPath(row: 0, section: 0)
    
    // MARK: Methods
    
    init() {}
    
    func getMenuCellBackgroundColorFromCellIndexPath(_ indexPath: IndexPath) -> UIColor {
        if indexPath == selectedMenuActionIndexPath {
            return Constants.appVioletColor
        }
        return UIColor.clear
    }
}
