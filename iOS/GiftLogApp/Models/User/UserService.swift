//
//  UserService.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/25/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import Foundation

class UserService {
    
    // MARK: Properties
    
//    var googlePlusID: String?
//    var facebookID: String?
    var firstName: String!
    var lastName: String!
    var nickName: String?
    var email: String?
    var phoneNumber: String?
    var avatar: String?
    var dates = [ContactDate]()
    var likes: String?
    var dislikes: String?
    var imageData: Data?
    
    // MARK: Lifecycle
    
    var fullName: String {
        if (firstName.isEmpty && lastName.isEmpty) {
            return "USER NAME"
        }
        return (firstName ?? "") + " " + (lastName ?? "")
    }
    
    init(user: User) {
//        self.googlePlusID = user.googlePlusID
//        self.facebookID = user.facebookID
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.nickName = user.nickName
        self.email = user.email
        self.phoneNumber = user.phoneNumber
        self.avatar = user.avatar
        self.dates = user.dates
        self.likes = user.likes
        self.dislikes = user.dislikes
    }
}
