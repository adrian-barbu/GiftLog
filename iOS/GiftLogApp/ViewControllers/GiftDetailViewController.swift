//
//  GiftDetailViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/28/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit
import FDTake
import MGSwipeTableCell
import SwiftPhotoGallery
import Kingfisher

protocol SelectGiftViewControllerDelegate: class {
  func selectGiftViewControllerDismissedWith(_ gift: Gift)
}

class GiftDetailViewController: BaseViewController {

    //MARK: Enums
    
    enum ValuePickerType: Int {
        case giftType = 0
        case giftStatus
    }
    
    enum Section: Int {
        
        // MARK: Cases
        
        case info = 0
        case contactInfo = 1
        case eventInfo = 2
        
        // MARK: Properties
        
        static let allValues = [info, contactInfo, eventInfo]
        
        var description: String {
            switch self {
            case .info:
                return "GIFT INFO"
            case .contactInfo:
                return "CONTACT INFO"
            case .eventInfo:
                return "EVENT INFO"
            }
        }
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: STCollapseTableView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    
    // MARK: Variables
    
    internal var mode: ControllerDetailPresentationMode!
    internal var gift:  Gift!
    fileprivate var fdTakeController:FDTakeController!
    fileprivate var giftService: GiftService!
    fileprivate var originalGiftService: GiftService!
    fileprivate var headers = [UniversalTableHeaderView]()
    fileprivate var originFrame: CGRect!
    fileprivate var valuePickerTypeChosen = ValuePickerType.giftType
    fileprivate var popupSave = false
    weak var delegate: SelectGiftViewControllerDelegate?
    var backBarItem: UIBarButtonItem!
    
    internal var prepopulatedEvent: EventPreload? /// GEC_Relationship Functional
    internal var prepopulatedContact: ContactPreload? /// GEC_Relationship Functional
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarItems()
        setGiftService()
        setContentForController()
        setTableView()
        preloadAllNeededData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if tableView.isOpenSection(UInt(Section.contactInfo.rawValue)) || tableView.isOpenSection(UInt(Section.eventInfo.rawValue)) {
            self.tableView.reloadSections(IndexSet(integer: Section.contactInfo.rawValue), with: .none)
            self.tableView.reloadSections(IndexSet(integer: Section.eventInfo.rawValue), with: .none)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        hideKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if tableView.isOpenSection(UInt(Section.contactInfo.rawValue)) || tableView.isOpenSection(UInt(Section.eventInfo.rawValue)) {
            self.tableView.reloadSections(IndexSet(integer: Section.contactInfo.rawValue), with: .none)
            self.tableView.reloadSections(IndexSet(integer: Section.eventInfo.rawValue), with: .none)
        }
        setOriginFrame()
        subscribeViewControllerForNotifications()
    }
    
    deinit {
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
    
    func subscribeViewControllerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateViewHeadersFromNotification(_:)), name: NSNotification.Name(rawValue: "TableViewWasCollapsed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showFDTakeController), name: NSNotification.Name(rawValue: "UserPressedAddImageAtGift"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleBlockedSectionNotification(_:)), name: NSNotification.Name(rawValue: "UserPressedBlockedSectionAtIndex"), object: nil)
    }
    
