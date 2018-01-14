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
    let cellEId = "cellEId"

    var events = [Event]()
    var timer: Timer?
    let currentUser = User()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(EventCell.self, forCellReuseIdentifier: cellEId)
        observeUserEvents()
        fetchUserAndSetupNavBarTitle()

    }
    //Defines the current user of the system, and passes it to another method to setup the navigation bar.
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //                self.navigationItem.title = dictionary["name"] as? String
                
                let user = User()
                user.email = dictionary["email"] as? String
                user.name = dictionary["name"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                self.setupNavBarWithUser(user)
            }
            
        }, withCancel: nil)
    }
    
    //gets passed the current user of the system, and then sets up the navigation bar with that users information.
    func setupNavBarWithUser(_ user: User) {

        tableView.reloadData()
        
  
        
     
        
        //x,y,width,height anchors

        
        self.navigationItem.title = (user.name! + "'s Events")
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
   override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        handleReload()
    }

    @objc func handleReload(){
        DispatchQueue.main.async() {
            self.tableView.reloadData()
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellEId", for: indexPath) as! EventCell
        cell.event = events[indexPath.row]
        cell.textLabel?.text = events[indexPath.row].title
        return cell
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
                let eventRef = Database.database().reference().child("events").child(eventId)
                
                eventRef.observeSingleEvent(of: .value, with: { (DataSnapshot) in
                    print(DataSnapshot)
                    if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                        let event = Event()
                        event.desc = dictionary["Description"] as? String
                        event.title = dictionary["Title"] as? String
                        event.host = dictionary["Host"] as? String
                        event.invitee = dictionary["Invitee"] as? String
                        event.time = dictionary["Time"] as? Int
                        print(dictionary)
                        self.events.append(event)
                        //cancelled timer, so only 1 timer gets called, and therefore the only reloads the table once
                        self.timer?.invalidate()
                        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
                    }
                    
                }, withCancel: nil)
            })
            
        }, withCancel: nil)
    }
    
    
}
