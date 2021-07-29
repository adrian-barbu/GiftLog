//
//  BaseFIRModel.swift
//  GiftLogApp
//
//  Created by Webs The Word on 12/26/16.
//  Copyright © GiftLogApp 2017. All rights reserved.
//

import Foundation
import FirebaseDatabase

class BaseFIRModel: NSObject {

    // MARK: System methods
    
    static func ==(lhs: BaseFIRModel, rhs: BaseFIRModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    override var hashValue: Int { get{
        return Int(self.identifier.hashValue)
        }
    }

    // MARK: Properties
    
    var ref: DatabaseReference?
    var identifier : String {
        if let reference = ref {
            return reference.description().components(separatedBy: "/").last!
        }
        return ""
    }
}
