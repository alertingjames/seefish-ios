//
//  UserLocationHistoryViewController.swift
//  See Fish
//
//  Created by james on 12/11/22.
//

import UIKit
import Alamofire
import SwiftyJSON

class UserRouteHistoryViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var listView: UITableView!
    @IBOutlet weak var view_search: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var noResult: UILabel!
    
    var routes = [Route]()
    var allRoutes = [Route]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view_search.isHidden = true
        edt_search.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        edt_search.underlined()
        
        listView.delegate = self
        listView.dataSource = self
        listView.estimatedRowHeight = 60.0
        listView.rowHeight = UITableView.automaticDimension
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor(rgb: 0x0BFFFF, alpha: 1.0) ]
        
        routes.removeAll()
        allRoutes.removeAll()
        if !gRouteList.isEmpty {
            for route in gRouteList {
                routes.append(route)
                allRoutes.append(route)
            }
            noResult.isHidden = !routes.isEmpty
        }
        listView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserRoutes()
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
            routes = filter(keyword: "")
            noResult.isHidden = !routes.isEmpty
            listView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RouteCell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath) as! RouteCell
        let index:Int = indexPath.row
        if routes.indices.contains(index) {
            let route = routes[index]
            cell.nameBox.text = route.name
            cell.timeBox.text = getDateTimeFromTimeStamp(timeStamp: Double(route.start_time)!/1000) + " ~ " + getDateTimeFromTimeStamp(timeStamp: Double(route.end_time)!/1000)
            cell.durationBox.text = getDurationFromMilliseconds(ms: route.duration)
            cell.distanceBox.text = String(format: "%.2f", route.distance) + "km"
            cell.descBox.text = route.description
            if route.description.count > 0 {
                cell.descBox.visibility = .visible
            }else {
                cell.descBox.visibility = .gone
            }
            cell.container.tag = index
            let tap = UITapGestureRecognizer(target: self, action: #selector(tappedItem(gesture:)))
            cell.container.addGestureRecognizer(tap)
                
            cell.descBox.sizeToFit()
            cell.timeBox.sizeToFit()
            cell.container.sizeToFit()
            cell.container.layoutIfNeeded()
            
            cell.statusBox.layer.cornerRadius = 3
            if route.status.count > 0 {
                cell.statusBox.isHidden = true
            }else{
                cell.statusBox.text = "BUSY"
                cell.statusBox.isHidden = false
            }
        }
        return cell
        
    }
    
    @objc func tappedItem(gesture:UITapGestureRecognizer) {
        if let index = gesture.view?.tag {
            gRoute = routes[index]
            self.showLoadingView()
            APIs.getRouteDetails(route_id: gRoute.idx, handleCallback: {
                route, points, result_code in
                self.dismissLoadingView()
                print("Saved traces: \(points!.count)")
                print(result_code)
                if result_code == "0" {
                    gPoints = points!
                    self.to(strb: "Main2", vc: "RouteDetailViewController", trans: false, modal: false, anim: true)
                } else {
                    self.showToast(msg: "SERVER ERROR 500")
                }
            })
        }
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        routes = filter(keyword: (textField.text?.lowercased())!)
        noResult.isHidden = !routes.isEmpty
        listView.reloadData()
    }
        
    func filter(keyword:String) -> [Route]{
        if keyword == ""{
            return allRoutes
        }
        var filteredData = [Route]()
        for route in allRoutes {
            if route.name.lowercased().contains(keyword){
                filteredData.append(route)
            }
        }
        return filteredData
    }
    
    
    func getUserRoutes() {
        if gRouteList.isEmpty { showLoadingView() }
        let params = [
            "member_id": String(gUser.idx),
        ] as [String : Any]
        Alamofire.request(SERVER_URL + "getmyroutes", method: .post, parameters: params).responseJSON { response in
            if gRouteList.isEmpty { self.dismissLoadingView() }
            if response.result.isFailure{
                self.showAlertDialog(title: "Notice", message: "SERVER ERROR 500")
            } else {
                let json = JSON(response.result.value!)
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    self.routes.removeAll()
                    self.allRoutes.removeAll()
                    for data in dataArray {
                        let route = Route()
                        route.idx = data["id"] as! Int64
                        route.user_id = Int64(data["member_id"] as! String)!
                        route.name = data["name"] as! String
                        route.description = data["description"] as! String
                        route.start_time = data["start_time"] as! String
                        route.end_time = data["end_time"] as! String
                        route.duration = Int64(data["duration"] as! String)!
                        route.distance = Double(data["distance"] as! String)!
                        route.created_on = data["created_on"] as! String
                        route.status = data["status"] as! String
                        self.routes.append(route)
                        self.allRoutes.append(route)
                    }
                    gRouteList = self.allRoutes
                    self.noResult.isHidden = !self.routes.isEmpty
                    self.listView.reloadData()
                } else {
                    self.showAlertDialog(title: "Notice", message: "SERVER ERROR 500")
                }
                
            }
        }
    }
    


}



