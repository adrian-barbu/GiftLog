//
//  ProfileDetailViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/25/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit
import FDTake
import MGSwipeTableCell

class UserDetailViewController: BaseViewController {

    
    // MARK: Enums
    
    enum Mode {
        case new
        case old
    }
    
    enum Section: Int {
        
        // MARK: Cases
        
        case info = 0
        case dates = 1
        case wishlist = 2
        case actions = 3
        
        // MARK: Properties
        
        static let allValues = [info, dates, wishlist, actions]
        
        var description: String {
            switch self {
            case .info: return "INFO"
            case .dates: return "DATES"
            case .wishlist: return "WISHLIST"
            case .actions: return "ACTIONS"
            }
        }
    }
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: STCollapseTableView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    
    
    //MARK: - Variables
    
    internal var mode: Mode!
    internal var user: User!
    fileprivate var fdTakeController: FDTakeController!
    fileprivate var userService: UserService!
    fileprivate var userDateSelectedIndexPath: IndexPath?
    fileprivate var headers = [UniversalTableHeaderView]()
    fileprivate var originFrame: CGRect!
    fileprivate var textPickedType: TextPickerType!
    
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarItems()
        setUserService()
        setTableView()
        setContentForController()
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeViewControllerForNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setOriginFrame()
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
    
    //MARK: - Methods
    
