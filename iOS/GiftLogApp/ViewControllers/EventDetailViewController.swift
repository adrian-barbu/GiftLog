//
//  EventDetailViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/30/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit
import FDTake
import MGSwipeTableCell

@objc protocol EventDetailViewControllerDelegate: class {
    @objc optional func detailEventControllerDismissedWithEvent(_ event: Event)
}

class EventDetailViewController: BaseViewController {

  
    //MARK: - Enums

    enum DatePickerType: Int {
        case startDate = 0
        case endDate
    }

    enum Section: Int {
        
    // MARK: Cases

    case info = 0
    case attendees = 1
    case gifts = 2
    case wishlist = 3

    // MARK: Properties

    static let allValues = [info, attendees, gifts, wishlist]

    var description: String {
        switch self {
            case .info: return "INFO"
            case .attendees: return "ATTENDEES"
            case .gifts: return "GIFTS"
            case .wishlist: return "WISHLIST"
            }
        }
    }

    //MARK: - Outlets

    @IBOutlet weak var tableView: STCollapseTableView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var imageButton: UIButton!

    //MARK: - Variables

    weak var delegate: EventDetailViewControllerDelegate?
    internal var mode: ControllerDetailPresentationMode!
    internal var event: Event!
    fileprivate var fdTakeController: FDTakeController!
    fileprivate var eventService: EventService!
    fileprivate var originalEventService: EventService!
    fileprivate var datePickedType: DatePickerType!
    fileprivate var textPickedType: TextPickerType!
    fileprivate var headers = [UniversalTableHeaderView]()
    fileprivate var originFrame: CGRect!
    fileprivate var popupSave = false
    var backBarItem: UIBarButtonItem!

    internal var prepopulatedGift: GiftPreload? /// GEC_Relationship Functional
    internal var prepopulatedContact: ContactPreload? /// GEC_Relationship Functional
    
