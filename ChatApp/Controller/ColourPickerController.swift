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
        tf.text = NSLocalizedString("exampleMyMessage", comment: "My Message")
        return tf
    }()
    
    ///Text field to sample
    let theirBoxTF : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.allowsEditingTextAttributes = false
        tf.isUserInteractionEnabled = false

        tf.text = NSLocalizedString("exampleTheirMessage", comment: "Their Message")
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
    let colorDropdown = [NSLocalizedString("green", comment: "green colour"), NSLocalizedString("pink", comment: "Pink colour"), NSLocalizedString("purple", comment: "Purple colour")]
    
    ///The toolbar added to the pickerview.
    let tb : UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.purple
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: NSLocalizedString("done", comment: "Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }()
    ///The save button.
    let saveButton : UIButton = {
        let btn = UIButton()
        btn.setTitle(NSLocalizedString("saveTitle", comment: "save"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        btn.backgroundColor = UIColor.niceOtherOrange
        return btn
    }()
    
    // MARK: - Variables
    ///The current users settings.
    var settings : Settings? {
        didSet {
            if settings?.myColor! == "Green"{
                myColor.text = NSLocalizedString("green", comment: "Green Colour")
            }
            else if settings?.myColor! == "Pink"{
                myColor.text = NSLocalizedString("pink", comment: "Pink Colour")
            }
            else if settings?.myColor! == "Purple"{
                myColor.text = NSLocalizedString("purple", comment: "Purple Colour")
            }

            if settings?.theirColor! == "Green"{
                theirColor.text = NSLocalizedString("green", comment: "Green Colour")
            }
            else if settings?.theirColor! == "Pink"{
                theirColor.text = NSLocalizedString("pink", comment: "Pink Colour")
            }
            else if settings?.theirColor! == "Purple"{
                theirColor.text = NSLocalizedString("purple", comment: "Purple Colour")
            }
            
        }
    }
    
    ///SettingsView
    var settingsView = SettingsController()

    
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
        
        self.navigationItem.title = NSLocalizedString("updateColours", comment: "Update colours title")
        
        setupVariables()
        super.viewDidLoad()
    
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: NSLocalizedString("backText", comment: "Back"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
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
        let values = ["Greeting" : settings?.greeting!, "TheirColor" : settings?.theirColor!, "YourColor" : settings?.myColor!] as [String: AnyObject]
        if let id = Auth.auth().currentUser?.uid{
            print(values)
            let ref = Database.database().reference().child("user-settings").child(id)
            ref.updateChildValues(values)
            self.setColors()
            settingsView.currentUser.settings = self.settings
            self.showAlert(title: NSLocalizedString("validColoursTitle", comment: "Alert title"), message: NSLocalizedString("validColoursBody", comment: "Alert body"))
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
            myColorBox.backgroundColor = UIColor(r: 255, g: 105, b: 180)
            myBoxTF.textColor = UIColor.black
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
        case "Purple" :
            theirColorBox.backgroundColor = UIColor.purple
            theirBoxTF.textColor = UIColor.white
        case "Pink" :
            theirColorBox.backgroundColor = UIColor(r: 255, g: 105, b: 180)
            theirBoxTF.textColor = UIColor.black
        default:
            theirColorBox.backgroundColor = UIColor.orange
            theirBoxTF.textColor = UIColor.black
        }
        
    }
    func saveSettings(){
        if myColor.text! == NSLocalizedString("green", comment: "Green colour"){
            settings!.myColor = "Green"
        }
        else if myColor.text! == NSLocalizedString("purple", comment: "Green colour"){
            settings!.myColor = "Purple"
        }
        else if myColor.text! == NSLocalizedString("pink", comment: "Green colour"){
            settings!.myColor = "Pink"
        }
        if theirColor.text! == NSLocalizedString("green", comment: "Green colour"){
            settings!.theirColor = "Green"
        }
        else if theirColor.text! == NSLocalizedString("purple", comment: "Green colour"){
            settings!.theirColor = "Purple"
        }
        else if theirColor.text! == NSLocalizedString("pink", comment: "Green colour"){
            settings!.theirColor = "Pink"
        }
    }
    
    //MARK: - Alert
    
    //By creating the method in this way, I was able to reduce a lot of extra code by just calling this function when its just a simple alert.
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
            self.back(sender: self.navigationItem.leftBarButtonItem!)

        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    ///Back button for NavigationBarItem
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
