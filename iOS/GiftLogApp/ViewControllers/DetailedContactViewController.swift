//
//  DetailedContactViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/11/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit
import FDTake
import MGSwipeTableCell

@objc protocol DetailedContactViewControllerDelegate: class {
    @objc optional func detailContactControllerDismissedWithContact(_ contact: Contact)
}

class DetailedContactViewController: BaseViewController {

    // MARK: Enums
    
    enum Section: Int {
        
        // MARK: Cases
        
        case info = 0
        case dates = 1
        case gifts = 2
        case wishlist = 3
        
        // MARK: Properties
        
        static let allValues = [info, dates, gifts, wishlist]

        var description: String {
            switch self {
            case .info: return "INFO"
            case .dates: return "DATES"
            case .gifts: return "GIFTS"
            case .wishlist: return "WISHLIST"
            }
        }
    }
    
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: STCollapseTableView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    
    
    // MARK: Vars
    
    weak var delegate: DetailedContactViewControllerDelegate?
    internal var mode: ControllerDetailPresentationMode!
    internal var contact: Contact!
    fileprivate var fdTakeController:FDTakeController!
    fileprivate var contactService: ContactService!
    fileprivate var originalContactService: ContactService!
    fileprivate var contactDateSelectedIndexPath: IndexPath?
    fileprivate var headers = [UniversalTableHeaderView]()
    fileprivate var originFrame: CGRect!
    fileprivate var textPickedType: TextPickerType!
    fileprivate var popupSave = false
    var backBarItem: UIBarButtonItem!
    
    internal var prepopulatedGift: GiftPreload? /// GEC_Relationship Functional
    internal var prepopulatedEvent: EventPreload? /// GEC_Relationship Functional
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarItems()
        setContactService()
        setTableView()
        setContentForController()
        preloadAllNeededData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        hideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if tableView.isOpenSection(UInt(Section.gifts.rawValue)) {
            self.tableView.reloadSections(IndexSet(integer: Section.gifts.rawValue), with: .none)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setOriginFrame()
        subscribeViewControllerForNotifications()
    }
    
    deinit {
        self.tableView.delegate = nil
    }
    
    // MARK: Keyboard methods
    
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
    
    func setPrepopulatingDataIfNeeded() {
        var arrayOfBlockedSectionIndexs = [Int]()
        if let prepopulatedGift = prepopulatedGift {
            if self.contactService.getIndexOfGiftAtArrayFrom(prepopulatedGift.identifier) == nil {
                contactService.gifts.append(prepopulatedGift)
            }
            arrayOfBlockedSectionIndexs.append(Section.gifts.rawValue)
        }
        tableView.blockedSectionIndexes = arrayOfBlockedSectionIndexs as! NSMutableArray
    }
    
