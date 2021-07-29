//
//  Gift.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/27/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit
import FirebaseDatabase

/*
 GIFTS (mandatory)

 Gift Name
 In/OUT
 Status
 Contact

 */
class Gift: BaseFIRModel {
    
    // MARK: - Properties
    
    var ownerId: String!
    var name: String = ""
    var inOutType: Int = InOutType.recieved.rawValue
    var type: Int?
    var giftDescription: String?
    var price: String?
    var recieptType: Int = RecieptType.no.rawValue
    var status: Int = Gift.Status.none.rawValue
    var images = [GiftImage]()
    var thankYouSent: Bool = false
    var contacts = [ContactPreload]()
    var eventPreload: EventPreload?
    
    var imageUrl: URL? {
        if !images.isEmpty {
            return URL(string: images.first!.url)
        }
        return nil
    }
    
    var avatarThumb: UIImage {
        return UIImage(named: "giftThumb")!
    }
    
    init(data: [String:AnyObject], snapshotRef: DatabaseReference?) {
        super.init()
        self.ownerId = data["ownerId"] as? String
        self.name = data["name"] as? String ?? ""
        self.inOutType = data["inOutType"] as! Int
        self.type = data["type"] as? Int
        self.giftDescription = data["description"] as? String
        self.price = data["price"] as? String
        self.recieptType = data["recieptType"] as! Int
        self.status = data["status"] as! Int
        if let arrayOfImages = data["images"] as? [AnyObject] {
            for image in arrayOfImages {
                self.images.append(GiftImage(data: image as! [String: AnyObject]))
            }
        }
        self.thankYouSent = data["thankYouSent"] as! Bool
        if let arrayOfContacts = data["contacts"] as? [AnyObject] {
            for contactData in arrayOfContacts {
                self.contacts.append(ContactPreload(data: contactData as! [String: AnyObject]))
            }
        }
        if let eventPreloadData = data["eventPreload"] as? [String: AnyObject] {
            self.eventPreload = EventPreload(data: eventPreloadData)
        }
        self.ref = snapshotRef
    }
    
    override init () {
        super.init()
        self.ref = FirebaseEndPoints.contactsDatabaseRef.childByAutoId()
        self.ownerId = UserManager.shared.currentUser.identifier
    }
    
    func updateGiftFromService(_ giftService: GiftService) {
        self.name = giftService.name
        self.inOutType = giftService.inOutType
        self.type = giftService.type
        self.giftDescription = giftService.description
        self.price = giftService.price
        self.recieptType = giftService.recieptType
        self.status = giftService.status
        self.images = giftService.images
        self.thankYouSent = giftService.thankYouSent
        self.contacts = giftService.contacts
        self.eventPreload =  giftService.eventPreload
    }
    
    func copyGift() -> Gift {
        let gift = Gift()
        gift.name = self.name
        gift.inOutType = self.inOutType
        gift.type = self.type
        gift.giftDescription = self.giftDescription
        gift.price = self.price
        gift.recieptType = self.recieptType
        gift.status = self.status
        gift.images = self.images
        gift.thankYouSent = self.thankYouSent
        gift.contacts = self.contacts
        gift.eventPreload =  self.eventPreload
        return gift
    }
    
    func formattedArrayOfGiftImages() -> [String: AnyObject] {
        var formattedDictionaryOfImages = [String: AnyObject]()
        var index = 0
        for item in self.images {
            formattedDictionaryOfImages[String(index)] = item.formattedDict() as AnyObject
            index += 1
        }
        return formattedDictionaryOfImages
    }
    
    func formattedArrayOfGiftContacts() -> [String: AnyObject] {
        var formattedDictionaryOfContacts = [String: AnyObject]()
        var index = 0
        for item in self.contacts {
            formattedDictionaryOfContacts[String(index)] = item.formattedDict() as AnyObject
            index += 1
        }
        return formattedDictionaryOfContacts
    }
    
    func toAnyObject() -> Any {
        
        // Non optional values
        
        var dict = [
            "ownerId": self.ownerId,
            "name": self.name,
            "inOutType": self.inOutType,
            "recieptType": self.recieptType,
            "status": self.status,
            "thankYouSent": self.thankYouSent
            ] as [String : Any]
        
        // Optional values
        
        if let value = type {
            dict["type"] = value
        }
        if let value = giftDescription {
            dict["description"] = value
        }
        if let value = price {
            dict["price"] = value
        }
        if !images.isEmpty {
            dict["images"] = self.formattedArrayOfGiftImages()
        }
        if !contacts.isEmpty {
            dict["contacts"] = self.formattedArrayOfGiftContacts()
        }
        if let value = eventPreload {
            dict["eventPreload"] = value.formattedDict()
        }
        return dict
    }
}

extension Gift {
    // MARK: Enums for Gift
    
    enum InOutType: Int {
        case recieved = 0
        case given
        
        var description: String {
            switch self {
            case .recieved:
                return "Recieved"
            case .given:
                return "Given"
            }
        }
    }
    
    enum RecieptType: Int {
        case no = 0
        case yes
        
        var description: String {
            switch self {
            case .no:
                return "No"
            case .yes:
                return "Yes"
            }
        }
    }
    
    enum Status: Int {
        case keep = 0
        case regift
        case returned
        case exchange
        case none
        
        var description: String {
            switch self {
            case .keep:
                return "Keep"
            case .regift:
                return "Regift"
            case .returned:
                return "Return"
            case .exchange:
                return "Exchange"
            case .none:
                return "None"
            }
        }
        
        static let allValues = [Status.keep, .regift, .returned, .exchange, .none]
        
        static var allValuesWithDescription: [String] {
            var values = [String]()
            for object in Status.allValues {
                values.append(object.description)
            }
            return values
        }
    }
    
    enum Category: Int { // type
        case books = 0 //  Books / Stationery
        case toys // Toys / Games
        case electronics // Electronics / Gadgets
        case clothing // Clothing
        case food // Food / Drink
        case cash // Cash
        case vouchers // Vouchers / Gift Certificates
        case home // Home / Garden / Pets / DIY
        case health // Health / Fitness / Lifestyle
        case sports // Sports / Outdoors
        case other // Other
        case jewellery // Jewellery
        
        var description: String {
            switch self {
            case .books:
                return "Books / Stationery"
            case .toys:
                return "Toys / Games"
            case .electronics:
                return "Electronics / Gadgets"
            case .clothing:
                return "Clothing"
            case .food:
                return "Food / Drink"
            case .cash:
                return "Cash"
            case .vouchers:
                return "Vouchers / Gift Certificates"
            case .home:
                return "Home / Garden / Pets / DIY"
            case .health:
                return "Health / Fitness / Lifestyle"
            case .sports:
                return "Sports / Outdoors"
            case .jewellery:
                return "Jewellery"
            case .other:
                return "Other"
            }
        }
        
        static let allValues = [Category.books, .toys, .electronics, .clothing, .food, .cash, .vouchers, .home, .health, .sports, .jewellery, .other]
        
        static var allValuesWithDescription: [String] {
            var values = [String]()
            for object in Category.allValues {
                values.append(object.description)
            }
            return values
        }
    }
}
