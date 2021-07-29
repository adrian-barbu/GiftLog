//
//  ContactService.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/12/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import Foundation

class ContactService: Equatable {
   
    // MARK: Properties
    
    var firstName: String!
    var lastName: String?
    var nickName: String?
    var email: String?
    var phoneNumber: String?
    var avatar: String?
    var dates = [ContactDate]()
    var gifts = [GiftPreload]()
    var likes: String?
    var dislikes: String?
    var imageData: Data?
    
    // MARK: Lifecycle
    
    var fullName: String {
        if (firstName.isEmpty) {
            return "CONTACT NAME"
        }
        return (firstName ?? "") + " " + (lastName ?? "")
    }
    
    init(contact: Contact) {
        self.firstName = contact.firstName
        self.lastName = contact.lastName
        self.nickName = contact.nickName
        self.email = contact.email
        self.phoneNumber = contact.phoneNumber
        self.avatar = contact.avatar
        self.dates = contact.dates
        self.likes = contact.likes
        self.dislikes = contact.dislikes
        self.gifts = contact.gifts
    }
    
    func getIndexOfGiftAtArrayFrom(_ identifier: String) -> Int? {
        var index = 0
        for gift in gifts {
            if gift.identifier == identifier {
                return index
            }
            index += 1
        }
        return nil
    }
    
    // Equatable compare
    
    static func ==(lhs: ContactService, rhs: ContactService) -> Bool {
        // checking for equality in dates
        if lhs.dates.count != rhs.dates.count {
            return false
        } else {
            for index in 0..<lhs.dates.count {
                if lhs.dates[index] != rhs.dates[index] {
                    return false
                }
            }
        }
        
        // checking for equality in contact's gifts
        if lhs.gifts.count != rhs.gifts.count {
            return false
        } else {
            for index in 0..<lhs.gifts.count {
                if lhs.gifts[index].identifier != rhs.gifts[index].identifier {
                    return false
                }
            }
        }
        
        return
            lhs.firstName == rhs.firstName &&
                lhs.lastName == rhs.lastName &&
                lhs.nickName == rhs.nickName &&
                lhs.email == rhs.email &&
                lhs.phoneNumber == rhs.phoneNumber &&
                lhs.avatar == rhs.avatar &&
                lhs.likes == rhs.likes &&
                lhs.dislikes == rhs.dislikes &&
                lhs.imageData == rhs.imageData
        
    }
}
