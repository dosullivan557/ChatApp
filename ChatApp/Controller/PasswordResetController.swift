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
        
    }
    
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
    @objc func handlePasswordReset(){
        if let email = emailField.text {
            Auth.auth().sendPasswordReset(withEmail: email, completion: { (Error) in
                if Error != nil {
                    print("successful, show alert")
                }
                else {
                    print(Error?.localizedDescription)
                }
            })
        }
    }


}