    //MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarItems()
        setEventService()
        setContentForController()
        setTableView()
        preloadAllNeededData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if tableView.isOpenSection(UInt(Section.attendees.rawValue)) || tableView.isOpenSection(UInt(Section.gifts.rawValue)) {
            self.tableView.reloadSections(IndexSet(integer: Section.attendees.rawValue), with: .none)
            self.tableView.reloadSections(IndexSet(integer: Section.gifts.rawValue), with: .none)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setOriginFrame()
        subscribeViewControllerForBaseNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.newGiftWasCreatedForEventNotification(_:)), name: NSNotification.Name(rawValue: NotificationCenterManager.NotificationNames.GiftWasCreatedForEvent), object: nil) /// GEC_Relationship Functional
        NotificationCenter.default.addObserver(self, selector: #selector(self.newContactWasCreatedForEventNotification(_:)), name: NSNotification.Name(rawValue: NotificationCenterManager.NotificationNames.ContactWasCreatedForEvent), object: nil) /// GEC_Relationship Functional
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeViewControllerForBaseNotifications()
        hideKeyboard()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        self.tableView.delegate = nil
    }

    //MARK: - Methods

    func setOriginFrame() {
        originFrame = self.view.frame
    }

    func keyboardWillShow(notification:NSNotification) {
        let keyboardFrame:CGRect = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        self.view.frame.size = CGSize(width: originFrame.size.width, height: originFrame.size.height - keyboardFrame.size.height)
    }

    func keyboardWillHide(notification:NSNotification) {
        self.view.frame = originFrame
    }

    func subscribeViewControllerForBaseNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateViewHeadersFromNotification(_:)), name: NSNotification.Name(rawValue: "TableViewWasCollapsed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleBlockedSectionNotification(_:)), name: NSNotification.Name(rawValue: "UserPressedBlockedSectionAtIndex"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeViewControllerForBaseNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "TableViewWasCollapsed"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UserPressedBlockedSectionAtIndex"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func setNavigationBarItems() {
        let backButton: UIButton = UIButton.init(type: .custom)
        backButton.addTarget(self, action: #selector(self.backButtonTapped), for: .touchUpInside)
        backButton.setImage(UIImage(named: "backGreen"), for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.sizeToFit()
        backBarItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem  = backBarItem
        if mode == ControllerDetailPresentationMode.new {
            let saveBarItem = UIBarButtonItem(image: UIImage(named: "save"), style: .plain, target: self, action: #selector(self.saveButtonTapped))
            self.navigationItem.rightBarButtonItems = [saveBarItem]
        } else {
            let deleteBarItem = UIBarButtonItem(image: UIImage(named: "delete"), style: .plain, target: self, action: #selector(self.deleteButtonTapped))
            let saveBarItem = UIBarButtonItem(image: UIImage(named: "save"), style: .plain, target: self, action: #selector(self.saveButtonTapped))
            self.navigationItem.rightBarButtonItems = [saveBarItem, deleteBarItem]
        }
        
    }

    func setEventService() {
        eventService = EventService(event: event)
        originalEventService = EventService(event: event)
    }

    func setContentForController() {
        imageButton.imageView!.contentMode = .scaleAspectFill
        imageButton.contentVerticalAlignment = .fill
        imageButton.contentHorizontalAlignment = .fill
        if let url = eventService.image {
            self.imageButton.kf.setImage(with: URL(string: url), for: .normal)
            self.imageButton.kf.setImage(with: URL(string: url), for: .highlighted)
        } else if let data = eventService.imageData {
            self.imageButton.setImage(UIImage(data: data), for: .normal)
            self.imageButton.setImage(UIImage(data: data), for: .highlighted)
        }
        if !eventService.eventTitle.isEmpty {
            headerTitleLabel.text = eventService.eventTitle
        } else {
            headerTitleLabel.text = "EVENT NAME"
        }
        tableView.reloadData()
    }

    func setTableView() {
        tableView.estimatedRowHeight = 44.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.tableFooterView = UIView.emptyView
        tableView.register(UINib(nibName: EventInfoTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: EventInfoTableViewCellIdentifier)
        tableView.register(UINib(nibName: UniversalAddingTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UniversalAddingTableViewCellIdentifier)
        tableView.register(UINib(nibName: UniversalTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UniversalTableViewCellIdentifier)
        tableView.register(UINib(nibName: UniversalDetailTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UniversalDetailTableViewCellIdentifier)
        tableView.register(UINib(nibName: EventWishlistTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: EventWishlistTableViewCellIdentifier)
        tableView.exclusiveSections = false // all section can be opened at once
        tableView.openSection(0, animated: true)
        tableView.reloadData()
    }

    func updateViewHeadersFromNotification(_ notification: Notification?) {
        if !headers.isEmpty {
            for header in headers {
                header.setArrowImageViewFromState((tableView as STCollapseTableView).isOpenSection(UInt(header.tag)))
            }
        }
        if let notification = notification {
            if let userInfo = notification.userInfo {
                let indexOfCollapsedSection = (userInfo["sectionIndex"] as! NSNumber).intValue
                if indexOfCollapsedSection == 0 { return }
                if (tableView as STCollapseTableView).isOpenSection(UInt(indexOfCollapsedSection)) {
                    tableView.scrollToRow(at: IndexPath(row: 0, section: indexOfCollapsedSection), at: UITableViewScrollPosition.top, animated: true)
                }
            }
        }
    }

    func setPrepopulatingDataIfNeeded() {
        var arrayOfBlockedSectionIndexs = [Int]()
        if let prepopulatedGift = prepopulatedGift {
            if self.eventService.getIndexOfGiftAtArrayFrom(prepopulatedGift.identifier) == nil {
                eventService.gifts.append(prepopulatedGift)
            }
            arrayOfBlockedSectionIndexs.append(Section.gifts.rawValue)
        }
        if let prepopulatedContact = prepopulatedContact {
            if self.eventService.getIndexOfContactAtArrayFrom(prepopulatedContact.identifier) == nil {
                eventService.contacts.append(prepopulatedContact)
            }
            arrayOfBlockedSectionIndexs.append(Section.attendees.rawValue)
        }
        tableView.blockedSectionIndexes = arrayOfBlockedSectionIndexs as! NSMutableArray
    }

    func handleBlockedSectionNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let indexOfCollapsedSection = (userInfo["sectionIndex"] as! NSNumber).intValue
            switch Section(rawValue: indexOfCollapsedSection)! {
            case .attendees:
                UIAlertController.showAlertWithTitle("", message: "Contact info is already populated. To amend, please open 'Contacts' screen.")
            case .gifts:
                UIAlertController.showAlertWithTitle("", message: "Gift info is already populated. To amend, please open ‘Gifts’ screen.")
            default: break
            }
        }
    }
    
    /// GEC_Relationship Functional
    func newGiftWasCreatedForEventNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if userInfo["eventID"] as! String == self.event.identifier {
                let giftPreload = userInfo["giftPreload"] as! GiftPreload
                if eventService.getIndexOfGiftAtArrayFrom(giftPreload.identifier) == nil {
                    eventService.gifts.append(giftPreload)
                    tableView.reloadData()
                }
            }
        }
    }
    
    /// GEC_Relationship Functional
    func newContactWasCreatedForEventNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if userInfo["eventID"] as! String == self.event.identifier {
                let contactPreload = userInfo["contactPreload"] as! ContactPreload
                if eventService.getIndexOfContactAtArrayFrom(contactPreload.identifier) == nil {
                    eventService.contacts.append(contactPreload)
                    tableView.reloadData()
                }
            }
        }
    }

    func showFDTakeController() {
        fdTakeController = ImageManager.fdTakeController
        fdTakeController.didFail = { [unowned self] in
            let alert = UIAlertController(title: "Failed", message: "User selected but API failed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        fdTakeController.didGetPhoto = { [unowned self]
            (image: UIImage, info: [AnyHashable : Any]) in
            
            self.imageButton.setImage(image, for: .normal)
            self.imageButton.setImage(image, for: .highlighted)
            self.eventService.imageData = UIImageJPEGRepresentation(image, 0.5)
        }
        self.fdTakeController.presentingRect = imageButton.frame
        self.fdTakeController.presentingView = self.view
        self.fdTakeController.present()
    }

    func showDateActionSheet(_ date: Int64? = nil, title: String!, minimumDate: Int64? = nil) {
        let datePickerViewController = DatePickerViewController(nibName: "DatePickerViewController", bundle: nil)
        datePickerViewController.modalPresentationStyle = .overCurrentContext
        datePickerViewController.delegate = self
        datePickerViewController.titleLabelValue = title
        datePickerViewController.minuteInterval = 5
        if let date = date {
            datePickerViewController.initialDate = Date(timeIntervalSince1970: TimeInterval(date))
        } else {
            datePickerViewController.initialDate = Date()
        }
        if let minimumDate = minimumDate {
            datePickerViewController.minimumDate = Date(timeIntervalSince1970: TimeInterval(minimumDate))
        }
        
        self.present(datePickerViewController, animated: false, completion: nil)
    }

    func showTextActionSheet(_ text: String? = nil) {
        let textPickerViewController = TextPickerViewController(nibName: "TextPickerViewController", bundle: nil)
        textPickerViewController.delegate = self
        if let text = text {
            textPickerViewController.initialText = text
        }
        self.present(textPickerViewController, animated: true, completion: nil)
    }

    func preloadAllNeededData() {
        preloadContactsIfNeededWithCompletion { [unowned self] in
            self.preloadGiftsIfNeededWithCompletion { [unowned self] in
                self.setPrepopulatingDataIfNeeded()
                self.tableView.reloadData()
            }
        }
    }

    func preloadContactsIfNeededWithCompletion(_ completion: @escaping () -> Void) {
        if eventService.contacts.isEmpty {
            return completion()
        }
        HUDManager.showLoadingHUD()
        var counter = 0
        for contact in eventService.contacts {
            FirebaseManager.shared.getContactById(contact.identifier, completion: { [unowned self] (resultContact) in
                if let resultContact = resultContact {
                    if let index = self.eventService.getIndexOfContactAtArrayFrom(contact.identifier) {
                        self.eventService.contacts[index].model = resultContact
                    }
                } else { // contact was deleted from Firebase, so we should remove it from event.contacts list too.
                    if let index = self.eventService.getIndexOfContactAtArrayFrom(contact.identifier) {
                        self.eventService.contacts.remove(at: index)
                        self.originalEventService.contacts.remove(at: index)
                        debugPrint("Caution: Contact was deleted from Firebase, so we should remove it from event.contacts list too. but saves will occur after user press 'save' button.")
                        counter -= 1
                    } else {
                        debugPrint("Error: This model is missed at both Firebase and at service !")
                        // this model is missed at both Firebase and at service
                    }
                }
                counter += 1
                if counter == self.eventService.contacts.count {
                    HUDManager.hideLoadingHUDWithAnimation()
                    completion()
                }
            })
        }
    }

    func preloadGiftsIfNeededWithCompletion(_ completion: @escaping () -> Void) {
        if eventService.gifts.isEmpty {
            return completion()
        }
        HUDManager.showLoadingHUD()
        var counter = 0
        for gift in eventService.gifts {
            FirebaseManager.shared.getGiftById(gift.identifier, completion: { [unowned self] (resultGift) in
                if let resultGift = resultGift {
                    if let index = self.eventService.getIndexOfGiftAtArrayFrom(gift.identifier) {
                        self.eventService.gifts[index].model = resultGift
                    }
                } else { // gift was deleted from Firebase, so we should remove it from gifts list too.
                    if let index = self.eventService.getIndexOfGiftAtArrayFrom(gift.identifier) {
                        self.eventService.gifts.remove(at: index)
                        self.originalEventService.gifts.remove(at: index)
                        debugPrint("Caution: Gift was deleted from Firebase, so we should remove it from event.gifts list too. but saves will occur after user press 'save' button.")
                        counter -= 1
                    } else {
                        debugPrint("Error: This model is missed at both Firebase and at service !")
                        // this model is missed at both Firebase and at service
                    }
                }
                counter += 1
                if counter == self.eventService.gifts.count {
                    HUDManager.hideLoadingHUDWithAnimation()
                    completion()
                }
            })
        }
    }
    
    /// GEC_Relationship Functional
    func getEventPreloadFromCurrentEvent() -> EventPreload {
        let prepopulatedEvent = EventPreload()
        prepopulatedEvent.identifier = self.event.identifier
        prepopulatedEvent.model = self.event
        return prepopulatedEvent
    }

    /**  Method that saves or updates event with image. Or even without image data. */
    func saveOrUpdateEventWithImage() {
        if let data = self.eventService.imageData {
            HUDManager.showLoadingHUD()
            FirebaseManager.shared.uploadEventAvatarImage(with: data, forEvent: event, completion: { [unowned self] (url) in
                HUDManager.hideLoadingHUD()
                if let url = url {
                    self.eventService.image = url
                    self.eventService.imageData = nil
                }
                self.saveOrUpdateEvent()
            })
        } else {
            self.saveOrUpdateEvent()
        }
    }

    func saveOrUpdateEvent() {
        event.updateEventFromService(eventService)
        originalEventService = EventService(event: event)
        FirebaseManager.shared.saveOrUpdateEvent(event) { [unowned self] (success) in
            if success {
                HUDManager.showSuccessHUD()
                RemindService.shared.saveLocalNotificationForEventIfNeeded(event: self.event, completion: { [unowned self] in
                    if self.mode == .new {
                        self.delegate?.detailEventControllerDismissedWithEvent!(self.event)
                        let _ = self.navigationController?.popViewController(animated: true)
                    } else if self.popupSave {
                        let _ = self.navigationController?.popViewController(animated: true)
                    }
                })
            } else {
                HUDManager.showErrorHUD()
            }
        }
    }

    func saveEvent() {
        HUDManager.showLoadingHUD()
        self.saveEventForSelectedGifts { [unowned self] in
            self.saveOrUpdateEventWithImage()
        }
    }

    /// GEC_Relationship Functional
    func saveEventForSelectedGifts(completion: @escaping () -> Void) {
        let gifts = eventService.gifts
        if gifts.isEmpty {
            return completion()
        }
        var counter = 0
        for gift in gifts {
            let eventPreload = EventPreload()
            eventPreload.identifier = self.event.identifier
            gift.model.eventPreload = eventPreload
            FirebaseManager.shared.saveOrUpdateGift(gift.model, completion: { (success) in
                counter += 1
                if counter == gifts.count {
                    completion()
                }
            })
        }
    }

    func deleteEventForSelectedGift(giftPreload: GiftPreload,  completion: @escaping () -> Void) {
        giftPreload.model.eventPreload = nil
        FirebaseManager.shared.saveOrUpdateGift(giftPreload.model) { (success) in
            completion()
        }
    }

    func showSelectContactsViewControllerWithAlreadySelectedContacts(_ contacts: [Contact]) {
        let selectContactsViewController = SelectContactsViewController(nibName: ViewControllerIdentifiers.SelectContactsViewControllerID, bundle: nil)
        selectContactsViewController.delegate = self
        selectContactsViewController.contactsAddedBefore = contacts
        selectContactsViewController.prepopulatedGift = prepopulatedGift
        selectContactsViewController.prepopulatedEvent = getEventPreloadFromCurrentEvent()
        self.navigationController?.pushViewController(selectContactsViewController, animated: true)
    }

    func showGiftDetailViewController() {
        let giftDetailViewController = GiftDetailViewController(nibName: ViewControllerIdentifiers.GiftDetailViewControllerID, bundle: nil)
        giftDetailViewController.delegate = self
        giftDetailViewController.gift = Gift()
        giftDetailViewController.mode = .new
        giftDetailViewController.prepopulatedEvent = getEventPreloadFromCurrentEvent()
        self.navigationController?.pushViewController(giftDetailViewController, animated: true)
    }

    // MARK: Bar Item Actions

    func saveButtonTapped() {
        hideKeyboard()
        if eventService.eventTitle == nil || eventService.eventTitle == "" || eventService.dateStart == nil {
            return UIAlertController.showAlertWithTitle("Title & Dates cannot be empty.", message: "Please complete these fields.")
        }
        saveEvent()
    }

    func deleteButtonTapped() {
        AlertManager.shared.showDeleteAlertViewFrom(self, deleteButtonTitle: "Delete event", completion: { [unowned self] (buttonPressed) in
            if buttonPressed == DeleteButtonPressed.delete {
                HUDManager.showNetworkActivityIndicator()
                FirebaseManager.shared.deleteEventFromDatabase(self.event) { [weak self] (success) in
                    HUDManager.hideNetworkActivityIndicator()
                    if let strongSelf = self {
                        if success {
                            RemindService.shared.removeOldLocalNotificationOfEvent(strongSelf.event)
                            let _ = strongSelf.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        })
    }

    func backButtonTapped() {
        hideKeyboard()
        if originalEventService != eventService {
            AlertManager.shared.showBackActionSheetFromController(self, title: "Changes not saved", message: "Do you want to continue editing or discard changes?", completion: { (buttonPressed) in
                if buttonPressed == AlertButtonPressed.cancel {
                    self.navigationController?.popViewController(animated: true)
                }
                else if buttonPressed == AlertButtonPressed.save {
                    self.popupSave = true
                    self.saveButtonTapped()
                }
            })
        } else { self.navigationController?.popViewController(animated: true) }
    }

    //MARK: - Actions

    @IBAction func imageButtonTapped(_ sender: Any) {
        showFDTakeController()
    }
}

// MARK: - Tableview DataSource and Delegate

extension EventDetailViewController: UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allValues.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.universalSectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch Section(rawValue: indexPath.section)! {
        case Section.info:
            return UITableViewAutomaticDimension
        case Section.attendees:
            if indexPath.row == 0 { return 40.0 }
            else { return 60.0 }
        case Section.gifts:
            if indexPath.row == 0 { return 40.0 }
            else { return 60.0 }
        case Section.wishlist:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case Section.info:
            return 1 // always static
        case Section.attendees:
            return eventService.contacts.count + 1 // 1 is for extra 'add' cell
        case Section.gifts:
            return eventService.gifts.count + 1 // 1 is for extra 'add' cell
        case Section.wishlist:
            return 1 // always static
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
            universalTableHeaderView.mainTitleLabel.text = "INFO"
            universalTableHeaderView.iconImageView.image = UIImage(named: "dateInfoSection")
            universalTableHeaderView.backgroundColor = Constants.appVioletColor
        case 1:
            universalTableHeaderView.mainTitleLabel.text = "ATTENDEES"
            universalTableHeaderView.iconImageView.image = UIImage(named: "contactInfoSection")
            universalTableHeaderView.backgroundColor = Constants.appPurpleColor
        case 2:
            universalTableHeaderView.mainTitleLabel.text = "GIFTS"
            universalTableHeaderView.iconImageView.image = UIImage(named: "giftInfoSection")
            universalTableHeaderView.backgroundColor = Constants.appBlueColor
        case 3:
            universalTableHeaderView.mainTitleLabel.text = "WISHLIST"
            universalTableHeaderView.iconImageView.image = UIImage(named: "wishlistInfoSection")
            universalTableHeaderView.backgroundColor = Constants.appGreenColor
            universalTableHeaderView.bottomLineView.isHidden = true
        default:
            break
        }
        return universalTableHeaderView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case Section.info:
            let cell = tableView.dequeueReusableCell(withIdentifier: EventInfoTableViewCellIdentifier, for: indexPath) as! EventInfoTableViewCell
            cell.delegate = self
            cell.setContentFromService(eventService)
            return cell
        case Section.attendees:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: UniversalAddingTableViewCellIdentifier, for: indexPath) as! UniversalAddingTableViewCell
                cell.delegate = self
//                cell.setUnderlineTitleButton("Add Guest")
                cell.setAddButtonBackground(indexPath.section)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: UniversalDetailTableViewCellIdentifier, for: indexPath) as! UniversalDetailTableViewCell
                cell.delegate = self
                cell.rightButtons = [MGSwipeService.deleteButton()]
                cell.setContentFromUserContact(eventService.contacts[indexPath.row - 1].model)
                cell.shareButton.isHidden = true // force hide
                return cell
            }
            
        case Section.gifts:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: UniversalAddingTableViewCellIdentifier, for: indexPath) as! UniversalAddingTableViewCell
                cell.delegate = self
//                cell.setUnderlineTitleButton("Add Gift")
                cell.setAddButtonBackground(indexPath.section)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: UniversalDetailTableViewCellIdentifier, for: indexPath) as! UniversalDetailTableViewCell
                cell.delegate = self
                cell.rightButtons = [MGSwipeService.deleteButton()]
                cell.setGiftContentFrom(eventService.gifts[indexPath.row - 1].model)
                cell.shareButton.isHidden = true // force hide
                return cell
            }
            
        case Section.wishlist:
            let cell = tableView.dequeueReusableCell(withIdentifier: EventWishlistTableViewCellIdentifier, for: indexPath) as! EventWishlistTableViewCell
            cell.setContentFromService(eventService)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.attendees.rawValue {
            if eventService.contacts.isEmpty { return }
            let contact = self.eventService.contacts[indexPath.row - 1]
            NavigationManager.shared.showDetailedContactViewControllerFrom(self, withContact: contact.model, andWithMode: .old, prepopulatedGift: self.prepopulatedGift, prepopulatedEvent: getEventPreloadFromCurrentEvent())
            
        } else if indexPath.section == Section.gifts.rawValue {
            if eventService.gifts.isEmpty { return }
            let gift = self.eventService.gifts[indexPath.row - 1]
            NavigationManager.shared.showGiftDetailViewControllerFrom(self, withGift: gift.model, andWithMode: .old, prepopulatedEvent: getEventPreloadFromCurrentEvent(), prepopulatedContact: self.prepopulatedContact)
        }
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        let action = SwipeTableViewCellAction(rawValue: index)
        if action == .delete {
            if let indexPath = self.tableView.indexPath(for: cell) {
                if indexPath.section == Section.attendees.rawValue {
                    eventService.contacts.remove(at: indexPath.row - 1)
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                } else {
                    let giftToRemove = self.eventService.gifts[indexPath.row - 1]
                    eventService.gifts.remove(at: indexPath.row - 1)
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    if self.mode == .old {
                        HUDManager.showLoadingHUD()
                        deleteEventForSelectedGift(giftPreload: giftToRemove, completion: { [unowned self] in
                            self.saveOrUpdateEventWithImage()
                            HUDManager.hideLoadingHUD()
                        })
                    }
                }
            }
        }
        return true
    }
}

extension EventDetailViewController: DatePickerViewControllerDelegate, UniversalAddingTableViewCellDelegate, EventInfoTableViewCellDelegate, EventWishlistTableViewCellDelegate, TextPickerViewControllerDelegate, SelectGiftViewControllerDelegate {
    
    func addingButtonDidTouchFrom(_ cell: UniversalAddingTableViewCell) {
        if eventService.eventTitle == nil || eventService.eventTitle == "" || eventService.dateStart == nil {
            return UIAlertController.showAlertWithTitle("Title & Dates cannot be empty.", message: "Please complete these fields.")
        }
        if let indexPath = tableView.indexPath(for: cell) {
            switch Section(rawValue: indexPath.section)! {
            case .attendees:
                var selectedContacts = [Contact]()
                for contact in eventService.contacts {
                    selectedContacts.append(contact.model)
                }
                showSelectContactsViewControllerWithAlreadySelectedContacts(selectedContacts)
            case .gifts:
                showGiftDetailViewController()
            default:
                break
            }
        }
    }
    
    func startDateButtonDidTouchFrom(_ cell: EventInfoTableViewCell) {
        datePickedType = .startDate
        showDateActionSheet(eventService.dateStart, title: "Start Date & Time")
    }
    
    func endDateButtonDidTouchFrom(_ cell: EventInfoTableViewCell) {
        if eventService.dateStart != nil {
            datePickedType = .endDate
            showDateActionSheet(eventService.dateEnd, title: "End Date & Time", minimumDate: eventService.dateStart)
        } else {
            UIAlertController.showAlertWithTitle("Start date field is empty", message: "Please add start date before")
        }
    }
    
    func descriptionButtonDidTouchFrom(_ cell: EventInfoTableViewCell) {
        showTextActionSheet(eventService.description)
        textPickedType = .description
    }
    
    func textFieldFinishedInputWith(_ text: String?, textFieldType: EventInfoTableViewCell.TextFieldType) {
        switch textFieldType {
        case .eventTitle:
            eventService.eventTitle = text
        case .eventType:
            eventService.eventType = text
        case .description:
            eventService.description = text
        }
        headerTitleLabel.text = eventService.eventTitle
    }
    
    func likeButtonDidTouchFrom(_ cell: EventWishlistTableViewCell) {
        showTextActionSheet(eventService.likes)
        textPickedType = .likes
    }
    
    func dislikeButtonDidTouchFrom(_ cell: EventWishlistTableViewCell) {
        showTextActionSheet(eventService.dislikes)
        textPickedType = .dislikes
    }
    
    func shareButtonDidTouchFrom(_ cell: EventWishlistTableViewCell) {
        var shareString = "Hi,\n\n"
        shareString.append("Here’s my wishlist for \(eventService.eventTitle!).\n")
        if eventService.likes != nil && eventService.likes != "" {
            shareString.append("Would Like:\n\(String(describing: eventService.likes!))")
        }
        if shareString != "" {
            shareString.append("\n")
        }
        if eventService.dislikes != nil && eventService.dislikes != "" {
            shareString.append("Would Not Like:\n\(String(describing: eventService.dislikes!))")
        }
        
        if !shareString.isEmpty {
            var contacts = [Contact]()
            for contact in eventService.contacts {
                if contact.model != nil {
                    contacts.append(contact.model)
                }
            }
            shareString.append("\n\nRegards,\n\(UserManager.shared.currentUser.fullName)\n\n")
            shareString.append("Sent from GiftLog – your essential gift management app!\n")
            SSHelperManager.shared.showShareActionSheetFromController(self, withText: shareString)
        } else {
            UIAlertController.showAlertWithTitle("Nothing to share", message: "Please add at least one field")
        }
    }
    
    func hostingTypeSegmentedChangedValue(_ value: Int) {
        eventService.hostingType = HostingType(rawValue: value)!
    }
    
    func datePickerViewControllerSelectedValue(_ value: Date) {
        if datePickedType == .startDate {
            eventService.dateStart = Int64(value.timeIntervalSince1970)
            eventService.dateEnd = Int64(value.timeIntervalSince1970) + 3600 // plus one hour by default
            
        } else {
            eventService.dateEnd = Int64(value.timeIntervalSince1970)
        }
        tableView.reloadData()
    }
    
    func textPickerViewControllerSelected(_ text: String) {
        if textPickedType == .description {
            eventService.description = text
            tableView.reloadData()
            return
        } else if textPickedType == .likes {
            eventService.likes = text
        } else if textPickedType == .dislikes {
            eventService.dislikes = text
        }
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: Section.wishlist.rawValue), at: UITableViewScrollPosition.top, animated: false)
    }
    
    func selectGiftViewControllerDismissedWith(_ gift: Gift) {
        //self.mode = .old
        let giftPreload = GiftPreload()
        giftPreload.model = gift
        giftPreload.identifier = gift.identifier
        eventService.gifts.append(giftPreload)
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: Section.gifts.rawValue), at: UITableViewScrollPosition.top, animated: false)
        if mode == .old {
            saveEvent()
        }
    }
}

extension EventDetailViewController: SelectContactsViewControllerDelegate {
    func selectContactsViewControllerDismissedWith(_ contacts: [Contact]) {
        var contactsAtEvent = [ContactPreload]()
        for contact in contacts {
            let contactAtEvent = ContactPreload()
            contactAtEvent.identifier = contact.identifier
            contactAtEvent.model = contact
            contactsAtEvent.append(contactAtEvent)
        }
        eventService.contacts = contactsAtEvent
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: Section.attendees.rawValue), at: UITableViewScrollPosition.top, animated: false)
        if mode == .old {
            saveEvent()
        }
    }
}
