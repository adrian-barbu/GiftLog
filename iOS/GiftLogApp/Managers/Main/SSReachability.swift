//
//  SSReachability.swift
//
//
//  Created by Webs The Word on 3/2/17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

import SystemConfiguration

public class SSReachability {
    
    static let shared = SSReachability()
    let internetReachability = Reachability.forInternetConnection()
    var isInternetConnectionWasBefore: Bool!
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: NSNotification.Name.reachabilityChanged, object: nil)
        self.internetReachability?.startNotifier()
        if let reachability = self.internetReachability {
            if reachability.currentReachabilityStatus() == .NotReachable {
                isInternetConnectionWasBefore = false
            } else {
                isInternetConnectionWasBefore = true
            }
        }
    }
    
    @objc func reachabilityChanged(_ notification: Notification) {
        if let reachability = self.internetReachability {
            let newStatus = reachability.currentReachabilityStatus()
            switch newStatus {
            case .NotReachable:
                debugPrint("Internet connection was disappeared :(")
                isInternetConnectionWasBefore = false
                UIAlertController.showAlertWithTitle("", message: "Oops, you don’t seem to be connected to the Internet. Please check your settings and try again.")
            case .ReachableViaWiFi:
                debugPrint("Internet connection appeared :)")
                if !isInternetConnectionWasBefore {
                    // do something, when Internet connection appeared again
                }
                isInternetConnectionWasBefore = true
            case .ReachableViaWWAN:
                debugPrint("Internet connection appeared :)")
                if !isInternetConnectionWasBefore {
                    // do something, when Internet connection appeared again
                }
                isInternetConnectionWasBefore = true
            }
        }
    }
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
}
