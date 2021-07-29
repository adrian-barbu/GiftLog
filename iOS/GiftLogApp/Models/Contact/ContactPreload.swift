//
//  ContactPreload.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/18/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import Foundation

class ContactPreload {
    
    // MARK: Properties
    
    var identifier: String!
    var model: Contact! // this field loaded later, when detail screen is opened. It can not be empty or nil.
    
    // MARK: Methods
    
    init(data: [String: AnyObject]) {
        self.identifier = data["identifier"] as! String
    }
    
    init() { }
    
    func formattedDict() -> [String: AnyObject] {
        var dict = [String: AnyObject]()
        dict["identifier"] = self.identifier as AnyObject
        return dict
    }
}
