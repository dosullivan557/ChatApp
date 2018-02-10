//
//  PasswordResetController.swift
//  ChatApp
//
//  Created by Danny on 17/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
class PasswordResetController: UIViewController, UITextFieldDelegate {
    
    let titleMain: UITextView = {
        let title = UITextView()
        title.text = "Reset Password"
        title.isEditable = false
        title.isUserInteractionEnabled = false
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = UIColor.purple
        title.backgroundColor = UIColor.clear
        title.font = UIFont.systemFont(ofSize: 25)
        title.textAlignment = .center
        return title
    }()
    
    let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        return tf
    }()
    


    
    let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset Password", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.purple
        button.addTarget(self, action: #selector(handlePasswordReset), for: .touchUpInside)
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    ///Keyboard hides when return key is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    ///Dismisses keyboard when called.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    ///Called when the cancel button is pressed.
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 233, g: 175,b: 50)
        view.addSubview(titleMain)
        view.addSubview(emailField)
        view.addSubview(resetButton)
        view.addSubview(cancelButton)
        setupItems()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
    }
    
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
    
    /// Handles the password reset by using Firebase Authentications method to send an email to reset the password.
    @objc func handlePasswordReset(){
        if let email = emailField.text {
            if isValidEmail(testStr: email) {
            Auth.auth().sendPasswordReset(withEmail: email, completion: { (Error) in
                if Error != nil {
                    self.showAlert(title: "Invalid Email", message: (Error?.localizedDescription)! + " Please Enter a valid Email")
                }
                else {
                    self.showAlert(title: "Email has been sent", message: "An email has been sent with instructions to reset your password.")
                }
            })
        }
        }
        else {
            showAlert(title: "Invalid Email", message: "Please enter a valid Email Address")
        }
    }
    
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
