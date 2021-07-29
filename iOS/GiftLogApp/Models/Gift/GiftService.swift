//
//  GiftService.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/27/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import Foundation

class GiftService: Equatable {
    
    // MARK: Properties
    
    var name: String!
    var inOutType: Int!
    var type: Int?
    var description: String?
    var price: String?
    var recieptType: Int!
    var status: Int!
    var images = [GiftImage]()
    var thankYouSent: Bool = false
    var contacts = [ContactPreload]()
    var eventPreload: EventPreload?
    
    init(gift: Gift) {
        self.name = gift.name
        self.inOutType = gift.inOutType
        self.type = gift.type
        self.description = gift.giftDescription
        self.price = gift.price
        self.recieptType = gift.recieptType
        self.status = gift.status
        self.images = gift.images
        self.thankYouSent = gift.thankYouSent
        self.contacts = gift.contacts
        self.eventPreload = gift.eventPreload
    }
    
    // MARK: Custom methods
    
    func getIndexOfContactAtArrayFrom(_ identifier: String) -> Int? {
        var index = 0
        for contact in contacts {
            if contact.identifier == identifier {
                return index
            }
            index += 1
        }
        return nil
    }
    
    // Equatable compare
    
    static func ==(lhs: GiftService, rhs: GiftService) -> Bool {
        
        // checking for equality in event
        if lhs.eventPreload?.identifier != rhs.eventPreload?.identifier {
            return false
        }
        
        // checking for equality in contacts
        if lhs.contacts.count != rhs.contacts.count {
            return false
        } else {
            for index in 0..<lhs.contacts.count {
                if lhs.contacts[index].identifier != rhs.contacts[index].identifier {
                    return false
                }
            }
        }
        
        // checking for equality in images
        if lhs.images.count != rhs.images.count {
            return false
        } else {
            for index in 0..<lhs.images.count {
                if lhs.images[index].url != rhs.images[index].url {
                    return false
                }
            }
        }

        return
                lhs.name == rhs.name &&
                lhs.inOutType == rhs.inOutType &&
                lhs.type == rhs.type &&
                lhs.description == rhs.description &&
                lhs.price == rhs.price &&
                lhs.recieptType == rhs.recieptType &&
                lhs.status == rhs.status &&
                lhs.thankYouSent == rhs.thankYouSent
    }
}
