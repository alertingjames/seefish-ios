//
//  User.swift
//  See Fish
//
//  Created by Andre on 11/1/20.
//

import Foundation

class User{
    var idx:Int64 = 0
    var name:String = ""
    var email:String = ""
    var password:String = ""
    var photo_url:String = ""
    var phone_number:String = ""
    var city:String = ""
    var address:String = ""
    var lat:String = ""
    var lng:String = ""
    var registered_time:String = ""
    var followers:Int64 = 0
    var followings:Int64 = 0
    var followed:Bool = false
    var feeds:Int64 = 0
    var fcm_token:String = ""
    var os_playerid:String = ""
    var username:String = ""
    var terms:String = ""
    var auth_status:String = ""
    var status:String = ""
    
    var key:String = ""
}

var thisUser:User = User()
var gUser:User = User()
