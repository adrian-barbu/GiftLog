//
//  PhoneBookViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/10/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit
import APAddressBook

class PhoneBookViewController: BaseViewController {

    // MARK: Views
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultsLabel: UILabel!
    
    // MARK: Vars
    
    fileprivate var contacts = [APContact]()
    fileprivate var filteredContacts = [APContact]()
    fileprivate var selectedContacts = [APContact]()
    fileprivate var searchController = UISearchController(searchResultsController: nil)
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add contact"
        setTableView()
        setDoneButton()
        setCancelButton()
        loadUserPhonebookContacts()
    }
    
    // MARK: Custom methods
    
    func loadUserPhonebookContacts() {
        ContactsManager.getContactsFromPhonebookWithCompletion { [weak self] (fetchedContacts) in
            if let strongSelf = self {
                if let fetchedContacts = fetchedContacts {
                    strongSelf.contacts = fetchedContacts
                    strongSelf.noResultsLabel.isHidden = !fetchedContacts.isEmpty
                    strongSelf.tableView.reloadData()
                } else {
                    AlertManager.shared.showPrivacyAlertViewFromController(self, title: "It seems, that you denied access to contacts for this application.", message: "Please open Settings to enable access for your phonebook.", completion: { (buttonPressed) in
                        if buttonPressed == AlertButtonPressed.cancel {
                            self?.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            }
        }
    }
    
    func setTableView() {
        tableView.tableFooterView = UIView.emptyView
        tableView.register(UINib(nibName: UniversalTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UniversalTableViewCellIdentifier)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: true)
        tableView.allowsSelection = false
        tableView.reloadData()
        setSearchController()
    }
    
    func setSearchController() {
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = Constants.appGreenColor
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.layer.borderColor = Constants.appGreenColor.cgColor
        //self.definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func setDoneButton() {
        let doneBarItem = UIBarButtonItem(image: UIImage(named: "save"), style: .plain, target: self, action: #selector(self.doneButtonTapped))
        self.navigationItem.rightBarButtonItem = doneBarItem
    }
    
    func setCancelButton() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(self.cancelButtonTapped))
        self.navigationItem.leftBarButtonItem = cancelButton
    }

    func contactFromIndexPath(_ indexPath: IndexPath) -> APContact {
        var contact: APContact!
        if searchController.isActive && searchController.searchBar.text != "" {
            contact = filteredContacts[indexPath.row]
        } else {
            contact = contacts[indexPath.row]
        }
        return contact
    }
    
    func addContactToListOfSelectedContacts(_ contact: APContact) {
        if let _ = selectedContacts.index(of: contact) {
            return
        }
        selectedContacts.append(contact)
    }
    
    func removeContactFromListOfSelectedContacts(_ contact: APContact) {
        if let index = selectedContacts.index(of: contact) {
            selectedContacts.remove(at: index)
        }
    }
    
    func isContactSelected(_ contact: APContact) -> Bool {
        if let _ = selectedContacts.index(of: contact) {
            return true
        }
        return false
    }
    
    func saveAvatarsIfNeededForSelectedContacts(_ contacts: [Contact], completion: @escaping () -> Void) {
        var counter = 0
        for contact in contacts {
            if let data = contact.thumbDataToUpload {
                FirebaseManager.shared.uploadContactAvatarImage(data, forContact: contact, completion: { (url) in
                    if let url = url {
                        contact.thumbDataToUpload = nil
                        contact.avatar = url
                    }
                    counter += 1
                    if counter == contacts.count {
                        completion()
                    }
                })
            } else {
                counter += 1
                if counter == contacts.count {
                    completion()
                }
            }
        }
    }
    
    func saveContactsFromPhoneBook(_ contacts: [Contact], completion: @escaping () -> Void) {
        var counter = 0
        for contact in contacts {
            FirebaseManager.shared.saveOrUpdateContact(contact, completion: { (success) in
                if success {
                    debugPrint("Contact \(contact.fullName) was saved to firebase.")
                }
                counter += 1
                if counter == contacts.count {
                    completion()
                }
            })
        }
    }
    
    // MARK: BarItem Actions
    
    func doneButtonTapped() { // save selected contacts from phonebook
        if !self.selectedContacts.isEmpty {
            HUDManager.showLoadingHUD()
            var contactsForSave = [Contact]()
            for phonebookContact in selectedContacts {
                contactsForSave.append(Contact(phonebookContact: phonebookContact))
            }
            saveAvatarsIfNeededForSelectedContacts(contactsForSave, completion: { [unowned self] in
                self.saveContactsFromPhoneBook(contactsForSave, completion: { [unowned self] in
                    HUDManager.showSuccessHUD()
                    self.searchController.isActive = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            })
        } else {
            UIAlertController.showAlertWithTitle("", message: "You didn't select any contact")
        }
    }
    
    func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: Tableview DataSource and Delegate

extension PhoneBookViewController: UITableViewDataSource ,UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredContacts.count
        }
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UniversalTableViewCellIdentifier, for: indexPath) as! UniversalTableViewCell
        cell.setContentFromPhoneBookContact(contactFromIndexPath(indexPath))
        cell.selectionStyle = UITableViewCellSelectionStyle.gray
        cell.tintColor = Constants.appGreenColor
        if isContactSelected(contactFromIndexPath(indexPath)) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addContactToListOfSelectedContacts(contactFromIndexPath(indexPath))
        
        if tableView.isEditing {
            return
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        removeContactFromListOfSelectedContacts(contactFromIndexPath(indexPath))
    }
}

extension PhoneBookViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchController.isActive {
            dismissSearchController()
        }
    }
    
    func dismissSearchController() {
        self.tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContacts = contacts.filter { contact in
            return (contact.name?.firstName ?? "").contains(searchController.searchBar.text!)
        }
        tableView.reloadData()
    }
}

