//
//  StatusController.swift
//  ChatApp
//
//  Created by Danny on 09/03/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase

class StatusController: UIViewController {
    
    //MARK: - Constants

    ///Status Field
    let statusField : UITextField = {
        let tf = UITextField()
        tf.text = ""
        tf.placeholder = "Please enter a status."
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white
        return tf
    }()
    
    ///Save button.
    let saveButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("Save", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        btn.backgroundColor = UIColor.niceBlue
        return btn
    }()

    //MARK: - Variables
    var user = User() {
        didSet {
            statusField.text = user.status
        }
    }
    
    ///SettingsView
    var settingsView = SettingsView()

    //MARK: - View Initislisation

    //View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        addToolBar(textField: statusField)
        view.addSubview(statusField)
        view.addSubview(saveButton)
        view.backgroundColor = UIColor.niceOrange
        
        self.navigationItem.title = "Update Status"

        setupFields()
    }
    
    //MARK: - Setup

    func setupFields() {
        statusField.topAnchor.constraint(equalTo: view.topAnchor, constant: 75).isActive = true
        statusField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        statusField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        statusField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        saveButton.topAnchor.constraint(equalTo: statusField.bottomAnchor, constant: 30).isActive = true
        saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    
    //MARK: - Firebase
    
    ///Called when the save button is pressed. Updates the new data to the database.
    @objc func handleSave() {
        user.status = statusField.text
        let values = ["name": user.name!, "email": user.email!, "profileImageUrl": user.profileImageUrl!, "status": statusField.text!]
        if let id = Auth.auth().currentUser?.uid{
            print(values)
            let ref = Database.database().reference().child("users").child(id)
            ref.updateChildValues(values)
            self.settingsView.currentUser = user
        }
    }

}
