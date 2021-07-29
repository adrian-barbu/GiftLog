//
//  MenuViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/30/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit
import Kingfisher

class MenuViewController: BaseViewController {

    
    // MARK: Views
    
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileButton: UIButton!
    
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        updateTableViewHeaderOfCurrentUser()
        subscribeViewControllerForNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    
    // MARK: Custom methods
    
    func setTableView() {
        tableView.register(UINib(nibName: MenuTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: MenuTableViewCellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.reloadData()
    }
    
    func subscribeViewControllerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTableViewHeaderOfCurrentUser), name: NSNotification.Name(rawValue: NotificationCenterManager.NotificationNames.UserProfileWasUpdated), object: nil)
    }
    
    func updateTableViewHeaderOfCurrentUser() {
        userFullNameLabel.text = UserManager.shared.currentUser.fullName
        if let url = UserManager.shared.currentUser.avatarUrl {
            userAvatarImageView.kf.setImage(with: url)
        } else {
            userAvatarImageView.image = UIImage(named: "maleThumb")
        }
    }
    
    
    //MARK: - IBActions
    
    @IBAction func profileButtonDidTouch(_ sender: Any) {
        NavigationManager.shared.presentUserDetailViewControllerFrom(self, withUser: UserManager.shared.currentUser, andWithMode: .old)
    }
}


// MARK: Tableview DataSource and Delegate

extension MenuViewController: UITableViewDataSource ,UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55 // default
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuService.shared.arrayOfMenuActionIcons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuTableViewCellIdentifier, for: indexPath) as! MenuTableViewCell
        cell.menuIconImageView.image = UIImage(named: MenuService.shared.arrayOfMenuActionIcons[indexPath.row])
        cell.menuTitleLabel.text = MenuService.shared.arrayOfMenuTitles[indexPath.row]
        cell.backgroundColor = MenuService.shared.getMenuCellBackgroundColorFromCellIndexPath(indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == MenuService.shared.arrayOfMenuActionIcons.count - 1 { // log out
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // your function here
                AlertManager.shared.showLogoutAlertViewFromController(self)
            }
        } else if indexPath.row <= 3 {
            NavigationManager.shared.showMenuFrontViewControllerFromController(self, menuAction: MenuAction(rawValue: indexPath.row)!)
            tableView.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.tableView.isUserInteractionEnabled = true
            }
        } else {
            switch MenuAction(rawValue: indexPath.row)! {
            case .openPrivacy:
                NavigationManager.shared.presentDocumentsViewControllerFromController(self, withMode: .privacyPolicy)
            case .openTerms:
                NavigationManager.shared.presentDocumentsViewControllerFromController(self, withMode: .terms)
            case .shareApp:
                SSHelperManager.shared.showShareActionSheetFromController(self, withText: "Hi,\n\nCheck out GiftLog – it’s a great, free, gift management app I’m using to log gifts, send thank you messages and manage wish lists!\n\nRegards,\n\(UserManager.shared.currentUser.fullName)\n")
            case .emailGiftData:
                UserManager.shared.creatCSV()
            case .contactUs:
                NavigationManager.shared.presentDocumentsViewControllerFromController(self, withMode: .contactUs)
            case .faq:
                NavigationManager.shared.presentDocumentsViewControllerFromController(self, withMode: .faq)
            default:
                break
            }
        }
        MenuService.shared.selectedMenuActionIndexPath = indexPath
        tableView.reloadData()
    }
}

