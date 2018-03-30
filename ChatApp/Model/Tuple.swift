//
//  Tuple.swift
//  ChatApp
//
//  Created by Danny on 29/03/2018.
//  Copyright © 2017 Danny. All rights reserved.
//

import UIKit
//user object
class Tuple: NSObject {
    var stringOne: String?
    var stringTwo: String?
    
    func getStringOne() -> String{
        return stringOne!
    }
    
    func getStringTwo() -> String{
        return stringTwo!
    }
    
    func setStringOne(s: String){
        stringOne = s
    }
    
    func setStringTwo(s: String){
        stringTwo = s
    }
}
