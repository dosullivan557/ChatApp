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
    //constant variables.
    let settings = ["Greeting Message", "Colours"]
    let cellId = "cellId"
    var currentUser = User()
    
    
    
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
            show(GV, sender: self)
        }
        else {
            print("2")
            let CP = ColourPickerController()
            CP.settings = currentUser.settings
            show(CP, sender: self)
        }
    }
  
}
