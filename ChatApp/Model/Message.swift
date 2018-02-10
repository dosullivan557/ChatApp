//
//  Message.swift
//  ChatApp
//
//  Created by Danny on 05/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
//message object
class Message: NSObject {
    var sendId: String?
    var receiveId: String?
    var message: String?
    var timestamp: NSNumber?
    
    /**
        Method that returns your chatting partner's ID, so you can check which user is the correct user.
     
     
     - Returns: The userId of the user you are chatting with.
    */
    func chatWithId() -> String? {
    if sendId == Auth.auth().currentUser?.uid {
        return receiveId
    }
    else {
        return sendId
        }
    }
}
