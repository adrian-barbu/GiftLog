//
//  GiftImage.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/27/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import Foundation

class GiftImage {
    
    // MARK: Properties
    
    var url: String!
    
    // MARK: Methods
    
    init(data: [String: AnyObject]) {
        self.url = data["url"] as! String
    }
    
    init() {}
    
    func formattedDict() -> [String: AnyObject] {
        var dict = [String: AnyObject]()
        dict["url"] = self.url as AnyObject
        return dict
    }
}
