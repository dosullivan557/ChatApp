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
    ///Gives the number of rows in the table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    }
    ///Specifies each element in the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
  
}
