//
//  TestViewController.swift
//  See Fish
//
//  Created by Andre on 11/5/20.
//

import UIKit
import AVKit
import DropDown

class VideoPlayViewController: BaseViewController {
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var img_poster: UIImageView!
    @IBOutlet weak var lbl_poster_name: UILabel!
    @IBOutlet weak var lbl_poster_city: UILabel!
    @IBOutlet weak var lbl_follows: UILabel!
    @IBOutlet weak var btn_menu: UIButton!
    @IBOutlet weak var txv_desc: UITextView!    
    @IBOutlet weak var lbl_posted_time: UILabel!
    
    @IBOutlet weak var lbl_likes: UILabel!
    @IBOutlet weak var lbl_comments: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var player:AVPlayer!
    
    @IBOutlet weak var titleBox: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryBox: EdgeInsetLabel!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var rodView: UIView!
    @IBOutlet weak var rodBox: UILabel!
    @IBOutlet weak var rodAmazonButton: UIButton!
    @IBOutlet weak var rodSearchButton: UIButton!
    @IBOutlet weak var reelView: UIView!
    @IBOutlet weak var reelBox: UILabel!
    @IBOutlet weak var reelAmazonButton: UIButton!
    @IBOutlet weak var reelSearchButton: UIButton!
    @IBOutlet weak var lureView: UIView!
    @IBOutlet weak var lureBox: UILabel!
    @IBOutlet weak var lureAmazonButton: UIButton!
    @IBOutlet weak var lureSearchButton: UIButton!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var lineBox: UILabel!
    @IBOutlet weak var lineAmazonButton: UIButton!
    @IBOutlet weak var lineSearchButton: UIButton!
    
    var shareAlert:shareAlert!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let url = URL(string: gPost.video_url)!
        let playerItem = CachingPlayerItem(url: url)
        playerItem.delegate = self
        player = AVPlayer(playerItem: playerItem)
        player.rate = 1 //auto play
        let playerFrame = CGRect(x: 0, y: 0, width: self.playerView.frame.width, height: self.playerView.frame.height)
        let playerController = AVPlayerViewController()
        playerController.player = player
        playerController.showsPlaybackControls = true
        playerController.view.frame = playerFrame
        self.playerView.addSubview(playerController.view)
        self.addChild(playerController)
        playerController.didMove(toParent: self)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.playerView.bounds
//        playerView.layer.addSublayer(playerLayer)
        player.play()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gVideoPlayViewController = self
        recent = self
        
        shareAlert = (UIStoryboard(name: "Frames", bundle: nil).instantiateViewController(withIdentifier: "shareAlert") as! shareAlert)
        shareAlert.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        shareAlert.buttonsView.alpha = 0

        img_poster.layer.cornerRadius = img_poster.frame.height / 2
        rodSearchButton.setImageTintColor(primaryColor)
        reelSearchButton.setImageTintColor(primaryColor)
        lureSearchButton.setImageTintColor(primaryColor)
        lineSearchButton.setImageTintColor(primaryColor)
        loadPicture(imageView: img_poster, url: URL(string: gPost.user.photo_url)!)
        lbl_poster_name.text = gPost.user.name
        lbl_poster_city.text = gPost.user.city
        lbl_follows.text = "Followers: \(gPost.user.followers)"
        txv_desc.text = gPost.content
        if gPost.content.count > 0 {
            txv_desc.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
            txv_desc.visibility = .visible
        }else {
            txv_desc.visibility = .gone
        }
        txv_desc.isScrollEnabled = false
        lbl_posted_time.text = gPost.posted_time
        
        lbl_likes.text = String(gPost.likes)
        lbl_comments.text = String(gPost.comments)
        
        if gPost.isLiked {
            likeButton.setImage(UIImage(named: "ic_liked"), for: .normal)
        }else{
            likeButton.setImage(UIImage(named: "ic_like"), for: .normal)
        }
        
        if gPost.isSaved {
            saveButton.setImage(UIImage(named: "ic_saved"), for: .normal)
        }else{
            saveButton.setImage(UIImage(named: "ic_save"), for: .normal)
        }
        
        if gPost.comments > 0 {
            commentButton.setImage(UIImage(named: "ic_commented"), for: .normal)
        }else {
            commentButton.setImage(UIImage(named: "ic_comment"), for: .normal)
        }
        
