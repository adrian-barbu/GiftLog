//
//  BaseNavigationController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/27/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = Constants.appGreyColor
        self.navigationBar.isTranslucent = false
    }
}
