//
//  Settings.swift
//  ChatApp
//
//  Created by Danny on 19/02/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import Foundation
import UIKit
///Settings object for users
class Settings: NSObject {
    ///The id of the user these settings are for.
    var id : String?
    ///The users personalised message for starting a conversation.
    var greeting : String?
    ///The color the user wants to set for their side of the conversation.
    var myColor : String?
    ///The color the user wants to set for the other user's side of the conversation.
    var theirColor: String?
    
    /**
     Gets the string of the event including all of its information. Used for development.
     - Returns: The string containing all of the information.
     */
    func toString() -> String {
        return ("id: \(id!), greeting: \(greeting!), myColor: \(myColor!), theirColor: \(theirColor!)")
    }
}
