//
//  FollowingsViewController.swift
//  See Fish
//
//  Created by Andre on 11/8/20.
//

import UIKit

class FollowingsViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var userList: UICollectionView!
    @IBOutlet weak var noResult: UILabel!
    
    var searchUsers = [User]()
    var users = [User]()
    
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 3,
        minimumInteritemSpacing: 5,
        minimumLineSpacing: 5,
        sectionInset: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    )
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.userList?.collectionViewLayout = columnLayout
        self.userList?.contentInsetAdjustmentBehavior = .always
        
        self.userList.dataSource = self
        self.userList.delegate = self
        
//        self.userList.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getFollowings(me_id: thisUser.idx, member_id: gUser.idx)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileFollowerCell", for: indexPath) as! ProfileFollowerCell
        
        self.userList.backgroundColor = .clear
        cell.backgroundColor = .clear
        
        let index:Int = indexPath.row
        if users.indices.contains(index) {
            let user = self.users[index]
            if user.photo_url.count > 0 {
                loadPicture(imageView: cell.img_user, url: URL(string: user.photo_url)!)
            }
            cell.lbl_name.text = user.name
            cell.lbl_city.text = user.city
            
            cell.frame.size.height = 200
            
            cell.sizeToFit()
            cell.layoutIfNeeded()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index:Int = indexPath.row
        if users.indices.contains(index) {
            let user = self.users[index]
            
            if user.idx != thisUser.idx {
                gUser = user
                let vc = self.storyboard?.instantiateViewController(identifier: "UserProfileViewController")
                vc?.modalPresentationStyle = .fullScreen
                self.present(vc!, animated: true, completion: nil)
            }
        }
    }
    
    func getFollowings(me_id:Int64, member_id:Int64){
        self.showLoadingView()
        APIs.getFollowings(me_id:me_id, member_id: member_id, handleCallback: {
            users, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                
                self.users = users!
                
                if users!.count == 0 {
                    self.noResult.isHidden = false
                }else {
                    self.noResult.isHidden = true
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
    

}
