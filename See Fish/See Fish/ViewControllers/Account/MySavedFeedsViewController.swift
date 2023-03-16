//
//  MySavedFeedsViewController.swift
//  See Fish
//
//  Created by Andre on 11/10/20.
//

import UIKit
import AVFoundation
import AVKit
import GSImageViewerController

class MySavedFeedsViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var postList: UICollectionView!
    @IBOutlet weak var noResult: UILabel!
    
    var posts = [Post]()
    var searchPosts = [Post]()
    
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 3,
        minimumInteritemSpacing: 5,
        minimumLineSpacing: 5,
        sectionInset: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        self.postList?.collectionViewLayout = columnLayout
        self.postList?.contentInsetAdjustmentBehavior = .always
        
        self.postList.dataSource = self
        self.postList.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMySavedFeeds()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    
    func getMySavedFeeds(){
        self.showLoadingView()
        APIs.getSavedFeeds(member_id: thisUser.idx, handleCallback: { [self]
            saveds, result_code in
            self.dismissLoadingView()
            if result_code == "0" {
                posts.removeAll()
                searchPosts.removeAll()
                for sv in saveds! {
                    let ps = gHomeViewController.searchPosts.filter{ post in
                        return post.idx == sv.post_id
                    }
                    if ps.count > 0 {
                        let p = ps[0]
                        posts.append(p)
                        searchPosts.append(p)
                    }
                }
                if self.posts.count == 0 {
                    self.noResult.isHidden = false
                }else {
                    self.noResult.isHidden = true
                }
                self.postList.reloadData()
                
            }else {
                self.showToast(msg:"Something wrong")
            }
        })
        
    }
    

}
