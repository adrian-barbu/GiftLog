//
//  BaseRevealViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 10/28/16.
//  Copyright © 2015 Gift Log App. All rights reserved.
//

import UIKit
import SWRevealViewController
class BaseRevealViewController: BaseViewController, SWRevealViewControllerDelegate {

    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setting action to menu button on press
        if revealViewController() != nil {
            revealViewController().delegate = self
            getMenuButton().target = revealViewController()
            getMenuButton().action = #selector(SWRevealViewController.revealToggle(_:))
            let tapRevealGesture = self.revealViewController().tapGestureRecognizer()
            view.addGestureRecognizer(tapRevealGesture!)
            let panRevealGesture = self.revealViewController().panGestureRecognizer()
            view.addGestureRecognizer(panRevealGesture!)
            revealViewController().rearViewRevealWidth = UIScreen.main.bounds.width - 75.0
            revealViewController().replaceViewAnimationDuration = 0.1
        }
    }
    
    func getMenuButton() -> UIBarButtonItem! {
        return nil
    }
    
    // MARK: SWReveal Delegate
 
    func revealController(_ revealController: SWRevealViewController!, animateTo position: FrontViewPosition) {
        if position == .right {
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }
    }
}
