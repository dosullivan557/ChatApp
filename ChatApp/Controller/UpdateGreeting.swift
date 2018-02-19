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

}
