//
//  SelectEventViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/28/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

protocol SelectEventViewControllerDelegate: class {
    func selectEventViewControllerDismissedWith(_ event: Event)
}

class SelectEventViewController: BaseViewController {

    
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var addView: UIView!
    
    
    // MARK: - Variables
    
    fileprivate var eventsToDisplay = [Event]() // events, that will be dispalayed to user after sort
    weak var delegate: SelectEventViewControllerDelegate?
    
    internal var prepopulatedGift: GiftPreload?
    internal var prepopulatedContact: ContactPreload?
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCancelButton()
        setTableView()
        setEvents()
        subscribeControllerForNotifications()
    }
    
    // MARK: - Methods
    
    func setCancelButton() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(self.cancelButtonTapped))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func cancelButtonTapped() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func setTableView() {
        tableView.tableFooterView = UIView.emptyView
        tableView.register(UINib(nibName: UniversalTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UniversalTableViewCellIdentifier)
    }

    func setEvents() {
        eventsToDisplay = UserEventsManager.shared.userEvents
        tableView.reloadData()
    }
    
    func subscribeControllerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.setEvents), name: NSNotification.Name(rawValue: NotificationCenterManager.NotificationNames.UserEventsWereUpdated), object: nil)
    }
    
    
    // MARK: - Actions
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let eventDetailViewController = EventDetailViewController(nibName: ViewControllerIdentifiers.EventDetailViewControllerID, bundle: nil)
        eventDetailViewController.event = Event()
        eventDetailViewController.mode = .new
        eventDetailViewController.delegate = self
        eventDetailViewController.prepopulatedGift = self.prepopulatedGift
        eventDetailViewController.prepopulatedContact = self.prepopulatedContact
        self.navigationController?.pushViewController(eventDetailViewController, animated: true)
    }
}


// MARK: Tableview DataSource and Delegate

extension SelectEventViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // default
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noResultsLabel.isHidden = !eventsToDisplay.isEmpty
        return eventsToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UniversalTableViewCellIdentifier, for: indexPath) as! UniversalTableViewCell
        cell.setEventContentFrom(eventsToDisplay[indexPath.row])
        cell.tintColor = Constants.appGreenColor
        cell.shareButton.isHidden = true // force hide
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = eventsToDisplay[indexPath.row]
        self.delegate?.selectEventViewControllerDismissedWith(event)
        /// GEC_Relationship Functional
        if let prepopulatedContact = self.prepopulatedContact {
            if EventService(event: event).getIndexOfContactAtArrayFrom(prepopulatedContact.identifier) == nil {
                event.contacts.append(prepopulatedContact)
            }
            HUDManager.showNetworkActivityIndicator()
            FirebaseManager.shared.saveOrUpdateEvent(event) { [unowned self] (success) in
                HUDManager.hideNetworkActivityIndicator()
                let _ = self.navigationController?.popViewController(animated: true)
            }
        } else {
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
}

extension SelectEventViewController: EventDetailViewControllerDelegate {
    func detailEventControllerDismissedWithEvent(_ event: Event) {
        self.delegate?.selectEventViewControllerDismissedWith(event)
        let _ = self.navigationController?.popViewController(animated: true)
    }
}
