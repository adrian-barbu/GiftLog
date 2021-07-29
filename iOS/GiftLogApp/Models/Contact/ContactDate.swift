//
//  ContactDate.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/14/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import Foundation

struct ContactDate: Equatable {
    
    // MARK: Properties
    
    var timestamp: Int64! // timestamp
    var name: String!
   
    // MARK: Methods
    
    init(data: [String: AnyObject]) {
        self.timestamp = data["timestamp"] as! Int64
        self.name = data["name"] as! String
    }
    
    init() { }
    
    func formattedDict() -> [String: AnyObject] {
        var dict = [String: AnyObject]()
        dict["timestamp"] = self.timestamp as AnyObject
        dict["name"] = self.name as AnyObject
        return dict
    }
    
    static func ==(lhs: ContactDate, rhs: ContactDate) -> Bool {
        return
            lhs.timestamp == rhs.timestamp &&
                lhs.name == rhs.name
    }

}
