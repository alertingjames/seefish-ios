//
//  ImagePageViewController.swift
//  See Fish
//
//  Created by Andre on 11/7/20.
//

import UIKit
import Kingfisher
import Auk
import DynamicBlurView
import GSImageViewerController
import DropDown

class ImagePageViewController: BaseViewController {
    
    @IBOutlet weak var image_scrollview: UIScrollView!
    @IBOutlet weak var view_pictures: UIView!
    var blurView:DynamicBlurView!
    var count:Int = 1
    @IBOutlet weak var txv_desc: UITextView!
    @IBOutlet weak var descViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var img_poster: UIImageView!
    @IBOutlet weak var lbl_poster_name: UILabel!
    @IBOutlet weak var lbl_city: UILabel!
    @IBOutlet weak var lbl_follows: UILabel!
    @IBOutlet weak var lbl_posted_time: UILabel!
    
    @IBOutlet weak var lbl_likes: UILabel!
    @IBOutlet weak var lbl_comments: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gImagePageViewController = self
        recent = self

        // Do any additional setup after loading the view.
        image_scrollview.auk.settings.contentMode = .scaleAspectFit
        self.blurView = DynamicBlurView(frame: self.view_pictures.bounds)
        
        img_poster.layer.cornerRadius = img_poster.frame.height / 2
        loadPicture(imageView: img_poster, url: URL(string: gPost.user.photo_url)!)
        lbl_poster_name.text = gPost.user.name
        lbl_city.text = gPost.user.city
        lbl_follows.text = "Followers: \(gPost.user.followers)"
        lbl_posted_time.text = gPost.posted_time
        
//        if gPost.content.count == 0 {
//            descViewHeight.constant = 0
//        }
        self.txv_desc.text = gPost.content
        
//        self.sliderImagesArray.addObjects(from: gPostPictures)
            
        for pic in gPostPictures {
            self.image_scrollview.auk.show(url: pic.image_url)
        }
        
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
            
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedScrollView(_:)))
        self.image_scrollview.addGestureRecognizer(tap)
        
    }
        
    @objc func tappedScrollView(_ sender: UITapGestureRecognizer? = nil) {
        let index = self.image_scrollview.auk.currentPageIndex
    //        print("tapped on Image: \(index)")
        let images = self.image_scrollview.auk.images
        let image = images[index!]
            
        let imageInfo   = GSImageInfo(image: image , imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView:self.image_scrollview)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            
        imageViewer.dismissCompletion = {
                print("dismissCompletion")
        }
            
        present(imageViewer, animated: true, completion: nil)
    }

    @IBAction func back(_ sender: Any) {
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
                }else if idx == 1{
                    let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this feed?", preferredStyle: .alert)
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
            savePost(member_id: thisUser.idx, post: gPost)
        }
    }
    
    @IBAction func openComment(_ sender: Any) {
        if gPost.user.idx != thisUser.idx {
            openCommentBox()
        }
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
    
    
}
