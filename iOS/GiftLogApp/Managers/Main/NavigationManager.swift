//
//  PFNavigationManager.swift
//
//
//  Created by Webs The Word on 10/28/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation
import UIKit
import SWRevealViewController

//MARK: Identifiers of viewControllers from storyboard

struct ViewControllerIdentifiers {
    static let SWRevealViewControllerID = "SWRevealViewController"
    static let LoginViewControllerID = "LoginViewController"
    static let SignUpViewControllerID = "SignUpViewController"
    static let ForgotPasswordViewControllerID = "ForgotPasswordViewController"
    static let GiftsViewControllerID = "GiftsViewController"
    static let EventsViewControllerID = "EventsViewController"
    static let ContactsViewControllerID = "ContactsViewController"
    static let PhoneBookViewControllerID = "PhoneBookViewController"
    static let DetailedContactViewControllerID = "DetailedContactViewController"
    static let EventDetailViewControllerID = "EventDetailViewController"
    static let GiftDetailViewControllerID = "GiftDetailViewController"
    static let SelectContactsViewControllerID = "SelectContactsViewController"
    static let UserDetailViewControllerID = "UserDetailViewController"
    static let ValuePickerViewControllerID = "ValuePickerViewController"
    static let SelectEventViewControllerID = "SelectEventViewController"
    static let SelectGiftsViewControllerID = "SelectGiftsViewController"
    static let TutorialViewControllerID = "TutorialViewController"
    static let GiftIdeasViewControllerID = "GiftIdeasViewController"
    static let DocumentViewControllerID = "DocumentViewController"
    static let SearchViewControllerID = "SearchViewController"
}

class NavigationManager: NSObject {
    
    //MARK: Vars
    
    static let shared = NavigationManager()
    
    private var storyboard:UIStoryboard {
        get {
            return UIStoryboard(name: "Main", bundle: nil)
        }
    }
    
    private var window:UIWindow {
        get {
            return UIApplication.shared.delegate!.window!!
        }
    }
    
    internal var rootViewController:UIViewController {
        get {
            return window.rootViewController!
        }
    }
    
    //MARK: Helper methods
    
    func viewControllerFromIdentifier(_ identifier:String) -> UIViewController {
        return storyboard.instantiateViewController(withIdentifier: identifier) as UIViewController
    }
    
