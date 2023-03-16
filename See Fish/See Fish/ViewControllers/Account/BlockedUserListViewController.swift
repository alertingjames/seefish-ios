//
//  BlockedUserListViewController.swift
//  See Fish
//
//  Created by Andre on 12/14/20.
//

import UIKit

class BlockedUserListViewController: BaseViewController , UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var userList: UICollectionView!
    @IBOutlet weak var noResult: UILabel!
    
    var searchUsers = [User]()
    var users = [User]()
    
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 2,
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
        self.getBlockedUsers(member_id: thisUser.idx)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BlockedUserCell", for: indexPath) as! BlockedUserCell
        
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
            
            cell.unblockButton.tag = index
            cell.unblockButton.addTarget(self, action: #selector(userUnblock), for: .touchUpInside)
            cell.frame.size.height = 250
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
    
    @objc func userUnblock(_ sender:UIButton) {
        let user = self.users[sender.tag]
        let msg = """
        Are you sure you want to
        unblock this user?
        """
        let alert = UIAlertController(title: "Warning", message: msg, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .destructive){(ACTION) in
            alert.dismiss(animated: true, completion: nil)
        }
        let yesAction = UIAlertAction(title: "Yes", style: .cancel){ [self](ACTION) in
            self.unblockUser(member_id: user.idx)
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        self.present(alert, animated:true, completion:nil)
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 0
    }
    
    func unblockUser(member_id:Int64) {
        self.showLoadingView()
        APIs.unblockUser(member_id: member_id, blocker_id: thisUser.idx, handleCallback: { [self]
            result_code in
            self.dismissLoadingView()
            if result_code == "0" {
                showToast2(msg: "The user has been unblocked.")
                getBlockedUsers(member_id: thisUser.idx)
            }
        })
    }
    
    func getBlockedUsers(member_id:Int64){
        self.showLoadingView()
        APIs.getBlockedUsers(member_id: member_id, handleCallback: {
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
                self.showToast(msg: "Something is wrong!")
            }
        })
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
