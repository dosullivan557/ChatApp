//
//  UpdateGreeting.swift
//  ChatApp
//
//  Created by Danny on 19/02/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase

class UpdateGreeting: UIViewController {
    // MARK: - Constants
    
    ///Greeting text field.
    let greetingTextField : UITextField = {
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
    
    //MARK: - View initialisation
    override func viewDidLoad() {
        view.backgroundColor = UIColor.niceOrange
        super.viewDidLoad()
        view.addSubview(greetingTextField)
        view.addSubview(saveButton)
        greetingTextField.text = settings?.greeting!
        setupFields()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    //MARK: - Setup
    
    ///Sets up views.
    func setupFields(){
        greetingTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        greetingTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        greetingTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        greetingTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        saveButton.topAnchor.constraint(equalTo: greetingTextField.bottomAnchor, constant: 30).isActive = true
        saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    
    // MARK: - Variables
    ///The users settings.
    var settings : Settings?
    
    //MARK: - Firebase
    ///Called when the save button is pressed. Updates the new data to the database.
    @objc func handleSave() {
        let values = ["Greeting" : greetingTextField.text!, "TheirColor" : "Pink", "YourColor" : "Green"]
        if let id = Auth.auth().currentUser?.uid{
            print(values)
            let ref = Database.database().reference().child("user-settings").child(id)
            ref.updateChildValues(values)
        }
    }
  
    
    //MARK: - Keyboard
    ///Hides keyboard.
    @objc func hideKeyboard() {
        greetingTextField.endEditing(true)
    }
 
}
