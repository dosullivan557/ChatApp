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
     Gets the string of the message including all of its information. Used for development.
     - Returns: The string containing all of the information.
     */
    func toString() -> String {
        return ("sendId:\(sendId!), receiveId:\(receiveId!), message:\(message!), timestamp:\(timestamp!)")
    }
    
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
     Creates a string to use as the key. Removes all of the special characters and numbers from the string which is read in, and returns just the characters.
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
    
    /**
     Gets a string and returns a list of all of its characters.
     - Parameters:
         - text: The text to convert.
     - Returns: Returns the list of characters.
     */
    func stringToList(text: String) -> [Character] {
        var list = [Character]()
        for char in text.characters {
            list.append(char)
        }
        
        return list
    }
    /**
     Encrypts the message text.
     - Parameters:
         - key: The key to use.
    */
    func encrypt(key: String) {
        let newKey = getKey(key: key.lowercased())
        var enc = ""
        var counter = 0
        let keyChars = stringToList(text: newKey.lowercased())
        let aChar = stringToList(text: "a")[0].asciiValue
        let zChar = stringToList(text: "z")[0].asciiValue
        let capZChar = stringToList(text: "Z")[0].asciiValue
        let capAChar = stringToList(text: "A")[0].asciiValue

        print(stringToList(text: message!))
        for char in (stringToList(text: message!)) {
            guard let character = char.asciiValue else {
                enc += char.charToString()
                continue
            }
            if(char == " ") {
                enc += " "
            }
            else if ((char > "!" && char <= "/") || (char >= ":" && char <= "@" )) {
                enc += char.charToString()
            }
            else if (char.asciiValue! >= aChar! && char.asciiValue! <= zChar!){
                let partOne = (char.asciiValue! + keyChars[counter].asciiValue!)
                let algor = ((partOne - 2 * aChar!) % 26 + aChar!)
                enc += Character(UnicodeScalar(algor)!).charToString()
                counter = (counter+1) % newKey.count
            }
            else if (char.asciiValue! >= capAChar! && char.asciiValue! <= capZChar!){
                let partOne = (char.asciiValue! +  stringToList(text: keyChars[counter].charToString().uppercased())[0].asciiValue!)
                let algor = ((partOne - 2 * capAChar!) % 26 + capAChar!)
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
    
    /**
     Decrypts the message text.
     - Parameters:
         - key: The key to use.
     */
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
            else if (char.asciiValue! >= aChar! && char.asciiValue! <= zChar!){
                
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
            }
            else {
                dec += char.charToString()
            }
        message = dec
    }
    
}
}