    func handleBlockedSectionNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let indexOfCollapsedSection = (userInfo["sectionIndex"] as! NSNumber).intValue
            switch Section(rawValue: indexOfCollapsedSection)! {
            case .gifts:
                UIAlertController.showAlertWithTitle("", message: "Gift info is already populated. To amend, please open ‘Gifts’ screen.")
            default: break
            }
        }
    }
    
    func setContactService() {
        contactService = ContactService(contact: contact)
        originalContactService = ContactService(contact: contact)
    }
    
    func setContentForController() {
        imageButton.imageView!.contentMode = .scaleAspectFill
        imageButton.contentVerticalAlignment = .fill
        imageButton.contentHorizontalAlignment = .fill
        if let url = contactService.avatar {
            self.imageButton.kf.setImage(with: URL(string: url), for: .normal)
            self.imageButton.kf.setImage(with: URL(string: url), for: .highlighted)
        } else if let data = contactService.imageData {
            self.imageButton.setImage(UIImage(data: data), for: .normal)
            self.imageButton.setImage(UIImage(data: data), for: .highlighted)
        }
        headerTitleLabel.text = contactService.fullName
        tableView.reloadData()
    }
    
    func setTableView() {
        tableView.estimatedRowHeight = 44.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.tableFooterView = UIView.emptyView
        tableView.register(UINib(nibName: ContactInfoTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: ContactInfoTableViewCellIdentifier)
        tableView.register(UINib(nibName: ContactDateTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: ContactDateTableViewCellIdentifier)
        tableView.register(UINib(nibName: ContactWishlistTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: ContactWishlistTableViewCellIdentifier)
        tableView.register(UINib(nibName: UniversalAddingTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UniversalAddingTableViewCellIdentifier)
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
            
            self.imageButton.setImage(image, for: .normal)
            self.imageButton.setImage(image, for: .highlighted)
            self.contactService.imageData = UIImageJPEGRepresentation(image, 0.5)
        }
        self.fdTakeController.presentingRect = imageButton.frame
        self.fdTakeController.presentingView = self.view
        self.fdTakeController.present()
    }
    
    func showDateActionSheet(_ contactDate: ContactDate? = nil) {
        let dateAndTitlePickerViewController = DateAndTitlePickerViewController(nibName: "DateAndTitlePickerViewController", bundle: nil)
        dateAndTitlePickerViewController.pickerMode = .date
        dateAndTitlePickerViewController.modalPresentationStyle = .overCurrentContext
        dateAndTitlePickerViewController.delegate = self
        if let contactDate = contactDate {
            dateAndTitlePickerViewController.titleLabelValue = contactDate.name
            dateAndTitlePickerViewController.initialDate = Date(timeIntervalSince1970: TimeInterval(contactDate.timestamp))
        } else {
            dateAndTitlePickerViewController.titleLabelValue = ""
            dateAndTitlePickerViewController.initialDate = Date()
        }
        self.present(dateAndTitlePickerViewController, animated: false, completion: nil)
    }
    
    func showTextActionSheet(_ text: String?) {
        let textPickerViewController = TextPickerViewController(nibName: "TextPickerViewController", bundle: nil)
        textPickerViewController.delegate = self
        if let text = text {
            textPickerViewController.initialText = text
        }
        self.present(textPickerViewController, animated: true, completion: nil)
    }
    
    /**  Method that saves or updates contact with image. Or even without image data. */
    func saveOrUpdateContactWithImage() {
        if let data = self.contactService.imageData {
            HUDManager.showLoadingHUD()
            FirebaseManager.shared.uploadContactAvatarImage(data, forContact: contact, completion: { [unowned self] (url) in
                HUDManager.hideLoadingHUD()
                if let url = url {
                    self.contactService.avatar = url
                    self.contactService.imageData = nil
                }
                self.saveOrUpdateContact()
            })
        } else {
            self.saveOrUpdateContact()
        }
    }
    
    /// GEC_Relationship Functional
    func getContactPreloadFromCurrentContact() -> ContactPreload {
        let contactPreload = ContactPreload()
        contactPreload.model = self.contact
        contactPreload.identifier = self.contact.identifier
        return contactPreload
    }
    
    func saveContact() {
        HUDManager.showLoadingHUD()
        saveContactForSelectedGifts { [unowned self] in
            self.saveOrUpdateContactWithImage()
        }
    }
    
    func saveOrUpdateContact() {
        contact.updateContactFromService(contactService)
        originalContactService = ContactService(contact: contact)
        FirebaseManager.shared.saveOrUpdateContact(contact) { [unowned self] (success) in
            if success {
                HUDManager.showSuccessHUD()
                if self.mode == .new {
                    self.delegate?.detailContactControllerDismissedWithContact!(self.contact)
                    if let event = self.prepopulatedEvent {
                        NotificationCenterManager.postNotificationThatContact(self.getContactPreloadFromCurrentContact(), wasCreatedForEventWithIdentifier: event.identifier)
                    }
                    let _ = self.navigationController?.popViewController(animated: true)
                } else {
                    if let event = self.prepopulatedEvent {
                        NotificationCenterManager.postNotificationThatContact(self.getContactPreloadFromCurrentContact(), wasCreatedForEventWithIdentifier: event.identifier)
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
    
    func saveContactForSelectedGifts(completion: @escaping () -> Void) {
        let gifts = contactService.gifts
        if gifts.isEmpty {
            return completion()
        }
        var counter = 0
        for gift in gifts {
            var isContactPreloadFound = false
            for contactPreload in gift.model.contacts {
                if contactPreload.identifier == self.contact.identifier {
                    isContactPreloadFound = true
                    break
                }
            }
            if !isContactPreloadFound {
                let contactPreload = ContactPreload()
                contactPreload.identifier = self.contact.identifier
                gift.model.contacts.append(contactPreload)
                FirebaseManager.shared.saveOrUpdateGift(gift.model, completion: { (success) in
                    counter += 1
                    if counter == gifts.count {
                        completion()
                    }
                })
            } else {
                counter += 1
            }
            if counter == gifts.count {
                completion()
            }
        }
    }
    
    func deleteContactForSelectedGift(giftPreload: GiftPreload, completion: @escaping () -> Void) {
        if let contactIndexToDelete = UserContactsManager.shared.indexOf(contact: self.contact, at: giftPreload.model.contacts) {
            giftPreload.model.contacts.remove(at: contactIndexToDelete)
            FirebaseManager.shared.saveOrUpdateGift(giftPreload.model, completion: { (success) in
                completion()
            })
        } else {
            completion()
        }
    }
    
    func areRequiredFieldsEntered() -> Bool {
        if let firstName = contactService.firstName {
            if firstName.isEmpty {
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    func preloadAllNeededData() {
        preloadGiftsIfNeededWithCompletion { [unowned self] in
            self.setPrepopulatingDataIfNeeded()
            self.tableView.reloadData()
        }
    }
    
    func preloadGiftsIfNeededWithCompletion(_ completion: @escaping () -> Void) {
        if contactService.gifts.isEmpty {
            return completion()
        }
        HUDManager.showLoadingHUD()
        var counter = 0
        for gift in contactService.gifts {
            FirebaseManager.shared.getGiftById(gift.identifier, completion: { [unowned self] (resultGift) in
                if let resultGift = resultGift {
                    if let index = self.contactService.getIndexOfGiftAtArrayFrom(gift.identifier) {
                        self.contactService.gifts[index].model = resultGift
                    }
                } else { // gift was deleted from Firebase, so we should remove it from gifts list too.
                    if let index = self.contactService.getIndexOfGiftAtArrayFrom(gift.identifier) {
                        self.contactService.gifts.remove(at: index)
                        self.originalContactService.gifts.remove(at: index)
                        debugPrint("Caution: Gift was deleted from Firebase, so we should remove it from event.gifts list too. but saves will occur after user press 'save' button.")
                        counter -= 1
                    } else {
                        debugPrint("Error: This model is missed at both Firebase and at service !")
                        // this model is missed at both Firebase and at service
                    }
                }
                counter += 1
                if counter == self.contactService.gifts.count {
                    HUDManager.hideLoadingHUDWithAnimation()
                    completion()
                }
            })
        }
    }
    
    
    // MARK: Bar Item Actions
    
    func saveButtonTapped() {
        self.hideKeyboard()
        if !areRequiredFieldsEntered() {
            return UIAlertController.showAlertWithTitle("First name cannot be empty", message: "Please enter first name.")
        }
        saveContact()
    }
    
    func deleteButtonTapped() {
        AlertManager.shared.showDeleteAlertViewFrom(self, deleteButtonTitle: "Delete contact", completion: { [unowned self] (buttonPressed) in
            if buttonPressed == DeleteButtonPressed.delete {
                HUDManager.showNetworkActivityIndicator()
                FirebaseManager.shared.deleteContactFromDatabase(self.contact) { [weak self] (success) in
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
        if contactService != originalContactService {
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
    
    
    // MARK: IBActions

    @IBAction func imageButtonTapped(_ sender: Any) {
        showFDTakeController()
    }
}


// MARK: Tableview DataSource and Delegate

extension DetailedContactViewController: UITableViewDataSource ,UITableViewDelegate, MGSwipeTableCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allValues.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.universalSectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch Section(rawValue: indexPath.section)! {
        case Section.info:
            return ContactInfoTableViewCellHeight
        case Section.dates:
            if indexPath.row == 0 { return 40.0 }
            else { return 50.0 }
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
        case Section.dates:
            return contactService.dates.count + 1 // extra cell for adding
        case Section.gifts:
            return contactService.gifts.count + 1 // 1 is for extra 'add' cell
        case Section.wishlist:
            return 1 // always static
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var universalTableHeaderView: UniversalTableHeaderView!
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
            universalTableHeaderView.iconImageView.image = UIImage(named: "contactInfoSection")
            universalTableHeaderView.backgroundColor = Constants.appVioletColor
        case 1:
            universalTableHeaderView.mainTitleLabel.text = "DATES"
            universalTableHeaderView.iconImageView.image = UIImage(named: "dateInfoSection")
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
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactInfoTableViewCellIdentifier, for: indexPath) as! ContactInfoTableViewCell
            cell.delegate = self
            cell.setContentFromService(contactService)
            return cell
        case Section.dates:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: UniversalAddingTableViewCellIdentifier, for: indexPath) as! UniversalAddingTableViewCell
                cell.delegate = self
                cell.setAddButtonBackground(indexPath.section)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: ContactDateTableViewCellIdentifier, for: indexPath) as! ContactDateTableViewCell
                cell.ownDelegate = self
                cell.delegate = self
                cell.setContentFrom(contactService.dates[indexPath.row - 1])
                cell.rightButtons = [MGSwipeService.deleteButton()]
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
                cell.setGiftContentFrom(contactService.gifts[indexPath.row - 1].model)
                cell.shareButton.isHidden = true // force hide
                return cell
            }
        case Section.wishlist:
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactWishlistTableViewCellIdentifier, for: indexPath) as! ContactWishlistTableViewCell
            cell.delegate = self
            cell.setContentFromService(contactService)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.gifts.rawValue {
            if contactService.gifts.isEmpty { return }
            let gift = self.contactService.gifts[indexPath.row - 1]
            NavigationManager.shared.showGiftDetailViewControllerFrom(self, withGift: gift.model, andWithMode: .old, prepopulatedEvent: self.prepopulatedEvent, prepopulatedContact: self.getContactPreloadFromCurrentContact())
        }
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        let action = SwipeTableViewCellAction(rawValue: index)
        if action == .delete {
            if let indexPath = self.tableView.indexPath(for: cell) {
                if indexPath.section == Section.dates.rawValue {
                    self.contactService.dates.remove(at: indexPath.row - 1)
                    self.tableView.reloadData()
                } else if indexPath.section == Section.gifts.rawValue {
                    let giftToRemove = self.contactService.gifts[indexPath.row - 1]
                    self.contactService.gifts.remove(at: indexPath.row - 1)
                    self.tableView.reloadData()
                    if self.mode == .old {
                        HUDManager.showLoadingHUD()
                        deleteContactForSelectedGift(giftPreload: giftToRemove, completion: { 
                            self.saveOrUpdateContactWithImage()
                            HUDManager.hideLoadingHUD()
                        })
                    }
                }
            }
        }
        return true
    }
    
    func showGiftDetailViewController() {
        let giftDetailViewController = GiftDetailViewController(nibName: ViewControllerIdentifiers.GiftDetailViewControllerID, bundle: nil)
        giftDetailViewController.delegate = self
        giftDetailViewController.gift = Gift()
        giftDetailViewController.mode = .new
        giftDetailViewController.prepopulatedEvent = self.prepopulatedEvent
        giftDetailViewController.prepopulatedContact = self.getContactPreloadFromCurrentContact()
        self.navigationController?.pushViewController(giftDetailViewController, animated: true)
    }
}


// MARK: Contact Cells Delegates

extension DetailedContactViewController: ContactInfoTableViewCellDelegate, ContactDateTableViewCellDelegate, ContactWishlistTableViewCellDelegate, UniversalAddingTableViewCellDelegate, TextPickerViewControllerDelegate, SelectGiftViewControllerDelegate {
    
    func textFieldFinishedInputWith(_ text: String?, textFieldType: ContactInfoTableViewCell.TextFieldType) {
        switch textFieldType {
        case .firstName:
            contactService.firstName = text
        case .lastName:
            contactService.lastName = text
        case .nickName:
            contactService.nickName = text
        case .email:
            contactService.email = text
        case .phone:
            contactService.phoneNumber = text
        }
        headerTitleLabel.text = contactService.fullName
    }

    func textPickerViewControllerSelected(_ text: String) {
        if textPickedType == .likes {
            contactService.likes = text
        } else if textPickedType == .dislikes {
            contactService.dislikes = text
        }
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: Section.wishlist.rawValue), at: UITableViewScrollPosition.top, animated: false)
    }
    
    func inviteButtonTappedFromCell(_ cell: ContactInfoTableViewCell) {
        if let visibleController = UIViewController.getVisibleViewController(nil) {
            SSHelperManager.shared.showShareActionSheetFromController(visibleController, withText: "Hi,\n\nCheck out GiftLog – it’s a great, free, gift management app I’m using to log gifts, send thank you messages and manage wish lists!\n\nRegards,\n\(UserManager.shared.currentUser.fullName)\n")
        }
    }
    
    func addingButtonDidTouchFrom(_ cell: UniversalAddingTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            switch Section(rawValue: indexPath.section)! {
            case .dates:
                contactDateSelectedIndexPath = nil
                showDateActionSheet()
            case .gifts:
                if !areRequiredFieldsEntered() {
                    return UIAlertController.showAlertWithTitle("First name cannot be empty", message: "Please enter first name.")
                }
                showGiftDetailViewController()
            default:
                break
            }
        }
    }
    
    func dateButtonTappedFromCell(_ cell: ContactDateTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            contactDateSelectedIndexPath = indexPath
            showDateActionSheet(contactService.dates[indexPath.row - 1])
        }
    }
    
    func likeButtonDidTouchFrom(_ cell: ContactWishlistTableViewCell) {
        showTextActionSheet(contactService.likes)
        self.textPickedType = .likes
    }
    
    func dislikeButtonDidTouchFrom(_ cell: ContactWishlistTableViewCell) {
        showTextActionSheet(contactService.dislikes)
        self.textPickedType = .dislikes
    }
    
    func selectGiftViewControllerDismissedWith(_ gift: Gift) {
        //self.mode = .old
        let giftPreload = GiftPreload()
        giftPreload.model = gift
        giftPreload.identifier = gift.identifier
        contactService.gifts.append(giftPreload)
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: Section.gifts.rawValue), at: UITableViewScrollPosition.top, animated: false)
        if mode == .old {
            saveContact()
        }
        
    }
}

extension DetailedContactViewController: DateAndTitlePickerViewControllerDelegate {
    func datePickerViewControllerSelectedValue(_ date: Date, _ name: String) {
        if name.isEmpty {
            UIAlertController.showAlertWithTitle("Title cannot be empty", message: "Please enter a title for this date")
        } else {
            if let indexPath = self.contactDateSelectedIndexPath { // it is old date, we update it
                var contactDate = contactService.dates[indexPath.row - 1]
                contactDate.name = name
                contactDate.timestamp = date.timestamp()
                contactService.dates[indexPath.row - 1] = contactDate
            } else { // it is new date
                var contactDate = ContactDate()
                contactDate.name = name
                contactDate.timestamp = date.timestamp()
                contactService.dates.append(contactDate)
            }
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: 0, section: Section.dates.rawValue), at: UITableViewScrollPosition.top, animated: false)
        }
    }
}
