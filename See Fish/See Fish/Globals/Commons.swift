//
//  Commons.swift
//  See Fish
//
//  Created by Andre on 10/31/20.
//

import Foundation
import UIKit


/////////// Color //////////////////
var primaryMainLightColor = UIColor(rgb: 0xdef3f6, alpha: 1.0)
var primaryLightColor = UIColor(rgb: 0x7fcdff, alpha: 1.0)
var primaryColor = UIColor(rgb: 0x1da2d8, alpha: 1.0)
var primaryDarkColor = UIColor(rgb: 0x064273, alpha: 1.0)


////////// Request URL /////////////////
let SERVER_URL = "https://cayley5.pythonanywhere.com/seefish/"
let FIREBASE_URL = "https://motherwise-1585202524394.firebaseio.com/"


/////////// Map ////////////////////////////////
var RADIUS:Float = 15.24
var baseUrl:String = "https://maps.googleapis.com/maps/api/geocode/json?"
var apikey:String = "AIzaSyAALGjqJwiEBEYax5vMuWexhuPZCpsh8Lg"


////////  Variables ///////////////////////////
var gFCMToken:String = ""
var gPostPictures = [PostPicture]()
var gMediaOption = ""




///////// ViewController //////////////////////////
var recent:UIViewController!

var gSignupViewController:SignupViewController!
var gVideoSubmitViewController:VideoSubmitViewController!
var gMainViewController:MainViewController!

var gHomeViewController:HomeViewController!
var gCommentViewController:CommentViewController!
var gUserProfileViewController:UserProfileViewController!

var gImagePageViewController:ImagePageViewController!
var gSearchViewController:SearchViewController!
var gVideoPlayViewController:VideoPlayViewController!
var gEditProfileViewController:EditProfileViewController!

var gFeedContainerViewController:FeedContainerViewController!
var gFriendContainerViewController:FriendContainerViewController!

var gFishViewController:FishViewController!





























