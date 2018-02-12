//
//  Message.swift
//  ChatApp
//
//  Created by Danny on 05/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
//message object
class Message: NSObject {
    var sendId: String?
    var receiveId: String?
    var message: String?
    var timestamp: NSNumber?
    
    /**
        Method that returns your chatting partner's ID, so you can check which user is the correct user.
     
     
     - Returns: The userId of the user you are chatting with.
    */
    func chatWithId() -> String? {
    if sendId == Auth.auth().currentUser?.uid {
        return receiveId
    }
    else {
        return sendId
        }
    }
    /**
     Creates a string to use as the key.
     - Parameters:
        - key: The Key for the encryption - MessageId.
     - Returns: Returns the correct key to use.
     */
    fileprivate func getKey(key: String) -> String{
        var newKey = ""
        let chars = stringToList(text: key)
        for char in chars{
            if((char >= "a") && (char <= "z")){
                newKey += char.charToString()
            }
        }
        return newKey.lowercased()
    }
    
    func stringToList(text: String) -> [Character] {
        var list = [Character]()
        for char in text.characters {
            list.append(char)
        }
        
        return list
    }
}
