//
//  MyTabBar.swift
//  ChatApp
//
//  Created by Danny on 09/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//
import UIKit
import Firebase

/// My TabBar for MessagesController
class MyTabBar: UITabBarController {
    ///List of elements in the tab list.
    var tabList = [UIViewController]()
    
    ///Checks if user is logged in, then passes the current user to here, so that I can pass it to all of the tabs.
    var currentUser = User() {
        didSet {
            self.passUsersThrough(user: self.currentUser)
        }
    }
    ///An instance of MessagesController.
    let messagesController = MessagesController()
    
    //An instance of EventsController.
    let eventController = EventsController()
    
    ///An instance of MyProfileController.
    let myProfileController = MyProfileController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createElements(view: messagesController, title: NSLocalizedString("messagesTab", comment: "Messages Tab Title"), imageName: "Messages")
        createElements(view: eventController, title: NSLocalizedString("eventTab", comment: "Event Tab Title"), imageName: "CalendarIcon")
        createElements(view: myProfileController, title: NSLocalizedString("myProfileTab", comment: "My Profile Tab Title"), imageName: "profile")
        myProfileController.messagesController = messagesController
        viewControllers = tabList
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if (currentUser.id != delegate?.currentUser.id) {
            currentUser = (delegate?.currentUser)!
            passUsersThrough(user: currentUser)
        }
    }
    ///Gets the current users information.
    func getCurrentUser(){
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observe(.value, with: { (DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                user.id = DataSnapshot.key
                user.status = dictionary["status"] as? String
                let settingsRef = Database.database().reference().child("user-settings").child((user.id)!)
                settingsRef.observe(.value, with: { (DataSnapshot) in
                    if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                        
                        user.settings?.id = user.id
                        user.settings?.greeting = dictionary["Greeting"] as? String
                        user.settings?.theirColor = dictionary["TheirColor"] as? String
                        user.settings?.myColor = dictionary["YourColor"] as? String
                    }
                })
                self.passUsersThrough(user: user)
                
            }
        }, withCancel: nil)
    }
    /**
     Passes the current user into the tabs so it can set them up.
     - Parameters:
         - user: The current user to be passed to its views so they can be setup.
     */
    func passUsersThrough(user: User) {
        self.messagesController.user = user
        self.eventController.currentUser = user
        self.myProfileController.user = user
    }
    /**
     Creates a tab element, and adds it to the current tabbar.
     
     - Parameters:
         - view: The view to add.
         - title: The title of the tab bar element to add.
         - imageName: The name of the image to set as the tab bar item's image.
     */
    func createElements(view: UIViewController,title: String, imageName: String) {
        let view = view
        let navController = UINavigationController(rootViewController: view)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)?.withRenderingMode(.automatic)
        tabList.append(navController)
    }
    
}
