//
//  FirebaseEndPoints.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/29/17.
//  Copyright © 2017 GiftLogApp. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

struct FirebaseEndPoints {
    
    // MARK: ::: FIRDatabase paths :::
    
    static  let usersDatabaseRef              = FIRDatabase.database().reference(withPath: "users")
    static  let contactsDatabaseRef           = FIRDatabase.database().reference(withPath: "contacts")
    static  let eventsDatabaseRef             = FIRDatabase.database().reference(withPath: "events")
    static  let giftsDatabaseRef             = FIRDatabase.database().reference(withPath: "gifts")
    
    // MARK: ::: FIRStorage paths  :::
    
    static let userAvatarStorageRef           = FIRStorage.storage().reference(withPath: "userAvatars")
    static let contactAvatarStorageRef        = FIRStorage.storage().reference(withPath: "contactsAvatar")
    static let eventAvatarStorageRef          = FIRStorage.storage().reference(withPath: "eventAvatar")
    static let giftAvatarStorageRef          = FIRStorage.storage().reference(withPath: "giftAvatar")

}
