//
//  EventsController.swift
//  ChatApp
//
//  Created by Danny on 14/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
import EventKit

class EventsController: UITableViewController {
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
//        observeUserEvents()
        fetchUserAndSetupNavBarTitle()
//        self.hidesBottomBarWhenPushed = true
    }
    //Defines the current user of the system, and passes it to another method to setup the navigation bar.
    func fetchUserAndSetupNavBarTitle() {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            return
//        }
//
//        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
//
//            if let dictionary = snapshot.value as? [String: AnyObject] {
//                //                self.navigationItem.title = dictionary["name"] as? String
//
//                self.currentUser.email = dictionary["email"] as? String
//                self.currentUser.name = dictionary["name"] as? String
//                self.currentUser.id = snapshot.key
//                self.currentUser.profileImageUrl = dictionary["profileImageUrl"] as? String
//                self.setupNavBarWithUser(self.currentUser)
//            }
//
//        }, withCancel: nil)

        setupNavBarWithUser(currentUser)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            print("Edit button tapped")
        }
        edit.backgroundColor = UIColor.purple
        
        let decline = UITableViewRowAction(style: .normal, title: "Decline") { action, index in
            print("decline button tapped")
        }
        decline.backgroundColor = UIColor(r: 206, g: 27, b: 0)
        
        let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in
//            self.addToCalander() 
            print("share button tapped")
        }
        accept.backgroundColor = UIColor(r: 0, g: 168, b: 48)
        
        return [accept, decline, edit]
    }
    
    func declineFunc(){
        print("Decline")
    }
    func acceptFunc(){
        print("Accept")
    }
    //gets passed the current user of the system, and then sets up the navigation bar with that users information.
    func setupNavBarWithUser(_ user: User?) {
        tableView.reloadData()
        
        self.navigationItem.title = (currentUser.name! + "'s Events")
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
   override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let id = currentUser.id {
        if id == Auth.auth().currentUser?.uid {
            print("Same user")
        }
        else {
            print("Different")

            events.removeAll()
            fetchUserAndSetupNavBarTitle()
            observeUserEvents()
            handleReload()
            }
        }
        else {
            print("error")
        }
        
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
    
//    func addToCalander(){
//        let eventStore : EKEventStore = EKEventStore()
//
//        // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
//
//        eventStore.requestAccess(to: .event) { (granted, error) in
//
//            if (granted) && (error == nil) {
//                print("granted \(granted)")
//                print("error \(error)")
//
//                let event:EKEvent = EKEvent(eventStore: eventStore)
//
//                event.title = "Test Title"
//                event.startDate = Date()
//                event.endDate = Date()
//                event.notes = "This is a note"
//                event.calendar = eventStore.defaultCalendarForNewEvents
//                do {
//                    try eventStore.save(event, span: .thisEvent)
//                } catch let error as NSError {
//                    print("failed to save event with error : \(error)")
//                }
//                print("Saved Event")
//            }
//            else{
//
//                print("failed to save event with error : \(error) or access not granted")
//            }
//        }
//    }
    
    
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
                        event.desc = dictionary["Description"] as? String
                        event.title = dictionary["Title"] as? String
                        event.host = dictionary["Host"] as? String
                        event.invitee = dictionary["Invitee"] as? String
                        event.startTime = dictionary["StartTime"] as? NSNumber
                        event.finishTime = dictionary["FinishTime"] as? NSNumber
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
