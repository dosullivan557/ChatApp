//
//  ReportController.swift
//  ChatApp
//
//  Created by Danny on 22/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
class ReportController: UIViewController, UITextFieldDelegate {
    
    
    var user : User? {
        didSet {
            pageTitle.text = "Report " + (user?.name!)!
        }
    }
    let pageTitle : UITextView = {
        let name = UITextView()
        name.allowsEditingTextAttributes = false
        name.isEditable = false
        name.isUserInteractionEnabled = false
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textAlignment = .center
        name.font = UIFont(name: "arial", size: 20)
        name.backgroundColor = UIColor.clear
        name.textColor = UIColor.black
        return name
    }()
    
    let textField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Please Enter a description as to why you are reporting this user."
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont(name: "arial", size: 10)
        tf.textColor = UIColor.black
        tf.backgroundColor = UIColor.white
        return tf
    }()
    
    let reportButton: UIButton = {
        let button = UIButton()
        button.setTitle("Report User", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(handleReport), for: .touchUpInside)
        
        return button
    }()
    
    
    /**
     Called when the submit report button is pressed.
     */
    @objc func handleReport() {
        guard let id = Auth.auth().currentUser?.uid else {
            return
        }
        let values = ["UserReported": user?.id!, "Reporter": id, "Comment": textField.text!] as [String : Any]
        
        let ref = Database.database().reference().child("Reports").child((user?.id)!).child(id)
        ref.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if  err != nil {
                return
            }
            self.sucessfulReport()
        })
        
    }
    
    /// Called when a report has been submitted successfully.
    func sucessfulReport(){
        let alert = UIAlertController(title: "Thank you", message: "Thank you for reporting this user. We will look into this!", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 233, g: 175,b: 50)
        // Do any additional setup after loading the view.
        view.addSubview(pageTitle)
        view.addSubview(textField)
        view.addSubview(reportButton)
        setupFields()
    }
    ///Hides Keyboard when called.
    @objc func hideKeyboard() {
        view.self.endEditing(true)
    }
    ///Hides the keyboard when the return key is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    ///Sets up view constraints.
    func setupFields() {
        pageTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 75).isActive = true
        pageTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageTitle.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        pageTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        textField.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 20).isActive = true
        textField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        reportButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20).isActive = true
        reportButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        reportButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        reportButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
    }
    
    
    
}

