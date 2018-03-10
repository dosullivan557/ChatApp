//
//  User.swift
//  ChatApp
//
//  Created by Danny on 30/12/2017.
//  Copyright © 2017 Danny. All rights reserved.
//

import UIKit
//user object
class User: NSObject {
    ///Email address of the user.
    var email: String?
    ///Name of the user.
    var name: String?
    ///URL to the user's Profile Image
    var profileImageUrl: String?
    ///The user's id.
    var id: String?
    ///The settings of the user.
    var settings : Settings?
    
    ///User status
    var status: String?
    
    /**
     Gets the string of the user including all of its information. Used for development.
     - Returns: The string containing all of the information.
     */
    func toString() -> String {
        return ("name:\(name!), email:\(email!), profileImageUrl:\(profileImageUrl!), id:\(id!), settings: \(settings!)")
    }
}
