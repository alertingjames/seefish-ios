//
//  Post.swift
//  See Fish
//
//  Created by Andre on 11/4/20.
//

import Foundation
import AVKit

class Post{
    var idx:Int64 = 0
    var user:User!
    var content:String = ""
    var picture_url:String = ""
    var video_url:String = ""
    var link:String = ""
    var comments:Int64 = 0
    var posted_time:String = ""
    var likes:Int64 = 0
    var isLiked:Bool = false
    var isSaved:Bool = false
    var pictures:Int = 0
    var status:String = ""
}

var gPost:Post = Post()
