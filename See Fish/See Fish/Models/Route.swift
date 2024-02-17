//
//  Route.swift
//  See Fish
//
//  Created by james on 12/8/22.
//

import Foundation

class Route {
    var idx:Int64 = 0
    var user_id:Int64 = 0
    var name:String = ""
    var description:String = ""
    var start_time:String = ""
    var end_time:String = ""
    var duration:Int64 = 0
    var distance:Double = 0
    var created_on:String = ""
    var status:String = ""
    
    var user = User()
}

var gRoute = Route()
var gRouteList = [Route]()
