//
//  Settings.swift
//  ChatApp
//
//  Created by Danny on 19/02/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import Foundation
import UIKit

class Settings: NSObject {
    var id : String?
    var greeting : String?
    var myColor : String?
    var theirColor: String?
    
    func toString() -> String {
        return ("id: \(id!), greeting: \(greeting!), myColor: \(myColor!), theirColor: \(theirColor!)")
    }
}
