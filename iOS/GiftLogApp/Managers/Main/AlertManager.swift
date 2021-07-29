//
//  AlertManager.swift
//
//
//  Created by Webs The Word on 11/22/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation
import UIKit

enum AlertButtonPressed {
    case okey
    case cancel
    case save
}

enum DeleteButtonPressed {
    case cancel
    case delete
}

typealias QuestionAlertCompletionHandler = (_ buttonPressed: AlertButtonPressed) -> Void
typealias DeleteAlertCompletionHandler = (_ buttonPressed: DeleteButtonPressed) -> Void

class AlertManager {
    
    static let shared = AlertManager()
    
    func showPrivacyAlertViewFromController(_ controller: UIViewController!, title: String, message: String, completion: QuestionAlertCompletionHandler?) {
        var controller = controller
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { action in
            UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
            if let completion = completion {
                completion(AlertButtonPressed.okey)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
            if let completion = completion {
                completion(AlertButtonPressed.cancel)
            }
        }
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        if controller == nil {
            controller = UIViewController.getVisibleViewController(nil)
        }
        controller!.present(alert, animated: true, completion: nil)
    }
    
    // MARK: --- User's Alerts ---
    
    func showLogoutAlertViewFromController(_ controller: UIViewController) {
        let alert = UIAlertController(title: "Are you sure you want to log out?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Log out", style: UIAlertActionStyle.destructive, handler: { (handler) in
            AuthManager.shared.logOut()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (handler) in
            // dismiss
        }))
        controller.present(alert, animated: true, completion: nil)
    }
    
    func showDeleteUserAlertViewFromController(_ controller: UIViewController) {
        let alert = UIAlertController(title: "Are you sure you want to permanently delete this profile and all associated data? This action cannot be undone.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (handler) in
            AuthManager.shared.deleteAllUserData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (handler) in
            // dismiss
        }))
        controller.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Action Sheets
    
    func showShareActionSheetForContact(_ contact: Contact, fromController controller: UIViewController) {
        let alertStyle = (DeviceType.IS_IPAD) ? UIAlertControllerStyle.alert : UIAlertControllerStyle.actionSheet
        let actionSheetController = UIAlertController(title: "Share app to contact via:", message: "Option to select", preferredStyle: alertStyle)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelActionButton)
        
        let mailActionButton = UIAlertAction(title: "Email", style: .default) { action -> Void in
            var recipients = [String]()
            if let email = contact.email {
                recipients.append(email)
            }
            SSHelperManager.shared.showMailComposerFor(recipients: recipients, withText: "\(contact.fullName), how are you there ? Try this cool app by link: \(Constants.appStoreLink)")
        }
        actionSheetController.addAction(mailActionButton)
        
        let messageActionButton = UIAlertAction(title: "Message", style: .default) { action -> Void in
            var recipients = [String]()
            if let phoneNumber = contact.phoneNumber, !phoneNumber.isEmpty {
                recipients.append(phoneNumber)
            }
            SSHelperManager.shared.showMessageComposerFor(recipients: recipients, withText: "\(contact.fullName), how are you there ? Try this cool app by link: \(Constants.appStoreLink)")
        }
        actionSheetController.addAction(messageActionButton)
        controller.present(actionSheetController, animated: true, completion: nil)
    }
    
    func showShareWishlistActionSheetForContacts(_ contacts: [Contact], withText text: String, fromController controller: UIViewController) {
        let alertStyle = (DeviceType.IS_IPAD) ? UIAlertControllerStyle.alert : UIAlertControllerStyle.actionSheet
        let actionSheetController = UIAlertController(title: "Share wishlist to contacts via:", message: "Option to select", preferredStyle: alertStyle)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelActionButton)
        
        let mailActionButton = UIAlertAction(title: "Email", style: .default) { action -> Void in
            var recipients = [String]()
            for contact in contacts {
                if let email = contact.email {
                    recipients.append(email)
                }
            }
            SSHelperManager.shared.showMailComposerFor(recipients: recipients, withText: text)
        }
        actionSheetController.addAction(mailActionButton)
        
        let messageActionButton = UIAlertAction(title: "Message", style: .default) { action -> Void in
            var recipients = [String]()
            for contact in contacts {
                if let phoneNumber = contact.phoneNumber {
                    recipients.append(phoneNumber)
                }
            }
            SSHelperManager.shared.showMessageComposerFor(recipients: recipients, withText: text)
        }
        actionSheetController.addAction(messageActionButton)
        controller.present(actionSheetController, animated: true, completion: nil)
    }
    
    func showShareThankYouActionSheetForContacts(_ contacts: [Contact], withText text: String, fromController controller: UIViewController) {
        let alertStyle = (DeviceType.IS_IPAD) ? UIAlertControllerStyle.alert : UIAlertControllerStyle.actionSheet
        let actionSheetController = UIAlertController(title: "Send 'Thank you' letter to contacts via:", message: "Option to select", preferredStyle: alertStyle)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelActionButton)
        
        let mailActionButton = UIAlertAction(title: "Email", style: .default) { action -> Void in
            var recipients = [String]()
            for contact in contacts {
                if let email = contact.email {
                    recipients.append(email)
                }
            }
            SSHelperManager.shared.showMailComposerFor(recipients: recipients, withText: text)
        }
        actionSheetController.addAction(mailActionButton)
        
        let messageActionButton = UIAlertAction(title: "Message", style: .default) { action -> Void in
            var recipients = [String]()
            for contact in contacts {
                if let phoneNumber = contact.phoneNumber {
                    recipients.append(phoneNumber)
                }
            }
            SSHelperManager.shared.showMessageComposerFor(recipients: recipients, withText: text)
        }
        actionSheetController.addAction(messageActionButton)
        controller.present(actionSheetController, animated: true, completion: nil)
    }
    
    func showDeleteAlertViewFrom(_ controller: UIViewController, deleteButtonTitle: String, completion: DeleteAlertCompletionHandler?) {
        let alertStyle = (DeviceType.IS_IPAD) ? UIAlertControllerStyle.alert : UIAlertControllerStyle.actionSheet
        let title = (DeviceType.IS_IPAD) ? "Are you sure you want to delete item?" : nil
        let alert = UIAlertController(title: title, message: nil, preferredStyle: alertStyle)
        alert.addAction(UIAlertAction(title: deleteButtonTitle, style: UIAlertActionStyle.destructive, handler: { (handler) in
            if let completion = completion {
                completion(DeleteButtonPressed.delete)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (handler) in
            if let completion = completion {
                completion(DeleteButtonPressed.cancel)
            }
        }))
        controller.present(alert, animated: true, completion: nil)
    }
    
    func showBackActionSheetFromController(_ controller: UIViewController!, title: String, message: String, completion: QuestionAlertCompletionHandler?) {
        let alertStyle = (DeviceType.IS_IPAD) ? UIAlertControllerStyle.alert : UIAlertControllerStyle.actionSheet
        let actionSheetController = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: alertStyle)
        let continueAction = UIAlertAction(title: "Continue", style: .default) { action in
            if let completion = completion {
                completion(AlertButtonPressed.okey)
            }
        }
        actionSheetController.addAction(continueAction)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            if let completion = completion {
                completion(AlertButtonPressed.save)
            }
        }
        actionSheetController.addAction(saveAction)
        let discardAction = UIAlertAction(title: "Discard", style: .cancel) { action in
            if let completion = completion {
                completion(AlertButtonPressed.cancel)
            }
        }
        actionSheetController.addAction(discardAction)
        controller!.present(actionSheetController, animated: true, completion: nil)
    }
}