    func setNavigationBarItems() {
//        addSearchNavigationBarButton()
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
    
    func preloadAllNeededData() {
        preloadContactsIfNeededWithCompletion { [unowned self] in
            self.preloadEventIfNeededWithCompletion {
                self.setPrepopulatingDataIfNeeded()
                self.tableView.reloadData()
            }
        }
    }
    
    func preloadContactsIfNeededWithCompletion(_ completion: @escaping () -> Void) {
        if giftService.contacts.isEmpty {
            return completion()
        }
        HUDManager.showLoadingHUD()
        var counter = 0
        for contact in giftService.contacts {
            FirebaseManager.shared.getContactById(contact.identifier, completion: { [unowned self] (resultContact) in
                if let resultContact = resultContact {
                    if let index = self.giftService.getIndexOfContactAtArrayFrom(contact.identifier) {
                        self.giftService.contacts[index].model = resultContact
                    }
                } else { // contact was deleted from Firebase, so we should remove it from event.contacts list too.
                    if let index = self.giftService.getIndexOfContactAtArrayFrom(contact.identifier) {
                        self.giftService.contacts.remove(at: index)
                        self.originalGiftService.contacts.remove(at: index)
                        debugPrint("Caution: Contact was deleted from Firebase, so we should remove it from event.contacts list too. but saves will occur after user press 'save' button.")
                        counter -= 1
                    } else {
                        debugPrint("Error: This model is missed at both Firebase and at service !")
                        // this model is missed at both Firebase and at service
                    }
                }
                counter += 1
                debugPrint(counter)
                debugPrint(self.giftService.contacts.count)
                if counter == self.giftService.contacts.count {
                    HUDManager.hideLoadingHUDWithAnimation()
                    completion()
                }
            })
        }
    }
    
    func preloadEventIfNeededWithCompletion(_ completion: @escaping () -> Void) {
        guard let eventPreload = giftService.eventPreload else {
            return completion()
        }
        HUDManager.showLoadingHUD()
        FirebaseManager.shared.getEventById(eventPreload.identifier) { [unowned self] (event) in
            if let event = event {
                self.giftService.eventPreload!.model = event
                self.originalGiftService.eventPreload!.model = event
            } else {
                self.giftService.eventPreload = nil
                self.originalGiftService.eventPreload = nil
            }
            HUDManager.hideLoadingHUDWithAnimation()
            completion()
        }
    }

    /// GEC_Relationship Functional
    func setPrepopulatingDataIfNeeded() {
        var arrayOfBlockedSectionIndexs = [Int]()
        if prepopulatedEvent != nil {
            giftService.eventPreload = prepopulatedEvent
            arrayOfBlockedSectionIndexs.append(Section.eventInfo.rawValue)
        }
        if let prepopulatedContact = prepopulatedContact {
            if self.giftService.getIndexOfContactAtArrayFrom(prepopulatedContact.identifier) == nil {
                giftService.contacts.append(prepopulatedContact)
            }
            arrayOfBlockedSectionIndexs.append(Section.contactInfo.rawValue)
        }
        tableView.blockedSectionIndexes = arrayOfBlockedSectionIndexs as! NSMutableArray
    }
    
    func handleBlockedSectionNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let indexOfCollapsedSection = (userInfo["sectionIndex"] as! NSNumber).intValue
            switch Section(rawValue: indexOfCollapsedSection)! {
            case .contactInfo:
                UIAlertController.showAlertWithTitle("", message: "Contact info is already populated. To amend, please open 'Contacts' screen.")
            case .eventInfo:
                UIAlertController.showAlertWithTitle("", message: "Event info is already populated. To amend, please open 'Events' screen.")
            default: break
            }
        }
    }
    
    func setGiftService() {
        giftService = GiftService(gift: self.gift)
        originalGiftService = GiftService(gift: self.gift)
    }
    
    func setContentForController() {
        imageButton.imageView!.contentMode = .scaleAspectFill
        imageButton.contentVerticalAlignment = .fill
        imageButton.contentHorizontalAlignment = .fill
        if !giftService.images.isEmpty {
            if let url = giftService.images.first!.url {
                self.imageButton.kf.setImage(with: URL(string: url), for: .normal)
                self.imageButton.kf.setImage(with: URL(string: url), for: .highlighted)
            }
        } else {
            self.imageButton.setImage(UIImage(named: "imageThumb"), for: .normal)
            self.imageButton.setImage(UIImage(named: "imageThumb"), for: .highlighted)
        }
        if !giftService.name.isEmpty {
            headerTitleLabel.text = giftService.name
        } else {
            headerTitleLabel.text = "GIFT NAME"
        }
        tableView.reloadData()
    }
    
