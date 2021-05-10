//
//  SearchViewController.swift
//  See Fish
//
//  Created by Andre on 11/3/20.
//

import UIKit
import AVFoundation
import AVKit
import GSImageViewerController

class SearchViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var userList: UICollectionView!
    @IBOutlet weak var postList: UICollectionView!
    @IBOutlet weak var noResult: UILabel!
    @IBOutlet weak var btn_all: UIButton!
    @IBOutlet weak var btn_video: UIButton!
    @IBOutlet weak var btn_photo: UIButton!
    @IBOutlet weak var btn_filter: UIButton!
    
    var posts = [Post]()
    var searchPosts = [Post]()
    var users = [User]()
    
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 3,
        minimumInteritemSpacing: 5,
        minimumLineSpacing: 5,
        sectionInset: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    )
    
    var btnArray = [UIButton]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recent = self
        gSearchViewController = self

        self.postList?.collectionViewLayout = columnLayout
        self.postList?.contentInsetAdjustmentBehavior = .always
        
        btnArray = [btn_all, btn_video, btn_photo, btn_filter]
        
        btn_all.isHidden = true
        btn_video.isHidden = true
        btn_photo.isHidden = true
        btn_filter.isHidden = true
        
        updateSelectedButtonUI(selectedButton: btnArray[0])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getAllMembers(member_id: thisUser.idx)
        self.getPosts(member_id: thisUser.idx)
        gFishViewController.image = nil
    }
    
    func updateSelectedButtonUI(selectedButton: UIButton) {
        for button in btnArray {
            button.layer.cornerRadius = self.btn_all.frame.height / 2
            button.layer.backgroundColor = primaryMainLightColor.cgColor
            button.setTitleColor(primaryDarkColor, for: .normal)
        }
        selectedButton.layer.backgroundColor = primaryColor.cgColor
        selectedButton.setTitleColor(.white, for: .normal)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.userList {
            return self.users.count
        }else if collectionView == self.postList {
            return self.posts.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.userList {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostUserCell", for: indexPath) as! PostUserCell
            
            self.userList.backgroundColor = .clear
            cell.backgroundColor = .clear
            
            let index:Int = indexPath.row
            if users.indices.contains(index) {
                let user = self.users[index]
                if user.photo_url.count > 0 {
                    loadPicture(imageView: cell.img_user, url: URL(string: user.photo_url)!)
                }
                cell.img_user.layer.cornerRadius = cell.img_user.frame.height / 2
                cell.img_user.layer.borderWidth = 0
                cell.lbl_name.text = user.name
            }
            
            return cell
            
        }else if collectionView == self.postList {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchFeedCell", for: indexPath) as! SearchFeedCell
                    
            let index:Int = indexPath.row
            if posts.indices.contains(index) {
                let post = self.posts[index]
                
                if post.picture_url != "" {
                    loadPicture(imageView: cell.img_post, url: URL(string: post.picture_url)!)
                }
                
                if post.video_url != ""{
                    cell.img_videomark.isHidden = false
                }else {
                    cell.img_videomark.isHidden = true
                }
                    
            }
            
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "SearchFeedCell", for: indexPath) as! SearchFeedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.userList {
            if let cell = collectionView.cellForItem(at: indexPath) as? PostUserCell {
                
                let index:Int = indexPath.row
                if users.indices.contains(index) {
                    let user = self.users[index]
                    let cells = collectionView.visibleCells
                    for cell in cells {
                        let userCell = cell as! PostUserCell
                        userCell.img_user.layer.borderWidth = 0
                    }
                    cell.img_user.layer.borderWidth = 1.5
                    cell.img_user.layer.borderColor = UIColor.red.cgColor
                    
                    gUser = user
                    let vc = self.storyboard?.instantiateViewController(identifier: "UserProfileViewController")
                    vc?.modalPresentationStyle = .fullScreen
                    self.present(vc!, animated: true, completion: nil)
                }
            }
        }else if collectionView == self.postList {
            if let cell = collectionView.cellForItem(at: indexPath) as? SearchFeedCell {
                let index:Int = indexPath.row
                if posts.indices.contains(index) {
                    let post = self.posts[index]
                    
                    if post.video_url.count > 0 {
                        gPost = post
                        let videoVC = self.storyboard?.instantiateViewController(identifier: "VideoPlayViewController")
                        videoVC?.modalPresentationStyle = .fullScreen
                        self.present(videoVC!, animated: false, completion: nil)
                    }else {
                        self.getPostPictures(post: post, imageView: cell.img_post)
                    }
                        
                }
            }
        }
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
    
    func getAllMembers(member_id:Int64){
//        self.showLoadingView()
        APIs.getallmembers(member_id: member_id, handleCallback: {
            users, result_code in
//            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                
                self.users = users!
                
                if users!.count == 0 {
                    self.noResult.isHidden = false
                }
                
                self.userList.reloadData()
                
            }
            else{
                if result_code == "1" {
                    self.logout()
                }else if result_code == "2" {
                    /// cohort is empty and update profile //////////////////////////////
                }else {
                    self.showToast(msg: "Something wrong!")
                }
            }
        })
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
                
                if posts!.count > 0 {
                    self.btn_all.isHidden = false
                    self.btn_video.isHidden = false
                    self.btn_photo.isHidden = false
                    self.btn_filter.isHidden = false
                }else {
                    self.btn_all.isHidden = true
                    self.btn_video.isHidden = true
                    self.btn_photo.isHidden = true
                    self.btn_filter.isHidden = true
                }
                
                self.posts = posts!
                self.searchPosts = posts!
                
                if self.posts.count == 0 {
                    self.noResult.isHidden = false
                }else {
                    self.noResult.isHidden = true
                }
                
                self.postList.reloadData()

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
    
    @IBAction func getAll(_ sender: Any) {
        updateSelectedButtonUI(selectedButton: btnArray[0])
        refreshPosts(posts: self.searchPosts)
    }
    
    @IBAction func getVideos(_ sender: Any) {
        updateSelectedButtonUI(selectedButton: btnArray[1])
        let videos = self.searchPosts.filter{post in
            return post.video_url.count > 0
        }
        refreshPosts(posts: videos)
    }
    
    @IBAction func getPhotos(_ sender: Any) {
        updateSelectedButtonUI(selectedButton: btnArray[2])
        let photos = self.searchPosts.filter{post in
            return post.video_url.count == 0
        }
        refreshPosts(posts: photos)
    }
    
    @IBAction func filter(_ sender: Any) {
        updateSelectedButtonUI(selectedButton: btnArray[3])
    }
    
    func refreshPosts(posts:[Post]) {
        self.posts = posts
        if self.posts.count == 0 {
            self.noResult.isHidden = false
        }else {
            self.noResult.isHidden = true
        }
        self.postList.reloadData()
    }
}
