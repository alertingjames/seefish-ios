//
//  UserProfileViewController.swift
//  See Fish
//
//  Created by Andre on 11/8/20.
//

import UIKit
import DropDown
import SJSegmentedScrollView

class UserProfileViewController: BaseViewController {
    
    var headerController:ProfileHeaderViewController!
    var followersController:FollowersViewController!
    var followingsController:FollowingsViewController!
    var postsController:UserPostsViewController!
    
    @IBOutlet weak var view_container: UIView!
    @IBOutlet weak var btn_menu: UIButton!
    
    var selectedSegment: SJSegmentTab?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let storyboard = self.storyboard {

            headerController = storyboard
                .instantiateViewController(withIdentifier: "ProfileHeaderViewController") as? ProfileHeaderViewController

            followersController = storyboard
                .instantiateViewController(withIdentifier: "FollowersViewController") as? FollowersViewController
            followersController.title = "Followers"

            followingsController = storyboard
                .instantiateViewController(withIdentifier: "FollowingsViewController") as? FollowingsViewController
            followingsController.title = "Followings"
            
            postsController = storyboard
                .instantiateViewController(withIdentifier: "UserPostsViewController") as? UserPostsViewController
            postsController.title = "Feeds"
            
            let segmentedViewController = SJSegmentedViewController(headerViewController: headerController,
            segmentControllers: [
                postsController,
                followersController,
                followingsController])
            
            segmentedViewController.headerViewHeight = UIScreen.main.bounds.width * 4.1/5
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
        }
        
        super.viewDidLoad()
        
//        btn_menu.setImageTintColor(.white)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recent = self
        gUserProfileViewController = self
    }
    
    var isFollowing:Bool = false
    
    @IBAction func openMenu(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.anchorView = btn_menu
        var menu = [ "  Message", "  Block", "  Report"]
        if isFollowing { menu = [ "  Shared Routes", "  Message", "  Block", "  Report"] }
        dropDown.dataSource = menu
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
            print("Selected item: \(item) at index: \(idx)")
            if isFollowing {
                if idx == 0 {
                    self.to(strb: "Main2", vc: "UserRouteHistoryViewController", trans: false, modal: false, anim: true)
                }else if idx == 1 {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SendMessageViewController")
                    self.present(vc, animated: true, completion: nil)
                }else if idx == 2 {
                    showDialog(message: "Are you sure you want to block this user?")
                }else if idx == 3 {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ReportViewController")
                    self.present(vc, animated: true, completion: nil)
                }
            }else {
                if idx == 0 {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SendMessageViewController")
                    self.present(vc, animated: true, completion: nil)
                }else if idx == 1 {
                    showDialog(message: "Are you sure you want to block this user?")
                }else if idx == 2 {
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
        dropDown.width = 150
        
        dropDown.show()
    }
    
    var dialog:AlertDialog!
    
    func showDialog(message:String) {
        let msg = """
        Are you sure you want to block
        this user?
        """
        let alert = UIAlertController(title: "Warning", message: msg, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .destructive){(ACTION) in
            alert.dismiss(animated: true, completion: nil)
        }
        let yesAction = UIAlertAction(title: "Yes", style: .cancel){(ACTION) in
            self.blockMember(member_id: gUser.idx)
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        self.present(alert, animated:true, completion:nil)
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 0
    }
    
    func blockMember(member_id:Int64) {
        self.showLoadingView()
        APIs.blockUser(member_id: member_id, blocker_id: thisUser.idx, handleCallback: { [self]
            result_code in
            self.dismissLoadingView()
            if result_code == "0" {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension UserProfileViewController: SJSegmentedViewControllerDelegate {

    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {

        if selectedSegment != nil {
            selectedSegment?.titleColor(.lightGray)
        }
        
    }
}
