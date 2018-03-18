
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
import MapKit
class MyEventsController: UITableViewController {
    // MARK: - Constants
    
    
    ///The reuse cell identifier for the table view.
    let cellEId = "cellEId"
    
    // MARK: - Variables

    ///The list of events.
    var events = [Event]()
    ///Global timer to make ensure that the TableView is only refreshed once to prevent flickering when there are loads of cells to load.
    
    var acceptedEvents = [Event]()
    
    var declinedEvents = [Event]()
    
    var requestedEvents = [Event]()
    
    
    var timer: Timer?
    ///The current user of the system.
    var currentUser = User() {
        didSet {
            setupNavBarWithUser(currentUser)
            observeUserEvents()
            handleReload()
            events.removeAll()
        }
    }
    
    //MARK: - View initialisation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(EventCell.self, forCellReuseIdentifier: cellEId)
        let nc = UINavigationController()
        
        self.show(nc, sender: self)
        self.hidesBottomBarWhenPushed = true
        setupNavBarWithUser(currentUser)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        events.removeAll()
        setupNavBarWithUser(currentUser)
        observeUserEvents()
        handleReload()
    }
    
    //MARK: - Setup
    
    /**
     Gets passed the current user of the system, and then sets up the navigation bar with that users information.
     - Parameters:
         - user: The current user of the application.
     */
    func setupNavBarWithUser(_ user: User?) {
        tableView.reloadData()
        
        self.navigationItem.title = NSLocalizedString("myEvents", comment: "My Events")
        
    }
    
    
    
    //MARK: - TableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////
////        if section == 1 {
////            return acceptedEvents.count
////        }
////        else if section == 2 {
////            return declinedEvents.count
////        }
////        else {
////            return requestedEvents.count
////        }
//
//    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 1 {
//            return "Accepted"
//        }
//        else if section == 2 {
//            return "Declined"
//        }
//        else {
//            return "Requested"
//
//        }
//    }
    
    /// Reloads the table view.
    @objc func handleReload(){
        DispatchQueue.main.async() {
            self.tableView.reloadData()
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellEId", for: indexPath) as! EventCell
        print(events.count)
        cell.event = events[indexPath.row]
        cell.textLabel?.text = events[indexPath.row].title
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = events[indexPath.row]
        let eventController = EventController()
        eventController.event = event
        show(eventController, sender: self)
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
    
    //MARK: - Firebase
    
    ///Gets all the users events.
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
                        event.location = (dictionary["Location"] as? [NSString?])!
                        event.accepted = dictionary["Accepted"] as? NSNumber
                        print(event.title!)
                        print(dictionary["Accepted"] as? NSNumber)
//                            if event.host == self.currentUser.id {
//                                if event.accepted == 0 {
//                                    self.requestedEvents.append(event)
//                                }
//                                else if event.accepted == 1 {
////                                    self.addEventToCalendar(eventToAdd: event)
//                                    self.acceptedEvents.append(event)
//                                }
//                                else {
//                                    self.declinedEvents.append(event)
//                                }
                               self.events.append(event)
                        //                        }
                        //cancelled timer, so only 1 timer gets called, and therefore the only reloads the table once
                        self.timer?.invalidate()
                        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
                    }
                }, withCancel: nil)
            })
        }, withCancel: nil)
    }
    
        
    //MARK: - Alert
    
    /**
     Shows alerts for the given message and title. Calls [createAlertButton]() to add in the relevant buttons onto the alert.
     - Parameters:
         - title: The title to set for the alert box.
         - message: The message to set for the alert box.
     
     */
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
  
    //MARK: - Smart Features
 
    /**
     If the event has been accepted by the other user, it adds the event to their calendar.
     - Parameters:
         - eventToAdd: The event to add to the calendar.
     */
    func addEventToCalendar(eventToAdd: Event) {
        let eventStore: EKEventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (bool, error) in
            if (bool) && (error == nil) {
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = eventToAdd.title
                event.startDate = Date(timeIntervalSince1970: eventToAdd.startTime as! TimeInterval)
                event.endDate = Date(timeIntervalSince1970: eventToAdd.finishTime as! TimeInterval)
                event.notes = eventToAdd.desc
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    self.showAlert(title: NSLocalizedString("Error", comment: "error"), message: NSLocalizedString("techIssues", comment: "Error"))
                    self.postError(error: error)
                    return
                }
            }
            else {
                    self.showAlert(title: NSLocalizedString("Error", comment: "error"), message: NSLocalizedString("techIssues", comment: "Error"))
                self.postError(error: error!)
                return
            }
        }
    }
    
}
