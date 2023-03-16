//
//  MyFriendsViewController.swift
//  See Fish
//
//  Created by Andre on 11/10/20.
//

import UIKit
import SJSegmentedScrollView
import DropDown
import Alamofire
import SwiftyJSON

class FriendContainerViewController: BaseViewController {
    
    var headerController:MyFriendHeaderViewController!
    var followersController:MyFollowersViewController!
    var followingsController:MyFollowingsViewController!
    @IBOutlet weak var menuButton: UIButton!
    var isLatestRecordingEnded:Bool = true
    
    @IBOutlet weak var view_container: UIView!
    var selectedSegment: SJSegmentTab?

    override func viewDidLoad() {
        
        if let storyboard = self.storyboard {
            
            gFriendContainerViewController = self

            headerController = storyboard
                .instantiateViewController(withIdentifier: "MyFriendHeaderViewController") as? MyFriendHeaderViewController

            followersController = storyboard
                .instantiateViewController(withIdentifier: "MyFollowersViewController") as? MyFollowersViewController
            followersController.title = "Followers"

            followingsController = storyboard
                .instantiateViewController(withIdentifier: "MyFollowingsViewController") as? MyFollowingsViewController
            followingsController.title = "Followings"
            
            let segmentedViewController = SJSegmentedViewController(headerViewController: headerController,
            segmentControllers: [
                followersController,
                followingsController,
            ])
            
            segmentedViewController.headerViewHeight = UIScreen.main.bounds.width * 3/5
            segmentedViewController.segmentViewHeight = 40.0
            segmentedViewController.selectedSegmentViewHeight = 1.5
//            headerViewOffsetHeight = 50.0
            segmentedViewController.segmentBackgroundColor = .white
            segmentedViewController.segmentTitleColor = primaryLightColor
            segmentedViewController.segmentTitleFont = UIFont.systemFont(ofSize: 17.0)
            selectedSegment?.titleFont(UIFont.systemFont(ofSize: 19.0))
            segmentedViewController.segmentSelectedTitleColor = primaryColor
            segmentedViewController.selectedSegmentViewColor = primaryDarkColor
            segmentedViewController.segmentShadow = .init(offset: .zero, color: .clear, radius: 0, opacity: 0)
            segmentedViewController.showsHorizontalScrollIndicator = false
            segmentedViewController.showsVerticalScrollIndicator = false
            segmentedViewController.segmentBounces = false
//            segmentedViewController.segmentShadow = SJShadow.light()

            segmentedViewController.delegate = self
            
            self.addChild(segmentedViewController)
            self.view_container.addSubview(segmentedViewController.view)
            segmentedViewController.view.frame = self.view_container.bounds
            segmentedViewController.didMove(toParent: self)
            
            
            super.viewDidLoad()
            
            menuButton.setImageTintColor(.black)
            
        }        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkLatestRoute()
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openMenu(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.anchorView = menuButton
        var menu = ["  Share location route with followers", "  Browse location routes history"]
        if gHomeViewController.isLocationRecording || !self.isLatestRecordingEnded {
            menu = ["  Browse location routes history"]
        }
        dropDown.dataSource = menu
        dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
            if idx == 0 {
                if gHomeViewController.isLocationRecording || !self.isLatestRecordingEnded {
                    self.to(strb: "Main2", vc: "LocationRouteHistoryViewController", trans: false, modal: false, anim: true)
                }else {
                    gPoints.removeAll()
                    self.to(strb: "Main2", vc: "LocationSharingViewController", trans: false, modal: false, anim: true)
                }
            }else if idx == 1 {
                self.to(strb: "Main2", vc: "LocationRouteHistoryViewController", trans: false, modal: false, anim: true)
            }
        }
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.red
        DropDown.appearance().textFont = UIFont.boldSystemFont(ofSize: 13.0)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray
        DropDown.appearance().cellHeight = 40
        
        dropDown.separatorColor = UIColor.lightGray
        dropDown.width = 250
        
        dropDown.show()
    }
    
    func checkLatestRoute() {
        let params = [
            "member_id": String(thisUser.idx),
        ] as [String : Any]
        Alamofire.request(SERVER_URL + "getmyroutes", method: .post, parameters: params).responseJSON { response in
            if gRouteList.isEmpty { self.dismissLoadingView() }
            if response.result.isFailure{
//                self.showAlertDialog(title: "Notice", message: "SERVER ERROR 500")
            } else {
                let json = JSON(response.result.value!)
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    if dataArray.count > 0 {
                        let data = dataArray.first
                        if data!["status"] as! String == "" {
                            self.isLatestRecordingEnded = false
                        }else {
                            self.isLatestRecordingEnded = true
                        }
                    }
                }
            }
        }
    }
    
}

extension FriendContainerViewController: SJSegmentedViewControllerDelegate {

    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {

        if selectedSegment != nil {
            selectedSegment?.titleColor(.lightGray)
        }
        
    }
}
