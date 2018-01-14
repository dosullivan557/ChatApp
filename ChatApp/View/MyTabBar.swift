//
//  MyTabBar.swift
//  ChatApp
//
//  Created by Danny on 09/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//
import UIKit

class MyTabBar: UITabBarController {
    var tabList = [UIViewController]()
    override func viewDidLoad() {
        
        createElements(view: MessagesController(), title: "Messages", imageName: "Messages")
        createElements(view: EventsController(), title: "Events", imageName: "event")
        createElements(view: ProfileController(), title: "Profile", imageName: "profile")

        viewControllers = tabList
    }
    func createElements(view: UIViewController,title: String, imageName: String) {
        let view = view
        let navController = UINavigationController(rootViewController: view)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)?.withRenderingMode(.automatic)
        tabList.append(navController)
    }
    
}