    func subscribeViewControllerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateViewHeadersFromNotification(_:)), name: NSNotification.Name(rawValue: "TableViewWasCollapsed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func setNavigationBarItems() {
//        addSearchNavigationBarButton()
        if mode == Mode.old {
            let backBarItem = UIBarButtonItem(image: UIImage(named: "backGreen"), style: .plain, target: self, action: #selector(self.backButtonTapped))
            self.navigationItem.leftBarButtonItem = backBarItem
            let saveBarItem = UIBarButtonItem(image: UIImage(named: "save"), style: .plain, target: self, action: #selector(self.saveButtonTapped))
            self.navigationItem.rightBarButtonItem = saveBarItem
        } else { }
    }
    
    func setUserService() {
        userService = UserService(user: user)
    }
    
    func setContentForController() {
        imageButton.imageView!.contentMode = .scaleAspectFill
        imageButton.contentVerticalAlignment = .fill
        imageButton.contentHorizontalAlignment = .fill
        if let url = userService.avatar {
            self.imageButton.kf.setImage(with: URL(string: url), for: .normal)
            self.imageButton.kf.setImage(with: URL(string: url), for: .highlighted)
        } else if let data = userService.imageData {
            self.imageButton.setImage(UIImage(data: data), for: .normal)
            self.imageButton.setImage(UIImage(data: data), for: .highlighted)
        }
        headerTitleLabel.text = userService.fullName
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
        tableView.register(UINib(nibName: UserActionTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UserActionTableViewCellIdentifier)
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
            
            self.imageButton.setImage(image, for: .normal)
            self.imageButton.setImage(image, for: .highlighted)
            self.userService.imageData = UIImageJPEGRepresentation(image, 0.5)
        }
        self.fdTakeController.presentingRect = imageButton.frame
        self.fdTakeController.presentingView = self.view
        self.fdTakeController.present()
    }
    
    func showDateActionSheet(_ contactDate: ContactDate? = nil) {
        let dateAndTitlePickerViewController = DateAndTitlePickerViewController(nibName: "DateAndTitlePickerViewController", bundle: nil)
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
    
    func saveOrUpdateUser() {
        user.updateUserFromService(userService)
        HUDManager.showLoadingHUD()
        FirebaseManager.shared.saveOrUpdateUser(user) {(success) in
            if success {
                HUDManager.showSuccessHUD()
                NotificationCenterManager.postNotificationThatUserProfileWasUpdated()
            } else {
                HUDManager.showErrorHUD()
            }
        }
    }
    
    func areRequiredFieldsEntered() -> Bool {
        if let firstName = userService.firstName {
            if firstName.isEmpty {
                return false
            }
        } else {
            return false
        }
        if let lastName = userService.lastName {
            if lastName.isEmpty {
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    
    // MARK: Bar Item Actions
    
    func backButtonTapped() {
        UIApplication.shared.statusBarStyle = .lightContent
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveButtonTapped() {
        self.hideKeyboard()
        if !areRequiredFieldsEntered() {
            return UIAlertController.showAlertWithTitle("First name and last name cannot be empty", message: "Please fill these fields.")
        }
        if let data = self.userService.imageData {
            HUDManager.showLoadingHUD()
            FirebaseManager.shared.uploadUserAvatarImage(data, forUser: user, completion: { [unowned self] (url) in
                HUDManager.hideLoadingHUD()
                if let url = url {
                    self.userService.avatar = url
                    self.userService.imageData = nil
                }
                self.saveOrUpdateUser()
            })
        } else {
            self.saveOrUpdateUser()
        }
    }
    
    
    //MARK: - Actions
    
    @IBAction func imageButtonTapped(_ sender: Any) {
        showFDTakeController()
    }
    
    @IBAction func localNotificationsValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 { // local notifiations on
            RemindService.shared.saveLocalNotificationsForEvents(events: UserEventsManager.shared.userEvents, completion: { 
                
            })
        } else { // local notifiations off
            RemindService.shared.removeLocalNotificationsForEvents(events: UserEventsManager.shared.userEvents, completion: {
                
            })
        }
    }
}


// MARK: Tableview DataSource and Delegate

extension UserDetailViewController: UITableViewDataSource ,UITableViewDelegate, MGSwipeTableCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allValues.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.universalSectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch Section(rawValue: indexPath.section)! {
        case Section.info:
            return UserContactInfoTableViewCellHeight
        case Section.dates:
            if indexPath.row == 0 { return 40.0 }
            else { return 50.0 }
        case Section.wishlist:
            return UITableViewAutomaticDimension
        case Section.actions:
            return 210
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case Section.info:
            return 1 // always static
        case Section.dates:
            return userService.dates.count + 1 // extra cell for adding
        case Section.wishlist:
            return 1 // always static
        case Section.actions:
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
            universalTableHeaderView.mainTitleLabel.text = "WISHLIST"
            universalTableHeaderView.iconImageView.image = UIImage(named: "wishlistInfoSection")
            universalTableHeaderView.backgroundColor = Constants.appBlueColor
        case 3:
            universalTableHeaderView.mainTitleLabel.text = "ACTIONS"
            universalTableHeaderView.iconImageView.image = UIImage(named: "settingsInfoSection")
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
            cell.setUserContentFromService(userService)
            return cell
        case Section.dates:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: UniversalAddingTableViewCellIdentifier, for: indexPath) as! UniversalAddingTableViewCell
                cell.delegate = self
//                cell.setUnderlineTitleButton("Add date")
                cell.setAddButtonBackground(indexPath.section)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: ContactDateTableViewCellIdentifier, for: indexPath) as! ContactDateTableViewCell
                cell.ownDelegate = self
                cell.delegate = self
                cell.setContentFrom(userService.dates[indexPath.row - 1])
                cell.rightButtons = [MGSwipeService.deleteButton()]
                return cell
            }
        case Section.wishlist:
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactWishlistTableViewCellIdentifier, for: indexPath) as! ContactWishlistTableViewCell
            cell.delegate = self
            cell.setUserContentFromService(userService)
            return cell
        case Section.actions:
            let cell = tableView.dequeueReusableCell(withIdentifier: UserActionTableViewCellIdentifier, for: indexPath) as! UserActionTableViewCell
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case Section.info:
        return // nothing todo here
        case Section.dates:
            return
        case Section.wishlist:
            return // nothing todo here
        case Section.actions:
            return // nothing todo here
        }
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        let action = SwipeTableViewCellAction(rawValue: index)
        if action == .delete {
            if let indexPath = self.tableView.indexPath(for: cell) {
                self.userService.dates.remove(at: indexPath.row - 1)
                self.tableView.reloadData()
            }
        }
        return true
    }
    
    func notificationsButtonDidTouchFrom(_ cell: UserActionTableViewCell) {
        if cell.notificationsSegmentedControl.selectedSegmentIndex == 0 {
            UserDefaultsManager.shared.areLocalNotificationsUsed = true
            RemindService.shared.saveLocalNotificationsForEvents(events: UserEventsManager.shared.userEvents, completion: {
            })
        } else {
            UserDefaultsManager.shared.areLocalNotificationsUsed = false
            RemindService.shared.removeLocalNotificationsForEvents(events: UserEventsManager.shared.userEvents, completion: nil)
        }
    }
}