    func showRootViewControllerFromController(_ controller:UIViewController) {
        if window.rootViewController != nil {
            window.rootViewController?.dismiss(animated: false, completion: nil)
        }
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
    
    func showSystemPreferencesScreen() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    // MARK: Navigation methods
    
    func showTutorialViewController() {
        let tutorialViewController = TutorialViewController(nibName: ViewControllerIdentifiers.TutorialViewControllerID, bundle: nil)
        showRootViewControllerFromController(tutorialViewController)
    }
    
    func showLoginViewController() {
        let loginViewController = viewControllerFromIdentifier(ViewControllerIdentifiers.LoginViewControllerID)
        let navigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.isNavigationBarHidden = true
        showRootViewControllerFromController(navigationController)
    }
    
    func showSignUpViewControllerFromController(_ controller: UIViewController) {
        let signUpViewController = viewControllerFromIdentifier(ViewControllerIdentifiers.SignUpViewControllerID)
        controller.navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
    func showForgotPasswordViewControllerFromController(_ controller: UIViewController) {
        let forgotPasswordViewController = viewControllerFromIdentifier(ViewControllerIdentifiers.ForgotPasswordViewControllerID)
        controller.navigationController?.pushViewController(forgotPasswordViewController, animated: true)
    }
    
    func showSearchViewControllerFromController(_ controller: UIViewController) {
        let searchViewController = SearchViewController(nibName: ViewControllerIdentifiers.SearchViewControllerID, bundle: nil)
        controller.navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    func showDetailedContactViewControllerFrom(_ controller: UIViewController, withContact contact: Contact? = nil, andWithMode mode: ControllerDetailPresentationMode, prepopulatedGift: GiftPreload? = nil, prepopulatedEvent: EventPreload? = nil) {
        let detailedContactViewController = DetailedContactViewController(nibName: ViewControllerIdentifiers.DetailedContactViewControllerID, bundle: nil)
        if let contact = contact {
            detailedContactViewController.contact = contact
        } else {
            let newContact = Contact()
            detailedContactViewController.contact = newContact
        }
        detailedContactViewController.mode = mode
        detailedContactViewController.prepopulatedEvent = prepopulatedEvent
        detailedContactViewController.prepopulatedGift = prepopulatedGift
        controller.navigationController?.pushViewController(detailedContactViewController, animated: true)
    }
  
    func showEventDetailViewControllerFrom(_ controller: UIViewController, withEvent event: Event? = nil, andWithMode mode: ControllerDetailPresentationMode, prepopulatedGift: GiftPreload? = nil, prepopulatedContact: ContactPreload? = nil) {
      let eventDetailViewController = EventDetailViewController(nibName: ViewControllerIdentifiers.EventDetailViewControllerID, bundle: nil)
      if let event = event {
          eventDetailViewController.event = event
      } else {
          let newEvent = Event()
          eventDetailViewController.event = newEvent
      }
      eventDetailViewController.mode = mode
      eventDetailViewController.prepopulatedContact = prepopulatedContact
      eventDetailViewController.prepopulatedGift = prepopulatedGift
      controller.navigationController?.pushViewController(eventDetailViewController, animated: true)
  }
    
    func showGiftDetailViewControllerFrom(_ controller: UIViewController, withGift gift: Gift? = nil, andWithMode mode: ControllerDetailPresentationMode, prepopulatedEvent: EventPreload? = nil, prepopulatedContact: ContactPreload? = nil) {
        let giftDetailViewController = GiftDetailViewController(nibName: ViewControllerIdentifiers.GiftDetailViewControllerID, bundle: nil)
        if let gift = gift {
            giftDetailViewController.gift = gift
        } else {
            let newGift = Gift()
            giftDetailViewController.gift = newGift
        }
        giftDetailViewController.mode = mode
        giftDetailViewController.prepopulatedEvent = prepopulatedEvent
        giftDetailViewController.prepopulatedContact = prepopulatedContact
        controller.navigationController?.pushViewController(giftDetailViewController, animated: true)
    }
  
    func presentUserDetailViewControllerFrom(_ controller: UIViewController, withUser user: User? = nil, andWithMode mode: UserDetailViewController.Mode) {
        let userDetailViewController = UserDetailViewController(nibName: ViewControllerIdentifiers.UserDetailViewControllerID, bundle: nil)
        let navigationController = BaseNavigationController(rootViewController: userDetailViewController)
        
        if let user = user {
            userDetailViewController.user = user
        } else {
            //TODO: How will it be?
//            let newUser = User()
//            userDetailViewController.user = newUser
        }
        userDetailViewController.mode = mode
        
        controller.present(navigationController, animated: true, completion: nil)
    }
    
    func showMenuViewController() {
        let revealViewController = viewControllerFromIdentifier(ViewControllerIdentifiers.SWRevealViewControllerID) as! SWRevealViewController
        let frontViewController = GiftsViewController(nibName: ViewControllerIdentifiers.GiftsViewControllerID, bundle: nil)
        let navigationController = BaseNavigationController(rootViewController: frontViewController)
        navigationController.setViewControllers([frontViewController], animated: true)
        revealViewController.setFront(navigationController, animated: true)
        revealViewController.setFrontViewPosition(.left, animated: true)
        showRootViewControllerFromController(revealViewController)
    }
    
    func presentPhoneBookViewControllerFromController(_ controller: UIViewController) {
        let phoneBookViewController = PhoneBookViewController(nibName: ViewControllerIdentifiers.PhoneBookViewControllerID, bundle: nil)
        let navigationController = BaseNavigationController(rootViewController: phoneBookViewController)
        controller.present(navigationController, animated: true, completion: nil)
    }
    
    func presentDocumentsViewControllerFromController(_ controller: UIViewController, withMode mode: DocumentViewController.Mode) {
        let documentsViewController = DocumentViewController(nibName: ViewControllerIdentifiers.DocumentViewControllerID, bundle: nil)
        documentsViewController.mode = mode
        let navigationController = BaseNavigationController(rootViewController: documentsViewController)
        controller.present(navigationController, animated: true, completion: nil)
    }
    
    func showMenuFrontViewControllerFromController(_ controller: UIViewController, menuAction: MenuAction) {
        if let revealViewController = controller.revealViewController() {
            var rootViewController: UIViewController!
            switch menuAction {
            case .openGifts:
                rootViewController = GiftsViewController(nibName: ViewControllerIdentifiers.GiftsViewControllerID, bundle: nil)
            case .openEvents:
                rootViewController = EventsViewController(nibName: ViewControllerIdentifiers.EventsViewControllerID, bundle: nil)
            case .openContacts:
                rootViewController = ContactsViewController(nibName: ViewControllerIdentifiers.ContactsViewControllerID, bundle: nil)
            case .openGiftIdeas:
                rootViewController = GiftIdeasViewController(nibName: ViewControllerIdentifiers.GiftIdeasViewControllerID, bundle: nil)
            default:
                return
            }
            MenuService.shared.selectedMenuActionIndexPath = IndexPath(row: menuAction.rawValue, section: 0)
            let navigationController = BaseNavigationController(rootViewController: rootViewController)
            navigationController.setViewControllers([rootViewController], animated: true)
            revealViewController.setFront(navigationController, animated: true)
            revealViewController.setFrontViewPosition(.left, animated: true)
        }
    }
    
}