        btn_menu.setImageTintColor(.white)
        likeButton.setImageTintColor(.white)
        saveButton.setImageTintColor(.white)
        shareButton.setImageTintColor(.white)
        commentButton.setImageTintColor(.white)
        lbl_likes.textColor = .white
        lbl_comments.textColor = .white
        
        if gPost.title == "" { titleBox.visibility = .gone }
        else {
            titleBox.visibility = .visible
            titleBox.text = gPost.title
        }
        if gPost.category == "" { categoryView.visibility = .gone }
        else {
            categoryView.visibility = .visible
            categoryBox.text = gPost.category
            categoryBox.textInsets = UIEdgeInsets(top: 8, left: 25, bottom: 8, right: 25)
            categoryBox.roundCorners(corners: [.topRight, .bottomLeft], radius: 25)
            categoryBox.layer.masksToBounds = true
        }
        if gPost.lat != nil && gPost.lng != nil { pinButton.visibility = .visible }
        else { pinButton.visibility = .gone }
        if gPost.rod != "" {
            rodBox.text = gPost.rod
            rodView.visibility = .visible
        }else { rodView.visibility = .gone }
        if gPost.reel != "" {
            reelBox.text = gPost.reel
            reelView.visibility = .visible
        }else { reelView.visibility = .gone }
        if gPost.lure != "" {
            lureBox.text = gPost.lure
            lureView.visibility = .visible
        }else { lureView.visibility = .gone }
        if gPost.line != "" {
            lineBox.text = gPost.line
            lineView.visibility = .visible
        }else { lineView.visibility = .gone }

    }
    
    @IBAction func back(_ sender: Any) {
        if player != nil {
            player.pause()
            player = nil
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openMenu(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.anchorView = (sender as! AnchorView)
        if gPost.user.idx == thisUser.idx{
            dropDown.dataSource = ["  Edit", "  Delete"]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
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
                        self.deletePost(post_id: gPost.idx)
                    })
                    
                    alert.addAction(yesAction)
                    alert.addAction(noAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            let user = gPost.user
            var menu = [String]()
            if user?.followed == true {
                menu = ["  Profile", "  Unfollow", "  Message", "  Report"]
            }else {
                menu = ["  Profile", "  Follow", "  Message", "  Report"]
            }
            dropDown.dataSource = menu
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    gUser = gPost.user
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "UserProfileViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }else if idx == 1{
                    let member = gPost.user
                    self.followMember(member_id: member!.idx, me_id: thisUser.idx)
                }else if idx == 2{
                    gUser = gPost.user
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SendMessageViewController")
                    self.present(vc, animated: true, completion: nil)
                }else if idx == 3{
                    gUser = gPost.user
//                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ReportViewController")
//                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
        
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.white
        DropDown.appearance().textFont = UIFont.boldSystemFont(ofSize: 16.0)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.gray
        DropDown.appearance().cellHeight = 50
        
        dropDown.separatorColor = UIColor.lightGray
        dropDown.width = 110
        
        dropDown.show()
    }
    
    func followMember(member_id: Int64, me_id: Int64){
        self.showLoadingView()
        APIs.followMember(member_id: member_id, me_id: me_id, handleCallback: {
            followers, result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                if gUser.followed == true {
                    gUser.followed = false
                }else {
                    gUser.followed = true
                }
                self.lbl_follows.text = "Followers: \(followers)"
                gHomeViewController.refreshMyInfo(email: thisUser.email, password: thisUser.password)
            }else if result_code == "1"{
                self.showToast(msg:"Your account doesn\'t exist")
                self.logout()
            }else if result_code == "2"{
                self.showToast(msg:"This user doesn\'t exist")
                self.dismiss(animated: true, completion: nil)
            }else {
                self.showToast(msg:"Something wrong")
                self.dismiss(animated: true, completion: nil)
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
                self.dismiss(animated: true, completion: nil)
            }else if result_code == "1"{
                self.showToast(msg: "This post doesn\'t exist")
                self.dismiss(animated: true, completion: nil)
            }else {
                self.showToast(msg:"Something wrong")
            }
        })
    }
    
    @IBAction func savePost(_ sender: Any) {
        if gPost.user.idx != thisUser.idx {
//            savePost(member_id: thisUser.idx, post: gPost)
        }
        savePost(member_id: thisUser.idx, post: gPost)
    }
    
    @IBAction func openComment(_ sender: Any) {
        if gPost.user.idx != thisUser.idx {
//            openCommentBox()
        }
        openCommentBox()
    }
    
    @IBAction func likePost(_ sender: Any) {
        if gPost.user.idx != thisUser.idx {
            likePost(member_id: thisUser.idx, post: gPost)
        }
    }
    
    func savePost(member_id: Int64, post: Post){
        print("post id: \(post.idx)")
        APIs.savePost(member_id: member_id, post_id: post.idx, handleCallback: {
            result_code in
            if result_code == "0"{
                if !post.isSaved {
                    post.isSaved = true
                    self.saveButton.setImage(UIImage(named: "ic_saved"), for: .normal)
                }else{
                    post.isSaved = false
                    self.saveButton.setImage(UIImage(named: "ic_save"), for: .normal)
                }
                self.saveButton.setImageTintColor(.white)
            }else if result_code == "1"{
                self.showToast(msg:"Your account doesn\'t exist")
                self.logout()
            }else if result_code == "2"{
                self.showToast(msg:"This post doesn\'t exist")
            }else if result_code == "101"{
                self.showToast(msg:"This post user has already been blocked.")
                self.dismiss(animated: true, completion: nil)
            }else if result_code == "102"{
                self.showToast(msg:"You have already been blocked by this post user.")
                self.dismiss(animated: true, completion: nil)
            }else {
                self.showToast(msg:"Something wrong")
            }
        })
    }
    
    @objc func openCommentBox(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "CommentViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    func likePost(member_id: Int64, post: Post){
        print("post id: \(post.idx)")
        APIs.likePost(member_id: member_id, post_id: post.idx, handleCallback: {
            likes, result_code in
            if result_code == "0"{
                if !post.isLiked {
                    post.isLiked = true
                    self.likeButton.setImage(UIImage(named: "ic_liked"), for: .normal)
                }else{
                    post.isLiked = false
                    self.likeButton.setImage(UIImage(named: "ic_like"), for: .normal)
                }
                self.likeButton.setImageTintColor(.white)
                self.lbl_likes.text = likes
            }else if result_code == "1"{
                self.showToast(msg:"Your account doesn\'t exist")
                self.logout()
            }else if result_code == "2"{
                self.showToast(msg:"This post doesn\'t exist")
            }else if result_code == "101"{
                self.showToast(msg:"This post user has already been blocked.")
                self.dismiss(animated: true, completion: nil)
            }else if result_code == "102"{
                self.showToast(msg:"You have already been blocked by this post user.")
                self.dismiss(animated: true, completion: nil)
            }else {
                self.showToast(msg:"Something wrong")
            }
        })
    }
    
    
    @IBAction func toMap(_ sender: Any) {
        to(strb: "Main2", vc: "PostMapViewController", trans: false, modal: false, anim: false)
    }
    
    @IBAction func toRodAmazon(_ sender: Any) {
        let goods = gPost.rod
        if goods.count > 0 {
            toAmazon(goods: goods)
        }
    }
    
    @IBAction func toReelAmazon(_ sender: Any) {
        let goods = gPost.reel
        if goods.count > 0 {
            toAmazon(goods: goods)
        }
    }
    
    @IBAction func toLureAmazon(_ sender: Any) {
        let goods = gPost.lure
        if goods.count > 0 {
            toAmazon(goods: goods)
        }
    }
    
    @IBAction func toLineAmazon(_ sender: Any) {
        let goods = gPost.line
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
    
    func showShareButtons(){
        UIView.animate(withDuration: 0.3) {
            self.addChild(self.shareAlert)
            self.view.addSubview(self.shareAlert.view)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.shareAlert.showButtonFrame()
        }
    }
    
    @IBAction func openShareAlert(_ sender: Any) {
        showShareButtons()
    }
    
}

extension VideoPlayViewController: CachingPlayerItemDelegate {
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        print("File is downloaded and ready for storing")
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        print("\(bytesDownloaded)/\(bytesExpected)")
    }
    
    func playerItemPlaybackStalled(_ playerItem: CachingPlayerItem) {
        print("Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
        showToast(msg: "Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        print(error)
        showToast(msg: error.localizedDescription)
    }
    
}
