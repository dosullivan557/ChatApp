
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


//issue where the comparators weren't working, and these two functions were the fix to it
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class EventsController: UITableViewController {
    
    // MARK: - Constants
    
    
    ///The reuse cell identifier for the table view.
    let cellEId = "cellEId"
    
    // MARK: - Variables

    ///List of all the events.
    var events = [Event]()
    ///Global timer to make ensure that the TableView is only refreshed once to prevent flickering when there are loads of cells to load.
    var timer: Timer?
    ///The current user.
    var currentUser = User() {
        didSet {
            print("setting events")
            setupNavBarWithUser(currentUser)
            observeUserEvents()
            handleReload()
            events.removeAll()
        }
    }
    
    //MARK: - View initialisation
    
    override func viewDidAppear(_ animated: Bool) {
        if let id = currentUser.id {
            if id == Auth.auth().currentUser?.uid {
            }
            else {
                events.removeAll()
                handleReload()
                getCurrentUser()
                setupNavBarWithUser(currentUser)
                observeUserEvents()
            }
        }
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(EventCell.self, forCellReuseIdentifier: cellEId)
        setupNavBarWithUser(currentUser)

    }
    
    //MARK: - Setup
    
    /**
     Gets passed the current user of the system, and then sets up the navigation bar with that users information.
     - Parameters:
     - user: The current user.
     */
    func setupNavBarWithUser(_ user: User?) {
        tableView.reloadData()
        
        self.navigationItem.title = (currentUser.name! + "'s " + NSLocalizedString("eventTab", comment: "title"))
        
    }
    
    //MARK: - TableView
    
    ///Reloads the table.
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
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Defines the current user of the system, and passes it to another method to setup the navigation bar
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let deleteEvent = events[editActionsForRowAt.row]
        let decline = UITableViewRowAction(style: .normal, title: NSLocalizedString("decline", comment: "Declined")) { action, index in
            self.declineFunc(index: index, event: deleteEvent)
        }
        decline.backgroundColor = UIColor(r: 206, g: 27, b: 0)
        
        let accept = UITableViewRowAction(style: .normal, title: NSLocalizedString("accept", comment: "Accept")) { action, index in
            self.acceptFunc(index: index)
        }
        accept.backgroundColor = UIColor(r: 0, g: 168, b: 48)
        
        return [accept, decline]
    }
    
    //MARK: - Interaction
    
    /**
     This is called when the decline event button is pressed. It removes the event from the cell, and then updates the database to say that it was declined.
     - Parameters:
         - index: The index of the table view to remove.
     
     */
    func declineFunc(index: IndexPath, event: Event){
        self.updateDatabase(IndexPath: index, num: -1)
        self.events.remove(at: index.row)
        DispatchQueue.main.async() {
            self.tableView.deleteRows(at: [index], with: .fade)
        }
        showDeleteAlertSure(title: NSLocalizedString("declineAlertTitle", comment: "Title"), message: NSLocalizedString("declineAlertBody", comment: "Body"), index: index, event: event)
        self.handleReload()
    }
    
    func addEventExample() {
        let event = Event()
        event.id = "idValue"
        event.title = "title"
        event.accepted = 0
        event.desc = "Desc"
        event.startTime = Date().tomorrow.tomorrow.timeIntervalSince1970 as NSNumber
        event.finishTime = Date().tomorrow.tomorrow.timeIntervalSince1970 as NSNumber
        var locs = [NSString?]()
        locs.append("666666")
        locs.append("666666")
        locs.append("huhuh")
        event.location = locs
        event.host = "me"
        event.invitee = "You"
        events.append(event)
        handleReload()
    }
    
    /**
     This is called when the accept event button is pressed. It gets access to the calendar, and then adds it in. Once it has been accepted, it removes it from the table view.
     - Parameters:
         - index: The index of the table view to add.
     */
    func acceptFunc(index: IndexPath){
        let currentEvent = events[index.row]
        let eventStore: EKEventStore = EKEventStore()
        if eventConflict(newEvent: events[index.row]){
            eventStore.requestAccess(to: .event) { (bool, error) in
                if (bool) && (error == nil) {
                    let event:EKEvent = EKEvent(eventStore: eventStore)
                    event.title = currentEvent.title
                    event.startDate = Date(timeIntervalSince1970: currentEvent.startTime as! TimeInterval)
                    event.endDate = Date(timeIntervalSince1970: currentEvent.finishTime as! TimeInterval)
                    event.notes = currentEvent.desc
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    event.location = currentEvent.location[2] as String?
                    event.addAlarm(EKAlarm(absoluteDate: event.startDate!))
                    event.addAlarm(EKAlarm(absoluteDate: event.startDate!.hourBefore))
                    
                    do {
                        try eventStore.save(event, span: .thisEvent)
                    } catch let error as NSError {
                        self.showAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("techIssues", comment: "Error"))
                        self.postError(error: error)
                        return
                    }
                    self.updateDatabase(IndexPath: index, num: 1)
                    self.events.remove(at: index.row)
                    DispatchQueue.main.async() {
                        self.tableView.deleteRows(at: [index], with: .fade)
                    }
                    self.handleReload()
                    self.showAlert(title: NSLocalizedString("acceptedAlertTitle", comment: "Title"), message: NSLocalizedString("acceptedAlertBody", comment: "body"))
                }
                else {
                    self.showAlert(title: NSLocalizedString("Error", comment: "error"), message: NSLocalizedString("techIssues", comment: "Error"))
                    self.postError(error: error!)
                    return
                }
            }
        }
    }
    
    
    //MARK: - Alert
    
    
    //By creating the method in this way, I was able to reduce a lot of extra code by just calling this function when its just a simple alert.
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
    
    //By creating the method in this way, I was able to reduce a lot of extra code by just calling this function when its just a simple alert.
    /**
     Shows alerts for the given message and title. Calls [createAlertButton]() to add in the relevant buttons onto the alert.
     - Parameters:
         - title: The title to set for the alert box.
         - message: The message to set for the alert box.
         - event: The event to delete.
     */
    
    func showDeleteAlertSure(title: String, message: String, index: IndexPath, event: Event) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: "no"), style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: "yes"), style: UIAlertActionStyle.default, handler: { (x) in
            self.sendAppologies(event: event)
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Smart feature
   
    /**
     Checks whether there is a conflicting event in the users calendar.
     - Parameters:
         - newEvent: The event to check from.
     - Returns: a boolean value to see if there is any conflicts.
     */
    func eventConflict(newEvent: Event) -> Bool {

        var loadedEvents = [Event]()
        let eventStore = EKEventStore()
        let calendars = eventStore.calendars(for: .event)
        
        let oneMonthAgo = Date(timeIntervalSince1970: (Double(newEvent.finishTime!.intValue - 86400)))
        let oneMonthAfter = Date(timeIntervalSince1970: (Double(newEvent.finishTime!.intValue + 86400)))
        for calendar in calendars {
            
     
            
            let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo as Date, end: oneMonthAfter as Date, calendars: [calendar])
            
            let events = eventStore.events(matching: predicate)
            
            for event in events {
                let eventToAdd = Event()
                eventToAdd.title = event.title
                eventToAdd.startTime = event.startDate.timeIntervalSince1970 as NSNumber
                eventToAdd.finishTime = event.endDate.timeIntervalSince1970 as NSNumber
                loadedEvents.append(eventToAdd)
                
            }
            
        }
        print("\(newEvent.startTime!) \t \(newEvent.finishTime!) \n")
        let a = newEvent.startTime! as! Int
        let b = newEvent.finishTime! as! Int
        
        for event in loadedEvents {
            let c = event.startTime! as! Int
            let d = event.finishTime! as! Int
            if a<c && b>c {
                showAlert(title: NSLocalizedString("eventConflictingtitle", comment: "title"), message: NSLocalizedString("eventConflictingBody", comment: "body"))
                return false
            }
            else if a>c && b<d {
                showAlert(title: NSLocalizedString("eventConflictingtitle", comment: "title"), message: NSLocalizedString("eventConflictingBody", comment: "body"))
                return false
            }
            else if a<d && b>d {
                showAlert(title: NSLocalizedString("eventConflictingtitle", comment: "title"), message: NSLocalizedString("eventConflictingBody", comment: "body"))
                return false
            }
            else if a==c || b==d {
                showAlert(title: NSLocalizedString("eventConflictingtitle", comment: "title"), message: NSLocalizedString("eventConflictingBody", comment: "body"))
                return false
            }
        }
        return true
    }
    
    
    /**
     Called when the user decides to send appologies for declining an event.
     - Parameters:
         - event: The event to send the appology for.
     */
    func sendAppologies(event: Event){
        
        let id = NSUUID().uuidString
        let ref = Database.database().reference().child("messages")
        let childRef = ref.child(id)
        let recieveId = event.eventWithId()
        let sendId = Auth.auth().currentUser?.uid
        
        let message = Message()
        message.message = "I am sorry but I cannot make the event \(event.title!). We will have to organise something very soon!"
        message.receiveId = event.eventWithId()!
        message.sendId = Auth.auth().currentUser!.uid
        message.timestamp = Int(Date().timeIntervalSince1970) as NSNumber
        
        
        message.encrypt(key: id)
        let values = ["text": message.message!, "RecieveId": message.receiveId!, "SendId": message.sendId!, "TimeStamp": message.timestamp!] as [String : Any]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error ?? "")
                return
            }
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(sendId!).child(recieveId!)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(recieveId!).child(sendId!)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    //MARK: - Firebase
    
    /**
     Update the information in the database to say whether it has been accepted or declined.
     - Parameters:
         - IndexPath: The index of the tableCell which is to be accepted.
         - bool: The value to update the accepted value of that event to.
     */
    func updateDatabase(IndexPath: IndexPath, num: NSNumber){
        let event = events[IndexPath.row]
        
        let ref = Database.database().reference().child("events").child(event.id!)
        
        let values = ["Id" : event.id!, "Title": event.title!, "Description": event.desc!, "StartTime": event.startTime!, "FinishTime": event.finishTime!, "Host": event.host!, "Invitee": event.invitee!, "Accepted" : num] as [String : Any]
        
        ref.updateChildValues(values)
    }


    ///Gets all the users events.
    func observeUserEvents() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        print("print id: \(uid)")
        print("Observing")
        
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
                        event.accepted = dictionary["Accepted"] as? NSNumber
                        event.location = (dictionary["Location"] as? [NSString?])!
                        if event.invitee == self.currentUser.id {
                            self.events.append(event)
                        }   
                        //cancelled timer, so only 1 timer gets called, and therefore the only reloads the table once
                        self.timer?.invalidate()
                        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
                    }
                }, withCancel: nil)
            })
        }, withCancel: nil)
    }
    
    ///Gets the current users information.
    func getCurrentUser(){
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observe(.value, with: { (DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                user.id = DataSnapshot.key
                self.currentUser = user
            }
        }, withCancel: nil)
        
        
    }
 
 
}
