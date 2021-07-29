//
//  CustomTextField.swift
//  Gift Log App
//
//  Created by Webs The Word on 11/4/16.
//  Copyright © 2016 Gift Log App. All rights reserved.
//

import Foundation
import UIKit
class CustomTextfield :UITextField {
    override func draw(_ rect: CGRect) {
        self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: UIColor.white])
    } }
