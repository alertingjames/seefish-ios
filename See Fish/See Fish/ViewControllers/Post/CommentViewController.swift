//
//  CommentViewController.swift
//  See Fish
//
//  Created by Andre on 11/7/20.
//

import UIKit
import Kingfisher
import SCLAlertView
import YPImagePicker
import SwiftyJSON
import DropDown
import Auk
import DynamicBlurView
import GSImageViewerController
import ISEmojiView

class CommentViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, EmojiViewDelegate {

    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var commentList: UITableView!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentBox: UITextView!
    @IBOutlet weak var noResult: UILabel!
    @IBOutlet weak var view_emoji: UIView!
    
    @IBOutlet weak var lbl_emoji0: UILabel!
    @IBOutlet weak var lbl_emoji1: UILabel!
    @IBOutlet weak var lbl_emoji2: UILabel!
    @IBOutlet weak var lbl_emoji3: UILabel!
    @IBOutlet weak var lbl_emoji4: UILabel!
    @IBOutlet weak var lbl_emoji5: UILabel!
    @IBOutlet weak var lbl_emoji6: UILabel!
    @IBOutlet weak var lbl_emoji7: UILabel!
    @IBOutlet weak var lbl_emoji8: UILabel!
    @IBOutlet weak var lbl_emoji9: UILabel!
    
    @IBOutlet weak var messageBoxBottom: NSLayoutConstraint!
    
    var imageFile:Data!
    var ImageArray = NSMutableArray()
    
    var comments = [Comment]()
    
    var emojiButtons = [UILabel]()
    var emojiStrings = [String]()
    
    var isEmoji = false
    
    var dialog:AlertDialog!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        addShadowToBar(view: navBar)
    
        sendButton.setImageTintColor(primaryDarkColor)
        
        gCommentViewController = self
        
