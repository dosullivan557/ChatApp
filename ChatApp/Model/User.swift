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
    var email: String?
    var name: String?
    var profileImageUrl: String?
    var id: String?
    var settings : Settings?
    /**
     Gets the string of the user including all of its information. Used for development.
     - Returns: The string containing all of the information.
     */
    func toString() -> String {
        return ("name:\(name!), email:\(email!), profileImageUrl:\(profileImageUrl!), id:\(id!)")
    }
}
