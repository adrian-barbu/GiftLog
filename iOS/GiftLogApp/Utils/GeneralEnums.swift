//
//  GeneralEnums.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/27/17.
//  Copyright © 2017 GiftLogApp. All rights reserved.
//

import Foundation

// MARK: - Menu Enums -

enum MenuAction: Int {
    case openGifts = 0
    case openEvents
    case openContacts
    case openGiftIdeas
    case faq
    case shareApp
    case emailGiftData
    case openPrivacy
    case openTerms
    case contactUs
}

// MARK: General enums

enum SwipeTableViewCellAction: Int {
    case delete = 0
    case copy = 1
}

// MARK: Enums for event

enum HostingType: Int { //sequence of elements must be the same as EventViewController's hosting type segmented contol 
    case attending = 0
    case hosting
}

enum TextPickerType: Int {
    case description = 0
    case likes
    case dislikes
}

// MARK: DetailControllers Enums

enum ControllerDetailPresentationMode: Int {
    case new = 0
    case old
    case prepopulating
}

enum LocalNotificationType: String {
    case event = "event"
}
