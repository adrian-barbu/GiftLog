//
//  UserDefaultsManager.swift
//
//  Created by Webs The Word on 10/28/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

class UserDefaultsManager {

    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults()

    private struct Keys {
        static let AppLaunchNumber = "AppLaunchNumber"
        static let isUserAuthenticated = "isUserAuthenticated"
        static let isTutorialScreenShowedBefore = "isTutorialScreenShowedBefore"
        static let areLocalNotificationsUsed = "areLocalNotificationsUsed"
    }
    
    // MARK: User Values
    
    var appLaunchNumber: Int {
        get {
            return defaults.value(forKey: Keys.AppLaunchNumber) as? Int ?? 0
        }
        set {
            defaults.set(newValue, forKey: Keys.AppLaunchNumber)
        }
    }
    
    var isUserAuthenticated: Bool {
        get {
            return defaults.value(forKey: Keys.isUserAuthenticated) as? Bool ?? false
        }
        set {
            defaults.set(newValue, forKey: Keys.isUserAuthenticated)
        }
    }
    
    var isTutorialScreenShowedBefore: Bool {
        get {
            return defaults.value(forKey: Keys.isTutorialScreenShowedBefore) as? Bool ?? false
        }
        set {
            defaults.set(newValue, forKey: Keys.isTutorialScreenShowedBefore)
        }
    }
    
    var areLocalNotificationsUsed: Bool {
        get {
            return defaults.value(forKey: Keys.areLocalNotificationsUsed) as? Bool ?? true
        }
        set {
            defaults.set(newValue, forKey: Keys.areLocalNotificationsUsed)
        }
    }
}




