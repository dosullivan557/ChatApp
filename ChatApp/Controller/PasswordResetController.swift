//
//  PasswordResetController.swift
//  ChatApp
//
//  Created by Danny on 17/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
class PasswordResetController: UIViewController {
    // MARK: - Constants
    ///Title view.
    let titleMain: UITextView = {
        let title = UITextView()
        title.text = NSLocalizedString("resetPassword", comment: "reset password")
        title.isEditable = false
        title.isUserInteractionEnabled = false
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = UIColor.black
        title.backgroundColor = UIColor.clear
        title.font = UIFont.systemFont(ofSize: 25)
        title.textAlignment = .center
        return title
    }()
    
    ///Email textfield.
    let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = NSLocalizedString("email", comment: "email")
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    
    
    ///Reset button.
    let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("resetPassword", comment: "Reset password title button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.niceOtherOrange
        button.addTarget(self, action: #selector(handlePasswordReset), for: .touchUpInside)
        return button
    }()
    
    ///Cancel button.
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("cancel", comment: "cancel"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    

    //MARK: - View initialisation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.niceOrange
        view.addSubview(titleMain)
        view.addSubview(emailField)
        view.addSubview(resetButton)
        view.addSubview(cancelButton)
        setupItems()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
    }
    
    //MARK: - Setup
    
    ///Sets up the views constraints.
    func setupItems(){
        
        cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
        titleMain.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        titleMain.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleMain.heightAnchor.constraint(equalToConstant: 50).isActive = true
        titleMain.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        emailField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        emailField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
        emailField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        resetButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20).isActive = true
        resetButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
        resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        resetButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    //MARK: - Keyboard
    
    //Keyboard hides when return key is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    ///Dismisses keyboard when called.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - Interaction
    
    ///Called when the cancel button is pressed.
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    /// Handles the password reset by using Firebase Authentications method to send an email to reset the password.
    @objc func handlePasswordReset(){
        if let email = emailField.text {
            if isValidEmail(testStr: email) {
                Auth.auth().sendPasswordReset(withEmail: email, completion: { (Error) in
                    if Error != nil {
                        self.showAlert(title: NSLocalizedString("invalidEmailTitle", comment: "title"), message: (Error?.localizedDescription)! + NSLocalizedString("invalidEmailBody", comment: "Body"))
                    }
                    else {
                        self.showAlert(title: NSLocalizedString("emailResetTitle", comment: "Title"), message: NSLocalizedString("emailResetBody", comment: "Body"))
                    }
                })
            }
        }
        else {
            showAlert(title: NSLocalizedString("invalidEmailTitle", comment: "Title"), message: NSLocalizedString("invalidEmailBody", comment: "Body"))
        }
    }
    
    

    
    //MARK: - Validation
  
    /**
     Is called to verify the whether the email is valid locally before sending it to Firebase. Uses a regular expression to check the email typed in abides by the conventions.
     - Parameters:
         - testStr: The string to test.
     - Returns: A boolean value to say whether the email is valid.
     */
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    

    //MARK: - Alert
    
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
    
    
    
}
