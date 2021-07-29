//
//  ContactsManager.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/10/17.
//  Copyright © 2016 Gift Log App. All rights reserved.
//

import Foundation
import APAddressBook
import AddressBook
import Contacts

extension String {
    var stringByRemovingWhitespaces: String {
        return components(separatedBy: .whitespaces).joined(separator: "")
    }
}

class ContactsManager {
    /** We get contacts from phonebook, that were not still added by user to the server. */
    class func getContactsFromPhonebookWithCompletion(_ completion: @escaping (_ result: [APContact]?) -> Void) {
        let addressBook = APAddressBook()
        addressBook.fieldsMask = [APContactField.default, APContactField.thumbnail, APContactField.emailsWithLabels]
        addressBook.sortDescriptors = [NSSortDescriptor(key: "name.firstName", ascending: true), NSSortDescriptor(key: "name.lastName", ascending: true)]
        addressBook.filterBlock =
            {
                (contact: APContact) -> Bool in
                if let name = contact.name?.firstName
                {
                    return !name.isEmpty
                }
                return false
        }
        addressBook.loadContacts { (contacts: [APContact]?, error: Error?) in
            if error != nil { // make sure user hadn't previously denied access
                completion(nil)
            } else {
                let loadedContacts = contacts ?? [APContact]()
                var filteredContacts = [APContact]()
                for contact in loadedContacts {
                    if !UserContactsManager.shared.isPhonebookContactAlreadyAtUserContacts(contact) {
                        filteredContacts.append(contact)
                    }
                }
                completion(filteredContacts)
            }
        }
    }
    
    /** Removes unnecessary symbols from number string, keeping only numbers and '+' sign */
    class func getFormattedStringFromNumber(_ number: String?) -> String {
        if var phoneFormattedString = number {
            if phoneFormattedString.isEmpty { return "" }
            phoneFormattedString = phoneFormattedString.stringByRemovingWhitespaces
            phoneFormattedString = phoneFormattedString.replacingOccurrences(of: " ", with: "")
            phoneFormattedString = phoneFormattedString.replacingOccurrences(of: "(", with: "")
            phoneFormattedString = phoneFormattedString.replacingOccurrences(of: ")", with: "")
            phoneFormattedString = phoneFormattedString.replacingOccurrences(of: "-", with: "")
            return phoneFormattedString
        }
        return ""
    }
}
