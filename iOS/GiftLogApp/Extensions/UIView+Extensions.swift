//
//  UIView+Extensions.swift
//
//
//  Created by Webs The Word on 11/10/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    static func clearView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    static var emptyView: UIView {
        let view = UIView(frame: CGRect.zero)
        return view
    }
    
    var viewBorderLineWidth: CGFloat {
        set (key) {
            self.layer.borderWidth = key
        }
        get {
            return self.layer.borderWidth
        }
    }
    
    var viewBorderLineColor: UIColor {
        set (key) {
            self.layer.borderColor = key.cgColor
        }
        get {
            return UIColor.white
        }
    }
}
