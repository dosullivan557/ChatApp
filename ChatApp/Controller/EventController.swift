//
//  EventController.swift
//  ChatApp
//
//  Created by Danny on 20/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit

class EventController: UIViewController {
    var event : Event? {
        didSet {
            print(event?.toString())
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.hidesBottomBarWhenPushed = true
        // Do any additional setup after loading the view.
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
