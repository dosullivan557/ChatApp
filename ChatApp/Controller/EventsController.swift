
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
        let deleteEvent = events[editActionsForRowAt.row]
        let decline = UITableViewRowAction(style: .normal, title: "Decline") { action, index in
            print("decline button tapped")
            self.declineFunc(index: index, event: deleteEvent)
        }
        decline.backgroundColor = UIColor(r: 206, g: 27, b: 0)
        
        let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in

        print("accept button tapped")
            self.acceptFunc(index: index)
        }
        accept.backgroundColor = UIColor(r: 0, g: 168, b: 48)
        
        return [accept, decline]
    }
    
    /**
     This is called when the decline event button is pressed. It removes the event from the cell, and then updates the database to say that it was declined.
     - Parameters:
         - index: The index of the table view to remove.

     */
    func declineFunc(index: IndexPath, event: Event){
        print("Decline")
        self.updateDatabase(IndexPath: index, bool: false)
        self.events.remove(at: index.row)
        DispatchQueue.main.async() {
            self.tableView.deleteRows(at: [index], with: .fade)
        }
        showDeleteAlertSure(title: "You have declined this event", message: "You have declined the event with this user, would you like to send your appologies?", index: index, event: event)
        self.handleReload()
   
        
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
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (x) in
            self.sendAppologies(event: event)
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
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
             self.showAlert(title: "Event Declined", message: "This event has been removed.")
    }
    /**
     This is called when the accept event button is pressed. It gets access to the calendar, and then adds it in. Once it has been accepted, it removes it from the table view.
     - Parameters:
         - index: The index of the table view to add.
     */
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
                event.location = currentEvent.location[2] as String?
//                event.addAlarm(EKAlarm(relativeOffset: ((currentEvent.startTime!)) as! TimeInterval))
//                event.addAlarm(EKAlarm(relativeOffset: (currentEvent.startTime as! TimeInterval) - (3600 as TimeInterval)))

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
                self.showAlert(title: "Event Accepted", message: "Event has been confirmed, and is now in your calendar. We will remind you an hour before the event, as well as at the planned meeting time!.")
            }
            else {
                self.showAlert(title: "Error", message: "We have run into an issue whilst creating the event. We have informed the developer to this issue")
                self.postError(error: error!)
                return
            }
        }
    }
    
    /**
     Update the information in the database to say whether it has been accepted or declined.
     - Parameters:
         - IndexPath: The index of the tableCell which is to be accepted.
         - bool: The value to update the accepted value of that event to.
     */
    func updateDatabase(IndexPath: IndexPath, bool: Bool){
        let event = events[IndexPath.row]
        
        let ref = Database.database().reference().child("events").child(event.id!)
        
        let values = ["Id" : event.id!, "Title": event.title!, "Description": event.desc!, "StartTime": event.startTime!, "FinishTime": event.finishTime!, "Host": event.host!, "Invitee": event.invitee!, "Accepted" : bool] as [String : Any]
        
        ref.updateChildValues(values)
    }
    /**
     Uploads any errors to the database for examination.
     - Parameters:
         - error: The error code which is called.
     */
    func postError(error: Error){
        let ref = Database.database().reference().child("Error").child(NSUUID().uuidString)
        let values = ["Error Description": error.localizedDescription]
        ref.updateChildValues(values as [String: AnyObject])
    }
    
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
    
    /**
     Gets passed the current user of the system, and then sets up the navigation bar with that users information.
     - Parameters:
         - user: The current user.
    */
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
    override func viewDidAppear(_ animated: Bool) {
        if let id = currentUser.id {
            if id == Auth.auth().currentUser?.uid {
                print("Same user")
            }
            else {
                print("Different")
                events.removeAll()
                handleReload()
                getCurrentUser()
                setupNavBarWithUser(currentUser)
                observeUserEvents()
            }
        }
        else {
            print("error")
        }
        
    }
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
    
    /**
     Checks whether there is a conflicting event in the users calendar.
     - Parameters:
         - newEvent: The event to check from.
     - Returns: a boolean value to see if there is any conflicts.
     */
    func eventConflict(newEvent: Event) -> Bool {
        let eventStore = EKEventStore()
        let calendars = eventStore.calendars(for: .event)
    
        for calendar in calendars {
            
            var events = eventStore.events(matching: NSPredicate.init(block: {_,_ in return true}))
//
//            print("number of events in calander: \(events.count)")
//                for event in events {
//                    titles.append(event.title)
//                    startDates.append(event.startDate)
//                    endDates.append(event.endDate)
//                }
//
            events.sort(by: { (event1, event2) -> Bool in
                return event1.startDate.timeIntervalSince1970 < event2.startDate.timeIntervalSince1970
            })

            if let currentEventST = newEvent.startTime?.doubleValue, let currentEventET = newEvent.finishTime?.doubleValue{
                for event in events {
                    let eventStartTime = event.startDate.timeIntervalSince1970 as Double
                    let eventEndTime = event.endDate.timeIntervalSince1970 as Double
                    if ((currentEventST < eventStartTime) && (currentEventST < eventEndTime) && (currentEventET > eventStartTime) && (currentEventET < eventEndTime)) {
                        print("huh")
                    }
                }
                
            }
            
            
            
            
        }
    
    
        return false
    }
    
    
    /**
     Gets all the users events.
     */
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


