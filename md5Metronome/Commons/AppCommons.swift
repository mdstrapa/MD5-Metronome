//
//  AppCommons.swift
//  md5Metronome
//
//  Created by Marcos Strapazon on 29/07/18.
//  Copyright © 2018 Marcos Strapazon. All rights reserved.
//

import UIKit


enum viewMode{
    case add
    case edit
}

public enum metronomeMode {
    case simple
    case setList
}

enum directionsForSelectedSong{
    case next
    case previous
}

struct Settings{
    static var lang:String = "EN"
    static var messages=[Messages]()
}

struct Messages:Codable{
    var id:Int
    var value:String
}

class AppCommons{
    public func showOKMessage(message:String,view:UIViewController){
        let messageToUser = UIAlertController(title: Settings.messages[31].value, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        messageToUser.addAction(okAction)
        view.present(messageToUser, animated: true, completion: nil)
    }
    
    public func getLanguage()->[Messages]{
        var msg = [Messages]()
        
        let path = Bundle.main.path(forResource: "lang_" + Settings.lang, ofType: "json")
        let url = URL(fileURLWithPath: path!)
        let data = try! Data(contentsOf:url)
        let decoder = JSONDecoder()
        do{
            msg = try decoder.decode([Messages].self, from: data)
        }catch{
            print("Error during decoder process. The error is \(error)")
        }
        return msg
        
    }
    
}
