//
//  Message.swift
//  See Fish
//
//  Created by james on 7/21/23.
//

import Foundation

class Message {
    var idx:Int64 = 0
    var user_id:Int64 = 0
    var sender:User!
    var message:String = ""
    var messaged_time:String = ""
    var status:String = ""
    var key:String = ""
    var timestamp:Int64 = 0
    var type:String = ""
    var id:String = ""
}

var gMessage:Message = Message()
