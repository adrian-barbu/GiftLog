//
//  EventService.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/12/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import Foundation

class EventService: Equatable {
    
    // MARK: - Properties
    
    var eventTitle: String!
    var dateStart: Int64?
    var dateEnd: Int64?
    var eventType: String?
    var description: String?
    var hostingType = HostingType.attending
    var image: String?
    var contacts = [ContactPreload]()
    var gifts = [GiftPreload]()
    var likes: String?
    var dislikes: String?
    var imageData: Data?
    
    // MARK: - Lifecycle methods
    
    init(event: Event) {
        self.eventTitle = event.eventTitle
        self.dateStart = event.dateStart
        self.dateEnd = event.dateEnd
        self.eventType = event.eventType
        self.description = event.eventDescription
        self.hostingType = event.hostingType
        self.image = event.image
        self.likes = event.likes
        self.dislikes = event.dislikes
        self.contacts = event.contacts
        self.gifts = event.gifts
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
    
    static func ==(lhs: EventService, rhs: EventService) -> Bool {
        
        // checking for equality in gifts
        if lhs.gifts.count != rhs.gifts.count {
            return false
        } else {
            for index in 0..<lhs.gifts.count {
                if lhs.gifts[index].identifier != rhs.gifts[index].identifier {
                    return false
                }
            }
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
        
        return
            lhs.eventTitle == rhs.eventTitle &&
                lhs.dateStart == rhs.dateStart &&
                lhs.dateEnd == rhs.dateEnd &&
                lhs.eventType == rhs.eventType &&
                lhs.description == rhs.description &&
                lhs.hostingType == rhs.hostingType &&
                lhs.image == rhs.image &&
                lhs.likes == rhs.likes &&
                lhs.dislikes == rhs.dislikes &&
                lhs.imageData == rhs.imageData
    }
}
