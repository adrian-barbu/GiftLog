//
//  HUDManager.swift
//
//
//  Created by Webs The Word on 11/3/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation
import PKHUD

class HUDManager {
    
    // MARK: PKHUD methods
    
    static func showLoadingHUD() {
        if SSReachability.shared.isConnectedToNetwork() {
            PKHUD.sharedHUD.contentView = PKHUDProgressView()
            PKHUD.sharedHUD.show()
        }
    }
    
    static func hideLoadingHUD() {
        PKHUD.sharedHUD.hide(animated: false)
    }
    
    static func hideLoadingHUDWithAnimation() {
        PKHUD.sharedHUD.hide(animated: true)
    }
    
    static func showSuccessHUD() {
        PKHUD.sharedHUD.contentView = PKHUDSuccessView()
        PKHUD.sharedHUD.hide(animated: true)
    }
    
    static func showErrorHUD() {
        PKHUD.sharedHUD.contentView = PKHUDErrorView()
        PKHUD.sharedHUD.hide(animated: true)
    }
    
    // MARK: ActivityIndicator methods
    
    static func showNetworkActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    static func hideNetworkActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
