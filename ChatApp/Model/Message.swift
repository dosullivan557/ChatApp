//
//  Message.swift
//  ChatApp
//
//  Created by Danny on 05/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var sendId: String?
    var receiveId: String?
    var message: String?
    var timestamp: NSNumber?
    
    func chatWithId() -> String? {
    if sendId == Auth.auth().currentUser?.uid {
        return receiveId
    }
    else {
        return sendId
        }
    }
}
