//
//  SearchViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 5/17/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class SearchViewController: BaseViewController {
    
    
    //MARK: - Enums

    enum Section: Int {
        
        // MARK: Cases
        case gifts = 0
        case events = 1
        case contacts = 2
        
        // MARK: Properties
        
        static let allValues = [gifts, events, contacts]
        
        var description: String {
            switch self {
            case .gifts: return "GIFTS"
            case .events: return "EVENTS"
            case .contacts: return "CONTACTS"
            }
        }
    }
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: STCollapseTableView!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var searchBarContainer: UIView!
    
    
    //MARK: - Variables
    
    var gifts = [Gift]()
    var filteredGifts = [Gift]()
    var events = [Event]()
    var filteredEvents = [Event]()
    var contacts = [Contact]()
    var filteredContacts = [Contact]()
    let searchController = UISearchController(searchResultsController: nil)
    var searchIsActive = false
    fileprivate var headers = [UniversalTableHeaderView]()
    
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search"
        setTableView()
        setSearchController()
        setNavigationBarItems()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribeViewControllerForNotifications()
        setData()
        filterContentForSearchText(searchText: searchController.searchBar.text ?? "")
    }
    
    deinit {
        self.tableView.delegate = nil
    }
    
    
    //MARK: - Methods
    
    func setTableView() {
        tableView.estimatedRowHeight = 44.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.tableFooterView = UIView.emptyView
        tableView.register(UINib(nibName: UniversalDetailTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UniversalDetailTableViewCellIdentifier)
        tableView.exclusiveSections = false // all section can be opened at once
        tableViewOpenSections()
        tableView.reloadData()
    }
    
    func setSearchController() {
        
        // Search bar setup
        UISearchBar.appearance().barTintColor = UIColor.appGreyColor
        UISearchBar.appearance().tintColor = UIColor.appBlueColor
        UISearchBar.appearance().backgroundColor = UIColor.appGreyColor
        UISearchBar.appearance().textColor = UIColor.appBlueColor
        
        // Search controller setup
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = false
        searchController.searchBar.backgroundImage = UIImage()
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
//        automaticallyAdjustsScrollViewInsets = false
        self.searchBarContainer.addSubview(searchController.searchBar)
    }
    
    func setData() {
        gifts = UserGiftsManager.shared.userGifts
        events = UserEventsManager.shared.userEvents
        contacts = UserContactsManager.shared.userContacts
    }
    
    func subscribeViewControllerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateViewHeadersFromNotification(_:)), name: NSNotification.Name(rawValue: "TableViewWasCollapsed"), object: nil)
    }
    
    func updateViewHeadersFromNotification(_ notification: Notification?) {
        if !headers.isEmpty {
            for header in headers {
                header.setArrowImageViewFromState((tableView as STCollapseTableView).isOpenSection(UInt(header.tag)))
            }
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "Name") {
        filteredGifts = gifts.filter({( gift : Gift) -> Bool in
        return gift.name.lowercased().contains(searchText.lowercased())
        })
        self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
        filteredEvents = events.filter({( event : Event) -> Bool in
            return event.eventTitle.lowercased().contains(searchText.lowercased())
        })
        self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
        filteredContacts = contacts.filter({( contact : Contact) -> Bool in
            return contact.fullName.lowercased().contains(searchText.lowercased())
        })
        self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
        resultsLabel.text = "\(filteredGifts.count + filteredEvents.count + filteredContacts.count) results found"
    }
    
    func reloadTableViewSections() {
        self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
        self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
        self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
    }
    
    func setNavigationBarItems() {
        let backButton: UIButton = UIButton.init(type: .custom)
        backButton.addTarget(self, action: #selector(self.backButtonTapped), for: .touchUpInside)
        backButton.setImage(UIImage(named: "backGreen"), for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.sizeToFit()
        let backBarItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarItem
    }
    
    func backButtonTapped() {
        if searchController.isActive {
            dismissSearchController {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tableViewOpenSections() {
        tableView.openSection(0, animated: true)
        tableView.openSection(1, animated: true)
        tableView.openSection(2, animated: true)
    }
}


// MARK: - Tableview DataSource and Delegate

extension SearchViewController: UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allValues.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.universalSectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case Section.gifts:
            return filteredGifts.count
        case Section.events:
            return filteredEvents.count
        case Section.contacts:
            return filteredContacts.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var universalTableHeaderView = UniversalTableHeaderView.instanceFromNib()
        if let header = (headers.filter { $0.tag == section }).first {
            universalTableHeaderView = header
        } else {
            universalTableHeaderView = UniversalTableHeaderView.instanceFromNib()
            universalTableHeaderView.tag = section
            headers.append(universalTableHeaderView)
            updateViewHeadersFromNotification(nil)
        }
        switch section {
        case 0:
            universalTableHeaderView.mainTitleLabel.text = "GIFTS"
            universalTableHeaderView.iconImageView.image = UIImage(named: "giftInfoSection")
            universalTableHeaderView.backgroundColor = Constants.appVioletColor
        case 1:
            universalTableHeaderView.mainTitleLabel.text = "EVENTS"
            universalTableHeaderView.iconImageView.image = UIImage(named: "calendar")
            universalTableHeaderView.backgroundColor = Constants.appPurpleColor
        case 2:
            universalTableHeaderView.mainTitleLabel.text = "CONTACTS"
            universalTableHeaderView.iconImageView.image = UIImage(named: "contactInfoSection")
            universalTableHeaderView.backgroundColor = Constants.appBlueColor
        default:
            break
        }
        return universalTableHeaderView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UniversalDetailTableViewCellIdentifier, for: indexPath) as! UniversalDetailTableViewCell
        switch Section(rawValue: indexPath.section)! {
        case Section.gifts:
            cell.delegate = self
            cell.setGiftContentFrom(filteredGifts[indexPath.row])
            cell.shareButton.isHidden = true // force hide
            if indexPath.row == filteredGifts.count - 1 { // Hidding last green line
                cell.lineView.isHidden = true
            } else {
                cell.lineView.isHidden = false
            }
                return cell
        case Section.events:
            cell.delegate = self
            cell.setEventContentFrom(filteredEvents[indexPath.row])
            cell.shareButton.isHidden = true // force hide
            if indexPath.row == filteredEvents.count - 1 { // Hidding last green line
                cell.lineView.isHidden = true
            } else {
                cell.lineView.isHidden = false
            }
            return cell
        case Section.contacts:
            cell.delegate = self
            cell.setContentFromUserContact(filteredContacts[indexPath.row])
            cell.shareButton.isHidden = true // force hide
            if indexPath.row == filteredContacts.count - 1 { // Hidding last green line
                cell.lineView.isHidden = true
            } else {
                cell.lineView.isHidden = false
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissSearchController { [unowned self] in
            switch Section(rawValue: indexPath.section)! {
            case Section.gifts:
                NavigationManager.shared.showGiftDetailViewControllerFrom(self, withGift: self.filteredGifts[indexPath.row], andWithMode: ControllerDetailPresentationMode.old)
            case Section.events:
                NavigationManager.shared.showEventDetailViewControllerFrom(self, withEvent: self.filteredEvents[indexPath.row], andWithMode: ControllerDetailPresentationMode.old)
            case Section.contacts:
                NavigationManager.shared.showDetailedContactViewControllerFrom(self, withContact: self.filteredContacts[indexPath.row], andWithMode: .old)
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!, scope: "Name")
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let scope = "Name"
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchIsActive = true
        tableViewOpenSections()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchIsActive = false
    }
    
    func dismissSearchController(completion: @escaping () -> Void) {
        if searchController.isActive {
            searchController.dismiss(animated: true, completion: {
                self.searchIsActive = false
                completion()
            })
        } else {
            completion()
        }
    }
}

extension UISearchBar {
    var textColor: UIColor? {
        get {
            if let textField = self.value(forKey: "searchField") as? UITextField  {
                return textField.textColor
            } else {
                return nil
            }
        }
        
        set (newValue) {
            if let textField = self.value(forKey: "searchField") as? UITextField  {
                textField.textColor = newValue
            }
        }
    }
}
