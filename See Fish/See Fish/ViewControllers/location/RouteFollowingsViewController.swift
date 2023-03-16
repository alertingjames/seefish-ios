//
//  RouteFollowingsViewController.swift
//  See Fish
//
//  Created by james on 12/12/22.
//

import UIKit
import Alamofire
import SwiftyJSON

class RouteFollowingsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var listView: UITableView!
    @IBOutlet weak var noResult: UILabel!
    
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        listView.delegate = self
        listView.dataSource = self
        listView.estimatedRowHeight = 110.0
        listView.rowHeight = UITableView.automaticDimension
        
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        gRouteFollowingsViewController = self
        UserDefaults.standard.set(0, forKey: "actionID")
        getRouteFollowings(me_id: thisUser.idx)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CommentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        let index:Int = indexPath.row
        if users.indices.contains(index) {
            let user = users[index]
            if user.photo_url != "" {
                loadPicture(imageView: cell.userPicture, url: URL(string: user.photo_url)!)
            }            
            cell.userPicture.layer.cornerRadius = cell.userPicture.frame.width / 2
            cell.userNameBox.text = user.name
            cell.userCityBox.text = user.city
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tappedItem(gesture:)))
            cell.contentLayout.isUserInteractionEnabled = true
            cell.contentLayout.addGestureRecognizer(tap)
            
            cell.contentLayout.sizeToFit()
            cell.contentLayout.layoutIfNeeded()
        }
        return cell
        
    }
    
    @objc func tappedItem(gesture:UITapGestureRecognizer) {
        if let index = gesture.view?.tag {
            gUser = users[index]
            self.to(strb: "Main2", vc: "UserRouteHistoryViewController", trans: false, modal: false, anim: true)
        }        
    }
    
    func getRouteFollowings(me_id:Int64){
        self.showLoadingView()
        APIs.getRouteFollowings(me_id:me_id, handleCallback: {
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
                self.listView.reloadData()
            }
            else if result_code == "1" {
                self.logout()
            }else {
                self.showToast(msg: "SERVER ERROR 500!")
            }
        })
    }
    
    
}
