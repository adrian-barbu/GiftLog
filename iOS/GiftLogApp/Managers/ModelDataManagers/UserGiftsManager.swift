//
//  UserGiftsManager.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/17/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import Foundation

class UserGiftsManager {
    
    // MARK: - Variables
    
    static let shared = UserGiftsManager()
    internal var userGifts = [Gift]()
    private var allUserGiftsHandle: UInt = 0
    
    // MARK: - Methods
    
    func startListenToAllUserGiftsChanges() {
        FirebaseManager.shared.getAllGiftsOfUserWithId(UserManager.shared.currentUser.identifier, isSingleOperation: false) { [unowned self] (gifts, handle) in
            self.allUserGiftsHandle = handle
            self.userGifts = gifts.reversed()
            NotificationCenterManager.postNotificationThatUserGiftsWereUpdated()
        }
    }
    
    func stopListenToAllUserGiftsChanges() {
        // current user should not be nil at this moment
        if UserManager.shared.currentUser == nil {
            return
        }
        let refPath = FirebaseEndPoints.giftsDatabaseRef.queryOrdered(byChild: "ownerId").queryEqual(toValue: UserManager.shared.currentUser.identifier)
        refPath.removeObserver(withHandle: allUserGiftsHandle)
        userGifts.removeAll()
    }
    
    func isGiftAlreadyAdded(_ gifts: [Gift], gift: Gift) -> Bool {
        if gifts.isEmpty {
            return false
        }
        let results = gifts.filter { $0.identifier == gift.identifier }
        if results.isEmpty {
            return false
        }
        return true
    }
    
    func formattedArrayOfGiftIdentifiers(gifts: [GiftPreload]) -> [String: AnyObject] {
        var formattedDictionaryOfGifts = [String: AnyObject]()
        var index = 0
        for item in gifts {
            formattedDictionaryOfGifts[String(index)] = item.formattedDict() as AnyObject
            index += 1
        }
        return formattedDictionaryOfGifts
    }
    
    func indexOf(gift: Gift, at giftPreloads: [GiftPreload]) -> Int? {
        for (index, giftPreload) in giftPreloads.enumerated() {
            if giftPreload.identifier == gift.identifier {
                return index
            }
        }
        return nil
    }
}
