//
//  HomeViewController.swift
//  See Fish
//
//  Created by Andre on 11/2/20.
//

import UIKit
import AVKit
import Kingfisher
import SCLAlertView
import DropDown
import Auk
import DynamicBlurView
import GSImageViewerController
import AVFoundation
import AudioToolbox
import SDWebImage
import OneSignal
import CoreLocation
import AddressBookUI
import Network
import Alamofire
import SwiftyJSON

class HomeViewController: BaseViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var feedList: UITableView!
    @IBOutlet weak var img_noresult: UIImageView!
    @IBOutlet weak var view_noresult: UIView!
    @IBOutlet weak var img_profile: UIImageView!
    @IBOutlet weak var view_frame: CustomDashView!    
    @IBOutlet weak var img_search: UIImageView!
    @IBOutlet weak var img_story_add: UIImageView!
    @IBOutlet weak var locationRecordingNotificationBar: UILabel!
    @IBOutlet weak var routeFollowingsBar: UILabel!
    
    let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Comfortaa-Medium", size: 16.0)!,
        .foregroundColor: primaryColor,
    //   .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    var posts = [Post]()
    var searchPosts = [Post]()
    var users = [User]()
    var dialog:AlertDialog!
    
    var manager = CLLocationManager()
    var thisUserLocation:CLLocationCoordinate2D? = nil
    var isLocationRecording:Bool = false
    var totalDistance:Double = 0.0
    var duration:Int64 = 0
    var startedTime:Int64 = 0
    var endedTime:Int64 = 0
    var traces = [Point]()
    var traces1 = [Point]()
    var traces0 = [Point]()
    var routeID:Int64 = 0
    var liveRoute:Route!
    var userNotificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        img_story_add.isHidden = true
        
        view_searchbar.isHidden = true
        view_noresult.isHidden = true
        btn_search.setImageTintColor(primaryColor)
        setIconTintColor(imageView: img_search, color: primaryColor)
        
        edt_search.attributedPlaceholder = NSAttributedString(string: "Search...",
            attributes: attrs)
        edt_search.textColor = primaryColor
        
        edt_search.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        view_searchbar.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.3)
        
        setIconTintColor(imageView: img_noresult, color: primaryColor)
        
        self.img_profile.layer.cornerRadius = self.img_profile.frame.height / 2
        loadPicture(imageView: self.img_profile, url: URL(string: thisUser.photo_url)!)
        
        self.feedList.delegate = self
        self.feedList.dataSource = self
        
        self.feedList.estimatedRowHeight = 500.0
        self.feedList.rowHeight = UITableView.automaticDimension
        
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor(rgb: 0x0BFFFF, alpha: 1.0) ]
        
        if gFCMToken.count > 0 {
            registerFCMToken(member_id: thisUser.idx, token: gFCMToken)
        }
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(showMyProfile))
        img_profile.isUserInteractionEnabled = true
        img_profile.addGestureRecognizer(tap)
        
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let hasPrompted = status.permissionStatus.hasPrompted
        print("hasPrompted = \(hasPrompted)")
        let userStatus = status.permissionStatus.status
        print("userStatus = \(userStatus)")

        let isSubscribed = status.subscriptionStatus.subscribed
        print("isSubscribed = \(isSubscribed)")
        let userSubscriptionSetting = status.subscriptionStatus.userSubscriptionSetting
        print("userSubscriptionSetting = \(userSubscriptionSetting)")
        let userID = status.subscriptionStatus.userId // This one
        print("userID = \(userID)")
        let pushToken = status.subscriptionStatus.pushToken
        print("pushToken = \(pushToken)")
        
        print("OS playerID /////////// \(userID)")
        if userID != nil {
            APIs.registerOSToken(member_id: thisUser.idx, os_playerid: userID!, handleCallback: {
                result_code  in
                print("OS userID Resp")
            })
        }
        
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        manager.startMonitoringSignificantLocationChanges()
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        if CLLocationManager.locationServicesEnabled() {
            self.disableLocationManager()
        }        
        totalDistance = 0
        duration = 0
        startedTime = 0
        endedTime = 0
        
        userNotificationCenter.delegate = self
        requestNotificationAuthorization()
        
        UserDefaults.standard.set(0, forKey: "last_loaded")
        locationRecordingNotificationBar.visibility = .gone
        locationRecordingNotificationBar.addBorder(side: .top, color: .white, width: 1.0)
        if isLocationRecording { locationRecordingNotificationBar.visibility = .visible }
        
        tap = UITapGestureRecognizer(target: self, action: #selector(toLiveRoute))
        locationRecordingNotificationBar.isUserInteractionEnabled = true
        locationRecordingNotificationBar.addGestureRecognizer(tap)
        
        routeFollowingsBar.visibility = .gone
        routeFollowingsBar.addBorder(side: .top, color: .white, width: 1.0)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(toRouteFollowings))
        routeFollowingsBar.isUserInteractionEnabled = true
        routeFollowingsBar.addGestureRecognizer(tap)
        
    }
    
    @objc func toLiveRoute() {
        if liveRoute == nil { return }
        gRoute = liveRoute
        self.showLoadingView()
        APIs.getRouteDetails(route_id: gRoute.idx, handleCallback: {
            route, points, result_code in
            self.dismissLoadingView()
            print("Saved traces: \(points!.count)")
            print(result_code)
            if result_code == "0"{
                gPoints = points!
                self.to(strb: "Main2", vc: "LocationSharingViewController", trans: false, modal: false, anim: true)
            } else {
                self.showToast(msg: "SERVER ERROR 500")
            }
        })
    }
    
    @objc func toRouteFollowings() {
        self.to(strb: "Main2", vc: "RouteFollowingsViewController", trans: false, modal: false, anim: true)
    }
    
    
    func enableLocationManager() {
        manager.startUpdatingLocation()
        locationRecordingNotificationBar.visibility = .visible
    }

    func disableLocationManager() {
        manager.stopUpdatingLocation()
        locationRecordingNotificationBar.visibility = .gone
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            let userLocation = locations.last!
            print("My Location = \(userLocation)")
            let center = CLLocationCoordinate2D(latitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude))
            thisUserLocation = center
            if thisUserLocation != nil && isLocationRecording {
                handleLocation(loc: thisUserLocation!)
            }
        }
    }
    
    @objc func showMyProfile(gesture:UITapGestureRecognizer) {
        print("Tapped on ShowMyProfile button")
        gMainViewController.selectedIndex = 4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recent = self
        gHomeViewController = self
        self.loadPicture(imageView: self.img_profile, url: URL(string: thisUser.photo_url)!)
        self.getPosts(member_id: thisUser.idx)
        self.getMyStories(member_id: thisUser.idx)
        
        gFishViewController.image = nil
        getLiveRoute()
        getCheckRouteFollowings(me_id: thisUser.idx)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let actionID = UserDefaults.standard.integer(forKey: "actionID")
            if actionID != nil && actionID == 1 {
                let msg = """
                        They are sharing their location routes
                        with you now.
                        """
                let alert = UIAlertController(title: "Notice!", message: msg, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Close", style: .cancel, handler: {
                    (action : UIAlertAction!) -> Void in })
                let OKAction = UIAlertAction(title: "Browse", style: .destructive, handler: { alert -> Void in
                    self.to(strb: "Main2", vc: "RouteFollowingsViewController", trans: false, modal: false, anim: true)
                })
                alert.addAction(cancelAction)
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
                UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 0
            }
        }
    }
    
    @IBAction func tap_search(_ sender: Any) {
        if view_searchbar.isHidden{
            view_searchbar.isHidden = false
            btn_search.setImage(UIImage(named: "cancelicon"), for: .normal)
            lbl_title.isHidden = true
            edt_search.becomeFirstResponder()
            
        }else{
            view_searchbar.isHidden = true
            btn_search.setImage(UIImage(named: "ic_search"), for: .normal)
            lbl_title.isHidden = false
            self.edt_search.text = ""
            self.posts = searchPosts
            edt_search.resignFirstResponder()
            
            self.feedList.reloadData()
        }
        btn_search.setImageTintColor(primaryColor)
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }
    
    var kkk = 0
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:HomeFeedCell = tableView.dequeueReusableCell(withIdentifier: "HomeFeedCell", for: indexPath) as! HomeFeedCell
                
        let index:Int = indexPath.row
                
        if posts.indices.contains(index) {
            
            let post = self.posts[index]
            kkk += 1
            
            if post.picture_url != "" {
                cell.postImageHeight.constant = screenWidth
                cell.view_video.isHidden = true
                
                loadPicture(imageView: cell.img_post_picture, url: URL(string: post.picture_url)!)
//                if kkk > 1 {
//                    cell.img_post_picture.sd_setImage(with: URL(string: post.picture_url)!, placeholderImage: nil, options: [], completed: { (downloadedImage, error, cache, url) in
//                        do {
//                            cell.postImageHeight.constant = try! cell.img_post_picture.frame.size.width * (downloadedImage?.size.height ?? 0) / (downloadedImage?.size.width ?? self.screenWidth)
//                        }catch {}
//                    })
//                } else {
//                    loadPicture(imageView: cell.img_post_picture, url: URL(string: post.picture_url)!)
//                }
                
                if post.pictures > 1 {
                    cell.lbl_pics.isHidden = false
                    cell.lbl_pics.text = "+" + String(post.pictures - 1)
                }else{
                    cell.lbl_pics.isHidden = true
                }
                
                cell.img_videomark.isHidden = true
                cell.img_post_picture.sizeToFit()
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))
            cell.img_post_picture.tag = index
            cell.img_post_picture.addGestureRecognizer(tapGesture)
            cell.img_post_picture.isUserInteractionEnabled = true
            
            if post.video_url != ""{
                cell.img_videomark.isHidden = false
                cell.lbl_pics.isHidden = true
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))
                cell.view_video.tag = index
                cell.view_video.addGestureRecognizer(tapGesture)
            }else {
                cell.img_videomark.isHidden = true
            }
            
            if post.user.photo_url != "" {
                loadPicture(imageView: cell.img_poster, url: URL(string: post.user.photo_url)!)
            }
            cell.img_poster.layer.cornerRadius = cell.img_poster.frame.width / 2
                    
            cell.lbl_poster_name.text = post.user.name
            cell.lbl_city.text = post.user.city
            cell.lbl_follows.text = "Followers: \(post.user.followers)"
            cell.lbl_posted_time.text = post.posted_time
            if posts[index].status == "updated" {
                cell.lbl_posted_time.text = "Updated at " + post.posted_time
            }
            
            cell.txv_desc.text = post.content
            if post.content.count > 0 {
                cell.txv_desc.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
                cell.txv_desc.visibility = .visible
            }else {
                cell.txv_desc.visibility = .gone
            }
            cell.txv_desc.isScrollEnabled = false
            
            cell.lbl_likes.text = String(post.likes)

            cell.lbl_comments.text = String(post.comments)
            
            if post.isLiked {
                cell.likeButton.setImage(UIImage(named: "ic_liked"), for: .normal)
            }else{
                cell.likeButton.setImage(UIImage(named: "ic_like"), for: .normal)
            }
            
            if post.isSaved {
                cell.saveButton.setImage(UIImage(named: "ic_saved"), for: .normal)
            }else{
                cell.saveButton.setImage(UIImage(named: "ic_save"), for: .normal)
            }
            
            if post.comments > 0 {
                cell.commentButton.setImage(UIImage(named: "ic_commented"), for: .normal)
            }else {
                cell.commentButton.setImage(UIImage(named: "ic_comment"), for: .normal)
            }
            
            if post.title == "" { cell.titleBox.visibility = .gone }
            else {
                cell.titleBox.visibility = .visible
                cell.titleBox.text = post.title
            }
            if post.category == "" { cell.categoryView.visibility = .gone }
            else {
                cell.categoryView.visibility = .visible
                cell.categoryBox.text = post.category
                cell.categoryBox.textInsets = UIEdgeInsets(top: 8, left: 25, bottom: 8, right: 25)
                cell.categoryBox.layer.cornerRadius = 5
                cell.categoryBox.layer.masksToBounds = true
            }
            if post.lat != nil && post.lng != nil {
                cell.pinButton.visibility = .visible
                cell.pinButton.tag = index
                cell.pinButton.addTarget(self, action: #selector(toMap(sender:)), for: .touchUpInside)
            } else { cell.pinButton.visibility = .gone }
            if post.rod != "" {
                cell.rodBox.text = post.rod
                cell.rodView.visibility = .visible
                cell.rodAmazonButton.tag = index
                cell.rodAmazonButton.addTarget(self, action: #selector(toRodAmazon(sender:)), for: .touchUpInside)
            }else { cell.rodView.visibility = .gone }
            if post.reel != "" {
                cell.reelBox.text = post.reel
                cell.reelView.visibility = .visible
                cell.reelAmazonButton.tag = index
                cell.reelAmazonButton.addTarget(self, action: #selector(toReelAmazon(sender:)), for: .touchUpInside)
            }else { cell.reelView.visibility = .gone }
            if post.lure != "" {
                cell.lureBox.text = post.lure
                cell.lureView.visibility = .visible
                cell.lureAmazonButton.tag = index
                cell.lureAmazonButton.addTarget(self, action: #selector(toLureAmazon(sender:)), for: .touchUpInside)
            }else { cell.lureView.visibility = .gone }
            if post.line != "" {
                cell.lineBox.text = post.line
                cell.lineView.visibility = .visible
                cell.lineAmazonButton.tag = index
                cell.lineAmazonButton.addTarget(self, action: #selector(toLineAmazon(sender:)), for: .touchUpInside)
            }else { cell.lineView.visibility = .gone }
            
            setRoundShadowView(view: cell.view_content, corner: 5.0)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(toProfile(gesture:)))
            cell.view_info.tag = index
            cell.view_info.addGestureRecognizer(tap)
            cell.img_poster.tag = index
            cell.img_poster.addGestureRecognizer(tap)
            
            cell.likeButton.tag = index
            cell.likeButton.addTarget(self, action: #selector(self.toggleLike), for: .touchUpInside)
            
            cell.commentButton.tag = index
            cell.commentButton.addTarget(self, action: #selector(self.openCommentBox), for: .touchUpInside)
            
            cell.menuButton.tag = index
            cell.menuButton.addTarget(self, action: #selector(self.openFeedMenu), for: .touchUpInside)
            
            cell.saveButton.tag = index
            cell.saveButton.addTarget(self, action: #selector(toggleSave), for: .touchUpInside)
            
            cell.titleBox.sizeToFit()
            cell.categoryView.sizeToFit()
            cell.categoryBox.sizeToFit()
            cell.txv_desc.sizeToFit()
            if post.rod != "" { cell.rodView.sizeToFit() }
            if post.reel != "" { cell.reelView.sizeToFit() }
            if post.lure != "" { cell.lureView.sizeToFit() }
            if post.line != "" { cell.lineView.sizeToFit() }
            cell.view_content.sizeToFit()
            cell.view_content.layoutIfNeeded()
                
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = (cell as? HomeFeedCell) else { return }
        let index:Int = indexPath.row
        if posts.indices.contains(index) {
            let post = self.posts[index]
            if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
                if indexPath == lastVisibleIndexPath {
                    if post.video_url != "" {
                        print("video displaying")
                        cell.view_video.isHidden = false
                        cell.img_videomark.isHidden = true
                        
                        let url = URL(string: post.video_url)!
                        let playerItem = CachingPlayerItem(url: url)
                        playerItem.delegate = self
                        let player = AVPlayer(playerItem: playerItem)
                        cell.view_video?.playerLayer.player = player
                        cell.view_video.playerLayer.videoGravity = .resizeAspectFill
                        
                        cell.view_video.player?.play()
                        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? HomeFeedCell else { return }
        let index:Int = indexPath.row
        if posts.indices.contains(index) {
            let post = self.posts[index]
            if ((tableView.indexPathsForVisibleRows?.contains(indexPath)) == nil) {
                if post.video_url != "" {
                    print("video disappeared")
                    cell.view_video.isHidden = true
                    cell.img_videomark.isHidden = false
                    cell.view_video.player?.pause()
                    cell.view_video.player = nil
                }
            }
        }
    }
    
    @objc func playerDidFinishPlaying() {
        let visibleItems: Array = self.feedList.indexPathsForVisibleRows!
        if visibleItems.count > 0 {
            for currentCell in visibleItems {
                guard let cell = self.feedList.cellForRow(at: currentCell) as? HomeFeedCell else {
                    return
                }
                if cell.view_video.player != nil {
//                    cell.view_video.player?.seek(to: CMTime.zero)
//                    cell.view_video.player?.play()
                    cell.view_video.isHidden = true
                    cell.img_videomark.isHidden = false
                    cell.view_video.player?.pause()
                    cell.view_video.player = nil
                }
            }
        }
    }
    
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            let imgView = gesture.view as! UIImageView
            let index = imgView.tag
            let post = posts[index]
            if post.video_url == "" {
                self.getPostPictures(post: post, imageView: imgView)
            }else {
                print("Video Tapped")
                
                gPost = post
                let videoVC = self.storyboard?.instantiateViewController(identifier: "VideoPlayViewController")
                videoVC?.modalPresentationStyle = .fullScreen
                self.present(videoVC!, animated: false, completion: nil)
                
            }
        }else {
            if (gesture.view) != nil {
                let playerView = gesture.view as! PlayerView
                let index = playerView.tag
                let post = posts[index]
                gPost = post
                let videoVC = self.storyboard?.instantiateViewController(identifier: "VideoPlayViewController")
                videoVC?.modalPresentationStyle = .fullScreen
                self.present(videoVC!, animated: false, completion: nil)
            }
        }

    }
    
    @objc func toggleLike(sender:UIButton){
        let index = sender.tag
        let post = posts[index]
        if post.idx > 0 && post.user.idx != thisUser.idx {
            let cell = sender.superview?.superviewOfClassType(HomeFeedCell.self) as! HomeFeedCell
            likePost(member_id: thisUser.idx, post: post, button:sender, likeslabel: cell.lbl_likes!)
        }
    }
    
    func likePost(member_id: Int64, post: Post, button:UIButton, likeslabel:UILabel){
        print("post id: \(post.idx)")
        APIs.likePost(member_id: member_id, post_id: post.idx, handleCallback: {
            likes, result_code in
            if result_code == "0"{
                if !post.isLiked {
                    post.isLiked = true
                    button.setImage(UIImage(named: "ic_liked"), for: .normal)
                }else{
                    post.isLiked = false
                    button.setImage(UIImage(named: "ic_like"), for: .normal)
                }
                likeslabel.text = likes
            }else if result_code == "1"{
                self.showToast(msg:"Your account doesn\'t exist")
                self.logout()
            }else if result_code == "2"{
                self.showToast(msg:"This post doesn\'t exist")
                self.getPosts(member_id: thisUser.idx)
            }else if result_code == "101"{
                self.showToast(msg:"This post user has already been blocked.")
                self.getPosts(member_id: thisUser.idx)
            }else if result_code == "102"{
                self.showToast(msg:"You have already been blocked by this post user.")
                self.getPosts(member_id: thisUser.idx)
            }else {
                self.showToast(msg:"Something wrong")
                self.getPosts(member_id: thisUser.idx)
            }
        })
    }
    
    @objc func toggleSave(sender:UIButton){
        let index = sender.tag
        let post = posts[index]
        if post.idx > 0 {
            let cell = sender.superview?.superviewOfClassType(HomeFeedCell.self) as! HomeFeedCell
            savePost(member_id: thisUser.idx, post: post, button:sender)
        }
    }
    
    func savePost(member_id: Int64, post: Post, button:UIButton){
        print("post id: \(post.idx)")
        APIs.savePost(member_id: member_id, post_id: post.idx, handleCallback: {
            result_code in
            if result_code == "0"{
                if !post.isSaved {
                    post.isSaved = true
                    button.setImage(UIImage(named: "ic_saved"), for: .normal)
                }else{
                    post.isSaved = false
                    button.setImage(UIImage(named: "ic_save"), for: .normal)
                }
            }else if result_code == "1"{
                self.showToast(msg:"Your account doesn\'t exist")
                self.logout()
            }else if result_code == "2"{
                self.showToast(msg:"This post doesn\'t exist")
                self.getPosts(member_id: thisUser.idx)
            }else if result_code == "101"{
                self.showToast(msg:"This post user has already been blocked.")
                self.getPosts(member_id: thisUser.idx)
            }else if result_code == "102"{
                self.showToast(msg:"You have already been blocked by this post user.")
                self.getPosts(member_id: thisUser.idx)
            }else {
                self.showToast(msg:"Something wrong")
                self.getPosts(member_id: thisUser.idx)
            }
        })
    }
    
    @objc func openCommentBox(sender:UIButton){
        let index = sender.tag
        let post = posts[index]
        if post.idx > 0 {
            gPost = post
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "CommentViewController")
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
            
        edt_search.attributedText = NSAttributedString(string: edt_search.text!, attributes: attrs)
            
        posts = filter(keyword: (textField.text?.lowercased())!)
        if posts.isEmpty{
                
        }
        self.feedList.reloadData()
    }
        
    func filter(keyword:String) -> [Post]{
        if keyword == ""{
            return searchPosts
        }
        var filteredPosts = [Post]()
        for post in searchPosts{
            if post.content.lowercased().contains(keyword){
                filteredPosts.append(post)
            }else{
                if String(post.comments).contains(keyword){
                    filteredPosts.append(post)
                }else{
                    if post.posted_time.contains(keyword){
                        filteredPosts.append(post)
                    }else{
                        if post.user.name.lowercased().contains(keyword){
                            filteredPosts.append(post)
                        }
                    }
                }
            }
        }
        return filteredPosts
    }
    
    func getPosts(member_id:Int64){
        if self.posts.count == 0 {
            self.showLoadingView()
        }
        APIs.getPosts(member_id: member_id, handleCallback: {
            posts, result_code in
            if self.posts.count == 0 {
                self.dismissLoadingView()
            }
            print(result_code)
            if result_code == "0"{
                
                self.posts = posts!
                self.searchPosts = posts!
                
                if self.posts.count == 0 {
                    self.view_noresult.isHidden = false
                }else {
                    self.view_noresult.isHidden = true
                }
                
                self.feedList.reloadData()

            }
            else{
                if result_code == "1" {
                    self.logout()
                } else {
                    self.showToast(msg: "Something wrong!")
                }
            }
        })
    }
    
    
    func deletePost(post_id: Int64){
        self.showLoadingView()
        APIs.deletePost(post_id: post_id, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "Deleted")
                self.getPosts(member_id: thisUser.idx)
            }else if result_code == "1"{
                self.showToast(msg: "This post doesn\'t exist")
                self.getPosts(member_id: thisUser.idx)
            }else {
                self.showToast(msg:"Something wrong")
            }
        })
    }
    
    func getPostPictures(post: Post, imageView: UIImageView){
        self.showLoadingView()
        APIs.getPostPictures(post_id: post.idx,handleCallback: {
            pictures, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                gPostPictures = pictures!
                gPost = post
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ImagePageViewController")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        })
            
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    @objc func openFeedMenu(sender:UIButton){
        let index = sender.tag
        let cell = sender.superview?.superviewOfClassType(HomeFeedCell.self) as! HomeFeedCell
        
        let dropDown = DropDown()
        
        dropDown.anchorView = cell.menuButton
        if posts[index].user.idx == thisUser.idx{
            dropDown.dataSource = ["  Edit", "  Delete"]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    gPost = self.posts[index]
                    if gPost.video_url.count > 0 {
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "VideoSubmitViewController")
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }else {
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EditImagePostViewController")
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                }else if idx == 1 {
                    let msg = """
                    Are you sure you want to delete
                    this feed?
                    """
                    let alert = UIAlertController(title: "Delete", message: msg, preferredStyle: .alert)
                    let noAction = UIAlertAction(title: "No", style: .cancel, handler: {
                        (action : UIAlertAction!) -> Void in })
                    let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { alert -> Void in
                        self.deletePost(post_id: self.posts[index].idx)
                    })
                    
                    alert.addAction(yesAction)
                    alert.addAction(noAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            let user = self.posts[index].user
            var menu = [String]()
            if user?.followed == true {
                menu = ["  Profile", "  Unfollow", "  Message", "  Block", "  Report"]
            }else {
                menu = ["  Profile", "  Follow", "  Message", "  Block", "  Report"]
            }
            dropDown.dataSource = menu
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    gUser = self.posts[index].user
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "UserProfileViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }else if idx == 1{
                    let member = self.posts[index].user
                    self.followMember(member_id: member!.idx, me_id: thisUser.idx)
                }else if idx == 2{
                    gUser = self.posts[index].user
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SendMessageViewController")
                    self.present(vc, animated: true, completion: nil)
                }else if idx == 3{
                    gUser = self.posts[index].user
                    let msg = """
                    Are you sure you want to block
                    this user?
                    """
                    let alert = UIAlertController(title: "Warning", message: msg, preferredStyle: .alert)
                    let noAction = UIAlertAction(title: "No", style: .destructive){(ACTION) in
                        alert.dismiss(animated: true, completion: nil)
                    }
                    let yesAction = UIAlertAction(title: "Yes", style: .cancel){(ACTION) in
                        self.blockUser(member_id: gUser.idx)
                    }
                    alert.addAction(noAction)
                    alert.addAction(yesAction)
                    self.present(alert, animated:true, completion:nil);
                }else if idx == 4{
                    gUser = self.posts[index].user
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ReportViewController")
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
        
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.white
        DropDown.appearance().textFont = UIFont.boldSystemFont(ofSize: 13.0)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.gray
        DropDown.appearance().cellHeight = 40
        
        dropDown.separatorColor = UIColor.lightGray
        dropDown.width = 110
        
        dropDown.show()
        
    }
    
    func blockUser(member_id:Int64) {
        self.showLoadingView()
        APIs.blockUser(member_id: member_id, blocker_id: thisUser.idx, handleCallback: { [self]
            result_code in
            self.dismissLoadingView()
            if result_code == "0" {
                showToast2(msg: "The user has been blocked.")
                self.getPosts(member_id: thisUser.idx)
            }
        })
    }
    
    func registerFCMToken(member_id: Int64, token:String){
        APIs.registerFCMToken(member_id: member_id, token: token, handleCallback: {
            fcm_token, result_code in
            if result_code == "0"{
                print("token registered!!!", fcm_token)
            }
        })
    }
    
    func followMember(member_id: Int64, me_id: Int64){
        self.showLoadingView()
        APIs.followMember(member_id: member_id, me_id: me_id, handleCallback: {
            followers, result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.getPosts(member_id: thisUser.idx)
                self.refreshMyInfo(email: thisUser.email, password: thisUser.password)
            }else if result_code == "1"{
                self.showToast(msg:"Your account doesn\'t exist")
                self.logout()
            }else if result_code == "2"{
                self.showToast(msg:"This user doesn\'t exist")
                self.getPosts(member_id: thisUser.idx)
            }else {
                self.showToast(msg:"Something wrong")
                self.getPosts(member_id: thisUser.idx)
            }
        })
    }
    
    func refreshMyInfo(email:String, password: String)
    {
        APIs.login(email: email, password: password, handleCallback:{
            user, result_code in
            print(result_code)
            if result_code == "0"{
                thisUser = user!
            }
        })
    }
    
    @objc func toProfile(gesture:UITapGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            let imgView = gesture.view as! UIImageView
            let index = imgView.tag
            let post = posts[index]
            gUser = post.user
            if gUser.idx == thisUser.idx {
                gMainViewController.selectedIndex = 4
            }else {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "UserProfileViewController")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
        if (gesture.view) != nil {
            let infoView = gesture.view!
            let index = infoView.tag
            let post = posts[index]
            gUser = post.user
            if gUser.idx == thisUser.idx {
                gMainViewController.selectedIndex = 4
            }else {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "UserProfileViewController")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    func getMyStories(member_id:Int64){
        APIs.getStories(member_id: member_id, handleCallback: {
            stories, result_code in
            print(result_code)
            if result_code == "0"{
                
                gStories = stories!
                
//                if gStories.count == 0 {
//                    self.img_story_add.isHidden = false
//                }else {
//                    self.img_story_add.isHidden = true
//                }

            }
        })
    }
    
    @objc func toRodAmazon(sender:UIButton) {
        let index = sender.tag
        let goods = posts[index].rod
        if goods.count > 0 {
            toAmazon(goods: goods)
        }
    }
    
    @objc func toReelAmazon(sender:UIButton) {
        let index = sender.tag
        let goods = posts[index].reel
        if goods.count > 0 {
            toAmazon(goods: goods)
        }
    }
    
    @objc func toLureAmazon(sender:UIButton) {
        let index = sender.tag
        let goods = posts[index].lure
        if goods.count > 0 {
            toAmazon(goods: goods)
        }
    }
    
    @objc func toLineAmazon(sender:UIButton) {
        let index = sender.tag
        let goods = posts[index].line
        if goods.count > 0 {
            toAmazon(goods: goods)
        }
    }
    
    func toAmazon(goods:String) {
        let affiliate_link = "https://www.amazon.com/s?k=" + goods + "&ref=nb_sb_noss_1" + "&tag=tbd0ce-20"
        let strURL: String = affiliate_link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if let url = URL.init(string: strURL) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func toMap(sender:UIButton) {
        gPost = self.posts[sender.tag]
        to(strb: "Main2", vc: "PostMapViewController", trans: false, modal: false, anim: false)
    }
    
    func reset() {
        startedTime = Date().currentTimeMillis()
        totalDistance = 0
        duration = 0
        traces.removeAll()
        traces1.removeAll()
    }
    
    var lastDistance:Double = 0
    var cnt:Int = 0
    var isUploading:Bool = false
    
    func handleLocation(loc:CLLocationCoordinate2D) {
        if isLocationRecording {
            let currentTime = Date().currentTimeMillis()
            
            if traces.count == 0 {
                let point = Point()
                point.lat = loc.latitude
                point.lng = loc.longitude
                point.time = String(currentTime)
                traces.append(point)
                traces1.append(point)
                return
            }
            
            var point1:CLLocationCoordinate2D!
            var point2:CLLocationCoordinate2D!
            
            let lastRpoint = traces.last
            
            if traces.count >= 2 {
                let lastRpoint0 = traces[traces.count - 2]
                let dist0 = getDistance(from: CLLocationCoordinate2D(latitude: lastRpoint0.lat, longitude: lastRpoint0.lng), to: CLLocationCoordinate2D(latitude: lastRpoint!.lat, longitude: lastRpoint!.lng))
                let dist1 = getDistance(from: CLLocationCoordinate2D(latitude: lastRpoint!.lat, longitude: lastRpoint!.lng), to: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude))
                let dist2 = getDistance(from: CLLocationCoordinate2D(latitude: lastRpoint0.lat, longitude: lastRpoint0.lng), to: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude))
                if dist2 < dist0 || dist2 < dist1 {
                    traces.remove(at: traces.firstIndex(where: {$0.idx == lastRpoint!.idx})!)
                    totalDistance = totalDistance - lastDistance * 0.001
                    point1 = CLLocationCoordinate2D(latitude: lastRpoint0.lat, longitude: lastRpoint0.lng)
                    point2 = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)

                }else {
                    point1 = CLLocationCoordinate2D(latitude: lastRpoint!.lat, longitude: lastRpoint!.lng)
                    point2 = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                }
            }else {
                point1 = CLLocationCoordinate2D(latitude: lastRpoint!.lat, longitude: lastRpoint!.lng)
                point2 = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            }
            
            ////////////////////     Meter   ///////////////////////
            lastDistance = getDistance(from: point1, to: point2)
            
            totalDistance = totalDistance + lastDistance * 0.001
            duration = currentTime - startedTime
            let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(duration/1000))
            
            let point = Point()
            point.lat = loc.latitude
            point.lng = loc.longitude
            point.time = String(currentTime)
            
            traces.append(point)
            traces1.append(point)
            
            endedTime = Date().currentTimeMillis()
            
            if gLocationSharingViewController != nil {
                gLocationSharingViewController.updateRealTimeRoute()
            }
            
            if h >= 8 && m >= 1 {
                self.finalizeReport(is8hours: true)
                return
            }
            
            if self.isUploading {
                self.traces0.append(point)
                return
            }
            
            let last_loaded = UserDefaults.standard.object(forKey: "last_loaded") as! Int64
            let diff = currentTime - last_loaded
            if diff > 10000 {
                if isConnectedToNetwork {
                    self.isUploading = true
                    self.uploadRoutePoints(end: false)
                } else {
                    self.isUploading = false
                    if self.traces0.count > 0 {
                        self.traces0.removeAll()
                    }
                }
            }
        }
    }
    
    func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLoc = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLoc = CLLocation(latitude: to.latitude, longitude: to.longitude)
        let distanceInMeters = fromLoc.distance(from: toLoc)
        return distanceInMeters
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    var IS8HOURS:Bool = false
    
    func finalizeReport(is8hours:Bool) {
        isLocationRecording = false
        disableLocationManager()
        
        IS8HOURS = is8hours
        
        if is8hours {
            self.sendNotification(title: "SeeFish", body: "Since the log has exceeded 8 hours, it will be automatically stopped.")
            if !isConnectedToNetwork {
                gHomeViewController.traces1.removeAll()
                gHomeViewController.traces.removeAll()
                return
            }
            self.endedTime = Date().currentTimeMillis()
            self.uploadStartOrEndRoute(route_id: self.routeID, member_id: thisUser.idx, name: "", description: "", start_time: String(self.startedTime), end_time: String(self.endedTime), duration: self.duration, distance: self.totalDistance, status: "2", lat:String(thisUserLocation!.latitude), lng:String(thisUserLocation!.longitude), tm: String(self.endedTime))
        }else {
            if isConnectedToNetwork {
                if traces1.count > 0 {
                    uploadRoutePoints(end: true)
                }
            }else {
                gHomeViewController.traces1.removeAll()
                gHomeViewController.traces.removeAll()
            }
        }
    }
    
    //////// End route
    
    func endRoute(desc:String) {
        self.endedTime = Date().currentTimeMillis()
        self.uploadStartOrEndRoute(route_id: self.routeID, member_id: thisUser.idx, name: "", description: desc, start_time: String(self.startedTime), end_time: String(self.endedTime), duration: self.duration, distance: self.totalDistance, status: "2", lat:String(thisUserLocation!.latitude), lng:String(thisUserLocation!.longitude), tm: String(self.endedTime))
    }
    
    func uploadStartOrEndRoute(route_id:Int64, member_id: Int64, name:String, description:String, start_time:String, end_time:String, duration:Int64, distance:Double, status:String, lat:String, lng:String, tm:String) {
        if Int(status) == 0 || Int(status) == 2 { self.showLoadingView()}
        APIs.uploadStartOrEndRoute(route_id:route_id, member_id: member_id, name:name, description:description, start_time:start_time, end_time:end_time, duration:duration, distance:distance, status:status, lat:lat, lng:lng, tm:tm, handleCallback: { [self]
            route_id, result_code in
            if Int(status) == 0 || Int(status) == 2 { self.dismissLoadingView() }
            print(result_code)
            if result_code == "0"{
                routeID = Int64(route_id)!
                if Int(status) == 0 {
                    isLocationRecording = true
                    enableLocationManager()
                }else {
                    if Int(status) == 2 {
                        print("ROUTE ENDED!")
                        isLocationRecording = false
                        disableLocationManager()
                        traces1.removeAll()
                        traces.removeAll()
                    }
                }
            } else {
                print("Result: \(result_code)")
            }
            
        })
    }
    
    func uploadRoutePoints(end:Bool) {

        let jsonFile = createPointsJsonStr().data(using: .utf8)!

        let params = [
            "route_id":String(routeID),
            "member_id":String(thisUser.idx),
            "name":"",
            "description":"",
            "start_time": String(self.startedTime),
            "end_time": String(self.endedTime),
            "duration": String(self.duration),
            "distance": String(self.totalDistance),
            "status": end ? "1" : "0",
        ] as [String : Any]

        let fileDic = ["jsonfile" : jsonFile]
        // Here you can pass multiple image in array i am passing just one
        let fileArray = NSMutableArray(array: [fileDic as NSDictionary])

//        self.showLoadingView()
        APIs().uploadJsonFile(withUrl: SERVER_URL + "ETMupdate", withParam: params, withFiles: fileArray) { (isSuccess, response) in
            // Your Will Get Response here
//            self.dismissLoadingView()
            print("XXXXXXXXXX JSON: \(response)")
            self.isUploading = false
            if isSuccess == true {
                let result_code = response["result_code"] as Any
                if result_code as! String == "0" {
                    self.traces1.removeAll()
                    let curtime:Int64 = Date().currentTimeMillis()
                    UserDefaults.standard.set(curtime, forKey: "last_loaded")
                    if !end {
                        if self.traces0.count > 0 {
                            for tr in self.traces0 {
                                self.traces1.append(tr)
                            }
                        }
                    }
                    if end || self.IS8HOURS {
                        self.traces.removeAll()
                    }
                }
                self.traces0.removeAll()
            }else{
                print("Error!")
                self.isUploading = false
                self.traces0.removeAll()
            }
        }
    }
    
    
    func createPointsJsonStr() -> String {
        var jsonStr = ""
        var jsonArray = [Any]()
        var i = 0
        for rpoint in traces1 {
            i += 1
            let jsonObject: [String: String] = [
                "id": String(i),
                "route_id": String(routeID),
                "lat": String(rpoint.lat),
                "lng": String(rpoint.lng),
                "time": String(rpoint.time),
                "status": "",
            ]
            jsonArray.append(jsonObject)
        }
        
        let jsonItemsObj:[String: Any] = [
            "points":jsonArray
        ]
        
        jsonStr = stringify(json: jsonItemsObj)
        return jsonStr
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
    }
    
    let notification_identifier = "SeeFish Notification"

    func sendNotification(title:String, body:String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = body
        notificationContent.badge = NSNumber(value: 0)
        
        if let url = Bundle.main.url(forResource: "icon",
                                    withExtension: "png") {
            if let attachment = try? UNNotificationAttachment(identifier: notification_identifier,
                                                            url: url,
                                                            options: nil) {
                notificationContent.attachments = [attachment]
            }
        }
        let request = UNNotificationRequest(identifier: notification_identifier,
                                            content: notificationContent,
                                            trigger: nil)
        
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
    func removeNotification(){
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [notification_identifier])
        userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [notification_identifier])
    }
    
    
    func getLiveRoute() {
        let params = [
            "member_id": String(thisUser.idx),
        ] as [String : Any]
        Alamofire.request(SERVER_URL + "getmyroutes", method: .post, parameters: params).responseJSON { response in
            if response.result.isFailure{
//                self.showAlertDialog(title: "Notice", message: "SERVER ERROR 500")
            } else {
                let json = JSON(response.result.value!)
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    for data in dataArray {
                        let route = Route()
                        route.idx = data["id"] as! Int64
                        route.user_id = Int64(data["member_id"] as! String)!
                        route.name = data["name"] as! String
                        route.description = data["description"] as! String
                        route.start_time = data["start_time"] as! String
                        route.end_time = data["end_time"] as! String
                        route.duration = Int64(data["duration"] as! String)!
                        route.distance = Double(data["distance"] as! String)!
                        route.created_on = data["created_on"] as! String
                        route.status = data["status"] as! String
                        if self.routeID == route.idx {
                            self.liveRoute = route
                            break
                        }
                    }
                } else {
//                    self.showAlertDialog(title: "Notice", message: "SERVER ERROR 500")
                }
                
            }
        }
    }
    
    func getCheckRouteFollowings(me_id:Int64){
        APIs.getRouteFollowings(me_id:me_id, handleCallback: {
            users, result_code in
            print(result_code)
            if result_code == "0" {
                if users!.isEmpty {
                    self.routeFollowingsBar.visibility = .gone
                }else {
                    self.routeFollowingsBar.visibility = .visible
                }
            }
        })
    }
    

}


extension HomeViewController: CachingPlayerItemDelegate {
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        print("File is downloaded and ready for storing")
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        print("\(bytesDownloaded)/\(bytesExpected)")
    }
    
    func playerItemPlaybackStalled(_ playerItem: CachingPlayerItem) {
        print("Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
//        showToast(msg: "Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        print(error)
//        showToast(msg: error.localizedDescription)
    }
    
}



















