    func setTableView() {
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView.emptyView
        tableView.register(UINib(nibName: OneActionTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: OneActionTableViewCellIdentifier)
        tableView.register(UINib(nibName: GiftInfoTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: GiftInfoTableViewCellIdentifier)
        tableView.register(UINib(nibName: UniversalAddingTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UniversalAddingTableViewCellIdentifier)
        tableView.register(UINib(nibName: UniversalTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UniversalTableViewCellIdentifier)
        tableView.register(UINib(nibName: UniversalDetailTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UniversalDetailTableViewCellIdentifier)
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
    
    func showFDTakeController() {
        fdTakeController = ImageManager.fdTakeController
        fdTakeController.didFail = { [unowned self] in
            let alert = UIAlertController(title: "Failed", message: "User selected but API failed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        fdTakeController.didGetPhoto = { [unowned self]
            (image: UIImage, info: [AnyHashable : Any]) in
            if let imageData = UIImageJPEGRepresentation(image, 0.5) {
                HUDManager.showLoadingHUD()
                FirebaseManager.shared.uploadGiftAvatarImage(imageData, forGift: self.gift, completion: { [unowned self] (url) in
                    HUDManager.hideLoadingHUD()
                    if let url = url {
                        let giftImage = GiftImage()
                        giftImage.url = url
                        self.giftService.images.append(giftImage)
                        self.imageButton.kf.setImage(with: URL(string: self.giftService.images.first!.url), for: .normal)
                        self.imageButton.kf.setImage(with: URL(string: self.giftService.images.first!.url), for: .highlighted)
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.automatic)
                    }
                })
            }
        }
        self.fdTakeController.presentingRect = CGRect(x: self.view.center.x, y: UIScreen.main.bounds.height, width: 1, height: 10)
        self.fdTakeController.presentingView = self.view
        self.fdTakeController.present()
    }
    
    func showTextActionSheet(_ text: String? = nil) {
        let textPickerViewController = TextPickerViewController(nibName: "TextPickerViewController", bundle: nil)
        textPickerViewController.delegate = self
        if let text = text {
            textPickerViewController.initialText = text
        }
        self.present(textPickerViewController, animated: true, completion: nil)
    }
    
    func showValueActionSheet(_ values: [String], title: String!, selectedValueIndex: Int?) {
        let valuePickerViewController = ValuePickerViewController(nibName: ViewControllerIdentifiers.ValuePickerViewControllerID, bundle: nil)
        valuePickerViewController.modalPresentationStyle = .overCurrentContext
        valuePickerViewController.delegate = self
        valuePickerViewController.titleLabelValue = title
        valuePickerViewController.values = values
        valuePickerViewController.selectedIndex = selectedValueIndex ?? 0
        self.present(valuePickerViewController, animated: false, completion: nil)
    }
    
    func showSelectContactsViewControllerWithAlreadySelectedContacts(_ contacts: [Contact]) {
        let selectContactsViewController = SelectContactsViewController(nibName: ViewControllerIdentifiers.SelectContactsViewControllerID, bundle: nil)
        selectContactsViewController.delegate = self
        selectContactsViewController.contactsAddedBefore = contacts
        selectContactsViewController.prepopulatedEvent = self.prepopulatedEvent
        selectContactsViewController.prepopulatedGift = getGiftPreloadFromCurrentGift()
        self.navigationController?.pushViewController(selectContactsViewController, animated: true)
    }
    
    func showSelectEventViewController() {
        let selectEventViewController = SelectEventViewController(nibName: ViewControllerIdentifiers.SelectEventViewControllerID, bundle: nil)
        selectEventViewController.delegate = self
        selectEventViewController.prepopulatedContact = self.prepopulatedContact
        selectEventViewController.prepopulatedGift = getGiftPreloadFromCurrentGift()
        self.navigationController?.pushViewController(selectEventViewController, animated: true)
    }
    
    func showImageGalleryWithIndex(_ index: Int) {
        let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
        gallery.backgroundColor = UIColor.black
        gallery.pageIndicatorTintColor = UIColor.appGreenColor
        gallery.currentPageIndicatorTintColor = UIColor.white
        gallery.hidePageControl = false
        gallery.modalPresentationStyle = .overCurrentContext
        
        present(gallery, animated: false, completion: { () -> Void in
            gallery.currentPage = index
        })
    }
    
    /// GEC_Relationship Functional
    func getGiftPreloadFromCurrentGift() -> GiftPreload {
        let prepopulatedGift = GiftPreload()
        prepopulatedGift.identifier = self.gift.identifier
        prepopulatedGift.model = self.gift
        return prepopulatedGift
    }
    
    func saveOrUpdateGift() {
        gift.updateGiftFromService(giftService)
        originalGiftService = GiftService(gift: gift)
        FirebaseManager.shared.saveOrUpdateGift(gift) { [unowned self] (success) in
            if success {
                HUDManager.showSuccessHUD()
                if self.mode == .new {
                    if let delegate = self.delegate {
                        delegate.selectGiftViewControllerDismissedWith(self.gift)
                    }
                    if let event = self.prepopulatedEvent {
                        NotificationCenterManager.postNotificationThatGift(self.getGiftPreloadFromCurrentGift(), wasCreatedForEventWithIdentifier: event.identifier)
                    }
                    let _ = self.navigationController?.popViewController(animated: true)
                } else {
                    if let event = self.prepopulatedEvent {
                        NotificationCenterManager.postNotificationThatGift(self.getGiftPreloadFromCurrentGift(), wasCreatedForEventWithIdentifier: event.identifier)
                    }
                    if self.popupSave {
                        let _ = self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                HUDManager.showErrorHUD()
            }
        }
    }
    
    func saveContactsForSelectEvent(completion: @escaping () -> Void) {
        guard let event = giftService.eventPreload?.model else {
            return completion()
        }
        let giftContacts = giftService.contacts
        if giftContacts.isEmpty {
            return completion()
        }
        let eventService = EventService(event: event)
        for giftContact in giftContacts {
            if eventService.getIndexOfContactAtArrayFrom(giftContact.identifier) == nil {
                event.contacts.append(giftContact)
            }
        }
        FirebaseManager.shared.saveOrUpdateEvent(event) { (success) in
            completion()
        }
    }
    
    func saveGiftForSelectedContacts(completion: @escaping () -> Void) {
        let contacts = giftService.contacts
        if contacts.isEmpty {
            return completion()
        }
        var counter = 0
        for contact in contacts {
            var isGiftPreloadFound = false
            for giftPreload in contact.model.gifts {
                if giftPreload.identifier == self.gift.identifier {
                    isGiftPreloadFound = true
                    break
                }
            }
            if !isGiftPreloadFound {
                let giftPreload = GiftPreload()
                giftPreload.identifier = self.gift.identifier
                contact.model.gifts.append(giftPreload)
                FirebaseManager.shared.saveOrUpdateContact(contact.model, completion: { (success) in
                    counter += 1
                    if counter == contacts.count {
                        completion()
                    }
                })
            } else {
                counter += 1
            }
            if counter == contacts.count {
                completion()
            }
        }
    }
    
    func deleteGiftForSelectedContact(contactPreload: ContactPreload,  completion: @escaping () -> Void) {
        if let giftIndexToDelete = UserGiftsManager.shared.indexOf(gift: self.gift, at: contactPreload.model.gifts) {
            contactPreload.model.gifts.remove(at: giftIndexToDelete)
            FirebaseManager.shared.saveOrUpdateContact(contactPreload.model, completion: { (success) in
                completion()
            })
        } else {
            completion()
        }
    }
    
    func saveGiftForSelectedEvent(completion: @escaping () -> Void) {
        if let event = giftService.eventPreload {
            var isGiftPreloadFound = false
            for giftPreload in event.model.gifts {
                if giftPreload.identifier == self.gift.identifier {
                    isGiftPreloadFound = true
                    break
                }
            }
            if !isGiftPreloadFound {
                let giftPreload = GiftPreload()
                giftPreload.identifier = self.gift.identifier
                event.model.gifts.append(giftPreload)
                FirebaseManager.shared.saveOrUpdateEvent(event.model, completion: { (success) in
                    completion()
                })
            } else {
                completion()
            }
        } else {
            completion()
        }
    }
    
    func deleteGiftFromSelectedEvent(eventPreload: EventPreload, completion: @escaping () -> Void) {
        if let giftIndexToDelete = UserGiftsManager.shared.indexOf(gift: self.gift, at: eventPreload.model.gifts) {
            eventPreload.model.gifts.remove(at: giftIndexToDelete)
            FirebaseManager.shared.saveOrUpdateEvent(eventPreload.model) { (success) in
                completion()
            }
        } else {
            completion()
        }
    }
    
    func areAllFieldsEntered() -> Bool {
        if giftService.name == nil || giftService.name.isEmpty || giftService.status == nil {
            UIAlertController.showAlertWithTitle("Name and Status of the gift cannot be empty", message: "Please complete these fields.")
            return false
        } else if giftService.contacts.isEmpty && self.prepopulatedContact == nil {
            UIAlertController.showAlertWithTitle("At least one contact is required for the gift", message: "Please add one or more contacts")
            return false
        }
        return true
    }
    
    // MARK: Bar Item Actions
    
    func saveButtonTapped() {
        hideKeyboard()
        if areAllFieldsEntered() {
            saveGift()
        }
    }
    
    func saveGift() {
        HUDManager.showLoadingHUD()
        self.saveGiftForSelectedEvent { [unowned self] in
            self.saveGiftForSelectedContacts { [unowned self] in
                self.saveContactsForSelectEvent { [unowned self] in
                    self.saveOrUpdateGift()
                }
            }
        }
    }
    
    func deleteButtonTapped() {
        AlertManager.shared.showDeleteAlertViewFrom(self, deleteButtonTitle: "Delete gift", completion: { [unowned self] (buttonPressed) in
            if buttonPressed == DeleteButtonPressed.delete {
                HUDManager.showNetworkActivityIndicator()
                FirebaseManager.shared.deleteGiftFromDatabase(self.gift) { [weak self] (success) in
                    HUDManager.hideNetworkActivityIndicator()
                    if let strongSelf = self {
                        if success {
                            let _ = strongSelf.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        })
    }
    
    func backButtonTapped() {
        hideKeyboard()
        if giftService != originalGiftService {
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
}

// MARK: - Tableview DataSource and Delegate

extension GiftDetailViewController: UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate {
    
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
        case Section.contactInfo:
            if indexPath.row == 0 { return 40.0 }
            else if indexPath.row == giftService.contacts.count + 1 && giftService.inOutType == Gift.InOutType.given.rawValue {
                return 0
            } else if indexPath.row == giftService.contacts.count + 1 && giftService.inOutType == Gift.InOutType.recieved.rawValue {
                return 96.0
            }
            else { return 60.0 }
        case Section.eventInfo:
            if indexPath.row == 0 { return 40.0 }
            else { return 60.0 }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case Section.info:
            return 1 // always static
        case Section.contactInfo:
            return giftService.contacts.count + 2 // 1 is for extra 'add' cell, 1 is for 'thank you sent' cell
        case Section.eventInfo:
            if giftService.eventPreload != nil {
                return 2
            }
            return 1
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
        switch GiftDetailViewController.Section(rawValue: section)! {
            case .info:
                universalTableHeaderView.mainTitleLabel.text = GiftDetailViewController.Section.info.description
                universalTableHeaderView.iconImageView.image = UIImage(named: "giftInfoSection")
                universalTableHeaderView.backgroundColor = Constants.appVioletColor
            case .contactInfo:
                universalTableHeaderView.mainTitleLabel.text = GiftDetailViewController.Section.contactInfo.description
                universalTableHeaderView.iconImageView.image = UIImage(named: "contactInfoSection")
                universalTableHeaderView.backgroundColor = Constants.appPurpleColor
            case .eventInfo:
                universalTableHeaderView.mainTitleLabel.text = GiftDetailViewController.Section.eventInfo.description
                universalTableHeaderView.iconImageView.image = UIImage(named: "dateInfoSection")
                universalTableHeaderView.backgroundColor = Constants.appBlueColor
                universalTableHeaderView.bottomLineView.isHidden = true
            }
        return universalTableHeaderView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
            case Section.info:
                let cell = tableView.dequeueReusableCell(withIdentifier: GiftInfoTableViewCellIdentifier, for: indexPath) as! GiftInfoTableViewCell
                cell.delegate = self
                cell.setContentFromService(giftService)
                return cell
        case Section.contactInfo:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: UniversalAddingTableViewCellIdentifier, for: indexPath) as! UniversalAddingTableViewCell
                cell.delegate = self
                cell.setAddButtonBackground(indexPath.section)
                return cell
            } else if indexPath.row == giftService.contacts.count + 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: OneActionTableViewCellIdentifier, for: indexPath) as! OneActionTableViewCell
                cell.delegate = self
                cell.setContentFrom(giftService)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: UniversalDetailTableViewCellIdentifier, for: indexPath) as! UniversalDetailTableViewCell
                cell.delegate = self
                cell.rightButtons = [MGSwipeService.deleteButton()]
                cell.setContentFromUserContact(giftService.contacts[indexPath.row - 1].model)
                cell.shareButton.isHidden = true // force hide
                return cell
            }
        case Section.eventInfo:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: UniversalAddingTableViewCellIdentifier, for: indexPath) as! UniversalAddingTableViewCell
                cell.delegate = self
                cell.setAddButtonBackground(indexPath.section)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: UniversalDetailTableViewCellIdentifier, for: indexPath) as! UniversalDetailTableViewCell
                cell.delegate = self
                cell.rightButtons = [MGSwipeService.deleteButton()]
                cell.setEventContentFrom(giftService.eventPreload!.model)
                cell.shareButton.isHidden = true // force hide
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debugPrint(indexPath) // default
        if indexPath.section == Section.contactInfo.rawValue {
            if giftService.contacts.isEmpty { return }
            else if indexPath.row == giftService.contacts.count + 1 { return }
            let contact = self.giftService.contacts[indexPath.row - 1]
            NavigationManager.shared.showDetailedContactViewControllerFrom(self, withContact: contact.model, andWithMode: .old, prepopulatedGift: getGiftPreloadFromCurrentGift(), prepopulatedEvent: self.prepopulatedEvent)
            
        } else if indexPath.section == Section.eventInfo.rawValue {
            if giftService.eventPreload == nil { return }
            NavigationManager.shared.showEventDetailViewControllerFrom(self, withEvent: self.giftService.eventPreload!.model, andWithMode: .old, prepopulatedGift: getGiftPreloadFromCurrentGift(), prepopulatedContact: self.prepopulatedContact)
        }
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        let action = SwipeTableViewCellAction(rawValue: index)
        if action == .delete {
            if let indexPath = self.tableView.indexPath(for: cell) {
                if indexPath.section == Section.contactInfo.rawValue {
                    let contactToRemove = giftService.contacts[indexPath.row - 1]
                    giftService.contacts.remove(at: indexPath.row - 1)
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    if self.mode == .old {
                        HUDManager.showLoadingHUD()
                        deleteGiftForSelectedContact(contactPreload: contactToRemove, completion: { [unowned self] in
                            self.saveOrUpdateGift()
                            HUDManager.hideLoadingHUD()
                        })
                    }
                } else { // event info
                    let eventToRemove = giftService.eventPreload
                    giftService.eventPreload = nil
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    if self.mode == .old {
                        deleteGiftFromSelectedEvent(eventPreload: eventToRemove!, completion: { [unowned self] in
                            self.saveOrUpdateGift()
                            HUDManager.hideLoadingHUD()
                        })
                    }
                }
            }
        }
        return true
    }
}

extension GiftDetailViewController: GiftInfoTableViewCellDelegate, TextPickerViewControllerDelegate, ValuePickerViewControllerDelegate, UniversalAddingTableViewCellDelegate, OneActionTableViewCellDelegate {
    func descriptionButtonDidTouchFrom(_ cell: GiftInfoTableViewCell) {
        showTextActionSheet(giftService.description)
    }
    
    func textFieldFinishedInputWith(_ text: String?, textFieldType: GiftInfoTableViewCell.TextFieldType) {
        switch textFieldType {
        case .giftName:
            giftService.name = text ?? ""
        case .giftPrice:
            if let text = text {
                giftService.price = text
            } else {
                giftService.price = nil
            }
        }
        headerTitleLabel.text = giftService.name
    }
    
    func inOutSegmentedControlChangedValue(_ value: Int) {
        giftService.inOutType = value
        self.tableView.reloadSections(IndexSet(integer: Section.contactInfo.rawValue), with: .none)
    }
    
    func recieptSegmentedControlChangedValue(_ value: Int) {
        giftService.recieptType = value
    }
    
    func typeButtonDidTouchFrom(_ cell: GiftInfoTableViewCell) {
        self.valuePickerTypeChosen = .giftType
        showValueActionSheet(Gift.Category.allValuesWithDescription, title: "Type", selectedValueIndex: giftService.type)
    }
    
    func statusButtonDidTouchFrom(_ cell: GiftInfoTableViewCell) {
        self.valuePickerTypeChosen = .giftStatus
        showValueActionSheet(Gift.Status.allValuesWithDescription, title: "Status", selectedValueIndex: giftService.status)
    }
    
    func textPickerViewControllerSelected(_ text: String) {
        giftService.description = text
        tableView.reloadData()
    }
    
    func valuePickerViewControllerWasSelectedAtIndex(_ index: Int) {
        switch self.valuePickerTypeChosen {
        case ValuePickerType.giftStatus:
            giftService.status = Gift.Status.allValues[index].rawValue
        case ValuePickerType.giftType:
            giftService.type = Gift.Category.allValues[index].rawValue
        }
        tableView.reloadData()
    }
    
    func addingButtonDidTouchFrom(_ cell: UniversalAddingTableViewCell) {
        if giftService.name == nil || giftService.name.isEmpty || giftService.status == nil {
            UIAlertController.showAlertWithTitle("Name and Status of the gift cannot be empty", message: "Please complete these fields")
            return
        }
        if let indexPath = tableView.indexPath(for: cell) {
            switch Section(rawValue: indexPath.section)! {
            case .contactInfo:
                var selectedContacts = [Contact]()
                for contact in giftService.contacts {
                    selectedContacts.append(contact.model)
                }
                showSelectContactsViewControllerWithAlreadySelectedContacts(selectedContacts)
            case .eventInfo:
                if giftService.eventPreload != nil {
                    return UIAlertController.showAlertWithTitle("Gift can have only one event.", message: "To add a new event to this gift, please remove the existing one.")
                }
                showSelectEventViewController()
            default:
                break
            }
        }
    }
    
    func imagesCollectionViewDidSelectImageAtIndex(_ index: Int) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelActionButton)
        
        let showImage = UIAlertAction(title: "Show image", style: .default) { action -> Void in
            self.showImageGalleryWithIndex(index)
        }
        actionSheetController.addAction(showImage)
        let deleteImage = UIAlertAction(title: "Delete image", style: .destructive) { action -> Void in
            self.giftService.images.remove(at: index)
            self.tableView.reloadSections(IndexSet(integer: Section.info.rawValue), with: .none)
            self.setContentForController()
        }
        actionSheetController.addAction(deleteImage)
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.center.x, y: UIScreen.main.bounds.height, width: 1, height: 10)
        }
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func actionButtonTappedFromCell(_ cell: OneActionTableViewCell) {
        let inOutType = Gift.InOutType(rawValue: giftService.inOutType)!
//        if giftService.thankYouSent {
//            return UIAlertController.showAlertWithTitle("", message: "'Thank you' letter was already sent.")
//        }
        if giftService.name == nil || giftService.name.isEmpty || giftService.status == nil {
            return UIAlertController.showAlertWithTitle("Title and status cannot be empty", message: "Please enter these fields")
        }
        if inOutType == .recieved {
            if !giftService.contacts.isEmpty {
                var contacts = [Contact]()
                for contact in giftService.contacts {
                    if contact.model != nil {
                        contacts.append(contact.model)
                    }
                }
                var shareString = "Hi,\n\n"
//                var shareString = "Hi, "
//                for contact in contacts {
//                    shareString.append("\(contact.fullName), ")
//                }
//                shareString.append("\n")
                shareString.append("Thank you for the \(giftService.name!).\n\nRegards,\n\(UserManager.shared.currentUser.fullName)\n\n")
                shareString.append("Sent from GiftLog – your essential gift management app!\n")
                SSHelperManager.shared.showShareActionSheetFromController(self, withText: shareString)
                tableView.reloadData()
            } else {
                UIAlertController.showAlertWithTitle("You did not add any contact for the gift", message: "Please add at least one contact")
            }
        } else {
            UIAlertController.showAlertWithTitle("This gift is given by you.", message: "You cannot send 'Thank you' message.")
        }
    }
    
    func secondActionButtonTappedFromCell(_ cell: OneActionTableViewCell) {
        let alertStyle = (DeviceType.IS_IPAD) ? UIAlertControllerStyle.alert : UIAlertControllerStyle.actionSheet
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: alertStyle)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelActionButton)
        
        let yesActionButton = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            self.giftService.thankYouSent = true
            self.tableView.reloadSections(IndexSet(integer: Section.contactInfo.rawValue), with: .none)
        }
        actionSheetController.addAction(yesActionButton)
        
        let noActionButton = UIAlertAction(title: "No", style: .default) { action -> Void in
            self.giftService.thankYouSent = false
            self.tableView.reloadSections(IndexSet(integer: Section.contactInfo.rawValue), with: .none)
        }
        actionSheetController.addAction(noActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
}

extension GiftDetailViewController: SelectContactsViewControllerDelegate, SelectEventViewControllerDelegate {
    func selectContactsViewControllerDismissedWith(_ contacts: [Contact]) {
        var contactPreloads = [ContactPreload]()
        for contact in contacts {
            let contactPreload = ContactPreload()
            contactPreload.identifier = contact.identifier
            contactPreload.model = contact
            contactPreloads.append(contactPreload)
        }
        giftService.contacts = contactPreloads
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: Section.contactInfo.rawValue), at: UITableViewScrollPosition.top, animated: false)
        if mode == .old {
            saveGift()
        }
    }
    func selectEventViewControllerDismissedWith(_ event: Event) {
        let eventPreload = EventPreload()
        eventPreload.model = event
        eventPreload.identifier = event.identifier
        giftService.eventPreload = eventPreload
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: Section.eventInfo.rawValue), at: UITableViewScrollPosition.top, animated: false)
        if mode == .old {
            saveGift()
        }
    }
}

extension GiftDetailViewController: SwiftPhotoGalleryDataSource, SwiftPhotoGalleryDelegate {
    
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return giftService.images.count
    }
    
    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        let imageView = UIImageView()
        imageView.kf.setImage(with: URL(string: giftService.images[forIndex].url)!, placeholder: nil, options: nil, progressBlock: nil) { (image, var1, var2, var3) in
        }
        return imageView.image
    }
    
    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        dismiss(animated: true, completion: nil)
    }
}
