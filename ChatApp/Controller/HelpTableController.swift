//
//  HelpTableController.swift
//  ChatApp
//
//  Created by Danny on 18/02/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase

class HelpTableController: UITableViewController {
    // MARK: - Constants
    let cellId = "cellId"

    // MARK: - Variables
    var list = [QuadStructure<String, String, String, String>]()

    ///The current user of the system.
    
    
    //MARK: - View initalisation
    override func viewDidLoad() {
        setupList()
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        let titleView = UITextView()
        titleView.text = "Help"
        titleView.isEditable = false
        titleView.isUserInteractionEnabled = false
        titleView.backgroundColor? = UIColor.clear
        navigationItem.titleView = titleView
    }
  
    func setupList() {
        let sendMessageQuad = QuadStructure<String, String, String, String>(s1: Tuple<String, String>(s1: "Send Message", s2: "e4nsaeAqIHU"), s2: Tuple<String, String>(s1: "This is how a user is able to send a message to another user.", s2: "1. Click on the create message button in the top right corner of the messages tab.\n2. Select the user who you would like to send a message to.\n3. Click on the textfield in the bottom of that particular chatlog.\n4. Type your message to the user.\n5. Pres the send button in the bottom right hand corner of the screen."))
        list.append(sendMessageQuad)
        
        let planEventQuad = QuadStructure<String, String, String, String>(s1: Tuple<String, String>(s1: "Plan Event", s2: "UpqdPjGRBlI"), s2: Tuple<String, String>(s1: "This is how a user can create an event.", s2: "1. Open up the chatlog for the user you would like to create an event with.\n2. Click on the plus in the top right corner. \n3. Fill in the information about the event inside of that view.\n4. Click on submit.\n5. Wait for the user to accept the event, and it will be added into your calendar."))
        list.append(planEventQuad)
        
        let acceptEventQuad = QuadStructure<String, String, String, String>(s1: Tuple<String, String>(s1: "Accept Event", s2: "pw-xJ4RIYkY"), s2: Tuple<String, String>(s1: "This is how a user can accept an event.", s2: "1. Open up the events tab.\n2. Swipe left on the event you would like to accept.\n3. Click on accept."))
        list.append(acceptEventQuad)
        
        let declineEventQuad = QuadStructure<String, String, String, String>(s1: Tuple<String, String>(s1: "Decline Event", s2: "ZBY1kK3Btc0"), s2: Tuple<String, String>(s1: "This is how a user can decline an event", s2: "1. Open up the events tab.\n2. Swipe left on the event you would like to decline.\n3. Click on decline."))
        list.append(declineEventQuad)
        
        let changeUserSettingsQuad = QuadStructure<String, String, String, String>(s1: Tuple<String, String>(s1: "Change User Settings", s2: "OPHwGhXadnE"), s2: Tuple<String, String>(s1: "This is how a user can change their user settings, such as their greeting, status or chatlog colours.", s2: "1. Click on the My Profile tab\n2. Click on the gear button in the top right hand corner.\n3. Select the relevant setting to change.\n4. Change the value to the new value. Take note that if you are either changing the greeting or status, there is a maximum of 40 characters allowed, and the number of remaining characters is on the right of the text fields.\n5. Click on the save button."))
        list.append(changeUserSettingsQuad)
        
        let changeProfilePictureQuad = QuadStructure<String, String, String, String>(s1: Tuple<String, String>(s1: "Change Profile Picture", s2: "ivYrhtMADM4"), s2: Tuple<String, String>(s1: "This is how the user changes their profile picture.", s2: "1. Click on the My Profile tab.\n2. Click on the change profile button which is situated on top of the profile picture.\n3. This will launch a image picker. Select the image you would like to use.\n4. Crop the picture to your desired size.\n5. Click done, which is situated in the top right corner."))
        list.append(changeProfilePictureQuad)
        
        handleReload()
    }
    
    // MARK: - TableView
    
   
    ///Reloads the table view using the main thread.
    @objc func handleReload() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    //Gives the number of rows in the table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    //Specifies each element in the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.detailTextLabel?.text = list[indexPath.row].getObjectOne().getObjectOne()
        
        return cell
    }
    
    //Defines the height of each table cell.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    //Called when a tablecell is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let helpController = HelpController()
        helpController.quadTuple = list[indexPath.row]
        self.show(helpController, sender: self)
//        print(list[indexPath.row].getStringTwo())
    }
    
    
}

