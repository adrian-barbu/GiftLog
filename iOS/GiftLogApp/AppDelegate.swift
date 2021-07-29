//
//  AppDelegate.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/24/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import UserNotifications
import FirebaseMessaging
import Firebase
import FirebaseInstanceID

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setVisualStyles()
        FIRApp.configure()
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        let _ = SSHelperManager.shared
        registerForPushNotifications(application: application)
        if let _ = FirebaseManager.shared.getAuthentificatedUserId(), UserDefaultsManager.shared.isUserAuthenticated {
        } else { // app was removed and then install again
            UIApplication.shared.cancelAllLocalNotifications()
        }
        if let launchOptions = launchOptions {
            if let notification = launchOptions[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
                RemindService.shared.unhandledLocalNotification = notification
            }
        }
        return true
    }

    func registerForPushNotifications(application: UIApplication) {
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url as URL!,
                                                                sourceApplication: sourceApplication,
                                                                annotation: annotation)
        return facebookDidHandle || googleDidHandle
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url as URL!,
                                                                sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                                annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        return facebookDidHandle || googleDidHandle
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if !SSReachability.shared.isConnectedToNetwork() {
            UIAlertController.showAlertWithTitle("", message: "Oops, you don’t seem to be connected to the Internet. Please check your settings and try again.")
        }
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func setVisualStyles() {
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = Constants.appGreenColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : Constants.appVioletColor]
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        AppDelegate.handleLocalNotification(notification, from: application, ignoringAppState: false)
    }
    
    class func handleLocalNotification(_ notification: UILocalNotification, from application: UIApplication, ignoringAppState: Bool) {
        if let userInfo = notification.userInfo {
            if ignoringAppState {
                RemindService.shared.handleLocalNotificationFromUserInfo(userInfo)
            } else {
                if application.applicationState != .active  {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        RemindService.shared.handleLocalNotificationFromUserInfo(userInfo)
                    }
                } else {
                    // do nothing
                }
            }
        }
    }
}

