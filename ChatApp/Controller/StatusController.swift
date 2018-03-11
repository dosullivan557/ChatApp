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
    
    lazy var remainingChars : UITextField = {
        let tf = UITextField()
        tf.text = String(describing: 40 - user.status!.count)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white
        return tf
        
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
        view.addSubview(remainingChars)
        view.addSubview(saveButton)
        view.backgroundColor = UIColor.niceOrange
        statusField.addTarget(self, action: #selector(handleChangeValue), for: .editingChanged)
        self.navigationItem.title = "Update Status"

        setupFields()
    }
    
    //MARK: - Setup

    func setupFields() {
        statusField.topAnchor.constraint(equalTo: view.topAnchor, constant: 75).isActive = true
//        statusField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        statusField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        statusField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
        statusField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        remainingChars.topAnchor.constraint(equalTo: view.topAnchor, constant: 75).isActive = true
//        remainingChars.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        remainingChars.leftAnchor.constraint(equalTo: statusField.rightAnchor).isActive = true
        remainingChars.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        remainingChars.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        saveButton.topAnchor.constraint(equalTo: statusField.bottomAnchor, constant: 30).isActive = true
        saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    //MARK: - Keyboard
    
    /**
     Checks whether the textfield length is valid; in this case it is the length of the text inside of the textfield. If it passes, it allows the textfield's value to be changed, and if it doesn't, it doesn't allow the value to change.
     - Parameters:
         - textField : extfield to check.
         - range : Range to pass.
         - string : String to change.
     - Returns: A boolean value that checks whether the test passes.
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 40
    }
    
    ///Called when the value of the textfield changes.
    @objc func handleChangeValue() {
//        print("Value changes")
        remainingChars.text = String(describing: 40 - statusField.text!.count)
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
