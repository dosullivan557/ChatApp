//
//  ColourPickerController.swift
//  ChatApp
//
//  Created by Danny on 20/02/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase

class ColourPickerController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    // MARK: - Constants
    
    ///The textfield used for the current users colour.
    let myColor : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white
        return tf
    }()
    
    ///The textfield used for the other users colour.
    let theirColor : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white
        return tf
    }()
    ///The array used to populate the picker view.
    let colorDropdown = ["Green", "Pink", "Purple"]
    ///The toolbar added to the pickerview.
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
    ///The save button.
    let saveButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("Save", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        btn.backgroundColor = UIColor.niceBlue
        return btn
    }()
    
    // MARK: - Variables
    ///The current users settings.
    var settings : Settings? {
        didSet {
            myColor.text = settings?.myColor!
            theirColor.text = settings?.theirColor!
        }
    }
    
    //MARK: - View initialisation
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.niceOrange
        view.addSubview(myColor)
        view.addSubview(theirColor)
        view.addSubview(saveButton)
        setupFields()
        myColor.inputAccessoryView = tb
        theirColor.inputAccessoryView = tb
        
        setupVariables()
        super.viewDidLoad()
    }
    
    //MARK: - Setup
    
    ///Sets up pickers.
    func setupVariables(){
        let pickerView = UIPickerView()
        pickerView.delegate = self
        myColor.inputView = pickerView
        myColor.allowsEditingTextAttributes = false
        theirColor.inputView = pickerView
        theirColor.allowsEditingTextAttributes = false
    }
    
    ///Sets up fields.
    func setupFields() {
        myColor.topAnchor.constraint(equalTo: view.topAnchor, constant: 90).isActive = true
        myColor.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        myColor.heightAnchor.constraint(equalToConstant: 50).isActive = true
        myColor.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        theirColor.topAnchor.constraint(equalTo: myColor.bottomAnchor, constant: 30).isActive = true
        theirColor.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        theirColor.heightAnchor.constraint(equalToConstant: 50).isActive = true
        theirColor.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        saveButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
    
    

    
    
    //MARK: - Pickerview
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /**
     When the done button in the toolbar is pressed, it checks which datefield is being edited, and then forces the finish of that, which will hide the picker.
     */
    @objc func donePicker(){
        
        if myColor.isEditing {
            myColor.endEditing(true)
        }
        else if theirColor.isEditing {
            theirColor.endEditing(true)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colorDropdown.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return colorDropdown[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if myColor.isEditing {
            myColor.text = colorDropdown[row]
        }
        else if theirColor.isEditing {
            theirColor.text = colorDropdown[row]
        }
    }
    
   
    //MARK: - Firebase
    ///Called when the save button is pressed.
    @objc func handleSave() {
        let values = ["Greeting" : settings?.greeting!, "TheirColor" : theirColor.text!, "YourColor" : myColor.text!]
        if let id = Auth.auth().currentUser?.uid{
            print(values)
            let ref = Database.database().reference().child("user-settings").child(id)
            ref.updateChildValues(values)
        }
    }
    
}
