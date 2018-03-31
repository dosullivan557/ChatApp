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
    var list = [Tuple<String, String>]()

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
        let sendMessageTuple = Tuple<String, String>(s1: "Send Message", s2: "e4nsaeAqIHU")
        list.append(sendMessageTuple)
        
        let planEventTuple = Tuple<String, String>(s1: "Plan Event", s2: "UpqdPjGRBlI")
        list.append(planEventTuple)
        
        let acceptEventTuple = Tuple<String, String>(s1: "Accept Event", s2: "pw-xJ4RIYkY")
        list.append(acceptEventTuple)
        
        let declineEventTuple = Tuple<String, String>(s1: "Decline Event", s2: "ZBY1kK3Btc0")
        list.append(declineEventTuple)
        
        let changeUserSettingTuple = Tuple<String, String>(s1: "Change User Settings", s2: "OPHwGhXadnE")
        list.append(changeUserSettingTuple)
        
        let changeProfilePictureTuple = Tuple<String, String>(s1: "Change Profile Picture", s2: "ivYrhtMADM4")
        list.append(changeProfilePictureTuple)
        
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
        cell.detailTextLabel?.text = list[indexPath.row].getObjectOne()
        
        return cell
    }
    
    //Defines the height of each table cell.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    //Called when a tablecell is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let helpController = HelpController()
        helpController.tuple = list[indexPath.row]
        self.show(helpController, sender: self)
//        print(list[indexPath.row].getStringTwo())
    }
    
    
}

