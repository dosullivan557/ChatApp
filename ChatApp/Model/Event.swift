//
//  Event.swift
//  ChatApp
//
//  Created by Danny on 14/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
//Event object
class Event: NSObject {
    var id: String?
    var title: String?
    var desc: String?
    var host: String?
    var invitee: String?
    var startTime: NSNumber?
    var finishTime: NSNumber?
    
    func toString() -> String {
        return ("title:\(title!), desc:\(desc!), host:\(host!), invitee:\(invitee!), startTime:\(startTime!), finishTime:\(finishTime!)")
    }
    
    func eventWithId() -> String? {
        if invitee == Auth.auth().currentUser?.uid {
            return host
        }
        else {
            return invitee
        }
    }
    
}
