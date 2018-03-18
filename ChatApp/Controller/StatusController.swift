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
        tf.placeholder = NSLocalizedString("statusPlaceHolder", comment: "status")
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white
        return tf
    }()
    
    ///Save button.
    let saveButton : UIButton = {
        let btn = UIButton()
        btn.setTitle(NSLocalizedString("saveTitle", comment: "save"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        btn.backgroundColor = UIColor.niceBlue
        return btn
    }()

    
    ///Remaining characters.
    lazy var remainingChars : UITextField = {
        let tf = UITextField()
        tf.text = String(describing: 40 - user.status!.count)
        tf.isUserInteractionEnabled = false
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
    var settingsView = SettingsController()

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
        self.navigationItem.title = NSLocalizedString("updateStatus", comment: "Update Status")

        setupFields()
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: NSLocalizedString("backText", comment: "Back"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
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
        if statusField.text!.count == 0 {
            showAlert(title: NSLocalizedString("invalidStatusTitle", comment: "Alert title"), message: NSLocalizedString("invalidStatusBody", comment: "Alert title"))
            return
        }
        user.status = statusField.text
        let values = ["name": user.name!, "email": user.email!, "profileImageUrl": user.profileImageUrl!, "status": statusField.text!]
        if let id = Auth.auth().currentUser?.uid{
            print(values)
            let ref = Database.database().reference().child("users").child(id)
            ref.updateChildValues(values)
            self.settingsView.currentUser = user
            self.showAlert(title: NSLocalizedString("validStatusTitle", comment: "Alert title"), message: NSLocalizedString("validStatusBody", comment: "Alert body"))
        }
        
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
            if title == NSLocalizedString("validStatusTitle", comment: "Title") {
                self.back(sender: self.navigationItem.leftBarButtonItem!)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    ///Back button for NavigationBarItem
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}
