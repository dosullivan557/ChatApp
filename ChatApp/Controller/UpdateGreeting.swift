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
    
    ///Remaining characters.
    lazy var remainingChars : UITextField = {
        let tf = UITextField()
        tf.text = String(describing: 40 - settings!.greeting!.count)
        tf.isUserInteractionEnabled = false
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white
        return tf
        
    }()

    // MARK: - Variables
    ///The users settings.
    var settings : Settings?
    ///SettingsView
    var settingsView = SettingsView()

    //MARK: - View initialisation
    override func viewDidLoad() {
        view.backgroundColor = UIColor.niceOrange
        super.viewDidLoad()
        addToolBar(textField: greetingTextField)
        
        view.addSubview(greetingTextField)
        view.addSubview(remainingChars)
        view.addSubview(saveButton)
        greetingTextField.text = settings?.greeting!
        setupFields()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        self.navigationItem.title = "Update Greeting"

        view.addGestureRecognizer(tap)
    }
    
    //MARK: - Setup
    
    ///Sets up views.
    func setupFields(){
        greetingTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive = true
        greetingTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        greetingTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
        greetingTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        remainingChars.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive = true
        remainingChars.leftAnchor.constraint(equalTo: greetingTextField.rightAnchor).isActive = true
        remainingChars.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        remainingChars.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        saveButton.topAnchor.constraint(equalTo: greetingTextField.bottomAnchor, constant: 30).isActive = true
        saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    

    
    //MARK: - Firebase
    ///Called when the save button is pressed. Updates the new data to the database.
    @objc func handleSave() {
        settings?.greeting = greetingTextField.text!
        let values = ["Greeting" : greetingTextField.text!, "TheirColor" : "Pink", "YourColor" : "Green"]
        if let id = Auth.auth().currentUser?.uid{
            print(values)
            let ref = Database.database().reference().child("user-settings").child(id)
            ref.updateChildValues(values)
            self.showAlert(title: "Updated", message: "Your greeting has successfully been updated.")

        }
        settingsView.currentUser.settings = settings
    }
  
    //MARK: - Alert
    
    //By creating the method in this way, I was able to reduce a lot of extra code by just calling this function when its just a simple alert.
    /**
     Shows alerts for the given message and title. Calls [createAlertButton]() to add in the relevant buttons onto the alert.
     - Parameters:
     - title: The title to set for the alert box.
     - message: The message to set for the alert box.
     */
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Keyboard
    ///Hides keyboard.
    @objc func hideKeyboard() {
        greetingTextField.endEditing(true)
    }
 
}
