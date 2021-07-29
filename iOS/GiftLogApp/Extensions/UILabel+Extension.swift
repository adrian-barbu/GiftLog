//
//  UILabel+Extension.swift
//
//
//  Created by Webs The Word on 11/7/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    var localizedText: String {
        set (value) {
            text = NSLocalizedString(value, comment: "")
        }
        get {
            return text!
        }
    }
}
