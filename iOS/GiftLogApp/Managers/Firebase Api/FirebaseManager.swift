//
//  FirebaseManager.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/17/17.
//  Copyright © 2017 GiftLogApp. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import UIKit

typealias FIRSetCompletionHandler = (_ success: Bool) -> Void

class FirebaseManager {
    
    // MARK: Properties
    
    static let shared = FirebaseManager()
    
    // MARK: ------ Firebase methods ------

    func getAuthentificatedUserId() -> String? {
        return FIRAuth.auth()?.currentUser?.uid
    }

    func showErrorAlertWithMessage(_ message: String, fromFunction function: String) {
        // TODO: Should be commented before uploading to AppStore
        //UIAlertController.showAlertWithTitle("Error at \(function) occured", message: message)
    }
    
    // MARK: --- CONTACTS ----

    func saveOrUpdateContact(_ contact: Contact, completion: @escaping FIRSetCompletionHandler) {
        let contactItemRef = FirebaseEndPoints.contactsDatabaseRef.child(contact.identifier) // path at Firebase DB to current user
        contactItemRef.setValue(contact.toAnyObject()) { (error, ref) in // overwrite user
            if error != nil {
                self.showErrorAlertWithMessage(error.debugDescription, fromFunction: #function)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func getContactById(_ id: String, completion: @escaping (_ contact: Contact?) -> Void) {
        var handle: UInt = 0
        let refPath = FirebaseEndPoints.contactsDatabaseRef.child(id)
        handle = refPath.observe(.value, with: { snapshot in
            refPath.removeObserver(withHandle: handle)   
            if snapshot.exists() {
                if let snaphotValue = snapshot.value as? [String: AnyObject] {
                    completion(Contact(data: snaphotValue, snapshotRef: snapshot.ref))
                }
            } else {
                completion(nil)
            }
        })
    }
    
    func deleteContactFromDatabase(_ contact: Contact, completion: @escaping FIRSetCompletionHandler) {
        let contactItemRef = FirebaseEndPoints.contactsDatabaseRef.child(contact.identifier) // path at Firebase DB to current user
        contactItemRef.setValue(nil) { (error, ref) in // overwrite user
            if error != nil {
                self.showErrorAlertWithMessage(error.debugDescription, fromFunction: #function)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func getAllContactsOfUserWithId(_ id: String, isSingleOperation: Bool, completion: @escaping (_ contacts: [Contact], _ handle: UInt) -> Void) {
        var handle: UInt = 0
        let refPath = FirebaseEndPoints.contactsDatabaseRef.queryOrdered(byChild: "ownerId").queryEqual(toValue: id)
        handle = refPath.observe(.value, with: { snapshot in
            if isSingleOperation { refPath.removeObserver(withHandle: handle) }
            var contacts = [Contact]()
            if snapshot.exists() {
                for item in snapshot.children {
                    let snapshot = item as! FIRDataSnapshot
                    let contact = Contact(data: snapshot.value as! [String : AnyObject], snapshotRef: snapshot.ref)
                    contacts.append(contact)
                }
                completion(contacts, handle)
            } else {
                completion(contacts, handle)
            }
        })
    }
    
    func uploadContactAvatarImage(_ imageData: Data, forContact contact: Contact, completion: @escaping (_ avatarPath: String?) -> Void) {
        let imagePath = contact.identifier + "/\(Int64(Date.timeIntervalSinceReferenceDate * 1000)).png"
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/png"
        let contactAvatarStorageRef = FirebaseEndPoints.contactAvatarStorageRef.child(imagePath)
        contactAvatarStorageRef.put(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                HUDManager.showErrorHUD()
                print("Error uploading photo: \(error)")
                completion(nil)
                return
            }
            completion(metadata?.downloadURL()?.description)
        }
    }
    
    // MARK: --- USER ----

    func getUserById(_ id:String, isSingleOperation: Bool, completion: @escaping (_ user: User?) -> Void) {
        var handle: UInt = 0
        let refPath = FirebaseEndPoints.usersDatabaseRef.child(id)
        handle = refPath.observe(.value, with: { snapshot in
            if isSingleOperation { refPath.removeObserver(withHandle: handle) }
            if snapshot.exists() {
                if let snaphotValue = snapshot.value as? [String: AnyObject] {
                    completion(User(snapshotValue: snaphotValue, snapshotRef: snapshot.ref))
                }
            } else {
                completion(nil)
                
            }
        })
    }
    
    func saveOrUpdateUser(_ user: User, completion: @escaping FIRSetCompletionHandler) {
        let userItemRef = FirebaseEndPoints.usersDatabaseRef.child(user.identifier) // path at Firebase DB to current user
        userItemRef.setValue(user.toAnyObject()) { (error, ref) in // overwrite user
            if error != nil {
                self.showErrorAlertWithMessage(error.debugDescription, fromFunction: #function)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func deleteUserFromDatabase(_ user: User, completion: @escaping FIRSetCompletionHandler) {
        let userItemRef = FirebaseEndPoints.usersDatabaseRef.child(user.identifier) // path at Firebase DB to current user
        userItemRef.setValue(nil) { (error, ref) in // overwrite user
            if error != nil {
                self.showErrorAlertWithMessage(error.debugDescription, fromFunction: #function)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func resetPasswordFromEmail(_ email: String, completion: @escaping FIRSetCompletionHandler) {
        HUDManager.showLoadingHUD()
        FIRAuth.auth()?.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                HUDManager.showErrorHUD()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    UIAlertController.showAlertWithTitle(error.localizedDescription, message: "")
                    completion(false)
                }
            } else {
                HUDManager.showSuccessHUD()
                completion(true)
            }
        }
    }
    
    func getAllUsers(isSingleOperation: Bool, completion: @escaping (_ users: [User], _ handle: UInt) -> Void) {
        var handle: UInt = 0
        let refPath = FirebaseEndPoints.usersDatabaseRef
        handle = refPath.observe(.value, with: { snapshot in
            if isSingleOperation { refPath.removeObserver(withHandle: handle) }
            var users = [User]()
            if snapshot.exists() {
                for item in snapshot.children {
                    let snapshot = item as! FIRDataSnapshot
                    let user = User(snapshotValue: snapshot.value as! [String : AnyObject], snapshotRef: snapshot.ref)
                    users.append(user)
                }
                completion(users, handle)
            } else {
                completion(users, handle)
            }
        })
    }
    
    func uploadUserAvatarImage(_ imageData: Data, forUser user: User, completion: @escaping (_ avatarPath: String?) -> Void) {
        let imagePath = user.identifier + "/\(Int64(Date.timeIntervalSinceReferenceDate * 1000)).png"
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/png"
        let userAvatarStorageRef = FirebaseEndPoints.userAvatarStorageRef.child(imagePath)
        userAvatarStorageRef.put(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                HUDManager.showErrorHUD()
                print("Error uploading photo: \(error)")
                completion(nil)
                return
            }
            completion(metadata?.downloadURL()?.description)
        }
    }
    
    
    // MARK: --- EVENT ----
    
    func saveOrUpdateEvent(_ event: Event, completion: @escaping FIRSetCompletionHandler) {
        let eventItemRef = FirebaseEndPoints.eventsDatabaseRef.child(event.identifier) // path at Firebase DB to current event
        eventItemRef.setValue(event.toAnyObject()) { (error, ref) in // overwrite event
            if error != nil {
                self.showErrorAlertWithMessage(error.debugDescription, fromFunction: #function)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func deleteEventFromDatabase(_ event: Event, completion: @escaping FIRSetCompletionHandler) {
        let eventItemRef = FirebaseEndPoints.eventsDatabaseRef.child(event.identifier) // path at Firebase DB to current event
        eventItemRef.setValue(nil) { (error, ref) in // overwrite event
            if error != nil {
                self.showErrorAlertWithMessage(error.debugDescription, fromFunction: #function)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func getAllEventsOfUserWith(_ id: String, isSingleOperation: Bool, completion: @escaping (_ events: [Event], _ handle: UInt) -> Void) {
        var handle: UInt = 0
        let refPath = FirebaseEndPoints.eventsDatabaseRef.queryOrdered(byChild: "ownerId").queryEqual(toValue: id)
        handle = refPath.observe(.value, with: { snapshot in
            if isSingleOperation { refPath.removeObserver(withHandle: handle) }
            var events = [Event]()
            if snapshot.exists() {
                for item in snapshot.children {
                    let snapshot = item as! FIRDataSnapshot
                    let event = Event(data: snapshot.value as! [String : AnyObject], snapshotRef: snapshot.ref)
                    events.append(event)
                }
                completion(events, handle)
            } else {
                completion(events, handle)
            }
        })
    }
    
    func uploadEventAvatarImage(with imageData: Data, forEvent event: Event, completion: @escaping (_ avatarPath: String?) -> Void) {
        let imagePath = event.identifier + "/\(Int64(Date.timeIntervalSinceReferenceDate * 1000)).png"
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/png"
        let eventAvatarStorageRef = FirebaseEndPoints.eventAvatarStorageRef.child(imagePath)
        eventAvatarStorageRef.put(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                HUDManager.showErrorHUD()
                print("Error uploading photo: \(error)")
                completion(nil)
                return
            }
            completion(metadata?.downloadURL()?.description)
        }
    }
    
    func getEventById(_ id: String, completion: @escaping (_ contact: Event?) -> Void) {
        var handle: UInt = 0
        let refPath = FirebaseEndPoints.eventsDatabaseRef.child(id)
        handle = refPath.observe(.value, with: { snapshot in
            refPath.removeObserver(withHandle: handle)
            if snapshot.exists() {
                if let snaphotValue = snapshot.value as? [String: AnyObject] {
                    completion(Event(data: snaphotValue, snapshotRef: snapshot.ref))
                }
            } else {
                completion(nil)
            }
        })
    }
    
    // MARK: --- GIFTS ----
    
    func saveOrUpdateGift(_ gift: Gift, completion: @escaping FIRSetCompletionHandler) {
        let giftItemRef = FirebaseEndPoints.giftsDatabaseRef.child(gift.identifier) // path at Firebase DB to current gift
        giftItemRef.setValue(gift.toAnyObject()) { (error, ref) in // overwrite gift
            if error != nil {
                self.showErrorAlertWithMessage(error.debugDescription, fromFunction: #function)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func deleteGiftFromDatabase(_ gift: Gift, completion: @escaping FIRSetCompletionHandler) {
        let giftItemRef = FirebaseEndPoints.giftsDatabaseRef.child(gift.identifier) // path at Firebase DB to current user
        giftItemRef.setValue(nil) { (error, ref) in // overwrite gift
            if error != nil {
                self.showErrorAlertWithMessage(error.debugDescription, fromFunction: #function)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func getAllGiftsOfUserWithId(_ id: String, isSingleOperation: Bool, completion: @escaping (_ gifts: [Gift], _ handle: UInt) -> Void) {
        var handle: UInt = 0
        let refPath = FirebaseEndPoints.giftsDatabaseRef.queryOrdered(byChild: "ownerId").queryEqual(toValue: id)
        handle = refPath.observe(.value, with: { snapshot in
            if isSingleOperation { refPath.removeObserver(withHandle: handle) }
            var gifts = [Gift]()
            if snapshot.exists() {
                for item in snapshot.children {
                    let snapshot = item as! FIRDataSnapshot
                    let gift = Gift(data: snapshot.value as! [String : AnyObject], snapshotRef: snapshot.ref)
                    gifts.append(gift)
                }
                completion(gifts, handle)
            } else {
                completion(gifts, handle)
            }
        })
    }
    
    func uploadGiftAvatarImage(_ imageData: Data, forGift gift: Gift, completion: @escaping (_ avatarPath: String?) -> Void) {
        let imagePath = gift.identifier + "/\(Int64(Date.timeIntervalSinceReferenceDate * 1000)).png"
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/png"
        let giftAvatarStorageRef = FirebaseEndPoints.giftAvatarStorageRef.child(imagePath)
        giftAvatarStorageRef.put(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                HUDManager.showErrorHUD()
                print("Error uploading photo: \(error)")
                completion(nil)
                return
            }
            completion(metadata?.downloadURL()?.description)
        }
    }
    
    func getGiftById(_ id: String, completion: @escaping (_ contact: Gift?) -> Void) {
        var handle: UInt = 0
        let refPath = FirebaseEndPoints.giftsDatabaseRef.child(id)
        handle = refPath.observe(.value, with: { snapshot in
            refPath.removeObserver(withHandle: handle)
            if snapshot.exists() {
                if let snaphotValue = snapshot.value as? [String: AnyObject] {
                    completion(Gift(data: snaphotValue, snapshotRef: snapshot.ref))
                }
            } else {
                completion(nil)
            }
        })
    }
    
}
