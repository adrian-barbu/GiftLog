//
//  User.swift
//  Noti
//
//  Created by Webs The Word on 11/1/16.
//  Copyright © 2016 Noti. All rights reserved.
//

import Foundation
import FirebaseDatabase
import GoogleSignIn

class User: BaseFIRModel {
    
    // MARK: Properties
    
    var googlePlusID: String?
    var facebookID: String?
    
    var firstName: String = ""
    var lastName: String = ""
    var nickName: String?
    var email: String?
    var phoneNumber: String?
    var avatar: String?
    var dates = [ContactDate]()
    var likes: String?
    var dislikes: String?
    
    /* Local variables (not for server), only for internal usage. */
    
    var thumbDataToUpload: Data?
    var avatarUrl: URL? {
        if let avatar = avatar {
            return URL(string: avatar)
        }
        return nil
    }
    
    var avatarThumb: UIImage {
        return UIImage(named: "maleThumb")!
    }
    
    var fullName: String {
        if firstName.isEmpty && lastName.isEmpty {
            return "USER NAME"
        }
        return (firstName) + " " + (lastName)
    }
    
    init(snapshotValue: [String:AnyObject], snapshotRef: DatabaseReference?) {
        super.init()
        self.googlePlusID = snapshotValue["gplusId"] as? String
        self.facebookID = snapshotValue["facebookId"] as? String
        
        self.firstName = snapshotValue["firstName"] as? String ?? ""
        self.lastName = snapshotValue["lastName"] as? String ?? ""
        self.nickName = snapshotValue["nickName"] as? String
        self.email = snapshotValue["email"] as? String
        self.phoneNumber = snapshotValue["phoneNumber"] as? String
        self.avatar = snapshotValue["avatar"] as? String
        if let arrayOfDates = snapshotValue["dates"] as? [AnyObject] {
            for userData in arrayOfDates {
                self.dates.append(ContactDate(data: userData as! [String: AnyObject]))
            }
        }
        self.likes = snapshotValue["likes"] as? String
        self.dislikes = snapshotValue["dislikes"] as? String
        self.ref = snapshotRef
    }
    
//    override init () {
//        super.init()
//        self.ref = FirebaseEndPoints.usersDatabaseRef.childByAutoId()
//    }
    
    init(userProfile: [String:AnyObject]) {
        self.email = userProfile["email"] as? String
        self.firstName = ""
        self.lastName = ""
    }
    
    init(facebookProfile: [String:AnyObject]) {
        self.email = facebookProfile["email"] as? String ?? ""
        self.firstName = facebookProfile["first_name"] as? String ?? ""
        self.lastName = facebookProfile["last_name"] as? String ?? ""
        self.facebookID = facebookProfile["id"] as? String
        self.avatar = ((facebookProfile["picture"] as! [String:AnyObject])["data"] as! [String:AnyObject])["url"] as? String
    }
    
    init(googleUser: GIDGoogleUser) {
        self.email = googleUser.profile.email
        self.firstName = googleUser.profile.givenName
        self.lastName = googleUser.profile.familyName
        self.googlePlusID = googleUser.userID
        if googleUser.profile.hasImage {
            self.avatar = "\(googleUser.profile.imageURL(withDimension: 100)!)"
        }
    }
    
    func updateUserFromService(_ userService: UserService) {
        self.firstName = userService.firstName
        self.lastName = userService.lastName
        self.nickName = userService.nickName
        self.email = userService.email
        self.phoneNumber = userService.phoneNumber
        self.avatar = userService.avatar
        self.dates = userService.dates
        self.likes = userService.likes
        self.dislikes = userService.dislikes
    }
    
    func toAnyObject() -> Any {
        
        // Non optional values
        
        var dict = [
        "firstName" : self.firstName,
        "lastName" : self.lastName,
        ] as [String : Any]
        
        // Optional values
     
        if let value = googlePlusID {
            dict["gplusId"] = value
        }
        if let value = facebookID {
            dict["facebookId"] = value
        }
        if let value = nickName {
            dict["nickName"] = value
        }
        if let value = email {
            dict["email"] = value
        }
        if let value = phoneNumber {
            dict["phoneNumber"] = value
        }
        if let value = avatar {
            dict["avatar"] = value
        }
        if let value = likes {
            dict["likes"] = value
        }
        if let value = dislikes {
            dict["dislikes"] = value
        }
        if !dates.isEmpty {
            dict["dates"] = UserContactsManager.shared.formattedArrayOfContactDates(dates: dates)
        }
        return dict
    }
    
}
