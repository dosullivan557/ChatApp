
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
        setupNavBarWithUser(currentUser)
        //        self.hidesBottomBarWhenPushed = true
    }
    
    
    
    //Defines the current user of the system, and passes it to another method to setup the navigation bar
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let decline = UITableViewRowAction(style: .normal, title: "Decline") { action, index in
            print("decline button tapped")
            self.declineFunc(index: index)
        }
        decline.backgroundColor = UIColor(r: 206, g: 27, b: 0)
        
        let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in

        print("accept button tapped")
            self.acceptFunc(index: index)
        }
        accept.backgroundColor = UIColor(r: 0, g: 168, b: 48)
        
        return [accept, decline]
    }
    
    func declineFunc(index: IndexPath){
        print("Decline")
        self.updateDatabase(IndexPath: index, bool: false)
        self.events.remove(at: index.row)
        DispatchQueue.main.async() {
            self.tableView.deleteRows(at: [index], with: .fade)
        }
        self.handleReload()
        self.showAlert(title: "Event Declines", message: "This event has been removed.")
        
    }
    func acceptFunc(index: IndexPath){
        let currentEvent = events[index.row]
        let eventStore: EKEventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (bool, error) in
            if (bool) && (error == nil) {
                print("granted \(bool)")
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = currentEvent.title
                event.startDate = Date(timeIntervalSince1970: currentEvent.startTime as! TimeInterval)
                event.endDate = Date(timeIntervalSince1970: currentEvent.finishTime as! TimeInterval)
                event.notes = currentEvent.desc
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    self.showAlert(title: "Error", message: "We have run into an issue whilst creating the event. We have informed the developer to this issue")
                    self.postError(error: error)
                    return
                }
                self.updateDatabase(IndexPath: index, bool: true)
                self.events.remove(at: index.row)
                DispatchQueue.main.async() {
                    self.tableView.deleteRows(at: [index], with: .fade)
                }
                self.handleReload()
                self.showAlert(title: "Event Accepted", message: "Event has been confirmed, and is now in your calendar")
            }
            else {
                self.showAlert(title: "Error", message: "We have run into an issue whilst creating the event. We have informed the developer to this issue")
                self.postError(error: error!)
                return
            }
        }
    }
    
    
    func updateDatabase(IndexPath: IndexPath, bool: Bool){
        let event = events[IndexPath.row]
        
        let ref = Database.database().reference().child("events").child(event.id!)
        
        let values = ["Id" : event.id, "Title": event.title!, "Description": event.desc!, "StartTime": event.startTime!, "FinishTime": event.finishTime!, "Host": event.host!, "Invitee": event.invitee!, "Accepted" : bool] as [String : Any]
        
        ref.updateChildValues(values)
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
                setupNavBarWithUser(currentUser)
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = events[indexPath.row]
        //pass event through
        let eventController = EventController()
        eventController.event = event
        eventController.hidesBottomBarWhenPushed = true
        
        show(eventController, sender: self)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
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
                            if event.invitee == self.currentUser.id {
                                if acceptedS == "" {
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


