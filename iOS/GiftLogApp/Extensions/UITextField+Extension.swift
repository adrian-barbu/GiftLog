//
//  UITextField+Extension.swift
//
//
//  Created by Webs The Word on 11/7/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    var localizedPlaceholderText: String {
        set (value) {
            placeholder = NSLocalizedString(value, comment: "")
        }
        get {
            return placeholder!
        }
    }
    
    var attributedPlaceholderTextColor: UIColor {
        set (value) {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: value])
        }
        get {
            return UIColor.white
        }
    }
}