        var topSafeAreaHeight: CGFloat = 0
        var bottomSafeAreaHeight: CGFloat = 0

        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows[0]
            let safeFrame = window.safeAreaLayoutGuide.layoutFrame
            topSafeAreaHeight = safeFrame.minY
            bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
        }

        messageBoxBottom.constant = bottomSafeAreaHeight + 5
        self.view.layoutIfNeeded()
        
        sendButton.visibilityh = .gone
        view_emoji.visibility = .gone
        
        commentBox.layer.cornerRadius = commentBox.frame.height / 2
        
        commentBox.setPlaceholder(string: "Write something ...")
        commentBox.textContainerInset = UIEdgeInsets(top: commentBox.textContainerInset.top, left: 8, bottom: commentBox.textContainerInset.bottom, right: 5)
        commentBox.becomeFirstResponder()
        
        self.commentList.delegate = self
        self.commentList.dataSource = self
        
        self.commentList.estimatedRowHeight = 170.0
        self.commentList.rowHeight = UITableView.automaticDimension
        
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor.yellow ]
        
        emojiButtons = [lbl_emoji0, lbl_emoji1, lbl_emoji2, lbl_emoji3, lbl_emoji4, lbl_emoji5, lbl_emoji6, lbl_emoji7, lbl_emoji8, lbl_emoji9]
        emojiStrings = ["Close", "💖","👍","😊","😄","😍","🙁","😂","😠","😛"]
        
        for emjButton in emojiButtons {
            let index = emojiButtons.firstIndex(of: emjButton)!
            emjButton.text = emojiStrings[index].decodeEmoji
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(addEmoji))
            emjButton.tag = index
            emjButton.isUserInteractionEnabled = true
            emjButton.addGestureRecognizer(tap)
        }

    }
    
    @objc func addEmoji(sender:UITapGestureRecognizer){
        let label = sender.view as! UILabel
        let index = label.tag
        if index == 0{
            self.view_emoji.visibility = .gone
        }else{
            self.commentBox.text = self.commentBox.text + emojiStrings[index].decodeEmoji
            self.commentBox.checkPlaceholder()
            if self.commentBox.text == ""{
                sendButton.visibilityh = .gone
            }else{
                sendButton.visibilityh = .visible
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.getComments(me_id: thisUser.idx, post_id: gPost.idx)
        
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if !self.isEmoji {
            commentBox.inputView = nil
            commentBox.keyboardType = .default
            commentBox.reloadInputViews()
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.isEmoji = false
        return true
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:CommentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        
//        commentList.backgroundColor = UIColor.clear
//        cell.backgroundColor = UIColor.clear
                
        let index:Int = indexPath.row
                
        if comments.indices.contains(index) {
            
            let comment = comments[index]
            
            if comment.user.photo_url != ""{
                loadPicture(imageView: cell.userPicture, url: URL(string: comment.user.photo_url)!)
            }
            
            cell.userPicture.layer.cornerRadius = cell.userPicture.frame.width / 2
            
            if comment.user.idx != thisUser.idx{
                cell.userNameBox.text = comment.user.name
            }else{
                cell.userNameBox.text = "Me"
            }
            
            cell.userCityBox.text = comment.user.city
            cell.commentBox.text = comment.comment.decodeEmoji
            cell.commentedTimeBox.text = comment.commented_time
            
            if comment.user.status == "blocked" {
                cell.userNameBox.textColor = .lightGray
                cell.userCityBox.textColor = .lightGray
                cell.commentBox.textColor = .lightGray
                cell.commentedTimeBox.textColor = .lightGray
            }else {
                cell.userNameBox.textColor = .black
                cell.userCityBox.textColor = .black
                cell.commentBox.textColor = .black
                cell.commentedTimeBox.textColor = .black
            }
            
            cell.menuButton.setImageTintColor(UIColor.gray)
            
            cell.menuButton.tag = index
            cell.menuButton.addTarget(self, action: #selector(self.openDropDownMenu), for: .touchUpInside)
            
//            setRoundShadowView(view: cell.contentLayout, corner: 5.0)
                    
            cell.commentBox.sizeToFit()
            cell.contentLayout.sizeToFit()
            cell.contentLayout.layoutIfNeeded()
                
        }
        
        return cell
        
    }
    
    @objc func openDropDownMenu(sender:UIButton){
        let index = sender.tag
        let cell = sender.superview?.superviewOfClassType(CommentCell.self) as! CommentCell
        
        let dropDown = DropDown()
        
        dropDown.anchorView = cell.menuButton
        if comments[index].user.idx == thisUser.idx{
            dropDown.dataSource = ["  Edit", "  Delete"]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    self.commentBox.text = cell.commentBox.text.decodeEmoji
                    self.commentBox.checkPlaceholder()
                    self.commentBox.becomeFirstResponder()
                }else if idx == 1{
                    let msg = """
                    Are you sure you want to delete
                    this comment?
                    """
                    let alert = UIAlertController(title: "Delete", message: msg, preferredStyle: .alert)
                    let noAction = UIAlertAction(title: "No", style: .cancel, handler: {
                        (action : UIAlertAction!) -> Void in })
                    let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { alert -> Void in
                        self.deleteComment(comment_id: self.comments[index].idx)
                    })
                    alert.addAction(yesAction)
                    alert.addAction(noAction)
                    self.present(alert, animated: true, completion: nil)
                    UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 0
                }
            }
        }else{
            var menu = [String]()
            if comments[index].user.status == "blocked" {
                menu = ["  Message", "  Unblock"]
            }else {
                menu = ["  Message", "  Block"]
            }
            dropDown.dataSource = menu
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    if comments[index].user.status != "blocked" {
                        gUser = self.comments[index].user
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SendMessageViewController")
                        self.present(vc, animated: true, completion: nil)
                    }else {
                        let msg = """
                        You have already blocked this user.
                        """
                        showAlertDialog(title: "Note!", message: msg)
                    }
                }else if idx == 1 {
                    gUser = self.comments[index].user
                    if gUser.status != "blocked" {
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
                    }else {
                        let msg = """
                        Are you sure you want to unblock
                        this user?
                        """
                        let alert = UIAlertController(title: "Warning", message: msg, preferredStyle: .alert)
                        let noAction = UIAlertAction(title: "No", style: .destructive){(ACTION) in
                            alert.dismiss(animated: true, completion: nil)
                        }
                        let yesAction = UIAlertAction(title: "Yes", style: .cancel){(ACTION) in
                            self.unblockUser(member_id: gUser.idx)
                        }
                        alert.addAction(noAction)
                        alert.addAction(yesAction)
                        self.present(alert, animated:true, completion:nil);
                    }
                    
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
        dropDown.width = 100
        
        dropDown.show()
        
    }
    
    func blockUser(member_id:Int64) {
        self.showLoadingView()
        APIs.blockUser(member_id: member_id, blocker_id: thisUser.idx, handleCallback: { [self]
            result_code in
            self.dismissLoadingView()
            if result_code == "0" {
                showToast2(msg: "The user has been blocked.")
                self.getComments(me_id: thisUser.idx, post_id: gPost.idx)
            }
        })
    }
    
    func unblockUser(member_id:Int64) {
        self.showLoadingView()
        APIs.unblockUser(member_id: member_id, blocker_id: thisUser.idx, handleCallback: { [self]
            result_code in
            self.dismissLoadingView()
            if result_code == "0" {
                showToast2(msg: "The user has been unblocked.")
                self.getComments(me_id: thisUser.idx, post_id: gPost.idx)
            }
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.checkPlaceholder()
        if textView.text == ""{
            sendButton.visibilityh = .gone
        }else{
            sendButton.visibilityh = .visible
        }
    }
    
    func getComments(me_id:Int64, post_id:Int64){
        self.showLoadingView()
        APIs.getComments(me_id: me_id, post_id: post_id, handleCallback: {
            comments, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                
                self.comments = comments!
                
                if comments!.count == 0 {
                    self.noResult.isHidden = false
                }else {
                    self.noResult.isHidden = true
                }
                
                self.commentList.reloadData()

            }else{
                if result_code == "1" {
                    self.showToast(msg: "The post doesn\'t exist.")
                }else if result_code == "101"{
                    self.showToast(msg:"This post user has already been blocked.")
                    self.dismiss(animated: true, completion: nil)
                }else if result_code == "102"{
                    self.showToast(msg:"You have already been blocked by this post user.")
                    self.dismiss(animated: true, completion: nil)
                }else {
                    self.showToast(msg: "Something wrong!")
                }
            }
        })
    }
    
    @IBAction func openCamera(_ sender: Any) {
//        self.view_emoji.visibility = .visible
        self.isEmoji = true
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
        commentBox.inputView = emojiView
        commentBox.reloadInputViews()
        commentBox.becomeFirstResponder()
        
    }
    
    @IBAction func submitComment(_ sender: Any) {
        if commentBox.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showToast(msg: "Please type something...")
            return
        }
                
        let parameters: [String:Any] = [
            "member_id" : String(thisUser.idx),
            "post_id" : String(gPost.idx),
            "content" : commentBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).encodeEmoji as Any,
        ]
                
        self.showLoadingView()
        APIs().registerWithoutPicture(withUrl: SERVER_URL + "submitcomment", withParam: parameters) { (isSuccess, response) in
            // Your Will Get Response here
            self.dismissLoadingView()
            print("Response: \(response)")
            if isSuccess == true{
                let result_code = response["result_code"] as Any
                if result_code as! String == "0"{
                    self.getComments(me_id:thisUser.idx, post_id: gPost.idx)
                    self.commentBox.text = ""
                    self.commentBox.resignFirstResponder()
                    self.commentBox.checkPlaceholder()
                    self.sendButton.visibilityh = .gone
                    self.imageFile = nil
                    if recent == gHomeViewController{
                        gHomeViewController.getPosts(member_id:thisUser.idx)
                    }else if recent == gImagePageViewController {
                        let mycomments = self.comments.filter{comment in
                            return comment.user === thisUser
                        }
                        if mycomments.count == 0 {
                            gPost.comments = gPost.comments + 1
                            gImagePageViewController.commentButton.setImage(UIImage(named: "ic_commented"), for: .normal)
                            gImagePageViewController.lbl_comments.text = String(gPost.comments)
                        }
                    }else if recent == gVideoPlayViewController {
                        let mycomments = self.comments.filter{comment in
                            return comment.user === thisUser
                        }
                        if mycomments.count == 0 {
                            gPost.comments = gPost.comments + 1
                            gVideoPlayViewController.commentButton.setImage(UIImage(named: "ic_commented"), for: .normal)
                            gVideoPlayViewController.commentButton.setImageTintColor(.white)
                            gVideoPlayViewController.lbl_comments.text = String(gPost.comments)
                        }
                    }
                }else if result_code as! String == "1"{
                    self.showToast(msg: "This user doesn\'t exist.")
                    self.logout()
                }else if result_code as! String == "2"{
                    self.showToast(msg: "This post doesn\'t exist.")
                    if recent == gHomeViewController{
                        gHomeViewController.getPosts(member_id:thisUser.idx)
                    }
                    self.dismiss(animated: true, completion: nil)
                }else if result_code as! String == "101"{
                    self.showToast(msg:"This post user has already been blocked.")
                    self.dismiss(animated: true, completion: nil)
                }else if result_code as! String == "102"{
                    self.showToast(msg:"You have already been blocked by this post user.")
                    self.dismiss(animated: true, completion: nil)
                }else {
                    self.showToast(msg: "Something wrong")
                }
            }else{
                let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
                self.showToast(msg: "Issue: \n" + message)
            }
        }
                
    }
    
    func deleteComment(comment_id: Int64){
        self.showLoadingView()
        APIs.deleteComment(comment_id: comment_id, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "Deleted")
                self.getComments(me_id:thisUser.idx, post_id: gPost.idx)
                if recent == gHomeViewController {
                    gHomeViewController.getPosts(member_id:thisUser.idx)
                }else if recent == gImagePageViewController {
                    gPost.comments = gPost.comments - 1
                    if gPost.comments > 0 {
                        gImagePageViewController.commentButton.setImage(UIImage(named: "ic_commented"), for: .normal)
                    }else {
                        gImagePageViewController.commentButton.setImage(UIImage(named: "ic_comment"), for: .normal)
                    }
                    gImagePageViewController.commentButton.setImageTintColor(.white)
                    gImagePageViewController.lbl_comments.text = String(gPost.comments)
                }else if recent == gVideoPlayViewController {
                    gPost.comments = gPost.comments - 1
                    if gPost.comments > 0 {
                        gVideoPlayViewController.commentButton.setImage(UIImage(named: "ic_commented"), for: .normal)
                    }else {
                        gVideoPlayViewController.commentButton.setImage(UIImage(named: "ic_comment"), for: .normal)
                    }
                    gVideoPlayViewController.commentButton.setImageTintColor(.white)
                    gVideoPlayViewController.lbl_comments.text = String(gPost.comments)
                }
            }else if result_code == "1"{
                self.showToast(msg: "This comment doesn\'t exist")
                self.getComments(me_id:thisUser.idx, post_id: gPost.idx)
            }else {
                self.showToast(msg:"Something wrong")
            }
        })
    }
    
    // callback when tap a emoji on keyboard
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        commentBox.insertText(emoji)
    }

    // callback when tap change keyboard button on keyboard
    func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
        commentBox.inputView = nil
        commentBox.keyboardType = .default
        commentBox.reloadInputViews()
    }
        
    // callback when tap delete button on keyboard
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        commentBox.deleteBackward()
    }

    // callback when tap dismiss button on keyboard
    func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
        print("dismiss keyboard")
        commentBox.resignFirstResponder()
    }
    
}
