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
    
    var settings : Settings? {
        didSet {
            myColor.text = settings?.myColor!
            theirColor.text = settings?.theirColor!
        }
    }
}
