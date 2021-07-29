//
//  Event.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/10/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Event: BaseFIRModel {
  
  // MARK: - Properties
  
  var ownerId: String!
  var eventTitle: String = ""
  var dateStart: Int64?
  var dateEnd: Int64?
  var eventType: String?
  var eventDescription: String?
  var hostingType = HostingType.attending
  var image: String?
  var contacts = [ContactPreload]()
  var gifts = [GiftPreload]()
  var likes: String?
  var dislikes: String?
  var imageUrl: URL? {
    if let image = image {
      return URL(string: image)
    }
    return nil
  }
  
  var imageThumb: UIImage {
    return UIImage(named: "eventThumb")!
  }
  
  init(data: [String:AnyObject], snapshotRef: DatabaseReference?) {
    super.init()
    self.ownerId = data["ownerId"] as? String
    self.eventTitle = data["eventTitle"] as? String ?? ""
    self.dateStart = (data["dateStart"] as? NSNumber)?.int64Value
    self.dateEnd = (data["dateEnd"] as? NSNumber)?.int64Value
    self.eventType = data["eventType"] as? String
    self.eventDescription = data["description"] as? String
    self.hostingType = HostingType(rawValue: data["hostingType"] as! Int)!
    self.image = data["image"] as? String
    if let arrayOfContacts = data["contacts"] as? [AnyObject] {
        for contactData in arrayOfContacts {
            self.contacts.append(ContactPreload(data: contactData as! [String: AnyObject]))
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
  
    override init () {
        super.init()
        self.ref = FirebaseEndPoints.contactsDatabaseRef.childByAutoId()
        self.ownerId = UserManager.shared.currentUser.identifier
    }
    
    func updateEventFromService(_ eventService: EventService) {
        self.eventTitle = eventService.eventTitle
        self.dateStart = eventService.dateStart
        self.dateEnd = eventService.dateEnd
        self.eventType = eventService.eventType
        self.eventDescription = eventService.description
        self.hostingType = eventService.hostingType
        self.image = eventService.image
        self.likes = eventService.likes
        self.dislikes = eventService.dislikes
        self.contacts = eventService.contacts
        self.gifts = eventService.gifts
        
    }
    
    func copyEvent() -> Event {
        let event = Event()
        event.eventTitle = self.eventTitle
        event.dateStart = self.dateStart
        event.dateEnd = self.dateEnd
        event.eventType = self.eventType
        event.eventDescription = self.eventDescription
        event.hostingType = self.hostingType
        event.image = self.image
        event.likes = self.likes
        event.dislikes = self.dislikes
        event.contacts = self.contacts
        event.gifts = self.gifts
        return event
    }
    
    func formattedArrayOfContactIdentifiers() -> [String: AnyObject] {
        var formattedDictionaryOfContacts = [String: AnyObject]()
        var index = 0
        for item in self.contacts {
            formattedDictionaryOfContacts[String(index)] = item.formattedDict() as AnyObject
            index += 1
        }
        return formattedDictionaryOfContacts
    }
    
    func formattedArrayOfGiftIdentifiers() -> [String: AnyObject] {
        var formattedDictionaryOfGifts = [String: AnyObject]()
        var index = 0
        for item in self.gifts {
            formattedDictionaryOfGifts[String(index)] = item.formattedDict() as AnyObject
            index += 1
        }
        return formattedDictionaryOfGifts
    }
    
  func toAnyObject() -> Any {
    
    // Non optional values
    
    var dict = [
      "ownerId": self.ownerId,
      "eventTitle": self.eventTitle,
      "hostingType": self.hostingType.rawValue
      ] as [String : Any]
    
    // Optional values
    
    if let value = dateStart {
      dict["dateStart"] = value
    }
    if let value = dateEnd {
      dict["dateEnd"] = value
    }
    if let value = eventType {
      dict["eventType"] = value
    }
    if let value = eventDescription {
      dict["description"] = value
    }
    if let value = image {
      dict["image"] = value
    }
    if let value = likes {
      dict["likes"] = value
    }
    if let value = dislikes {
      dict["dislikes"] = value
    }
    if !contacts.isEmpty {
        dict["contacts"] = self.formattedArrayOfContactIdentifiers()
    }
    if !gifts.isEmpty {
        dict["gifts"] = UserGiftsManager.shared.formattedArrayOfGiftIdentifiers(gifts: gifts)
    }
    return dict
  }
}
