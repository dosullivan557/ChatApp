//
//  EventsController.swift
//  ChatApp
//
//  Created by Danny on 14/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
class EventsController: UITableViewController {
    var events = [Event]()
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        observeUserEvents()
    }
    func observeUserEvents() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-events").child(uid)
        ref.observe(.childAdded, with: { (DataSnapshot) in
            let newRef = ref.child(DataSnapshot.key)
            newRef.observe(.childAdded, with: { (snapshot) in
                let eventId = snapshot.key
                let messagesReference = Database.database().reference().child("events").child(eventId)
                
                messagesReference.observeSingleEvent(of: .value, with: { (DataSnapshot) in
                    print(DataSnapshot)
                    if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                        let event = Event()
                        event.title = dictionary["Title"] as? String
                        event.desc = dictionary["Description"] as? String
                        event.host = dictionary["Invitee"] as? String
                        event.invitee = dictionary["Host"] as? String
                        event.time = dictionary["Time"] as? Int
                        self.events.append(event)
                        print(dictionary)
                        //cancelled timer, so only 1 timer gets called, and therefore the only reloads the table once
                        self.timer?.invalidate()
                        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
                    }
                    
                }, withCancel: nil)
            })
            
        }, withCancel: nil)
    }
    //Reloads the table view
    @objc func handleReload() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    



}
