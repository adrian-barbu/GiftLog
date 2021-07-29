//
//  EventsViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/30/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit
import HMSegmentedControl
import MGSwipeTableCell

class EventsViewController: BaseRevealViewController {
  
  enum SortingType: String {
    case alphabet = "A to Z"
    case oppositeAlphabet = "Z to A"
    case newest = "Newest"
    case oldest = "Oldest"
  }
    
    
  //MARK: - Outlets
  
  @IBOutlet weak var segmentedControl: HMSegmentedControl!
  @IBOutlet weak var sortButton: UIButton!
  @IBOutlet weak var sortButtonImageView: UIImageView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var noResultsLabel: UILabel!
  @IBOutlet weak var bottomNavigationBar: BottomNavigationBar!
  
  
  //MARK: - Constants
    
  let sortRegularTitle = "Sort by "
    
    
  //MARK: - Variables
  
  var menuButton: UIBarButtonItem!
  var sortedEventsArray: [Event] = []
  var sortedIndex: Int?
  var eventTypeIndex: Int?
    
    
  //MARK: - Lifecycle methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Events"
    SSHelperManager.shared.setEmptyBackNavigationButtonIn(self)
    setCustomSegmentedControl()
    bottomNavigationBar.setButtonsFromController(self)
    addSearchNavigationBarButton()
    self.setSortButton("", with: self.sortRegularTitle)
    setTableView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(self.reloadDataInController), name: NSNotification.Name(rawValue: NotificationCenterManager.NotificationNames.UserEventsWereUpdated), object: nil)
    self.reloadDataInController()
  }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
  //MARK: - Functions
  
  override func getMenuButton() -> UIBarButtonItem! {
    if menuButton == nil {
      setMenuButton()
    }
    return menuButton
  }
    
  func setMenuButton() {
    menuButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: nil)
    self.navigationItem.leftBarButtonItem = menuButton
  }
  
  func setCustomSegmentedControl() {
    segmentedControl.sectionTitles = ["ALL", "ATTENDED", "HOSTED"]
    segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : Constants.appGreenColor, NSFontAttributeName: UIFont.systemFont(ofSize: 15.0)]
    segmentedControl.autoresizingMask = [UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleWidth]
    segmentedControl.selectionIndicatorHeight = 2.0
    segmentedControl.selectionIndicatorColor = Constants.appVioletColor
    segmentedControl.backgroundColor = Constants.appGreyColor
    segmentedControl.selectionIndicatorLocation = .down
    segmentedControl.selectionStyle = .fullWidthStripe
    segmentedControl.addTarget(self, action: #selector(self.segmentedControlChangedValue(_:)), for: .valueChanged)
  }
  
  func setSortButton(_ string: String, with regular: String) {
    sortButton.setAttributedTitle(SSHelperManager.shared.getBoldAttributedStringFromString(regular, stringToMakeBold: string, color: .lightGray, fontSize: 12.0), for: .normal)
  }
  
  func setTableView() {
    tableView.tableFooterView = UIView.emptyView
    tableView.tableFooterView?.backgroundColor = Constants.appGreyColor
    tableView.register(UINib(nibName: UniversalTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UniversalTableViewCellIdentifier)
  }
  
    func reloadDataInController() {
        eventTypeIndex = segmentedControl.selectedSegmentIndex
        self.setSortedEventsArray()
    }
    
  func deleteEventAtIndexPath(_ indexPath: IndexPath) {
        let event = sortedEventsArray[indexPath.row]
        HUDManager.showNetworkActivityIndicator()
        FirebaseManager.shared.deleteEventFromDatabase(event) { (success) in
            RemindService.shared.removeOldLocalNotificationOfEvent(event, completion: {
                HUDManager.hideNetworkActivityIndicator()
            })
        }
    
  }
    
  func copyEventAtIndexPath(_ indexPath: IndexPath) {
    let event = sortedEventsArray[indexPath.row]
    let newEvent = event.copyEvent()
    NavigationManager.shared.showEventDetailViewControllerFrom(self, withEvent: newEvent, andWithMode: ControllerDetailPresentationMode.new)
  }
    
  func showEventOptionActionSheet() {
    let actionSheetController = UIAlertController(title: "Sort", message: "Option to select", preferredStyle: .actionSheet)
    let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
    }
    actionSheetController.addAction(cancelActionButton)
    let alphabetSorting = UIAlertAction(title: SortingType.alphabet.rawValue, style: .default) { action -> Void in
        self.sortedIndex = 0
        self.setSortedEventsArray()
    }
    actionSheetController.addAction(alphabetSorting)
    let oppositeAlphabetSorting = UIAlertAction(title: SortingType.oppositeAlphabet.rawValue, style: .default) { action -> Void in
        self.sortedIndex = 1
        self.setSortedEventsArray()
    }
    actionSheetController.addAction(oppositeAlphabetSorting)
    let newestSorting = UIAlertAction(title: SortingType.newest.rawValue, style: .default) { action -> Void in
        self.sortedIndex = 2
        self.setSortedEventsArray()
    }
    actionSheetController.addAction(newestSorting)
    let oldest = UIAlertAction(title: SortingType.oldest.rawValue, style: .default) { action -> Void in
        self.sortedIndex = 3
        self.setSortedEventsArray()
    }
    actionSheetController.addAction(oldest)
    let noneSorting = UIAlertAction(title: "None", style: .default) { action -> Void in
        self.sortedIndex = nil
        self.setSortedEventsArray()
        self.setSortButton("", with: self.sortRegularTitle)
    }
    actionSheetController.addAction(noneSorting)
    if let popoverController = actionSheetController.popoverPresentationController {
        popoverController.sourceView = sortButton
        popoverController.sourceRect = sortButton.bounds
    }
    self.present(actionSheetController, animated: true, completion: nil)
    }
    
  func hostingTypeSorting(_ sortIndex: Int) {
    if sortIndex != 0 {
      var tempEventArray: [Event] = []
//      setSortedEventsArray()
      for item in sortedEventsArray {
        if item.hostingType.rawValue == sortIndex-1 {
          tempEventArray.append(item)
        }
      }
      sortedEventsArray = tempEventArray
    } else {
//        setSortedEventsArray()
    }
    tableView.reloadData()
  }
    
    func setSortedEventsArray() { // Uses to sort all gifts. Depends on segmented value.
        sortedEventsArray = UserEventsManager.shared.userEvents
    
        if eventTypeIndex != nil {
            hostingTypeSorting(eventTypeIndex!)
        }
        if sortedIndex != nil {
            eventSorting(sortedIndex!)
        }
    }
    
    func eventSorting(_ sortIndex: Int) {
        //        setSortedGiftsArray()
        switch sortIndex {
        case 0: // A -> Z
            self.sortedEventsArray = self.sortedEventsArray.sorted(by: { $0.eventTitle < $1.eventTitle })
            self.setSortButton(SortingType.alphabet.rawValue, with: self.sortRegularTitle)
        case 1: // Z <- A
            self.sortedEventsArray = self.sortedEventsArray.sorted(by: { $0.eventTitle > $1.eventTitle })
            self.setSortButton(SortingType.oppositeAlphabet.rawValue, with: self.sortRegularTitle)
        case 2: // newest first
            self.sortedEventsArray = self.sortedEventsArray.sorted(by: { $0.dateStart ?? Date().timestamp() > $1.dateStart ?? Date().timestamp() })
            self.setSortButton(SortingType.newest.rawValue, with: self.sortRegularTitle)
        case 3: // oldest first
            self.sortedEventsArray = self.sortedEventsArray.sorted(by: { $0.dateStart ?? Date().timestamp() < $1.dateStart ?? Date().timestamp() })
            self.setSortButton(SortingType.oldest.rawValue, with: self.sortRegularTitle)
        default:
            break
        }
        
        self.tableView.reloadData()
    }
    
  //MARK: - Actions
  
  @IBAction func segmentedControlChangedValue(_ sender: HMSegmentedControl) {
    eventTypeIndex = segmentedControl.selectedSegmentIndex
    self.setSortedEventsArray()
  }
    
  @IBAction func sortButtonDidTouch(_ sender: Any) {
    showEventOptionActionSheet()
  }
    
  @IBAction func addButtonTapped(_ sender: Any) {
    NavigationManager.shared.showEventDetailViewControllerFrom(self, andWithMode: ControllerDetailPresentationMode.new)
  }
}

