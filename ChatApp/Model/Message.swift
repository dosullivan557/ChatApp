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
        let newKey = getKey(key: key.lowercased())
        var enc = ""
        var counter = 0
        let keyChars = stringToList(text: newKey.lowercased())
        let aChar = stringToList(text: "a")[0].asciiValue
        let zChar = stringToList(text: "z")[0].asciiValue
        let capZChar = stringToList(text: "Z")[0].asciiValue
        let capAChar = stringToList(text: "A")[0].asciiValue


        print("aChar: \(aChar!)")
        print("zChar: \(zChar!)")
        print("CapAChar: \(capAChar!)")
        print("CapZChar: \(capZChar!)")
        print(stringToList(text: message!))
        for char in (stringToList(text: message!)) {
            print(char)
            guard let character = char.asciiValue else {
                enc += char.charToString()
                continue
            }

            if(char == " ") {
                enc += " "
                print(" ")
            }
            else if ((char > "!" && char <= "/") || (char >= ":" && char <= "@" )) {
                print("Special Character")
                enc += char.charToString()
            }
            else if (char.asciiValue! >= aChar! && char.asciiValue! <= zChar!){
                print("lowercase")
                let partOne = (char.asciiValue! + keyChars[counter].asciiValue!)
                let algor = ((partOne - 2 * aChar!) % 26 + aChar!)
                enc += Character(UnicodeScalar(algor)!).charToString()
                counter = (counter+1) % newKey.count
            }
            else if (char.asciiValue! >= capAChar! && char.asciiValue! <= capZChar!){
                print("capital")
                let partOne = (char.asciiValue! +  stringToList(text: keyChars[counter].charToString().uppercased())[0].asciiValue!)
                let algor = ((partOne - 2 * capAChar!) % 26 + capAChar!)
                //                print("Char +\(Character(UnicodeScalar(algor)!).charToString())")
                enc += Character(UnicodeScalar(algor)!).charToString()
                counter = (counter+1) % newKey.count
            }
            else {
                print(char)
                enc += char.charToString()
            }
        }
        message = enc

    }
    
    func decrypt(key: String) {
        let newKey = getKey(key: key.lowercased())
        var dec = ""
        var counter = 0
        let keyChars = stringToList(text: newKey)
        let aChar = stringToList(text: "a")[0].asciiValue
        let zChar = stringToList(text: "z")[0].asciiValue
        let messageChars = stringToList(text: message!)
        let capZChar = stringToList(text: "Z")[0].asciiValue
        let capAChar = stringToList(text: "A")[0].asciiValue
        
        for char in messageChars {
            guard let character = char.asciiValue else {
                dec += char.charToString()
                continue
            }
            
            if(char == " " ) {
                dec += " "
            }

            else if (char.asciiValue! > aChar! && char.asciiValue! < zChar!){
        
                let partOne = (char.asciiValue!.hashValue - keyChars[counter].asciiValue!.hashValue)
                let algor = (((partOne + 26) % 26) + aChar!.hashValue)
                
            
                dec += Character(UnicodeScalar(algor)!).charToString()

                counter = (counter+1) % newKey.count


            }
            else if (char.asciiValue! >= capAChar! && char.asciiValue! <= capZChar!) {
                
                let partOne = (char.asciiValue!.hashValue - stringToList(text: keyChars[counter].charToString().uppercased())[0].asciiValue!.hashValue)
                let algor = (((partOne + 26) % 26) + capAChar!.hashValue)
                
                
                dec += Character(UnicodeScalar(algor)!).charToString()
                
                counter = (counter+1) % newKey.count

            //            print(dec)
        }
            else {
                dec += char.charToString()
            }
        message = dec
//        print(dec)
    }
    
}
}
