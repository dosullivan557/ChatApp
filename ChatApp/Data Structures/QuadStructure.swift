//
//  QuadStructure.swift
//  ChatApp
//
//  Created by Danny on 31/03/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import Foundation
import UIKit
/**
 Tuple object using polymorphism and generics.
 let tuple = Tuple<String, String>()
 This allows the developer to set whatever data type they would like to use for both objects.
 */
class QuadStructure<A, B, C, D>: NSObject {
    ///The first object.
    var objectOne: Tuple<A,B>?
    ///The second object.
    var objectTwo: Tuple<C,D>?

    
    /**
     Sets both of the variables in the tuple.
     - Parameters:
     - s1: First object to set.
     - s2: Second object to set.
     */
    init(s1: Tuple<A,B>, s2: Tuple<C,D>) {
        objectOne = s1
        objectTwo = s2
    }
    
    /**
     This returns the unwrapped element of the structure.
     - Returns: The first element of the datastructure.
     */
    func getObjectOne() -> Tuple<A,B>{
        return objectOne!
    }
    
    /**
     This returns the unwrapped element of the structure.
     - Returns: The Second element of the datastructure.
     */
    func getObjectTwo() -> Tuple<C,D>{
        return objectTwo!
    }
    
    /**
     This sets the first element in the datastructure. Used to overwrite the current values.
     - Parameters:
     - s: The object to set the object one to.
     */
    func setObjectOne(s: Tuple<A,B>){
        objectOne = s
    }
    
    /**
     This sets the second element in the datastructure. Used to overwrite the current values.
     - Parameters:
     - s: The object to set the object two to.
     */
    func setObjectTwo(s: Tuple<C,D>){
        objectTwo = s
    }
    
   
}
