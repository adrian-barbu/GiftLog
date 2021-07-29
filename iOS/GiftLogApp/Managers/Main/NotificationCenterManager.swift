//
//  NotificationCenterManager.swift
//
//
//  Created by Webs The Word on 10/28/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation
import UIKit

class NotificationCenterManager {
    
    // MARK: Vars
    
    static let controllerIDKey = "controllerID"
    static let shared = NotificationCenterManager()
    
    // MARK: Notification Identifiers
    
    struct NotificationNames {
        static let UserProfileWasUpdated = "UserProfileWasUpdated"
        static let MenuSelectedButtonChanged = "MenuSelectedButtonChanged"
        static let UserContactsWereUpdated = "UserContactsWereUpdated"
        static let UserEventsWereUpdated = "UserEventsWereUpdated"
        static let UserGiftsWereUpdated = "UserGiftsWereUpdated"
        static let UserPressedAddImageAtGift = "UserPressedAddImageAtGift"
        static let GiftWasCreatedForEvent = "GiftWasCreatedForEvent"
        static let ContactWasCreatedForEvent = "ContactWasCreatedForEvent"
    }
    
    // MARK: Static methods
    
    static func postNotificationThatUserProfileWasUpdated() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.UserProfileWasUpdated), object: nil)
    }
    
    static func postNotificationThatUserContactsWereUpdated() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.UserContactsWereUpdated), object: nil)
    }
    
    static func postNotificationThatMenuSelectedButtonChanged(_ index: Int) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.MenuSelectedButtonChanged), object: nil, userInfo: ["index" : index])
    }
    
    static func postNotificationThatUserEventsWereUpdated() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.UserEventsWereUpdated), object: nil)
    }
    
    static func postNotificationThatUserGiftsWereUpdated() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.UserGiftsWereUpdated), object: nil)
    }
    
    static func postNotificationThatUserPressedAddImageAtGift() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.UserPressedAddImageAtGift), object: nil)
    }

    static func postNotificationThatGift(_ giftPreload: GiftPreload, wasCreatedForEventWithIdentifier eventIdentifier: String) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.GiftWasCreatedForEvent), object: nil, userInfo: ["giftPreload" : giftPreload, "eventID" : eventIdentifier])
    }
    
    static func postNotificationThatContact(_ contactPreload: ContactPreload, wasCreatedForEventWithIdentifier eventIdentifier: String) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.ContactWasCreatedForEvent), object: nil, userInfo: ["contactPreload" : contactPreload, "eventID" : eventIdentifier])
    }
}
