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
    
    var settings : Settings? 
    let textField : UITextField = {
        let tf = UITextField()
        tf.text = ""
        tf.placeholder = "Please enter a greeting."
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white
        return tf
    }()
    
    let button : UIButton = {
        let btn = UIButton()
        btn.setTitle("Save", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        btn.backgroundColor = UIColor.niceBlue
        return btn
    }()
    
    ///Called when the save button is pressed. Updates the new data to the database.
    @objc func handleSave() {
        let values = ["Greeting" : textField.text!, "TheirColor" : "Pink", "YourColor" : "Green"]
        if let id = Auth.auth().currentUser?.uid{
            print(values)
            let ref = Database.database().reference().child("user-settings").child(id)
            ref.updateChildValues(values)
        }
    }
    override func viewDidLoad() {
        view.backgroundColor = UIColor.niceOrange
        super.viewDidLoad()
        view.addSubview(textField)
        view.addSubview(button)
        textField.text = settings?.greeting!
        setupFields()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    ///Hides keyboard.
    @objc func hideKeyboard() {
        textField.endEditing(true)
    }
    
    ///Sets up views.
    func setupFields(){
        textField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        textField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        textField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        button.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 30).isActive = true
        button.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
}
