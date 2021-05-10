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

class HomeViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    
    let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Comfortaa-Medium", size: 16.0)!,
        .foregroundColor: primaryColor,
    //   .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    var posts = [Post]()
    var searchPosts = [Post]()
    var users = [User]()
    
    var dialog:AlertDialog!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gHomeViewController = self
        recent = self
        
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
        
        self.feedList.estimatedRowHeight = 1000.0
        self.feedList.rowHeight = UITableView.automaticDimension
        
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor(rgb: 0x0BFFFF, alpha: 1.0) ]
        
        if gFCMToken.count > 0{
            registerFCMToken(member_id: thisUser.idx, token: gFCMToken)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showMyProfile))
        img_profile.addGestureRecognizer(tap)
        
    }
    
    @objc func showMyProfile(gesture:UITapGestureRecognizer) {
        print("Tapped on ShowMyProfile button")
        gMainViewController.selectedIndex = 4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadPicture(imageView: self.img_profile, url: URL(string: thisUser.photo_url)!)
        self.getPosts(member_id: thisUser.idx)
        self.getMyStories(member_id: thisUser.idx)
        
        gFishViewController.image = nil
    }
    
    @IBAction func tap_search(_ sender: Any) {
        if view_searchbar.isHidden{
            view_searchbar.isHidden = false
            btn_search.setImage(UIImage(named: "ic_cancel"), for: .normal)
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
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:HomeFeedCell = tableView.dequeueReusableCell(withIdentifier: "HomeFeedCell", for: indexPath) as! HomeFeedCell
                
        let index:Int = indexPath.row
                
        if posts.indices.contains(index) {
            
            let post = self.posts[index]
            
            if post.picture_url != "" {
//                loadPicture(imageView: cell.img_post_picture, url: URL(string: post.picture_url)!)
                cell.postImageHeight.constant = screenWidth
                cell.view_video.isHidden = true
                cell.img_post_picture.sd_setImage(with: URL(string: post.picture_url)!, placeholderImage: nil, options: [], completed: { (downloadedImage, error, cache, url) in
                    print(downloadedImage?.size.width)//prints width of image
                    print(downloadedImage?.size.height)//prints height of image
                    cell.postImageHeight.constant = cell.img_post_picture.frame.width * (downloadedImage?.size.height)! / (downloadedImage?.size.width)!
                })
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
            
            if post.user.photo_url != ""{
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
                    
            cell.txv_desc.sizeToFit()
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
        if post.idx > 0 && post.user.idx != thisUser.idx {
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
        if post.idx > 0 && post.user.idx != thisUser.idx {
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
                if self.loadingView.isAnimating { self.dismissLoadingView() }
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
                }else if idx == 1{
                    let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this feed?", preferredStyle: .alert)
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
                    let alert = UIAlertController(title: "Warning", message: "Are you sure you want to block this user?", preferredStyle: .alert)
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



















































