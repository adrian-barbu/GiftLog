//
//  FacebookManager.swift
//
//
//  Created by Webs The Word on 12/16/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import FirebaseAuth

class FacebookManager {
    
    // MARK: Methods
    
    class func getUserProfileFromFacebookToken(token: FBSDKAccessToken, completion: @escaping (_ result: [String:AnyObject]?) -> Void) {
        if let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, email, first_name, last_name, picture.type(large)"], tokenString: token.tokenString, version: nil, httpMethod: "GET") {
            HUDManager.showNetworkActivityIndicator()
            req.start(completionHandler:  { (connection, result, error) in
                HUDManager.hideNetworkActivityIndicator()
                if let result = result as? [String:AnyObject] {
                    completion(result)
                }
                else { completion(nil) }
            })
        }
    }
    
    class func getUserFriendsListFromController(_ controller: UIViewController, facebookID: String, completion: @escaping (_ result: [String]?) -> Void) {
        if FBSDKAccessToken.current() != nil {
            if let req = FBSDKGraphRequest(graphPath: "/\(facebookID)/friends", parameters:[AnyHashable : Any](), httpMethod: "GET") {
                HUDManager.showNetworkActivityIndicator()
                req.start(completionHandler:  { (connection, result, error) in
                    HUDManager.hideNetworkActivityIndicator()
                    if let result = result as? [String:AnyObject] {
                        if let friendsList = result["data"] as? [[String:AnyObject]] {
                            var friendsIdentifiersArray = [String]()
                            for object in friendsList {
                                friendsIdentifiersArray.append(object["id"] as! String)
                            }
                            completion(friendsIdentifiersArray)
                        } else {
                            completion(nil)
                        }
                    }
                    else { completion(nil) }
                })
            }
        } else {
            completion(nil)
        }
    }
}
