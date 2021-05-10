//
//  Story.swift
//  See Fish
//
//  Created by Andre on 11/11/20.
//

import Foundation

class Story {
    var idx:Int64 = 0
    var user:User!
    var content:String = ""
    var picture_url:String = ""
    var video_url:String = ""
    var link:String = ""
    var posted_time:String = ""
    var views:Int64 = 0
    var pictures:Int = 0
    var status:String = ""
}

var gStory:Story = Story()
var gStories = [Story]()
