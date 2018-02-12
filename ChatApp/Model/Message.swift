//
//  Message.swift
//  ChatApp
//
//  Created by Danny on 05/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
///A Message object that holds the user id of the sender and the receiver, the message, and a timestamp.
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
    
    func encrypt(key: String) {
        message = message?.lowercased()
        let newKey = getKey(key: key.lowercased())
        var enc = ""
        var counter = 0
        let keyChars = stringToList(text: newKey.lowercased())
        let aChar = stringToList(text: "a")[0].asciiValue
        let zChar = stringToList(text: "z")[0].asciiValue
//        print("key: \(key)")
//        print("newKey: \(newKey)")
//        print("chars: \(keyChars)")
//        print("aChar: \(aChar!)")
//        print("zChar: \(zChar!)")

    for char in (message?.characters)! {

//            print("algor: \(algor)")
            if(char == " ") {
                enc += " "
//                print("Space")
                print(" ")
            }
            else if (char.asciiValue! < aChar! || char.asciiValue! > zChar!) {
                print(char)
                enc += char.charToString()
            }
            else {
                let partOne = (char.asciiValue! + keyChars[counter].asciiValue!)
                let algor = ((partOne - 2 * aChar!) % 26 + aChar!)
                if(algor >= aChar!) && (algor <= zChar!) {
                print("Char +\(Character(UnicodeScalar(algor)!).charToString())")
                enc += Character(UnicodeScalar(algor)!).charToString()
                }
//            else {
////                print("specialValue")
//                print(char)
//                enc += char.charToString()
//            }
//        print("enc: \(enc)")
//        print("counter\(counter)")
            counter = (counter+1) % newKey.count
        }
        
//        print(enc)
        message = enc
        }
    }
    
    func decrypt(key: String) {
        let newKey = getKey(key: key.lowercased())
        var dec = ""
        var counter = 0
        let keyChars = stringToList(text: newKey)
        let aChar = stringToList(text: "a")[0].asciiValue
        let zChar = stringToList(text: "z")[0].asciiValue
        
//        print("key: \(key)")
//        print("newKey: \(newKey)")
//        print("chars: \(keyChars)")
//        print("aChar: \(aChar!)")
//        print("zChar: \(zChar!)")
        
        for char in (message?.characters)! {

            if(char == " " ) {
                dec += " "
            }
            else if (char.asciiValue! < aChar! || char.asciiValue! > zChar!) {
                dec += char.charToString()
            }
            else{
                let partOne = char.asciiValue! - keyChars[counter].asciiValue!
                let algor = ((partOne + 26) % 26 + aChar!)
                
                if ((algor >= aChar!) && (algor <= zChar!)) {
                    dec += Character(UnicodeScalar(algor)!).charToString()
                }

                counter = (counter+1) % newKey.count

                }
        }
        message = dec
        print(dec)
    }
    
}
