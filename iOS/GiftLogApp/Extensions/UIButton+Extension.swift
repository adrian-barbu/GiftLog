//
//  UIButton+Extension.swift
//
//
//  Created by Webs The Word on 11/7/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    var localizedTitleForNormal: String {
        set (key) {
            setTitle(NSLocalizedString(key, comment: ""), for: .normal)
        }
        get {
            return title(for: .normal)!
        }
    }
    
    var localizedTitleForHighlighted: String {
        set (key) {
            setTitle(NSLocalizedString(key, comment: ""), for: .highlighted)
        }
        get {
            return title(for: .highlighted)!
        }
    }
    
    var buttonBorderLineWidth: CGFloat {
        set (key) {
            self.layer.borderWidth = key
        }
        get {
            return self.layer.borderWidth
        }
    }
    
    var buttonBorderLineColor: UIColor {
        set (key) {
            self.layer.borderColor = key.cgColor
        }
        get {
            return UIColor.white
        }
    }
}