// MARK: - TableView DataSource and Delegate

extension EventsViewController: UITableViewDataSource ,UITableViewDelegate, MGSwipeTableCellDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    noResultsLabel.isHidden = !sortedEventsArray.isEmpty
    return sortedEventsArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: UniversalTableViewCellIdentifier, for: indexPath) as! UniversalTableViewCell
    cell.delegate = self
    cell.setEventContentFrom(sortedEventsArray[indexPath.row])
    cell.rightButtons = [MGSwipeService.deleteButton(), MGSwipeService.copyButton()]
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    NavigationManager.shared.showEventDetailViewControllerFrom(self, withEvent: sortedEventsArray[indexPath.row], andWithMode: ControllerDetailPresentationMode.old)
  }
    
  func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        let action = SwipeTableViewCellAction(rawValue: index)
        if action == .delete {
            if let indexPath = self.tableView.indexPath(for: cell) {
                AlertManager.shared.showDeleteAlertViewFrom(self, deleteButtonTitle: "Delete event", completion: { [unowned self] (buttonPressed) in
                    if buttonPressed == DeleteButtonPressed.delete {
                        self.deleteEventAtIndexPath(indexPath)
                    }
                })
            }
        } else if action == .copy {
            if let indexPath = self.tableView.indexPath(for: cell) {
                self.copyEventAtIndexPath(indexPath)
            }
        }
        return true
  }
}
