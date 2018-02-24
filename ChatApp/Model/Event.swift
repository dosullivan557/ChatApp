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
    ///The id of the event.
    var id: String?
    ///The title of the event.
    var title: String?
    ///The event description.
    var desc: String?
    ///The user id of the host of the event.
    var host: String?
    ///The user id of the person who was invited to the event.
    var invitee: String?
    ///The start time of the event.
    var startTime: NSNumber?
    ///The finish time of the event.
    var finishTime: NSNumber?
    ///The location of the event: Given as a list of NSString, containing the latitude, longitude and name.
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
