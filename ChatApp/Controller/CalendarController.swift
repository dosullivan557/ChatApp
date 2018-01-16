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
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if timesField.isEditing{
            timesField.text = times[row]
        }
        else if zoneField.isEditing {
            zoneField.text = zones[row]
        }
            
        else {
            timeAreaField.text = timesArea[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.isEqual(timePicker){
            return times.count
        }
        if pickerView.isEqual(zonePicker){
            return zones.count
        }
        return timesArea.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.isEqual(timePicker){
            return times[row]
        }
        if pickerView.isEqual(zonePicker) {
            return zones[row]
        }
        return timesArea[row]
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
    
    let times = ["0", "1", "2", "3", "4", "5", "6", "7"]
    let timesArea = ["Minutes", "Hours", "Days"]
    let zones = ["Before", "After"]

    let zonePicker : UIPickerView = {
        let picker = UIPickerView()
        
        return picker
    }()
    let zoneField : UITextField = {
        let tf = UITextField()
        tf.text = "Zone"
        tf.allowsEditingTextAttributes = false
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.layer.borderColor = UIColor.black.cgColor
        tf.layer.borderWidth = 1
        return tf
    }()
    
    let timePicker : UIPickerView = {
        let picker = UIPickerView()

        return picker
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
    let timeAreaPicker : UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    let tb : UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.purple
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
//        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }()
    
    @objc func donePicker(){
        if timeAreaField.isEditing {
            timeAreaField.endEditing(true)
        }
        if dateField.isEditing {
            dateField.endEditing(true)
        }
        else if zoneField.isEditing {
            zoneField.endEditing(true)
        }
        else {
            timesField.endEditing(true)
        }
    }
    
    let timesField : UITextField = {
        let tf = UITextField()
        tf.text = "Time"
        tf.allowsEditingTextAttributes = false
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.layer.borderColor = UIColor.black.cgColor
        tf.layer.borderWidth = 1
        return tf
    }()
    
    let timeAreaField : UITextField = {
       let tf = UITextField()
        tf.text = "Time area"
        tf.allowsEditingTextAttributes = false
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.layer.borderColor = UIColor.black.cgColor
        tf.layer.borderWidth = 1
        return tf
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        
        //date picker
        dateField.inputView = datePicker
        dateField.inputAccessoryView = tb
        
        //time numbers
        timeAreaField.inputAccessoryView = tb
        timeAreaField.inputView = timeAreaPicker

        //time name
        timesField.inputAccessoryView = tb
        timesField.inputView = timePicker
        
        //time zone
        zoneField.inputAccessoryView = tb
        zoneField.inputView = zonePicker
        
        zonePicker.delegate = self
        timePicker.delegate = self
        timeAreaPicker.delegate = self
        
        view.addSubview(titleField)
        view.addSubview(descriptionField)
        view.addSubview(dateField)
        view.addSubview(containerView)
        view.addSubview(submitButton)

        setupContainerView()
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
    func setupContainerView(){
        containerView.addSubview(timesField)
        containerView.addSubview(timeAreaField)
        containerView.addSubview(zoneField)

        containerView.topAnchor.constraint(equalTo: dateField.bottomAnchor, constant: 25).isActive = true
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        timesField.leftAnchor.constraint(equalTo:containerView.leftAnchor).isActive = true
        timesField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        timesField.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.33).isActive = true
        timesField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        timeAreaField.leftAnchor.constraint(equalTo:timesField.rightAnchor).isActive = true
        timeAreaField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        timeAreaField.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.34).isActive = true
        timeAreaField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        zoneField.leftAnchor.constraint(equalTo:timeAreaField.rightAnchor).isActive = true
        zoneField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        zoneField.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.33).isActive = true
        zoneField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    }
    
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
        
        dateField.topAnchor.constraint(equalTo: descriptionField.bottomAnchor, constant: 25).isActive = true
        dateField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        dateField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        dateField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        submitButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        submitButton.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        submitButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 25).isActive = true
    }
    
   
}
