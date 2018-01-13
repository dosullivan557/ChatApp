//
//  CalendarContainer.swift
//  ChatApp
//
//  Created by Danny on 13/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit

class CalendarController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    var user: User?
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
        return dp
    }()
    
    let dateField : UITextField = {
        let field = UITextField()
        field.placeholder = "Please select a date..."
        field.layer.borderColor = UIColor.black.cgColor
        field.layer.borderWidth = 1
        field.translatesAutoresizingMaskIntoConstraints = false

        return field
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        dateField.inputView = datePicker
        view.addSubview(titleField)
        view.addSubview(descriptionField)
        view.addSubview(dateField)
        setupFields()
    }
    

    
    func setupFields(){
        titleField.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
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
    }
    
}
