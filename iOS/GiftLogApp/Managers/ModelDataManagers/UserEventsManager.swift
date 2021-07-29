//
//  UserEventsManager.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/17/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import Foundation

class UserEventsManager {
    
    // MARK: - Variables
    
    static let shared = UserEventsManager()
    internal var userEvents = [Event]()
    private var allUserEventsHandle: UInt = 0
    
    // MARK: - Methods
    
    func startListenToAllUserEventsChanges() {
        FirebaseManager.shared.getAllEventsOfUserWith(UserManager.shared.currentUser.identifier, isSingleOperation: false) { [unowned self] (events, handle) in
            self.allUserEventsHandle = handle
            self.userEvents = events.reversed()
            RemindService.shared.saveLocalNotificationsForEvents(events: events, completion: { 
                NotificationCenterManager.postNotificationThatUserEventsWereUpdated()
            })
        }
    }
    
    func stopListenToAllUserEventsChanges() {
        // current user should not be nil at this moment
        if UserManager.shared.currentUser == nil {
            return
        }
        let refPath = FirebaseEndPoints.eventsDatabaseRef.queryOrdered(byChild: "ownerId").queryEqual(toValue: UserManager.shared.currentUser.identifier)
        refPath.removeObserver(withHandle: allUserEventsHandle)
        userEvents.removeAll()
    }
    
    func getEventById(_ id: String) -> Event? {
        if userEvents.isEmpty {
            return nil
        }
        return (userEvents.filter { $0.identifier == id }).first
    }
}
