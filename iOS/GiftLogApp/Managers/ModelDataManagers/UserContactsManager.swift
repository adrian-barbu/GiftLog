//
//  UserContactsManager.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/11/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import Foundation
import FirebaseDatabase
import APAddressBook

class UserContactsManager {
    
    // MARK: Properties
    
    static let shared = UserContactsManager()
    internal var userContacts = [Contact]()
    private var allUserContactsHandle: UInt = 0
    
    // MARK: Methods
    
    func startListenToAllUserContactsChanges() {
        FirebaseManager.shared.getAllContactsOfUserWithId(UserManager.shared.currentUser.identifier, isSingleOperation: false) { [unowned self] (contacts, handle) in
            self.allUserContactsHandle = handle
            self.userContacts = contacts
            // sort contacts in alphabet order
            self.userContacts.sort(by: { (firContact, secContact) -> Bool in
                return firContact.firstName < secContact.firstName
            })
            NotificationCenterManager.postNotificationThatUserContactsWereUpdated()
            self.getUsersUsingThisApp(contacts)
        }
    }
    
    func stopListenToAllUserContactsChanges() {
        // current user should not be nil at this moment
        if UserManager.shared.currentUser == nil {
            return
        }
        let refPath = FirebaseEndPoints.contactsDatabaseRef.queryOrdered(byChild: "ownerId").queryEqual(toValue: UserManager.shared.currentUser.identifier)
        refPath.removeObserver(withHandle: allUserContactsHandle)
        userContacts.removeAll()
    }
    
    func isPhonebookContactAlreadyAtUserContacts(_ phonebookContact: APContact) -> Bool {
        if userContacts.isEmpty {
            return false
        }
        let results = userContacts.filter { $0.firstName == phonebookContact.name?.firstName &&
            $0.phoneNumber == ContactsManager.getFormattedStringFromNumber(phonebookContact.phones?.first?.number) }
        if results.isEmpty {
            return false
        }
        return true
    }
    
    func isContactAlreadyAddedToEvent(_ eventContacts: [Contact], contact: Contact) -> Bool {
        if eventContacts.isEmpty {
            return false
        }
        let results = eventContacts.filter { $0.identifier == contact.identifier }
        if results.isEmpty {
            return false
        }
        return true
    }
    
    func formattedArrayOfContactDates(dates: [ContactDate]) -> [String: AnyObject] {
        var formattedDictionaryOfDates = [String: AnyObject]()
        var index = 0
        for item in dates {
            formattedDictionaryOfDates[String(index)] = item.formattedDict() as AnyObject
            index += 1
        }
        return formattedDictionaryOfDates
    }
    
    func getUsersUsingThisApp(_ contacts: [Contact]) {
        FirebaseManager.shared.getAllUsers(isSingleOperation: true) { (users, handle) in
            for contact in contacts {
                for user in users {
                    if contact.phoneNumber == user.phoneNumber && contact.phoneNumber != nil && contact.phoneNumber != "" {
                        contact.isContactHasOwnAccount = true
                    }
                }
            }
            NotificationCenterManager.postNotificationThatUserContactsWereUpdated()
        }
    }
    
    func indexOf(contact: Contact, at contactPreloads: [ContactPreload]) -> Int? {
        for (index, contactPreload) in contactPreloads.enumerated() {
            if contactPreload.identifier == contact.identifier {
                return index
            }
        }
        return nil
    }
    
    func getContactById(_ id: String) -> Contact? {
        if userContacts.isEmpty {
            return nil
        }
        return (userContacts.filter { $0.identifier == id }).first
    }
}
