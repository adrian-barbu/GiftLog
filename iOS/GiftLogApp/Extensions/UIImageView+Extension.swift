//
//  UIImageView+Extension.swift
//  Vyvlo
//
//  Created by Serhii Kharauzov on 3/20/17.
//  Copyright © 2017 Vyvlo. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    var imageViewBorderLineWidth: CGFloat {
        set (key) {
            self.layer.borderWidth = key
        }
        get {
            return self.layer.borderWidth
        }
    }
    
    var imageViewBorderLineColor: UIColor {
        set (key) {
            self.layer.borderColor = key.cgColor
        }
        get {
            return UIColor.white
        }
    }
}
