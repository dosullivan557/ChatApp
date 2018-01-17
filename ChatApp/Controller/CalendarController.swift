//
//  CalendarContainer.swift
//  ChatApp
//
//  Created by Danny on 13/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase

class CalendarController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    

   
    
    var user: User? {
        didSet{

            navigationItem.title = "Event with " + ((user?.name)!.components(separatedBy: " "))[0]
        }
    }

    let titleField : UITextField = {
        let title = UITextField()
        title.placeholder = "Enter Title"
        title.translatesAutoresizingMaskIntoConstraints = false
        title.backgroundColor = UIColor.white
        title.layer.borderColor = UIColor.black.cgColor
        title.layer.borderWidth = 1
        return title
    }()
    let descriptionField : UITextField = {
        let title = UITextField()
        title.placeholder = "Enter Description"
        title.translatesAutoresizingMaskIntoConstraints = false
        title.backgroundColor = UIColor.white
        title.layer.borderColor = UIColor.black.cgColor
        title.layer.borderWidth = 1
        return title
    }()
    
    let datePicker : UIDatePicker = {
        let dp = UIDatePicker()
        dp.translatesAutoresizingMaskIntoConstraints = false
        dp.layer.borderColor = UIColor.black.cgColor
        dp.layer.borderWidth = 1
        dp.minuteInterval = 5
        dp.addTarget(self, action: #selector(selectedDate), for: .valueChanged)
        return dp
    }()
    
    let labelStart :UITextView = {
        let label = UITextView()
        label.text = "Start Date"
        label.isEditable = false
        label.textColor = UIColor.black
        label.isUserInteractionEnabled = false
        label.backgroundColor = UIColor.red
        return label
    }()
    
    let labelFinish :UITextView = {
        let label = UITextView()
        label.text = "End Date"
        label.isEditable = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    @objc func selectedDate(){
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = DateFormatter.Style.short
        timeFormatter.dateStyle = DateFormatter.Style.long
        let strDate = timeFormatter.string(from: datePicker.date)
        // do what you want to do with the string.
        
       dateField.text = strDate
    }
    
    
    let dateField : UITextField = {
        let field = UITextField()
        field.allowsEditingTextAttributes = false
        field.placeholder = "Please select a date..."
        field.layer.borderColor = UIColor.black.cgColor
        field.layer.borderWidth = 1
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    
    let submitButton : UIButton = {
        let button = UIButton()
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.green
        
        return button
    }()
    
    @objc func handleSubmit(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let myRef = Database.database().reference().child("events").childByAutoId()
        let event = Event()
        event.title = titleField.text
        event.desc = descriptionField.text
        event.time = datePicker.date.timeIntervalSince1970 as NSNumber
        event.host = uid
        event.invitee = user?.id
        
        
        let values = ["Title": event.title!, "Description": event.desc!, "Time": event.time!, "Host": event.host!, "Invitee": event.invitee!] as [String : Any]
        
        myRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error ?? "")
                return
            }
        
            
            let userEventRef = Database.database().reference().child("user-events").child(uid).child((self.user?.id)!)
            
            let messageId = myRef.key
            userEventRef.updateChildValues([messageId: 1])
            
            let recipientUserEventRef = Database.database().reference().child("user-events").child((self.user?.id)!).child(uid)
            recipientUserEventRef.updateChildValues([messageId: 1])
            
        }
        
    }
    func dateToSecs() -> Int{
        return Int(datePicker.date.timeIntervalSince1970)

    }

    
    let tb : UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.purple
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)

        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }()
    
    @objc func donePicker(){

        if dateField.isEditing {
            dateField.endEditing(true)
        }
    }
    
    
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        
        //date picker
        dateField.inputView = datePicker
        dateField.inputAccessoryView = tb
        
    
        
        view.addSubview(titleField)
        view.addSubview(descriptionField)
        view.addSubview(labelStart)
        view.addSubview(dateField)
        view.addSubview(labelFinish)
        view.addSubview(submitButton)
        setupFields()
    }
    let containerView: UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor.green
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    
    }()

    
    func setupFields(){
        //main title
        
        titleField.topAnchor.constraint(equalTo: view.topAnchor, constant: 65).isActive = true
        titleField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        titleField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        titleField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        descriptionField.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 25).isActive = true
        descriptionField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descriptionField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        descriptionField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        descriptionField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        labelStart.topAnchor.constraint(equalTo:descriptionField.bottomAnchor,constant: 25).isActive = true
        labelStart.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        labelStart.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
        labelStart.heightAnchor.constraint(equalToConstant: 50).isActive = true


        dateField.topAnchor.constraint(equalTo: labelStart.bottomAnchor, constant: 25).isActive = true
        dateField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        dateField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        dateField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        submitButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        submitButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25).isActive = true
        
    
    }
    
   
}
