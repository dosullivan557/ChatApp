//
//  SettingsView.swift
//  ChatApp
//
//  Created by Danny on 18/02/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase

class SettingsView: UITableViewController {
    // MARK: - Constants
    ///Array for the settings.
    let settings = ["Greeting Message", "Colours", "Status"]
    ///The reuse cell identifier for the table view.
    let cellId = "cellId"
    var profileView = MyProfileController()
    // MARK: - Variables
    
    ///The current user of the system.
    var currentUser = User()
    
    
    //MARK: - View initalisation
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        let titleView = UITextView()
        titleView.text = "Settings"
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
            let details = (currentUser.settings?.myColor!)! + " and " + (currentUser.settings?.theirColor!)!
            cell.detailTextLabel?.text = details
        }
        else if indexPath.row == 2 {
            cell.detailTextLabel?.text = currentUser.status!
            profileView.statusLabel.text = currentUser.status
        }
        return cell
    }
    ///Defines the height of each table cell.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let GV = UpdateGreeting()
            GV.settings = currentUser.settings
            GV.settingsView = self
            show(GV, sender: self)
        }
        else if indexPath.row == 1{
            //            print("2")
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
    }
    
}
