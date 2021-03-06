//
//  EventController.swift
//  ChatApp
//
//  Created by Danny on 20/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation

class EventController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    // MARK: - Constants
    
    ///Height for text fields.
    let fieldWidth = CGFloat(80)
    ///Height for images.
    let imageWidth = CGFloat(25)
    ///Default height for elements.
    let defaultHeight = CGFloat(30)
    ///Default height for labels.
    let labelHeight = CGFloat(40)
    ///Larger space for bigger elements.
    let spaces = CGFloat(25)
    ///Default spacing between elements.
    let spacing = CGFloat(10)
    ///Location manager to get permissions to access location.
    let locationManager = CLLocationManager()
    ///Coordinates for the destination of the event.
    let destinationCoordinates =  CLLocationCoordinate2D()
    
    ///Mapview to show route.
    let mapView : MKMapView = {
        let mv = MKMapView()
        mv.translatesAutoresizingMaskIntoConstraints = false
        return mv
    }()
    
    ///Description box.
    let descriptionBox: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.allowsEditingTextAttributes = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.font = UIFont(name: "arial", size: 10)
        
        view.textColor = UIColor.black
        return view
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
        label.text = NSLocalizedString("endDate", comment: "start date")
        label.isEditable = false
        label.textColor = UIColor.white
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor(r: 233, g: 175,b: 50)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    ///Date start text view.
    let dateFieldS : UITextView = {
        let field = UITextView()
        field.allowsEditingTextAttributes = false
        field.isEditable = false
        field.isUserInteractionEnabled = false
        field.layer.borderColor = UIColor.black.cgColor
        field.layer.borderWidth = 1
        field.backgroundColor = UIColor.white
        field.font = UIFont(name: "arial", size: 10)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    ///Date finish text view.
    let dateFieldF : UITextView = {
        let field = UITextView()
        field.allowsEditingTextAttributes = false
        field.isEditable = false
        field.isUserInteractionEnabled = false
        field.layer.borderColor = UIColor.black.cgColor
        field.backgroundColor = UIColor.white
        field.layer.borderWidth = 1
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = UIFont(name: "arial", size: 10)
        
        return field
    }()
    
    ///Event with container box.
    let eventWith: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    ///Estimate container box.
    let estimateBox: UIView =  {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    ///Walking icon.
    let walkingIcon : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "walk")
        return image
    }()
    
    ///The textfield for walking.
    let walkingField : UITextView = {
        let field = UITextView()
        field.allowsEditingTextAttributes = false
        field.isEditable = false
        field.isUserInteractionEnabled = false
        field.textAlignment = .center
        field.layer.borderColor = UIColor.black.cgColor
        field.backgroundColor = UIColor.white
        field.layer.borderWidth = 1
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = UIFont(name: "arial", size: 10)
        
        return field
    }()
    
    ///Driving icon.
    let drivingIcon : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "car")
        return image
    }()
    
    ///The textfield for driving.
    let drivingField : UITextView = {
        let field = UITextView()
        field.allowsEditingTextAttributes = false
        field.isEditable = false
        field.isUserInteractionEnabled = false
        field.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openMapForPlace)))
        field.layer.borderColor = UIColor.black.cgColor
        field.backgroundColor = UIColor.white
        field.layer.borderWidth = 1
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = UIFont(name: "arial", size: 10)
        
        field.textAlignment = .center
        return field
    }()
    
    ///The tapable area for opening maps.
    let drivingArea : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        //        view.backgroundColor = UIColor.purple
        return view
    }()
    
    ///The icon for transit.
    let transitIcon : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "transit")
        return image
    }()
    
    ///The textfield for transit.
    let transitField : UITextView = {
        let field = UITextView()
        field.allowsEditingTextAttributes = false
        field.isEditable = false
        field.isUserInteractionEnabled = false
        field.layer.borderColor = UIColor.black.cgColor
        field.backgroundColor = UIColor.white
        field.layer.borderWidth = 1
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = UIFont(name: "arial", size: 10)
        field.textAlignment = .center
        
        return field
    }()
    ///Profile image of who the event is with.
    let picview: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named:"defaultPic")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        return view
    }()
    ///The name of who the event is with.
    let nameLabel: UITextView = {
        let field = UITextView()
        field.allowsEditingTextAttributes = false
        field.isEditable = false
        field.isUserInteractionEnabled = false
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = UIFont(name: "arial", size: 15)
        field.backgroundColor = UIColor.clear
        field.textAlignment = .center
        return field
    }()
    
    // MARK: - Variables
    ///The event that this information is for.
    var event : Event? {
        didSet {
            self.navigationItem.title = event?.title
            descriptionBox.text = (event?.desc)!
            
            let startTimestampDate = Date(timeIntervalSince1970: event?.startTime as! TimeInterval)
            let finishTimestampDate = Date(timeIntervalSince1970: event?.finishTime as! TimeInterval)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy hh:mm a"
            dateFieldS.text = dateFormatter.string(from: startTimestampDate)
            dateFieldF.text = dateFormatter.string(from: finishTimestampDate)
            fetchUser()
            
        }
    }
    ///The user who the event is with.
    var user = User()

    //MARK: - View initialisation
    
    override func viewDidLoad() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openMapForPlace))
        
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 233, g: 175,b: 50)
        self.hidesBottomBarWhenPushed = true
        // Do any additional setup after loading the view.
        view.addSubview(descriptionBox)
        view.addSubview(labelStart)
        view.addSubview(dateFieldS)
        view.addSubview(labelFinish)
        view.addSubview(dateFieldF)
        eventWith.addSubview(picview)
        eventWith.addSubview(nameLabel)
        
        
        estimateBox.addSubview(walkingIcon)
        estimateBox.addSubview(walkingField)
        estimateBox.addSubview(drivingIcon)
        estimateBox.addSubview(drivingField)
        estimateBox.addSubview(transitIcon)
        estimateBox.addSubview(transitField)
        estimateBox.addSubview(drivingArea)
        view.addSubview(mapView)
        
        drivingArea.addGestureRecognizer(tap)
        
        
        mapView.delegate = self
        mapView.showsPointsOfInterest = true
        mapView.showsScale = true
        mapView.showsUserLocation = true
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        let sourceCoordinates = locationManager.location?.coordinate
        let destinationCoordinates = CLLocationCoordinate2DMake((event?.location[0]!.doubleValue)!, (event?.location[1]!.doubleValue)!)
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates!)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destinationItem
        
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print(error)
                }
                return
            }
            let route = response.routes[0]
            self.mapView.add(route.polyline, level: .aboveRoads)
            let rekt = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rekt), animated: true)
        }
        fillInEstimates(request: directionRequest)

        view.addSubview(estimateBox)

        setupEstimateBox()
        setupContainer()
        view.addSubview(eventWith)
        setupFields()
    }
    
    
    //MARK: - Setup
    
    ///Sets up the container constraints.
    func setupContainer(){
        picview.heightAnchor.constraint(equalToConstant: 50).isActive = true
        picview.widthAnchor.constraint(equalToConstant: 50).isActive = true
        picview.centerXAnchor.constraint(equalTo: eventWith.centerXAnchor).isActive = true
        picview.topAnchor.constraint(equalTo: eventWith.topAnchor).isActive = true
        
        nameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: eventWith.widthAnchor, constant: -30).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: eventWith.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: picview.bottomAnchor).isActive = true
        
    }
    
    ///Sets up view constraints.
    func setupEstimateBox(){
        walkingIcon.topAnchor.constraint(equalTo: estimateBox.topAnchor).isActive = true
        walkingIcon.centerXAnchor.constraint(equalTo: walkingField.centerXAnchor).isActive = true
        walkingIcon.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
        walkingIcon.heightAnchor.constraint(equalToConstant: imageWidth).isActive = true
        
        walkingField.topAnchor.constraint(equalTo: walkingIcon.bottomAnchor, constant: 5).isActive = true
        walkingField.leftAnchor.constraint(equalTo: estimateBox.leftAnchor).isActive = true
        walkingField.widthAnchor.constraint(equalToConstant: fieldWidth).isActive = true
        walkingField.bottomAnchor.constraint(equalTo: estimateBox.bottomAnchor).isActive = true
        
        drivingField.topAnchor.constraint(equalTo: drivingIcon.bottomAnchor, constant: 5).isActive = true
        drivingField.leftAnchor.constraint(equalTo: walkingField.rightAnchor, constant: spaces).isActive = true
        drivingField.widthAnchor.constraint(equalToConstant: fieldWidth).isActive = true
        drivingField.bottomAnchor.constraint(equalTo: estimateBox.bottomAnchor).isActive = true
        
        drivingIcon.topAnchor.constraint(equalTo: estimateBox.topAnchor).isActive = true
        drivingIcon.centerXAnchor.constraint(equalTo: drivingField.centerXAnchor).isActive = true
        drivingIcon.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
        drivingIcon.heightAnchor.constraint(equalToConstant: imageWidth).isActive = true
        
        drivingArea.topAnchor.constraint(equalTo: estimateBox.topAnchor).isActive = true
        drivingArea.centerXAnchor.constraint(equalTo: drivingField.centerXAnchor).isActive = true
        drivingArea.widthAnchor.constraint(equalTo: drivingField.widthAnchor).isActive = true
        drivingArea.heightAnchor.constraint(equalTo: estimateBox.heightAnchor).isActive = true
        
        transitIcon.centerXAnchor.constraint(equalTo: transitField.centerXAnchor).isActive = true
        transitIcon.topAnchor.constraint(equalTo: estimateBox.topAnchor).isActive = true
        transitIcon.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
        transitIcon.heightAnchor.constraint(equalToConstant: imageWidth).isActive = true
        
        transitField.topAnchor.constraint(equalTo: walkingIcon.bottomAnchor, constant: 5).isActive = true
        transitField.leftAnchor.constraint(equalTo: drivingField.rightAnchor, constant: spaces).isActive = true
        transitField.widthAnchor.constraint(equalToConstant: fieldWidth).isActive = true
        transitField.bottomAnchor.constraint(equalTo: estimateBox.bottomAnchor).isActive = true
    }
    
    ///Sets up the view constraints
    func setupFields(){
        descriptionBox.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive = true
        descriptionBox.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descriptionBox.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        descriptionBox.heightAnchor.constraint(equalToConstant: defaultHeight*1.5).isActive = true
        
        labelStart.topAnchor.constraint(equalTo: descriptionBox.bottomAnchor).isActive = true
        labelStart.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        labelStart.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        labelStart.heightAnchor.constraint(equalToConstant: labelHeight).isActive = true
        
        dateFieldS.topAnchor.constraint(equalTo: labelStart.bottomAnchor).isActive = true
        dateFieldS.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateFieldS.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        dateFieldS.heightAnchor.constraint(equalToConstant: defaultHeight).isActive = true
        
        labelFinish.topAnchor.constraint(equalTo: dateFieldS.bottomAnchor).isActive = true
        labelFinish.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        labelFinish.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        labelFinish.heightAnchor.constraint(equalToConstant: labelHeight).isActive = true
        
        dateFieldF.topAnchor.constraint(equalTo: labelFinish.bottomAnchor).isActive = true
        dateFieldF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateFieldF.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        dateFieldF.heightAnchor.constraint(equalToConstant: defaultHeight).isActive = true
        
        mapView.topAnchor.constraint(equalTo: dateFieldF.bottomAnchor,constant: spacing).isActive = true
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalToConstant: 135).isActive = true
        
        estimateBox.heightAnchor.constraint(equalToConstant: 60).isActive = true
        estimateBox.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        estimateBox.centerXAnchor.constraint(equalTo: eventWith.centerXAnchor).isActive = true
        estimateBox.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: spacing).isActive = true
        
        eventWith.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        eventWith.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        eventWith.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        eventWith.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
    }
    
    //MARK: - Firebase
    
    ///Fetches the user the event is planned with.
    func fetchUser(){
        Database.database().reference().child("users").child((event?.eventWithId())!).observe(.value, with: { (DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                user.id = DataSnapshot.key
                self.user = user
                self.nameLabel.text = user.name!
                self.picview.loadImageUsingCache(urlString: user.profileImageUrl)
            }
        }, withCancel: nil)
        
        
    }
    
    //MARK: - Location
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.purple
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    ///Called when the driving icon is pressed.
    @objc func openMapForPlace() {
        
        let coordinate = CLLocationCoordinate2DMake((event?.location[0]?.doubleValue)!,(event?.location[1]?.doubleValue)!)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = event?.location[2]! as String?
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    /**
     Estimates the time for the each method of transport, and then sets the time in the relevant textField.
     - Parameters:
     - request: The MKDirectionsRequest which is to be used to get the route.
     */
    
    func fillInEstimates(request: MKDirectionsRequest) {
        request.transportType = .walking
        
        let directionsWalk = MKDirections(request: request)
        directionsWalk.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print(error)
                }
                return
            }
            let route = response.routes[0]
            self.walkingField.text = self.stringFromTimeInterval(interval: route.expectedTravelTime)
        }
        
        request.transportType = .automobile
        
        let directionsDrive = MKDirections(request: request)
        directionsDrive.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            let route = response.routes[0]
            self.drivingField.text = self.stringFromTimeInterval(interval: route.expectedTravelTime)
        }
        
        let directionsTransit = MKDirections(request: request)
        directionsTransit.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print(error)
                }
                return
            }
            let route = response.routes[0]
            self.transitField.text = self.stringFromTimeInterval(interval: route.expectedTravelTime)
        }
        
    }
    
   
    //MARK: - Time interval
    
    /**
     Converts a time interval into a string.
     - Parameter:
         - interval: TimeInterval to convert.
     - Return: Returns the formate
     */
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        
        let ti = NSInteger(interval)
        
        
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        if String(describing: hours) == "0"
        {
            return String(format: "%0.2d mins",minutes)
        }
        return String(format: "%0.2d h %0.2d mins",hours,minutes)
    }
    
}
