//
//  ContactsViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/4/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class ContactsViewController: BaseRevealViewController {
    
    // MARK: Constraints
    
    @IBOutlet weak var bottomNavigationBarHeightConstraint: NSLayoutConstraint!
    
    // MARK: Views
    
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var bottomNavigationBar: BottomNavigationBar!
    
    // MARK: Vars
    
    var menuButton: UIBarButtonItem!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Contacts"
        SSHelperManager.shared.setEmptyBackNavigationButtonIn(self)
        bottomNavigationBar.setButtonsFromController(self)
        addSearchNavigationBarButton()
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadDataInController), name: NSNotification.Name(rawValue: NotificationCenterManager.NotificationNames.UserContactsWereUpdated), object: nil)
        self.reloadDataInController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func getMenuButton() -> UIBarButtonItem! {
        if menuButton == nil {
            setMenuButton()
        }
        return menuButton
    }
    
    // MARK: Custom methods
    
    func setTableView() {
        tableView.tableFooterView = UIView.emptyView
        tableView.register(UINib(nibName: UniversalTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UniversalTableViewCellIdentifier)
        tableView.reloadData()
    }
    
    func reloadDataInController() {
        tableView.reloadData()
    }
    
    func setAddView() {
        self.view.bringSubview(toFront: addView)
    }
    
    func setMenuButton() {
        menuButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = menuButton
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
            NavigationManager.shared.showDetailedContactViewControllerFrom(self, andWithMode: ControllerDetailPresentationMode.new)
        }
        actionSheetController.addAction(manuallyActionButton)
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = addButton
            popoverController.sourceRect = addButton.bounds
        }
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func deleteContactAtIndexPath(_ indexPath: IndexPath) {
        let contact = UserContactsManager.shared.userContacts[indexPath.row]
        HUDManager.showNetworkActivityIndicator()
        FirebaseManager.shared.deleteContactFromDatabase(contact) { (success) in
            HUDManager.hideNetworkActivityIndicator()
        }
    }
    
    func copyContactAtIndexPath(_ indexPath: IndexPath) {
        let contact = UserContactsManager.shared.userContacts[indexPath.row]
        let newContact = contact.copyContact()
        NavigationManager.shared.showDetailedContactViewControllerFrom(self, withContact: newContact, andWithMode: ControllerDetailPresentationMode.new)
    }
    
    // MARK: IBActions
    
    @IBAction func addButtonTapped(_ sender: Any) {
        showContactOptionActionSheet()
    }
}

// MARK: Tableview DataSource and Delegate

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate,UniversalTableViewCellDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // default
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noResultsLabel.isHidden = !UserContactsManager.shared.userContacts.isEmpty
        return UserContactsManager.shared.userContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UniversalTableViewCellIdentifier, for: indexPath) as! UniversalTableViewCell
        cell.delegate = self
        cell.ownDelegate = self
        cell.setContentFromUserContact(UserContactsManager.shared.userContacts[indexPath.row])
        cell.rightButtons = [MGSwipeService.deleteButton(), MGSwipeService.copyButton()]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NavigationManager.shared.showDetailedContactViewControllerFrom(self, withContact: UserContactsManager.shared.userContacts[indexPath.row], andWithMode: .old)
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        let action = SwipeTableViewCellAction(rawValue: index)
        if action == .delete {
            if let indexPath = self.tableView.indexPath(for: cell) {
                AlertManager.shared.showDeleteAlertViewFrom(self, deleteButtonTitle: "Delete contact", completion: { [unowned self] (buttonPressed) in
                    if buttonPressed == DeleteButtonPressed.delete {
                        self.deleteContactAtIndexPath(indexPath)
                    }
                })
            }
        } else if action == .copy {
            if let indexPath = self.tableView.indexPath(for: cell) {
                self.copyContactAtIndexPath(indexPath)
            }
        }
        return true
    }
    
    func shareButtonTappedFromCell(_ cell: UniversalTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            SSHelperManager.shared.showShareActionSheetFromController(self, withText: "Hi,\n\nCheck out GiftLog – it’s a great, free, gift management app I’m using to log gifts, send thank you messages and manage wish lists!\n\nRegards,\n\(UserManager.shared.currentUser.fullName)\n")
        }
    }
}
