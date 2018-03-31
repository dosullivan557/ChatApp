//
//  Tuple.swift
//  ChatApp
//
//  Created by Danny on 29/03/2018.
//  Copyright © 2017 Danny. All rights reserved.
//

import UIKit
/**
 Tuple object using polymorphism and generics.
     let tuple = Tuple<String, String>()
 This allows the developer to set whatever data type they would like to use for both objects.
 */
class Tuple<A,B>: NSObject {
    ///The first object.
    var objectOne: A?
    ///The second object.
    var objectTwo: B?
    
    /**
     Sets both of the variables in the tuple.
     - Parameters:
        - s1: First object to set.
        - s2: Second object to set.
     */
    init(s1: A, s2: B) {
        objectOne = s1
        objectTwo = s2
    }
    
    /**
     This returns the unwrapped element of the structure.
     - Returns: The first element of the datastructure.
     */
    func getObjectOne() -> A{
        return objectOne!
    }
    
    /**
     This returns the unwrapped element of the structure.
     - Returns: The Second element of the datastructure.
     */
    func getObjectTwo() -> B{
        return objectTwo!
    }
    
    /**
     This sets the first element in the datastructure. Used to overwrite the current values.
     - Parameters:
         - s: The object to set the object one to.
     */
    func setObjectOne(s: A){
        objectOne = s
    }
    
    /**
     This sets the second element in the datastructure. Used to overwrite the current values.
     - Parameters:
         - s: The object to set the object two to.
     */
    func setObjectTwo(s: B){
        objectTwo = s
    }
}
