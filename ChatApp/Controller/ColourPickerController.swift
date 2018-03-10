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
    ///View to preview the colour to be used for the current users messages
    let myColorBox : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    ///View to preview the colour to be used for the other users messages
    let theirColorBox : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    let myBoxTF : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.allowsEditingTextAttributes = false
        tf.isUserInteractionEnabled = false
        tf.text = "Your message"
        return tf
    }()
    
    ///Text field to sample
    let theirBoxTF : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.allowsEditingTextAttributes = false
        tf.isUserInteractionEnabled = false

        tf.text = "Their message"
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
    
    var settingsView = SettingsView()

    
    //MARK: - View initialisation
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.niceOrange
        view.addSubview(myColor)
        view.addSubview(theirColor)
        view.addSubview(saveButton)
        myColorBox.addSubview(myBoxTF)
        theirColorBox.addSubview(theirBoxTF)
        view.addSubview(myColorBox)
        view.addSubview(theirColorBox)
        setupSampleConstraints()
        setupFields()
        setColors()
        myColor.inputAccessoryView = tb
        theirColor.inputAccessoryView = tb
        
        self.navigationItem.title = "Update Colour's"
        
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
        
        myColorBox.topAnchor.constraint(equalTo: theirColor.bottomAnchor, constant: 30).isActive = true
        myColorBox.widthAnchor.constraint(equalToConstant: 135).isActive = true
        myColorBox.heightAnchor.constraint(equalToConstant: 50).isActive = true
        myColorBox.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        
        theirColorBox.topAnchor.constraint(equalTo: theirColor.bottomAnchor, constant: 30).isActive = true
        theirColorBox.widthAnchor.constraint(equalToConstant: 135).isActive = true
        theirColorBox.heightAnchor.constraint(equalToConstant: 50).isActive = true
        theirColorBox.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        
        saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
      
    }
    
    func setupSampleConstraints() {
        myBoxTF.topAnchor.constraint(equalTo: myColorBox.topAnchor, constant: -2).isActive = true
        myBoxTF.leftAnchor.constraint(equalTo: myColorBox.leftAnchor, constant: 2).isActive = true
        myBoxTF.bottomAnchor.constraint(equalTo: myColorBox.bottomAnchor, constant: -2).isActive = true
        myBoxTF.rightAnchor.constraint(equalTo: myColorBox.rightAnchor, constant: -2).isActive = true
        
        theirBoxTF.topAnchor.constraint(equalTo: theirColorBox.topAnchor, constant: -2).isActive = true
        theirBoxTF.leftAnchor.constraint(equalTo: theirColorBox.leftAnchor, constant: 2).isActive = true
        theirBoxTF.bottomAnchor.constraint(equalTo: theirColorBox.bottomAnchor, constant: -2).isActive = true
        theirBoxTF.rightAnchor.constraint(equalTo: theirColorBox.rightAnchor, constant: -2).isActive = true
    }
    

    
    
    //MARK: - Pickerview
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /**
     When the done button in the toolbar is pressed, it checks which datefield is being edited, and then forces the finish of that, which will hide the picker.
     */
    @objc func donePicker(){
        setColors()
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
        saveSettings()
        let values = ["Greeting" : settings?.greeting!, "TheirColor" : theirColor.text!, "YourColor" : myColor.text!]
        if let id = Auth.auth().currentUser?.uid{
            print(values)
            let ref = Database.database().reference().child("user-settings").child(id)
            ref.updateChildValues(values)
            self.setColors()
            settingsView.currentUser.settings = self.settings
        }
        
    }

    //MARK: - Settings
    
    ///Decides which colours are downloaded, and using them, it sets the colours as UIColours to global variables, and using them, it can set colours to the bubble chat's colours.
    func setColors(){
        saveSettings()
        switch settings!.myColor! {
        case "Green":
            myColorBox.backgroundColor = UIColor.green
            myBoxTF.textColor = UIColor.black

        case "Pink" :
            myColorBox.backgroundColor = UIColor.blue
            myBoxTF.textColor = UIColor.white
        case "Purple" :
            myColorBox.backgroundColor = UIColor.purple
            myBoxTF.textColor = UIColor.white
        default:
            myColorBox.backgroundColor = UIColor.orange
            myBoxTF.textColor = UIColor.black
        }
        
        switch settings!.theirColor! {
        case "Green":
            theirColorBox.backgroundColor = UIColor.green
            theirBoxTF.textColor = UIColor.black
        case "Pink" :
            theirColorBox.backgroundColor = UIColor.blue
            theirBoxTF.textColor = UIColor.white
        case "Purple" :
            theirColorBox.backgroundColor = UIColor.purple
            theirBoxTF.textColor = UIColor.white
        default:
            theirColorBox.backgroundColor = UIColor.orange
            theirBoxTF.textColor = UIColor.black
        }
        
    }
    func saveSettings(){
        settings!.myColor = myColor.text!
        settings!.theirColor = theirColor.text!
    }
    
    
}
