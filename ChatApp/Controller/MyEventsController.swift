
//
//  MyEventsController.swift
//  ChatApp
//
//  Created by Danny on 14/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
import EventKit

class MyEventsController: UITableViewController {
    let cellEId = "cellEId"
    var events = [Event]()
    var timer: Timer?
    var currentUser = User() {
        didSet {
            setupNavBarWithUser(currentUser)
            observeUserEvents()
            handleReload()
            events.removeAll()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(EventCell.self, forCellReuseIdentifier: cellEId)
        let nc = UINavigationController()
        
        self.show(nc, sender: self)
        self.hidesBottomBarWhenPushed = true
        //        observeUserEvents()
        setupNavBarWithUser(currentUser)
        //        self.hidesBottomBarWhenPushed = true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let event = events[indexPath.row]
        
        if editingStyle == .delete {
            self.events.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            guard let eventId = event.eventWithId() else {
                return
            }
            
            if let currentUid = Auth.auth().currentUser?.uid {
                let ref = Database.database().reference().child("events").child(event.id!)
                ref.removeValue()
                
                let hostIdRef = Database.database().reference().child("user-events").child(currentUid).child(eventId).child(event.id!)
                let inviteeIdRef = Database.database().reference().child("user-events").child(eventId).child(currentUid).child(event.id!)
                hostIdRef.removeValue()
                inviteeIdRef.removeValue()
            }
        }
    }
    func postError(error: Error){
        let ref = Database.database().reference().child("Error").child(NSUUID().uuidString)
        let values = ["Error Description": error.localizedDescription]
        ref.updateChildValues(values as [String: AnyObject])
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //gets passed the current user of the system, and then sets up the navigation bar with that users information.
    func setupNavBarWithUser(_ user: User?) {
        tableView.reloadData()
        
        self.navigationItem.title = ("My Events")
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
            if  currentUser.id == Auth.auth().currentUser?.uid {
                print("Same user")
                return
            }
            else {
                print("Different")
                events.removeAll()
                setupNavBarWithUser(currentUser)
                observeUserEvents()
                handleReload()
        }
        print("Error")
        
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = events[indexPath.row]
        //pass event through
        let eventController = EventController()
        eventController.event = event
        show(eventController, sender: self)
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
                    if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                        let event = Event()
                        event.id = dictionary["Id"] as? String
                        event.desc = dictionary["Description"] as? String
                        event.title = dictionary["Title"] as? String
                        event.host = dictionary["Host"] as? String
                        event.invitee = dictionary["Invitee"] as? String
                        event.startTime = dictionary["StartTime"] as? NSNumber
                        event.finishTime = dictionary["FinishTime"] as? NSNumber
                        if let acceptedS = dictionary["Accepted"] as? String {

                            if event.host == self.currentUser.id {
                                if acceptedS == "" || acceptedS == "true"{
                                    self.events.append(event)
                                }
                            }
                        }
                        
                        //cancelled timer, so only 1 timer gets called, and therefore the only reloads the table once
                        self.timer?.invalidate()
                        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
                    }
                }, withCancel: nil)
            })
        }, withCancel: nil)
    }
}

