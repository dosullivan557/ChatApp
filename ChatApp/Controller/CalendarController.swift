//
//  CalendarContainer.swift
//  ChatApp
//
//  Created by Danny on 13/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
import MapKit

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

class CalendarController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    // MARK: - Constants
    
    ///The mapview to search.
    let mapView = MKMapView()
    
    ///Used aas a height for other elements.
    let defaultHeight = CGFloat(30)
    ///Used as a height for all labels.
    let labelHeight = CGFloat(40)
    ///Used as a standard space between elements.
    let spacing = CGFloat(10)
    ///Text field for the user to give a title to the event.
    let titleField : UITextField = {
        let title = UITextField()
        title.placeholder = NSLocalizedString("enterTitle", comment: "Title")
        title.translatesAutoresizingMaskIntoConstraints = false
        title.backgroundColor = UIColor.white
        title.layer.borderColor = UIColor.black.cgColor
        title.layer.borderWidth = 1
        return title
    }()
    ///Text field for the user to give a description for the event.
    let descriptionField : UITextField = {
        let title = UITextField()
        title.placeholder = NSLocalizedString("enterDescription", comment: "Description")
        title.translatesAutoresizingMaskIntoConstraints = false
        title.backgroundColor = UIColor.white
        title.layer.borderColor = UIColor.black.cgColor
        title.layer.borderWidth = 1
        return title
    }()
    ///The datepicker.
    let datePicker : UIDatePicker = {
        let dp = UIDatePicker()
        dp.translatesAutoresizingMaskIntoConstraints = false
        dp.layer.borderColor = UIColor.black.cgColor
        dp.layer.borderWidth = 1
        dp.minuteInterval = 5
        dp.addTarget(self, action: #selector(selectedDate), for: .valueChanged)
        return dp
    }()
    ///Start label.
    let labelStart :UITextView = {
        let label = UITextView()
        label.text = NSLocalizedString("startDate", comment: "start date")
        label.isEditable = false
        label.textColor = UIColor.white
        label.backgroundColor = UIColor(r: 233, g: 175,b: 50)
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    ///Finish label.
    let labelFinish :UITextView = {
        let label = UITextView()
        label.text = NSLocalizedString("endDate", comment: "End date")
        label.isEditable = false
        label.textColor = UIColor.white
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor(r: 233, g: 175,b: 50)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    ///Toolbar for the datepickers.
    let tb : UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.purple
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title:  NSLocalizedString("done", comment: "done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }()
    
    ///Date field for the user to select a start date and time.
    let dateFieldS : UITextField = {
        let field = UITextField()
        field.allowsEditingTextAttributes = false
        field.placeholder = NSLocalizedString("startDatePlaceholder", comment: "Start date placeholder")
        field.layer.borderColor = UIColor.black.cgColor
        field.layer.borderWidth = 1
        field.backgroundColor = UIColor.white
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    ///Date field for the user to select a finish date and time.
    let dateFieldF : UITextField = {
        let field = UITextField()
        field.allowsEditingTextAttributes = false
        field.placeholder = NSLocalizedString("endDatePlaceholder", comment: "End date placeholder")
        field.layer.borderColor = UIColor.black.cgColor
        field.backgroundColor = UIColor.white
        field.layer.borderWidth = 1
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    ///The submit event button.
    let submitButton : UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("submit", comment: "Submit"), for: .normal)
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.purple
        button.setTitleColor(UIColor.white, for: .normal)
        
        return button
    }()
    
    ///Textfield for the user to type in a location.
    let locationField : UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = NSLocalizedString("locationPlaceholder", comment: "Location")
        field.layer.borderColor = UIColor.black.cgColor
        field.backgroundColor = UIColor.white
        field.layer.borderWidth = 1
        return field
    }()
    
    
    ///The activity indicator.
    let activityInd = ActivityController()
    
    
    // MARK: - Variables
    ///The user that the event is with.
    var user: User? {
        didSet{
            
            navigationItem.title = NSLocalizedString("eventWith", comment: "Event with") + " " + ((user?.name)!.components(separatedBy: " "))[0]
        }
    }
    
    ///The date that the event is to start.
    var sDate : Date?
    ///The date that the event is to finish.
    var fDate : Date?
    ///The closest location with the given name.
    var closest = MKMapItem()
    
    // MARK: - View initialisation
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(r: 233, g: 175,b: 50)
        //        navigationController?.navigationBar.barTintColor = UIColor(r: 233, g: 175,b: 50)
        mapView.delegate = self
        mapView.showsUserLocation = true
        //date picker
        dateFieldS.inputView = datePicker
        dateFieldS.inputAccessoryView = tb
        dateFieldF.inputView = datePicker
        dateFieldF.inputAccessoryView = tb
        view.addSubview(titleField)
        view.addSubview(descriptionField)
        view.addSubview(dateFieldS)
        view.addSubview(dateFieldF)
        view.addSubview(submitButton)
        view.addSubview(locationField)
        addToolBar(textField: titleField)
        addToolBar(textField: descriptionField)
        addToolBar(textField: locationField)
        
        setupFields()
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: NSLocalizedString("backText", comment: "Back"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    //MARK: - Setup
    
    ///Sets up the view constraints.
    func setupFields(){
        //main title
        
        titleField.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive = true
        titleField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        titleField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        titleField.heightAnchor.constraint(equalToConstant: defaultHeight).isActive = true
        
        descriptionField.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: spacing).isActive = true
        descriptionField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descriptionField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        descriptionField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        descriptionField.heightAnchor.constraint(equalToConstant: defaultHeight).isActive = true
        
        dateFieldS.topAnchor.constraint(equalTo: descriptionField.bottomAnchor, constant: spacing).isActive = true
        dateFieldS.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateFieldS.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        dateFieldS.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        dateFieldS.heightAnchor.constraint(equalToConstant: defaultHeight).isActive = true
        
        dateFieldF.topAnchor.constraint(equalTo: dateFieldS.bottomAnchor, constant: spacing).isActive = true
        dateFieldF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateFieldF.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        dateFieldF.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        dateFieldF.heightAnchor.constraint(equalToConstant: defaultHeight).isActive = true
        
        locationField.topAnchor.constraint(equalTo: dateFieldF.bottomAnchor, constant: spacing).isActive = true
        locationField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        locationField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        locationField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        locationField.heightAnchor.constraint(equalToConstant: defaultHeight).isActive = true
        
        submitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        submitButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
        submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25).isActive = true
    }
    
    //MARK: - Datepicker
    
    ///Gets date from datepicker and sets the date to the relevant text field.
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    
    ///Converts the time from a datepicker to seconds.
    func dateToSecs() -> Int {
        return Int(datePicker.date.timeIntervalSince1970)
    }
    
    
    /**
     When the done button in the toolbar is pressed, it checks which datefield is being edited, and then forces the finish of that, which will hide the picker.
     */
    @objc func donePicker(){
        
        if dateFieldS.isEditing {
            dateFieldS.endEditing(true)
        }
        else if dateFieldF.isEditing {
            dateFieldF.endEditing(true)
        }
    }
    
    
    //MARK: - Validation
    
    
    /**
     Validates the information provided in the fields.
     - Returns: The boolean value to symbolise whether the values are valid or not.
     */
    func validate() -> Bool {
        if (titleField.text?.count)! < 3 {
            showAlert(title: NSLocalizedString("invalidTitleTitle", comment: "Title"), message: NSLocalizedString("invalidTitleBody", comment: "body"))
            return false
        }
        //        if ((descriptionField.text?.count)! < 5) {
        //            showAlert(title: "Invalid description", message: "Please enter a valid description. (Minimum of 5 characters).")
        //            return false
        //        }
        if (dateFieldS.text?.isEmpty)! {
            showAlert(title: NSLocalizedString("invalidSDTitle", comment: "Title"), message: NSLocalizedString("invalidSDBody", comment: "Body"))
            return false
        }
        if (dateFieldF.text?.isEmpty)! {
            showAlert(title: NSLocalizedString("invalidEDTitle", comment: "Title"), message: NSLocalizedString("invalidEDBody", comment: "Body"))
            return false
        }
        if((sDate?.timeIntervalSince1970 as NSNumber?)?.int32Value > (fDate?.timeIntervalSince1970 as NSNumber?)?.int32Value){
            showAlert(title: NSLocalizedString("invalidDatesTitle", comment: "Title"), message: NSLocalizedString("invalidDatesBody", comment: "Body"))
            return false
            
        }
        
        return true
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
            if title == NSLocalizedString("eventSubmitted", comment: "submitted")
            {
                self.navigationController?.popViewController(animated: true)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Interaction
    
    ///Called when the submit button is pressed. Adds all the information into an object, and uploads it to the database.
    @objc func handleSubmit(){
        startActivityIndicator()
        if !validate() {
            removeActivityIndicator()
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            removeActivityIndicator()
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
        
        findLocation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            var array = [NSString]()
            array.append(self.closest.placemark.coordinate.latitude.description as NSString)
            array.append(self.closest.placemark.coordinate.longitude.description as NSString)
            array.append(self.closest.placemark.title! as NSString)
            
            event.location = array
            
            let myRef = Database.database().reference().child("events").child(event.id!)
            let values = ["Id" : event.id!, "Title": event.title!, "Description": event.desc!, "StartTime": event.startTime!, "FinishTime": event.finishTime!, "Host": event.host!, "Invitee": event.invitee!, "Accepted" : "", "Location": event.location] as [String : Any]
            
            myRef.updateChildValues(values) { (error, ref) in
                if error != nil {
                    self.showAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("techIssues", comment: "Error body"))
                    self.postError(error: error!)
                    self.removeActivityIndicator()
                    
                    return
                }
                self.showAlert(title: NSLocalizedString("eventSubmitted", comment: "Title"), message: (NSLocalizedString("eventSubmittedBody", comment: "body 1") + (self.user?.name!)!) + NSLocalizedString("toConfirm", comment: "body 2"))
                
                let userEventRef = Database.database().reference().child("user-events").child(uid).child((self.user?.id)!)
                
                let messageId = myRef.key
                userEventRef.updateChildValues([messageId: 1])
                
                let recipientUserEventRef = Database.database().reference().child("user-events").child((self.user?.id)!).child(uid)
                recipientUserEventRef.updateChildValues([messageId: 1])
                self.removeActivityIndicator()
            }
        }
    }
    
    
    
    //MARK: - Location
    
    /**
     This method checks for permissions, and if it doesn't have them, it will not do anything, otherwise, it will get the current users location, and search for a place with the name which is given which is close to the location. If it cannot find any, it will search over a larger area, and then gets the location. Once it finds locations, it will sort through them and find the closest one, and then it sets the variable closest to it.
     */
    func findLocation() {
        let locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        else {
            print("permissions are needed")
            return
        }
        
        
        let currentLocation = locationManager.location
        
        
        let searchBarText = locationField.text
        let request = MKLocalSearchRequest()
        request.region = mapView.region
        request.naturalLanguageQuery = searchBarText
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            guard let response = response else {
                print("ERROR!")
                return
            }
            let currentCoordinates = currentLocation?.coordinate
            self.closest = response.mapItems[0]
            //print("Start value :\(self.closest)")
            print(response.mapItems.count)
            if response.mapItems.count > 1 {
                for i in 1...(response.mapItems.count - 1){
                    print("Checking another")
                    let destLong = Double(response.mapItems[i].placemark.coordinate.longitude)
                    let destLat = Double(response.mapItems[i].placemark.coordinate.latitude)
                    let currentLong = Double((currentCoordinates?.longitude)!)
                    let currentLat = Double((currentCoordinates?.latitude)!)
                    let currentClosestLong = Double(self.closest.placemark.coordinate.longitude)
                    let currentClosestLat = Double(self.closest.placemark.coordinate.latitude)
                    
                    if (destLong.distance(to: currentLong) + destLat.distance(to: currentLat)) < ((currentClosestLat.distance(to: currentLat) + currentClosestLong.distance(to: currentLong))){
                        print("Found closer: \(self.closest.placemark.coordinate)")
                        
                        self.closest = response.mapItems[i]
                    }
                }
                print("Finished searching. Closeset is: \(self.closest)")
                
            }
            else {
                let newRequest = MKLocalSearchRequest()
                newRequest.naturalLanguageQuery = searchBarText
                
                let newSearch = MKLocalSearch(request: newRequest)
                
                newSearch.start { response, error in
                    guard let response = response else {
                        print("ERROR!")
                        return
                    }
                    let currentCoordinates = currentLocation?.coordinate
                    self.closest = response.mapItems[0]
                    //            print("Start value :\(self.closest)")
                    for i in 1...(response.mapItems.count - 1){
                        print("Checking another")
                        let destLong = Double(response.mapItems[i].placemark.coordinate.longitude)
                        let destLat = Double(response.mapItems[i].placemark.coordinate.latitude)
                        let currentLong = Double((currentCoordinates?.longitude)!)
                        let currentLat = Double((currentCoordinates?.latitude)!)
                        let currentClosestLong = Double(self.closest.placemark.coordinate.longitude)
                        let currentClosestLat = Double(self.closest.placemark.coordinate.latitude)
                        
                        if (destLong.distance(to: currentLong) + destLat.distance(to: currentLat)) < ((currentClosestLat.distance(to: currentLat) + currentClosestLong.distance(to: currentLong))){
                            self.closest = response.mapItems[i]
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Activity Indicator
    
    
    ///Start the activity indicator.
    func startActivityIndicator() {
        activityInd.showActivityIndicatory(uiView: view)
    }
    ///Stops the animation and removes it from the view.
    func removeActivityIndicator() {
        activityInd.finishAnimating(uiView: view)
    }
    
    
    ///Back button for NavigationBarItem
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
