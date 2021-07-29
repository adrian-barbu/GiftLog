//
//  Contact.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/10/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import Foundation
import FirebaseDatabase
import APAddressBook

class Contact: BaseFIRModel {
    
    // MARK: Properties
    
    var ownerId: String!
    var firstName: String = ""
    var lastName: String?
    var nickName: String?
    var email: String?
    var phoneNumber: String?
    var avatar: String?
    var dates = [ContactDate]()
    var gifts = [GiftPreload]()
    var likes: String?
    var dislikes: String?
    var isContactHasOwnAccount: Bool = false // TODO: field for internal use only. Logic should be implemented later.
    var thumbDataToUpload: Data? // only for internal usage
    var avatarUrl: URL? {
        if let avatar = avatar {
            return URL(string: avatar)
        }
        return nil
    }
    
    var avatarThumb: UIImage {
        return UIImage(named: "contactThumb")!
    }
    
    var fullName: String {
        if firstName.isEmpty {
            return ""
        }
        return (firstName) + " " + (lastName ?? "")
    }
    
    init(data: [String:AnyObject], snapshotRef: DatabaseReference?) {
        super.init()
        self.ownerId = data["ownerId"] as? String
        self.firstName = data["firstName"] as? String ?? ""
        self.lastName = data["lastName"] as? String ?? ""
        self.nickName = data["nickName"] as? String
        self.email = data["email"] as? String
        self.phoneNumber = data["phoneNumber"] as? String
        self.avatar = data["avatar"] as? String
        if let arrayOfDates = data["dates"] as? [AnyObject] {
            for contactData in arrayOfDates {
                self.dates.append(ContactDate(data: contactData as! [String: AnyObject]))
            }
        }
        if let arrayOfGifts = data["gifts"] as? [AnyObject] {
            for giftData in arrayOfGifts {
                self.gifts.append(GiftPreload(data: giftData as! [String: AnyObject]))
            }
        }
        self.likes = data["likes"] as? String
        self.dislikes = data["dislikes"] as? String
        self.ref = snapshotRef
    }
    
    init(phonebookContact: APContact) {
        super.init()
        self.ref = FirebaseEndPoints.contactsDatabaseRef.childByAutoId()
        self.ownerId = UserManager.shared.currentUser.identifier
        self.firstName = phonebookContact.name?.firstName ?? ""
        self.lastName = phonebookContact.name?.lastName ?? ""
        self.nickName = phonebookContact.name?.middleName
        self.email = phonebookContact.emails?.first?.address
        self.phoneNumber = ContactsManager.getFormattedStringFromNumber(phonebookContact.phones?.first?.number)
        if let thumbnail = phonebookContact.thumbnail {
            self.thumbDataToUpload = UIImageJPEGRepresentation(thumbnail, 1.0)
        }
    }
    
    override init () {
        super.init()
        self.ref = FirebaseEndPoints.contactsDatabaseRef.childByAutoId()
        self.ownerId = UserManager.shared.currentUser.identifier
    }
    
    func updateContactFromService(_ contactService: ContactService) {
        self.firstName = contactService.firstName
        self.lastName = contactService.lastName
        self.nickName = contactService.nickName
        self.email = contactService.email
        self.phoneNumber = contactService.phoneNumber
        self.avatar = contactService.avatar
        self.dates = contactService.dates
        self.likes = contactService.likes
        self.dislikes = contactService.dislikes
        self.gifts = contactService.gifts
    }
    
    func copyContact() -> Contact {
        let contact = Contact()
        contact.firstName = self.firstName
        contact.lastName = self.lastName
        contact.nickName = self.nickName
        contact.email = self.email
        contact.phoneNumber = self.phoneNumber
        contact.avatar = self.avatar
        contact.dates = self.dates
        contact.likes = self.likes
        contact.dislikes = self.dislikes
        contact.gifts = self.gifts
        return contact
    }
    
    // MARK: Here suppose to be one more method to init Contact model from ContactService
    
    func toAnyObject() -> Any {
        
        // Non optional values
        
        var dict = [
            "ownerId": self.ownerId,
            "firstName" : self.firstName,
        ] as [String : Any]
        
        // Optional values
        
        if let value = lastName {
            dict["lastName"] = value
        }
        if let value = nickName {
            dict["nickName"] = value
        }
        if let value = email {
            dict["email"] = value
        }
        if let value = phoneNumber {
            dict["phoneNumber"] = value
        }
        if let value = avatar {
            dict["avatar"] = value
        }
        if let value = likes {
            dict["likes"] = value
        }
        if let value = dislikes {
            dict["dislikes"] = value
        }
        if !dates.isEmpty {
            dict["dates"] = UserContactsManager.shared.formattedArrayOfContactDates(dates: dates)
        }
        if !gifts.isEmpty {
            dict["gifts"] = UserGiftsManager.shared.formattedArrayOfGiftIdentifiers(gifts: gifts)
        }
        return dict
    }

}
