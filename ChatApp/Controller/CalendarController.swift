//
//  CalendarContainer.swift
//  ChatApp
//
//  Created by Danny on 13/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

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
    var sDate : Date?
    var fDate : Date?
    
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
        label.textColor = UIColor.white
        label.backgroundColor = UIColor(r: 233, g: 175,b: 50)
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    let labelFinish :UITextView = {
        let label = UITextView()
        label.text = "End Date"
        label.isEditable = false
        label.textColor = UIColor.white
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor(r: 233, g: 175,b: 50)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    @objc func selectedDate(){
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = DateFormatter.Style.short
        timeFormatter.dateStyle = DateFormatter.Style.long
        let strDate = timeFormatter.string(from: datePicker.date)
        // do what you want to do with the string.
        if dateFieldS.isEditing {
            dateFieldS.text = strDate
            sDate = datePicker.date
        }
        if dateFieldF.isEditing {
            dateFieldF.text = strDate
            fDate = datePicker.date

        }
    }
    
    
    let dateFieldS : UITextField = {
        let field = UITextField()
        field.allowsEditingTextAttributes = false
        field.placeholder = "Please select a date..."
        field.layer.borderColor = UIColor.black.cgColor
        field.layer.borderWidth = 1
        field.backgroundColor = UIColor.white
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let dateFieldF : UITextField = {
        let field = UITextField()
        field.allowsEditingTextAttributes = false
        field.placeholder = "Please select a date..."
        field.layer.borderColor = UIColor.black.cgColor
        field.backgroundColor = UIColor.white
        field.layer.borderWidth = 1
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    
    let submitButton : UIButton = {
        let button = UIButton()
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.purple
        button.setTitleColor(UIColor.white, for: .normal)
        
        return button
    }()
    
    func validate() -> Bool {
        if (titleField.text?.count)! < 5 {
            showAlert(title: "Invalid Title", message: "Please enter a valid title. (Minimum of 5 characters).")
            return false
        }
        if ((descriptionField.text?.count)! < 5) {
            showAlert(title: "Invalid description", message: "Please enter a valid description. (Minimum of 5 characters).")
            return false
        }
        if (dateFieldS.text?.isEmpty)! {
            showAlert(title: "Invalid Start Date.", message: "Please enter a valid Start Date.")
            return false
        }
        if (dateFieldF.text?.isEmpty)! {
            showAlert(title: "Invalid End Date.", message: "Please enter a valid End Date.")
            return false
        }
        if((sDate?.timeIntervalSince1970 as! NSNumber).int32Value > (fDate?.timeIntervalSince1970 as! NSNumber).int32Value){
            showAlert(title: "Invalid Dates.", message: "Your Start date is after your end date. Please enter valid dates and try again.")
            return false

        }
        
        return true
    }
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleSubmit(){
        if !validate() {
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let event = Event()
        event.title = titleField.text
        event.desc = descriptionField.text
        event.startTime = sDate?.timeIntervalSince1970 as NSNumber?
        event.finishTime = fDate?.timeIntervalSince1970 as NSNumber?
        event.host = uid
        event.invitee = user?.id
        event.id = NSUUID().uuidString
        let myRef = Database.database().reference().child("events").child(event.id!)

        let values = ["Id" : event.id, "Title": event.title!, "Description": event.desc!, "StartTime": event.startTime!, "FinishTime": event.finishTime!, "Host": event.host!, "Invitee": event.invitee!, "Accepted" : ""] as [String : Any]
        
        myRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                self.showAlert(title: "Error", message: "There has been an error, We have informed the developer to have a look at this.")
                self.postError(error: error!)
                return
            }
            showAlert(title: "Event has been submitted", message: "This event has been sent to \(self.user?.name) to confirm.")
            
            let userEventRef = Database.database().reference().child("user-events").child(uid).child((self.user?.id)!)
            
            let messageId = myRef.key
            userEventRef.updateChildValues([messageId: 1])
            
            let recipientUserEventRef = Database.database().reference().child("user-events").child((self.user?.id)!).child(uid)
            recipientUserEventRef.updateChildValues([messageId: 1])
            
            
        }
        
        func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (x) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    func postError(error: Error){
        let ref = Database.database().reference().child("Error").child(NSUUID().uuidString)
        let values = ["Error Description": error.localizedDescription]
        ref.updateChildValues(values as [String: AnyObject])
    }
    
    func dateToSecs() -> Int {
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

        if dateFieldS.isEditing {
            dateFieldS.endEditing(true)
        }
        else if dateFieldF.isEditing {
            dateFieldF.endEditing(true)
        }
    }
    
    
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(r: 233, g: 175,b: 50)
//        navigationController?.navigationBar.barTintColor = UIColor(r: 233, g: 175,b: 50)

        //date picker
        dateFieldS.inputView = datePicker
        dateFieldS.inputAccessoryView = tb
        dateFieldF.inputView = datePicker
        dateFieldF.inputAccessoryView = tb
    
        
        view.addSubview(titleField)
        view.addSubview(descriptionField)
        view.addSubview(labelStart)
        view.addSubview(dateFieldS)
        view.addSubview(dateFieldF)
        view.addSubview(labelFinish)
        view.addSubview(submitButton)
        setupFields()
    }
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    
    }()

    
    func setupFields(){
        //main title
        
        titleField.topAnchor.constraint(equalTo: view.topAnchor, constant: 90).isActive = true
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
        labelStart.heightAnchor.constraint(equalToConstant: 40).isActive = true

        dateFieldS.topAnchor.constraint(equalTo: labelStart.bottomAnchor).isActive = true
        dateFieldS.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateFieldS.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        dateFieldS.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        dateFieldS.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        labelFinish.topAnchor.constraint(equalTo: dateFieldS.bottomAnchor, constant: 25).isActive = true
        labelFinish.centerXAnchor.constraint(equalTo:view.centerXAnchor).isActive = true
        labelFinish.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
        labelFinish.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        dateFieldF.topAnchor.constraint(equalTo: labelFinish.bottomAnchor).isActive = true
        dateFieldF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateFieldF.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        dateFieldF.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        dateFieldF.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        submitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        submitButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
        submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25).isActive = true
    }
}
