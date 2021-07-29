//
//  SelectContactsViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/18/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

protocol SelectContactsViewControllerDelegate: class {
    func selectContactsViewControllerDismissedWith(_ contacts: [Contact])
}

class SelectContactsViewController: BaseViewController {

    // MARK: IBOutles
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: Variables
    
    internal var contactsAddedBefore: [Contact]! // contacts, that were already added to Event of Gift before
    fileprivate var contactsToDisplay = [Contact]() // contacts, that will be dispalayed to user after sort
    weak var delegate: SelectContactsViewControllerDelegate?
    
    internal var prepopulatedGift: GiftPreload?
    internal var prepopulatedEvent: EventPreload?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDoneButton()
        setCancelButton()
        setTableView()
        setContacts()
        subscribeControllerForNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func subscribeControllerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.setContacts), name: NSNotification.Name(rawValue: NotificationCenterManager.NotificationNames.UserContactsWereUpdated), object: nil)
    }
    
    func setContacts() {
        let contactsToFilter = UserContactsManager.shared.userContacts
        contactsToDisplay.removeAll()
        for contact in contactsToFilter {
            if !UserContactsManager.shared.isContactAlreadyAddedToEvent(contactsAddedBefore, contact: contact) {
                contactsToDisplay.append(contact)
            }
        }
        tableView.reloadData()
    }
    
    func setTableView() {
        tableView.tableFooterView = UIView.emptyView
        tableView.register(UINib(nibName: UniversalTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UniversalTableViewCellIdentifier)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: true)
        tableView.allowsSelection = false
    }
    
    func setDoneButton() {
        let doneBarItem = UIBarButtonItem(image: UIImage(named: "save"), style: .plain, target: self, action: #selector(self.doneButtonTapped))
        self.navigationItem.rightBarButtonItem = doneBarItem
    }
    
    func setCancelButton() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(self.cancelButtonTapped))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func contactFromIndexPath(_ indexPath: IndexPath) -> Contact {
        return contactsToDisplay[indexPath.row]
    }
    
    func showContactOptionActionSheet() {
        let actionSheetController = UIAlertController(title: "Add manually or import from phonebook", message: "Option to select", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelActionButton)
        
        let fromPhoneActionButton = UIAlertAction(title: "Add contact from phone", style: .default) { action -> Void in
            NavigationManager.shared.presentPhoneBookViewControllerFromController(self)
        }
        actionSheetController.addAction(fromPhoneActionButton)
        
        let manuallyActionButton = UIAlertAction(title: "Add contact manually", style: .default) { action -> Void in
            let detailedContactViewController = DetailedContactViewController(nibName: ViewControllerIdentifiers.DetailedContactViewControllerID, bundle: nil)
            detailedContactViewController.contact = Contact()
            detailedContactViewController.mode = .new
            detailedContactViewController.delegate = self
            detailedContactViewController.prepopulatedGift = self.prepopulatedGift
            detailedContactViewController.prepopulatedEvent = self.prepopulatedEvent
            self.navigationController?.pushViewController(detailedContactViewController, animated: true)
        }
        actionSheetController.addAction(manuallyActionButton)
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = addButton
            popoverController.sourceRect = addButton.bounds
        }
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    // MARK: BarItem Actions
    
    func doneButtonTapped() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows, !selectedIndexPaths.isEmpty {
            var selectedContacts = [Contact]()
            for contact in contactsAddedBefore {
                selectedContacts.append(contact)
            }
            for indexPath in selectedIndexPaths {
                selectedContacts.append(self.contactFromIndexPath(indexPath))
            }
            self.delegate?.selectContactsViewControllerDismissedWith(selectedContacts)
            if let event = self.prepopulatedEvent {
                for contact in selectedContacts {
                    let contactPreload = ContactPreload()
                    contactPreload.model = contact
                    contactPreload.identifier = contact.identifier
                    NotificationCenterManager.postNotificationThatContact(contactPreload, wasCreatedForEventWithIdentifier: event.identifier)
                }
            }
            let _ = self.navigationController?.popViewController(animated: true)
        } else {
            UIAlertController.showAlertWithTitle("", message: "You didn't select any contact")
        }
    }
    
    func cancelButtonTapped() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: IBActions
    
    @IBAction func addButtonTapped(_ sender: Any) {
        showContactOptionActionSheet()
    }
    
}

// MARK: Tableview DataSource and Delegate

extension SelectContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // default
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noResultsLabel.isHidden = !contactsToDisplay.isEmpty
        return contactsToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UniversalTableViewCellIdentifier, for: indexPath) as! UniversalTableViewCell
        cell.setContentFromUserContact(contactsToDisplay[indexPath.row])
        cell.selectionStyle = UITableViewCellSelectionStyle.gray
        cell.tintColor = Constants.appGreenColor
        cell.shareButton.isHidden = true // force hide
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            return
        }
    }
}

extension SelectContactsViewController: DetailedContactViewControllerDelegate {
    func detailContactControllerDismissedWithContact(_ contact: Contact) {
        var selectedContacts = [Contact]()
        for contact in contactsAddedBefore {
            selectedContacts.append(contact)
        }
        selectedContacts.append(contact)
        self.delegate?.selectContactsViewControllerDismissedWith(selectedContacts)
        let _ = self.navigationController?.popViewController(animated: true)
    }
}
