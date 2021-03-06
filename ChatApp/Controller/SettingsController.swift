//
//  SettingsView.swift
//  ChatApp
//
//  Created by Danny on 18/02/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase

class SettingsController: UITableViewController {
    // MARK: - Constants
    ///Array for the settings.
    let settings = [NSLocalizedString("greetingTitle", comment: "Greeting title"),NSLocalizedString("coloursTitle", comment: "Colours Title"), NSLocalizedString("statusTitle", comment: "Status Title"), NSLocalizedString("blockedTitle", comment: "Blocked users")]
    ///The reuse cell identifier for the table view.
    let cellId = "cellId"
    var profileView = MyProfileController()
    // MARK: - Variables
    
    ///The current user of the system.
    var currentUser = User()
    ///MessagesController
    var messagesController = MessagesController()
    
    //MARK: - View initalisation
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        let titleView = UITextView()
        titleView.text = NSLocalizedString("settingsTitle", comment: "Settings title")
        titleView.isEditable = false
        titleView.isUserInteractionEnabled = false
        titleView.backgroundColor? = UIColor.clear
        navigationItem.titleView = titleView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        handleReload()
    }
    
    
    //MARK: - Tableview
    
    ///Reloads the table view using the main thread.
    @objc func handleReload() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    ///Gives the number of rows in the table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    ///Specifies each element in the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel!.text = settings[indexPath.row]
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = currentUser.settings?.greeting!
        }
        else if indexPath.row == 1 {
            var myCol = ""
            var theirCol = ""
            if currentUser.settings?.myColor! == "Green" {
                myCol = NSLocalizedString("green", comment: "Green")
            }
            else if currentUser.settings?.myColor! == "Pink" {
                myCol = NSLocalizedString("pink", comment: "Pink")
            }
            else if currentUser.settings?.myColor! == "Purple" {
                myCol = NSLocalizedString("purple", comment: "Purple")
            }
            if currentUser.settings?.theirColor! == "Green" {
                theirCol = NSLocalizedString("green", comment: "Green")
            }
            else if currentUser.settings?.theirColor! == "Pink" {
                theirCol = NSLocalizedString("pink", comment: "Pink")
            }
            else if currentUser.settings?.theirColor! == "Purple" {
                theirCol = NSLocalizedString("purple", comment: "Purple")
            }
            let details = myCol + " " + NSLocalizedString("and", comment: "and") + " " + theirCol
            cell.detailTextLabel?.text = details
        }
        else if indexPath.row == 2 {
            cell.detailTextLabel?.text = currentUser.status!
            profileView.statusLabel.text = currentUser.status
        }
        else if indexPath.row == 3 {
            cell.detailTextLabel?.text = NSLocalizedString("unblockUsersDesc", comment: "Unblock users")
        }
        return cell
    }
    ///Defines the height of each table cell.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let GV = UpdateGreetingController()
            GV.settings = currentUser.settings
            GV.settingsView = self
            show(GV, sender: self)
        }
        else if indexPath.row == 1{
            let CP = ColourPickerController()
            CP.settings = currentUser.settings
            CP.settingsView = self
            show(CP, sender: self)
        }
        else if indexPath.row == 2 {
            let SController = StatusController()
            SController.settingsView = self
            SController.user = currentUser
            show(SController, sender: self)
        }
        else if indexPath.row == 3 {
            let BUC = BlockedContactsController()
            BUC.currentUser = self.currentUser
            BUC.messagesController = self.messagesController
            show(BUC, sender: self)
        }
    }
    
}
