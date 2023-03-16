//
//  MainViewController.swift
//  See Fish
//
//  Created by Andre on 11/3/20.
//

import UIKit
import FluidTabBarController

class MainViewController: FluidTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gMainViewController = self
        
        self.tabBar.tintColor = primaryColor
        self.tabBar.backgroundColor = .white
        
        let homeVC = self.storyboard?.instantiateViewController(identifier: "HomeViewController")
        let searchVC = self.storyboard?.instantiateViewController(identifier: "SearchViewController")
        let addFeedVC = self.storyboard?.instantiateViewController(identifier: "AddFeedViewController")
        let fishVC = self.storyboard?.instantiateViewController(identifier: "FishViewController")
        let accountVC = self.storyboard?.instantiateViewController(identifier: "AccountViewController")
        
        gFishViewController = (fishVC as! FishViewController)
        
        let viewControllers = [
            createSampleViewController(title: "Home", icon: UIImage(named: "home")!, vc: homeVC!),
            createSampleViewController(title: "Search", icon: UIImage(named: "search")!, vc: searchVC!),
            createSampleViewController(title: "New Feed", icon: UIImage(named: "add")!, vc: addFeedVC!),
            createSampleViewController(title: "Fish", icon: UIImage(named: "fish")!, vc: fishVC!),
            createSampleViewController(title: "Account", icon: UIImage(named: "account")!, vc: accountVC!),
        ]
        
        self.setViewControllers(viewControllers, animated: true)
        
//        self.selectedIndex = 2
        
    }

    private func createSampleViewController(title: String, icon: UIImage, vc: UIViewController) -> UIViewController {
        let item = FluidTabBarItem(title: title, image: icon, tag: 0)
        item.imageColor = primaryLightColor
        vc.tabBarItem = item
        return vc
    }

    @IBAction func logOut(_ sender: Any) {
        UserDefaults.standard.set("", forKey: "email")
        UserDefaults.standard.set("", forKey: "password")
        thisUser.idx = 0
        let vc = self.storyboard!.instantiateViewController(identifier: "ViewController")
        self.transitionVc(vc: vc, duration: 0.3, type: .fromLeft)
    }

}
