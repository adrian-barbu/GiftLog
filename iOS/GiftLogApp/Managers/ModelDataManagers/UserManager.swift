//
//  UserManager.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/17/17.
//  Copyright © 2017 GiftLogApp. All rights reserved.
//

import Foundation

class UserManager {
    
    // MARK: Properties
    
    static let shared = UserManager()
    private(set) var isListening: Bool = false
    
    internal var currentUser: User! {
        didSet {
            activateListeningOfUserContent()
        }
    }

    // MARK: Methods
    
    func activateListeningOfUserContent() {
        if currentUser != nil && !isListening && currentUser.ref != nil {
            UserGiftsManager.shared.startListenToAllUserGiftsChanges()
            UserContactsManager.shared.startListenToAllUserContactsChanges()
            UserEventsManager.shared.startListenToAllUserEventsChanges()
            isListening = true
            debugPrint("Listening is on")
        } else if currentUser == nil {
            isListening = false
            debugPrint("Listening is off")
        }
    }
    
    func creatCSV() -> Void {
        var csvText = "Name,In/Out,Gift type,Description,Value,Reciept type,Status,Event,Contacts\n"
        let gifts = UserGiftsManager.shared.userGifts
        for gift in gifts {
            var typeString = "-"
            if let value = gift.type {
                typeString = Gift.Category(rawValue: value)!.description
            }
            var eventTitle = "-"
            var eventStarts = "-"
            var eventEnds = "-"
            if let eventPreload = gift.eventPreload {
                if let event = UserEventsManager.shared.getEventById(eventPreload.identifier) {
                    eventTitle = event.eventTitle
                    if let starts = event.dateStart {
                        eventStarts = Date(timeIntervalSince1970: TimeInterval(starts)).formattedDateAndTimeString().replacingOccurrences(of: ",", with: " ")
                    }
                    if let ends = event.dateEnd {
                        eventEnds = Date(timeIntervalSince1970: TimeInterval(ends)).formattedDateAndTimeString().replacingOccurrences(of: ",", with: " ")
                    }
                }
            }
            let line = "\(gift.name),\(Gift.InOutType(rawValue: gift.inOutType)!.description),\(typeString),\(gift.giftDescription ?? "-"),\(gift.price?.replacingOccurrences(of: ",", with: ".") ?? "-"),\(Gift.RecieptType(rawValue: gift.recieptType)!.description),\(Gift.Status(rawValue: gift.status)!.description),Name: \(eventTitle) Starts: \(eventStarts) Ends: \(eventEnds),"
            csvText.append(line)
            
            for contact in gift.contacts {
                var contactName = "-"
                var contactNumber = "-"
                if let contact = UserContactsManager.shared.getContactById(contact.identifier) {
                    contactName = contact.fullName
                    if let number = contact.phoneNumber {
                        contactNumber = number
                    }
                }
                let contactString = "Name: \(contactName) Number: \(contactNumber); "
                csvText.append(contactString)
            }
            csvText.append("\n")
        }
        
        // Converting it to NSData.
        if let data = csvText.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            do {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsURL.appendingPathComponent("giftLogFile.csv")
                try data.write(to: fileURL, options: .atomic)
            } catch { }
            // Unwrapping the optional.
            print("NSData: \(data)")
            SSHelperManager.shared.showMailComposerFor(recipients: [], withText: "CSV File from GiftLog App", withFile: data)
        }
    }
}