// MARK: User Cells Delegates

extension UserDetailViewController: ContactInfoTableViewCellDelegate, ContactDateTableViewCellDelegate, ContactWishlistTableViewCellDelegate, UserActionTableViewCellDelegate, UniversalAddingTableViewCellDelegate, TextPickerViewControllerDelegate {
    
    func textFieldFinishedInputWith(_ text: String?, textFieldType: ContactInfoTableViewCell.TextFieldType) {
        switch textFieldType {
        case .firstName:
            userService.firstName = text
        case .lastName:
            userService.lastName = text
        case .nickName:
            userService.nickName = text
        case .email:
            userService.email = text
        case .phone:
           userService.phoneNumber = text
        }
        headerTitleLabel.text = userService.fullName
    }
    
    func textPickerViewControllerSelected(_ text: String) {
        if textPickedType == .likes {
            userService.likes = text
        } else if textPickedType == .dislikes {
            userService.dislikes = text
        }
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: Section.wishlist.rawValue), at: UITableViewScrollPosition.top, animated: false)
    }
    
    func inviteButtonTappedFromCell(_ cell: ContactInfoTableViewCell) {
    }
    
    func addingButtonDidTouchFrom(_ cell: UniversalAddingTableViewCell) {
        userDateSelectedIndexPath = nil
        showDateActionSheet()
    }
    
    func logOutButtonDidTouchFrom(_ cell: UserActionTableViewCell) {
        AlertManager.shared.showLogoutAlertViewFromController(self)
    }
    
    func deleteButtonDidTouchFrom(_ cell: UserActionTableViewCell) {
        AlertManager.shared.showDeleteUserAlertViewFromController(self)
    }
    
    func csvButtonDidTouchFrom(_ cell: UserActionTableViewCell) {
        UserManager.shared.creatCSV()
    }
    
    func dateButtonTappedFromCell(_ cell: ContactDateTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            userDateSelectedIndexPath = indexPath
            showDateActionSheet(userService.dates[indexPath.row - 1])
        }
    }
    
    func likeButtonDidTouchFrom(_ cell: ContactWishlistTableViewCell) {
        showTextActionSheet(userService.likes)
        self.textPickedType = .likes
    }
    
    func dislikeButtonDidTouchFrom(_ cell: ContactWishlistTableViewCell) {
        showTextActionSheet(userService.dislikes)
        self.textPickedType = .dislikes
    }
}

extension UserDetailViewController: DateAndTitlePickerViewControllerDelegate {
    func datePickerViewControllerSelectedValue(_ date: Date, _ name: String) {
        if name.isEmpty {
            UIAlertController.showAlertWithTitle("Title cannot be empty", message: "Please enter a title for this date")
        } else {
            if let indexPath = self.userDateSelectedIndexPath { // it is old date, we update it
                var contactDate = userService.dates[indexPath.row - 1]
                contactDate.name = name
                contactDate.timestamp = date.timestamp()
                userService.dates[indexPath.row - 1] = contactDate
            } else { // it is new date
                var contactDate = ContactDate()
                contactDate.name = name
                contactDate.timestamp = date.timestamp()
                userService.dates.append(contactDate)
            }
            tableView.reloadData()
        }
    }
}
