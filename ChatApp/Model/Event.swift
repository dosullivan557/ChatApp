//
//  Event.swift
//  ChatApp
//
//  Created by Danny on 14/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
import MapKit
///Object which represents an event.
class Event: NSObject {
    var id: String?
    var title: String?
    var desc: String?
    var host: String?
    var invitee: String?
    var startTime: NSNumber?
    var finishTime: NSNumber?
    var location = [NSString?]()
    
    /**
     Gets the string of the event including all of its information. Used for development.
     - Returns: The string containing all of the information.
     */
    func toString() -> String {
        return ("title:\(title!), desc:\(desc!), host:\(host!), invitee:\(invitee!), startTime:\(startTime!), finishTime:\(finishTime!), location: \(location)")
    }
    
    /**
     Method that returns your event partner's ID, so you can check which user is the correct user.
     - Returns: The userId of the user you are planning the event with.
     */
    func eventWithId() -> String? {
        if invitee == Auth.auth().currentUser?.uid {
            return host
        }
        else {
            return invitee
        }
    }
    
}
