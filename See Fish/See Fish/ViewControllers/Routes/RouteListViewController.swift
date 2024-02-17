//
//  RouteListViewController.swift
//  See Fish
//
//  Created by james on 9/5/23.
//

import UIKit
import SJSegmentedScrollView

class RouteListViewController: BaseViewController {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var view_search: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var btn_share: UIButton!
    
    var headerController:RouteListHeaderViewController!
    var myRoutesController:MyRoutesViewController!
    var otherRoutesController:OtherRoutesViewController!
    
    var selectedSegment: SJSegmentTab?
    var segmentedViewController:SJSegmentedViewController!
    
    var currentTab:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        gRouteListViewController = self
        
        let storyboard = UIStoryboard(name: "Routes", bundle: nil)

        headerController = storyboard
            .instantiateViewController(withIdentifier: "RouteListHeaderViewController") as? RouteListHeaderViewController

        myRoutesController = storyboard
            .instantiateViewController(withIdentifier: "MyRoutesViewController") as? MyRoutesViewController
        myRoutesController.title = "Mine"
        
        otherRoutesController = storyboard
            .instantiateViewController(withIdentifier: "OtherRoutesViewController") as? OtherRoutesViewController
        otherRoutesController.title = "Others"
        
        segmentedViewController = SJSegmentedViewController(headerViewController: headerController,
        segmentControllers: [
            myRoutesController,
            otherRoutesController])
        
        segmentedViewController.headerViewHeight = 0
        segmentedViewController.segmentViewHeight = 40.0
        segmentedViewController.selectedSegmentViewHeight = 2.5
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
        segmentedViewController.segmentShadow = SJShadow.light()

        segmentedViewController.delegate = self
        
        self.addChild(segmentedViewController)
        self.container.addSubview(segmentedViewController.view)
        segmentedViewController.view.frame = self.container.bounds
        segmentedViewController.didMove(toParent: self)
        
        super.viewDidLoad()
        
        view_search.isHidden = true
        edt_search.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        edt_search.underlined()       
        
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func openSearch(_ sender: Any) {
        if view_search.isHidden{
            view_search.isHidden = false
            btn_search.setImage(UIImage(named: "ic_close"), for: .normal)
            lbl_title.isHidden = true
            edt_search.becomeFirstResponder()
            
        }else{
            view_search.isHidden = true
            btn_search.setImage(UIImage(named: "ic_search"), for: .normal)
            lbl_title.isHidden = false
            self.edt_search.text = ""
            edt_search.resignFirstResponder()
        }
    }
    
    var routes = [Route]()
    var allRoutes = [Route]()
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        routes = filter(keyword: (textField.text?.lowercased())!)
        switch currentTab {
        case 0:
            myRoutesController.noResult.isHidden = !routes.isEmpty
            myRoutesController.routes = routes
            myRoutesController.listView.reloadData()
            break
        case 1:
            otherRoutesController.noResult.isHidden = !routes.isEmpty
            otherRoutesController.routes = routes
            otherRoutesController.listView.reloadData()
            break
        default:
            myRoutesController.noResult.isHidden = !routes.isEmpty
            myRoutesController.routes = routes
            myRoutesController.listView.reloadData()
        }
    }
    
    func filter(keyword:String) -> [Route]{
        if keyword == "" {
            switch currentTab {
            case 0: return myRoutesController.allRoutes
            case 1: return otherRoutesController.allRoutes
            default: return myRoutesController.allRoutes
            }
        }
        
        allRoutes = getTabRoutes()
        
        var filteredEntities = [Route]()
        for route in allRoutes {
            if route.name.lowercased().contains(keyword){
                filteredEntities.append(route)
            } else {
                if route.user.name.lowercased().contains(keyword){
                    filteredEntities.append(route)
                }
            }
        }
        return filteredEntities
    }
    
    func getTabRoutes() -> [Route] {
        switch currentTab {
        case 0: return myRoutesController.allRoutes
        case 1: return otherRoutesController.allRoutes
        default: return myRoutesController.allRoutes
        }
    }
    
    @IBAction func shareLocation(_ sender: Any) {
        gPoints.removeAll()
        self.to(strb: "Main2", vc: "LocationSharingViewController", trans: false, modal: false, anim: true)
    }
    
}


extension RouteListViewController: SJSegmentedViewControllerDelegate {
    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {
        if selectedSegment != nil {
            selectedSegment?.titleColor(.lightGray)
        }
        print("Segment index ===> \(index)")
        currentTab = index
    }
}
