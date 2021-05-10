//
//  Comment.swift
//  See Fish
//
//  Created by Andre on 11/4/20.
//

import Foundation

class Comment{
    var idx:Int64 = 0
    var post_id:Int64 = 0
    var user:User!
    var comment:String = ""
    var image_url:String = ""
    var video_url:String = ""
    var commented_time:String = ""
    var timestamp:Int64 = 0
    var status:String = ""
    var disp:Int = 0
    
    var key:String = ""
}

var gComment = Comment()

