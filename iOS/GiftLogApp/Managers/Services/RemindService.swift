//
//  RemindService.swift
//  GiftLogApp
//
//  Created by Webs The Word on 5/15/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import Foundation
import SWRevealViewController

class RemindService {
    
    // MARK: Properties
    
    static let shared = RemindService()
    
    /** Local notfication, that was not handled, when application launched from terminated state */
    var unhandledLocalNotification: UILocalNotification?
    
    // MARK: Methods
    
    func handleLocalNotificationFromUserInfo(_ userInfo: [AnyHashable: Any]) {
        var finalController: UIViewController!
        if var controller = UIViewController.getVisibleViewController(nil) {
            if let revealController = controller as? SWRevealViewController {
                if revealController.frontViewPosition == .right {
                    revealController.revealToggle(animated: false) // close menu controller, if it is opened
                }
                controller = revealController.frontViewController
                if controller is UINavigationController {
                    finalController = (controller as! UINavigationController).visibleViewController
                }
            } else {
                finalController = controller
            }
            if finalController == nil { return }
            switch LocalNotificationType(rawValue: userInfo["type"] as! String)! {
            case .event:
                HUDManager.showNetworkActivityIndicator()
                FirebaseManager.shared.getEventById(userInfo["eventID"] as! String, completion: { (event) in
                    HUDManager.hideNetworkActivityIndicator()
                    if let event = event {
                        if finalController is EventDetailViewController {
                            let navigationController = finalController.navigationController
                            finalController.navigationController?.popViewController(animated: false)
                            finalController = navigationController?.visibleViewController
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                NavigationManager.shared.showEventDetailViewControllerFrom(finalController, withEvent: event, andWithMode: ControllerDetailPresentationMode.old, prepopulatedGift: nil, prepopulatedContact: nil)
                            }
                        } else {
                            NavigationManager.shared.showEventDetailViewControllerFrom(finalController, withEvent: event, andWithMode: ControllerDetailPresentationMode.old, prepopulatedGift: nil, prepopulatedContact: nil)
                        }
                    }
                })
            }
        }
    }

    
    // MARK: Local notifications
    
    // MARK: --- EVENTS ---

    func saveLocalNotificationsForEvents(events: [Event], completion: (() -> Void)?) {
        if !UserDefaultsManager.shared.areLocalNotificationsUsed {
            completion?()
            return
        }
        var counter = 0
        for event in events {
            self.saveLocalNotificationForEventIfNeeded(event: event, completion: {
                counter += 1
                if counter == events.count {
                    completion?()
                }
            })
        }
        if events.isEmpty {
           completion?()
        }
    }
    
    func removeLocalNotificationsForEvents(events: [Event], completion: (() -> Void)?) {
        var counter = 0
        for event in events {
            self.removeOldLocalNotificationOfEvent(event, completion: {
                counter += 1
                if counter == events.count {
                    completion?()
                }
            })
        }
        if events.isEmpty {
            completion?()
        }
    }
    
    func saveLocalNotificationForEventIfNeeded(event: Event, completion: @escaping () -> Void) {
        RemindService.shared.removeOldLocalNotificationOfEvent(event, completion: {
            RemindService.shared.postNewLocalNotificationForEvent(event)
            completion()
        })
    }
    
    func postNewLocalNotificationForEvent(_ event: Event) {
        guard let fireDate = event.dateEnd else { return }
        if fireDate < Date().timestamp() { return }
        if !UserDefaultsManager.shared.areLocalNotificationsUsed { return }
        let localNotification = UILocalNotification()
        localNotification.fireDate = Date(timeIntervalSince1970: TimeInterval(fireDate)).addingTimeInterval(86400) // in 24 hours since event endDate.
        localNotification.alertBody = "We hope \(event.eventTitle) went well. Don’t forget to log your gifts!"
        localNotification.timeZone = TimeZone.autoupdatingCurrent
        var dict = [String:String]()
        dict["eventID"] = event.identifier
        dict["type"] = LocalNotificationType.event.rawValue
        localNotification.userInfo = dict
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.applicationIconBadgeNumber = 1
        UIApplication.shared.scheduleLocalNotification(localNotification)
        debugPrint("Local notification for event \(event.eventTitle) was saved.")
    }
    
    func removeOldLocalNotificationOfEvent(_ event: Event, completion: (() -> Void)? = nil) {
        let app:UIApplication = UIApplication.shared
        for oneEvent in app.scheduledLocalNotifications! {
            let notification = oneEvent as UILocalNotification
            if let userInfoCurrent = notification.userInfo as? [String:AnyObject] {
                if let type = userInfoCurrent["type"] as? String {
                    let typeEnum = LocalNotificationType(rawValue: type)!
                    if typeEnum == .event {
                        if let eventId = userInfoCurrent["eventID"] as? String {
                            if eventId == event.identifier {
                                app.cancelLocalNotification(notification)
                                debugPrint("Local notification for event \(event.eventTitle) was deleted.")
                                break
                            }
                        }
                    }
                }
            }
        }
        completion?()
    }
}
