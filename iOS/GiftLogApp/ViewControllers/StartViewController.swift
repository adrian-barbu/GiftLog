//
//  StartViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/27/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

class StartViewController: BaseViewController {

    // MARK: Views
    
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isStatusBarHidden = false // show status bar
        tryLoginSession()
    }
    
    func tryLoginSession() {
        activityIndicator.startAnimating()
        refreshButton.isHidden = true
        if !UserDefaultsManager.shared.isTutorialScreenShowedBefore {
            NavigationManager.shared.showTutorialViewController()
            return
        }
        if let _ = FirebaseManager.shared.getAuthentificatedUserId(), UserDefaultsManager.shared.isUserAuthenticated { // user has already signed in before
            
            if SSReachability.shared.isConnectedToNetwork() { // if we have internet connection
                // check if user account(token) exhists at accounts at Firebase
                AuthManager.shared.checkIfUserAccountExistAtAuthenticationUsers(completion: { [weak self] (exist, error) in
                    if exist {
                        // check if user model exhists at Database at Firebase
                        FirebaseManager.shared.getUserById(FirebaseManager.shared.getAuthentificatedUserId()!, isSingleOperation: true, completion: { (user) in
                            if let user = user {
                                UserManager.shared.currentUser = user
                                NavigationManager.shared.showMenuViewController()
                            } else {
                                self?.forceLogoutOfUser()
                            }
                        })
                    } else {
                        self?.forceLogoutOfUser()
                    }
                })
            } else {
                activityIndicator.stopAnimating()
                refreshButton.isHidden = false
                //UIAlertController.showAlertWithTitle("It seems, that you don't have internet connection", message: "Please try again.")
            }
        } else { // no account
            NavigationManager.shared.showLoginViewController()
        }
    }
    
    func forceLogoutOfUser() {
        AuthManager.shared.logOut()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIAlertController.showAlertWithTitle("This account was removed from database", message: "Please try another account or create a new one.")
        }
    }
    
    // MARK: IBActions
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        tryLoginSession()
    }
    
}
