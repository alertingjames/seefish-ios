//
//  OtherRoutesViewController.swift
//  See Fish
//
//  Created by james on 9/5/23.
//

import UIKit
import Alamofire
import SwiftyJSON

class OtherRoutesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var listView: UITableView!
    @IBOutlet weak var noResult: UILabel!
    
    var routes = [Route]()
    var allRoutes = [Route]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        recent = self
        gOtherRoutesViewController = self
        getRoutes()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UserRouteCell = tableView.dequeueReusableCell(withIdentifier: "UserRouteCell", for: indexPath) as! UserRouteCell
        let index:Int = indexPath.row
        if routes.indices.contains(index) {
            let route = routes[index]
            
            if route.user.photo_url != "" {
                loadPicture(imageView: cell.userPicture, url: URL(string: route.user.photo_url)!)
            }
            cell.userPicture.layer.cornerRadius = cell.userPicture.frame.width / 2
            cell.userNameBox.text = route.user.name
            cell.userCityBox.text = route.user.city
            
            cell.nameBox.text = route.name
            cell.timeBox.text = getDateTimeFromTimeStamp(timeStamp: Double(route.start_time)!/1000) + " ~ " + getDateTimeFromTimeStamp(timeStamp: Double(route.end_time)!/1000)
            cell.durationBox.text = getDurationFromMilliseconds(ms: route.duration)
//            cell.distanceBox.text = String(format: "%.2f", route.distance) + "km"
            cell.distanceBox.text = String(format: "%.2f", route.distance * ratioKMToMILE) + "mi"
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
            gRouteListViewController.showLoadingView()
            APIs.getRouteDetails(route_id: gRoute.idx, handleCallback: {
                route, points, result_code in
                gRouteListViewController.dismissLoadingView()
                print("Saved traces: \(points!.count)")
                print(result_code)
                if result_code == "0"{
                    gRoute = route!
                    gPoints = points!
                    if gRoute.status == "" {
                        self.to(strb: "Main2", vc: "LocationSharingViewController", trans: false, modal: false, anim: true)
                    }else {
                        self.to(strb: "Main2", vc: "RouteDetailViewController", trans: false, modal: false, anim: true)
                    }
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
    
    
    func getRoutes() {
        let params = [
            "me_id": String(thisUser.idx),
        ] as [String : Any]
        Alamofire.request(SERVER_URL + "getFolroutes", method: .post, parameters: params).responseJSON { response in
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
                        let routeData = data["route"] as! [String: Any]
                        let route = Route()
                        route.idx = routeData["id"] as! Int64
                        route.user_id = Int64(routeData["member_id"] as! String)!
                        route.name = routeData["name"] as! String
                        route.description = routeData["description"] as! String
                        route.start_time = routeData["start_time"] as! String
                        route.end_time = routeData["end_time"] as! String
                        route.duration = Int64(routeData["duration"] as! String)!
                        route.distance = Double(routeData["distance"] as! String)!
                        route.created_on = routeData["created_on"] as! String
                        route.status = routeData["status"] as! String
                        
                        let userData = data["member"] as! [String: Any]
                        let user = User()
                        user.idx = userData["id"] as! Int64
                        user.name = userData["name"] as! String
                        user.email = userData["email"] as! String
                        user.photo_url = userData["photo_url"] as! String
                        user.phone_number = userData["phone_number"] as! String
                        user.city = userData["city"] as! String
                        
                        route.user = user
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



