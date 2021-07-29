//
//  AuthManager.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/17/17.
//  Copyright © 2017 GiftLogApp. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn

enum SignInMethod: String {
    case facebook = "facebook.com"
    case googlePlus = "google.com"
    case emailPassword = "password"
}

typealias DeleteUserDataCompletion = (_ success:Bool) -> Void

class AuthManager: NSObject, GIDSignInDelegate {
    
    // MARK: Properties
    
    static let shared = AuthManager()
    private var isAuthenticated:Bool = false
    
    override init() {
        super.init()
        GIDSignIn.sharedInstance().delegate = self
    }
    
    // MARK: - Auth Stack -
    
    // MARK: Email/Password registration methods
    
    func signUpUserWithEmail(_ email: String, password: String) {
        HUDManager.showLoadingHUD()
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil {
                let userProfile = ["email":email]
                UserManager.shared.currentUser = User(userProfile: userProfile as [String : AnyObject])
                UserManager.shared.currentUser.ref = FirebaseEndPoints.usersDatabaseRef.child(FirebaseManager.shared.getAuthentificatedUserId()!) // path at Firebase DB to current user
                FirebaseManager.shared.saveOrUpdateUser(UserManager.shared.currentUser, completion: { (success) in
                    HUDManager.hideLoadingHUD()
                    if success {
                        self.signInUserWithEmail(email, password: password)
                    }
                })
            } else {
                HUDManager.hideLoadingHUD()
                UIAlertController.showAlertWithTitle(error!.localizedDescription, message: "")
            }
        }
    }
    
    func signInUserWithEmail(_ email: String, password: String) {
        HUDManager.showLoadingHUD()
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                HUDManager.hideLoadingHUD()
                UIAlertController.showAlertWithTitle(error.localizedDescription, message: "")
            } else {
                if let user = user {
                    self.getUserFromDateBaseOrSaveHim(firUser: user, googleUser: nil, method: .emailPassword)
                }
            }
        }
    }
    
    // MARK: Facebook registration methods
    
    func signUserWithFacebookFromController(_ controller: UIViewController) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: controller) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if result!.isCancelled || result!.token == nil {
                return
            }
            // success login from browser
            HUDManager.showLoadingHUD()
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signIn(with: credential) { (firUser, error) in
                if let firUser = firUser {
                    //self.getUserFromDateBaseOrSaveHim(firUser: firUser, googleUser: nil, method: .facebook)
                } else {
                    HUDManager.showErrorHUD()
                    debugPrint("\(#function) error")
                }
            }
        }
    }
    
    // MARK: Google Plus registration methods
    
    func signUserWithGooglePlus() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            debugPrint(error.localizedDescription)
            return
        }
        // success loign from browser
        let authentication = user.authentication
        let credential = GoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
        HUDManager.showLoadingHUD()
        Auth.auth().signIn(with: credential) { (firUser, error) in
            if let firUser = firUser {
                //self.getUserFromDateBaseOrSaveHim(firUser: firUser, googleUser: user, method: .googlePlus)
            } else {
                HUDManager.showErrorHUD()
                debugPrint("Error \(#function)")
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
              withError error: Error!) {
        debugPrint(#function)
    }
    
    // MARK: Methods that close auth chain
    
    // penult method in stack
    
    func getUserFromDateBaseOrSaveHim(firUser: User, googleUser: GIDGoogleUser?, method: SignInMethod) {
        FirebaseManager.shared.getUserById(firUser.identifier, isSingleOperation: true, completion: { (oldUser) in
            if let oldUser  = oldUser {
                debugPrint("This is not a new user")
                UserManager.shared.currentUser = oldUser
                self.authStackSuccessfullyFinishedForUser(user: oldUser)
            } else {
                debugPrint("This is a new user")
                switch method {
                case .facebook:
                    FacebookManager.getUserProfileFromFacebookToken(token: FBSDKAccessToken.current(), completion: { (result) in
                        if let result = result {
                            UserManager.shared.currentUser = User(facebookProfile: result)
                            UserManager.shared.currentUser.ref = FirebaseEndPoints.usersDatabaseRef.child(FirebaseManager.shared.getAuthentificatedUserId()!) // path at Firebase DB to current user
                            FirebaseManager.shared.saveOrUpdateUser(UserManager.shared.currentUser, completion: { (success) in
                                if success {
                                    self.authStackSuccessfullyFinishedForUser(user: UserManager.shared.currentUser)
                                }
                            })
                        } else {
                            HUDManager.showErrorHUD()
                        }
                    })
                case .googlePlus:
                    if let googleUser = googleUser {
                        UserManager.shared.currentUser = User(googleUser: googleUser)
                        UserManager.shared.currentUser.ref = FirebaseEndPoints.usersDatabaseRef.child(FirebaseManager.shared.getAuthentificatedUserId()!) // path at Firebase DB to current user
                        FirebaseManager.shared.saveOrUpdateUser(UserManager.shared.currentUser, completion: { (success) in
                            if success {
                                self.authStackSuccessfullyFinishedForUser(user: UserManager.shared.currentUser)
                            }
                        })
                    }
                default:
                    break
                }
            }
        })
    }
    
    // last method in stack
    
    func authStackSuccessfullyFinishedForUser(user: User) {
        HUDManager.hideLoadingHUD()
        if !isAuthenticated {
            isAuthenticated = true
            UserDefaultsManager.shared.isUserAuthenticated = true
            UIApplication.shared.statusBarStyle = .default
            UserManager.shared.activateListeningOfUserContent()
            NavigationManager.shared.showMenuViewController()
        }
        
    }
    
    // MARK: Account Availablity at Firebase
    
    /** Check if user does exists at Firebase */
    func checkIfUserAccountExistAtAuthenticationUsers(completion: @escaping (_ exist: Bool, _ error: NSError?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false, nil)
            return
        }
        currentUser.getTokenForcingRefresh(true) { (idToken, error) in
            if let error = error {
                completion(false, error as NSError?)
                debugPrint(error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }
    
    // MARK: Log out
    
    /** Reset all possible info of user at this method and clean local db */
    func logOut() {
        clearUserData()
        // TODO: Clean local singletons here
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            HUDManager.showErrorHUD()
            return debugPrint ("Error signing out: \(signOutError)")
        }
        NavigationManager.shared.showLoginViewController()
    }
    
    func deleteUserGifts(completion: @escaping DeleteUserDataCompletion) {
        let gifts = UserGiftsManager.shared.userGifts
        if gifts.isEmpty {
            return completion(true)
        }
        var counter = 0
        HUDManager.showNetworkActivityIndicator()
        for gift in gifts {
            FirebaseManager.shared.deleteGiftFromDatabase(gift) {(success) in
                if !success {
                    debugPrint("Error: Gift with id \(gift.identifier) was not deleted.")
                }
                counter += 1
                if counter == gifts.count {
                    HUDManager.hideNetworkActivityIndicator()
                    completion(true)
                }
            }
        }
    }
    
    func deleteUserContacts(completion: @escaping DeleteUserDataCompletion) {
        let contacts = UserContactsManager.shared.userContacts
        if contacts.isEmpty {
            return completion(true)
        }
        var counter = 0
        HUDManager.showNetworkActivityIndicator()
        for contact in contacts {
            FirebaseManager.shared.deleteContactFromDatabase(contact) {(success) in
                if !success {
                    debugPrint("Error: Contact with id \(contact.identifier) was not deleted.")
                }
                counter += 1
                if counter == contacts.count {
                    HUDManager.hideNetworkActivityIndicator()
                    completion(true)
                }
            }
        }
    }
    
    func deleteUserEvents(completion: @escaping DeleteUserDataCompletion) {
        let events = UserEventsManager.shared.userEvents
        if events.isEmpty {
            return completion(true)
        }
        var counter = 0
        HUDManager.showNetworkActivityIndicator()
        for event in events {
            FirebaseManager.shared.deleteEventFromDatabase(event) {(success) in
                if !success {
                    debugPrint("Error: Event with id \(event.identifier) was not deleted.")
                }
                counter += 1
                if counter == events.count {
                    HUDManager.hideNetworkActivityIndicator()
                    completion(true)
                }
            }
        }
    }
    
    func deleteAllUserData() {
        var deletedGifts = false
        var deletedContacts = false
        var deletedEvents = false
        HUDManager.showLoadingHUD()
        deleteUserGifts { (success) in
                deletedGifts = success
            if deletedGifts && deletedContacts && deletedEvents {
                self.finishDeletingOfAllUserData()
            }
        }
        deleteUserContacts { (success) in
            deletedContacts = success
            if deletedGifts == true && deletedContacts == true && deletedEvents == true {
                self.finishDeletingOfAllUserData()
            }
        }
        deleteUserEvents { (success) in
            deletedEvents = success
            if deletedGifts == true && deletedContacts == true && deletedEvents == true {
                self.finishDeletingOfAllUserData()
            }
        }
    }
    
    func finishDeletingOfAllUserData() {
        FirebaseManager.shared.deleteUserFromDatabase(UserManager.shared.currentUser) { (success) in
            if !success {
                debugPrint("Error: User with id \(UserManager.shared.currentUser.identifier) was not deleted.")
            }
            if let user = Auth.auth().currentUser {
                user.delete(completion: { (error) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        debugPrint("Fatal error: User with id \(user.uid) was not deleted.")
                    }
                    self.clearUserData()
                    HUDManager.hideLoadingHUD()
                    NavigationManager.shared.showLoginViewController()
                })
            }
        }
//        self.clearUserData()
//        HUDManager.hideLoadingHUD()
//        NavigationManager.shared.showLoginViewController()
    }
    
    func clearUserData() {
        UIApplication.shared.cancelAllLocalNotifications()
        isAuthenticated = false
        UserContactsManager.shared.stopListenToAllUserContactsChanges()
        UserEventsManager.shared.stopListenToAllUserEventsChanges()
        UserGiftsManager.shared.stopListenToAllUserGiftsChanges()
        UserManager.shared.currentUser = nil
        UserDefaultsManager.shared.isUserAuthenticated = false
    }
}
