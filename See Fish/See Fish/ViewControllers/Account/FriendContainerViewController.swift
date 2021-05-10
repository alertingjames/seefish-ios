//
//  MyFriendsViewController.swift
//  See Fish
//
//  Created by Andre on 11/10/20.
//

import UIKit
import SJSegmentedScrollView

class FriendContainerViewController: BaseViewController {
    
    var headerController:MyFriendHeaderViewController!
    var followersController:MyFollowersViewController!
    var followingsController:MyFollowingsViewController!
    
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
        }
        
        
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension FriendContainerViewController: SJSegmentedViewControllerDelegate {

    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {

        if selectedSegment != nil {
            selectedSegment?.titleColor(.lightGray)
        }
        
    }
}
