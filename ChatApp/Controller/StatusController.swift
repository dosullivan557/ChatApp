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
    
    var user = User() {
        didSet {
            statusField.text = user.status
        }
    }
    ///Status Field
    let statusField : UITextField = {
        let tf = UITextField()
        tf.text = ""
        tf.placeholder = "Please enter a greeting."
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
    
    var settingsView = SettingsView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addToolBar(textField: statusField)
        view.addSubview(statusField)
        view.addSubview(saveButton)
        view.backgroundColor = UIColor.niceOrange
        
        self.navigationItem.title = "Update Status"

        setupFields()
    }
    
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
    
}
