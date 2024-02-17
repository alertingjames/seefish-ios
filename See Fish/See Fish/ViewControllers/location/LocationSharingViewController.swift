//
//  LocationSharingViewController.swift
//  See Fish
//
//  Created by james on 12/6/22.
//

import UIKit
import SwiftyJSON
import Alamofire
import GoogleMaps
import GooglePlaces
import CoreLocation
import DropDown
import AddressBookUI
import Network

class LocationSharingViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    var manager = CLLocationManager()
    var map = GMSMapView()
    var thisUserLocation:CLLocationCoordinate2D? = nil
    var camera: GMSCameraPosition? = nil
    var timer = Timer()
    
    @IBOutlet weak var viewForGMap: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var durationBox: UILabel!
    @IBOutlet weak var distanceBox: UILabel!
    @IBOutlet weak var panel: UIView!
    
    var polylines = [GMSPolyline]()
    
    var routeSaveBox:RouteSaveBox!
    var questionDialog:QuestionDialog!
    var locationLoadingDialog:LocationLoadingDialog!
    var mLoading:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gLocationSharingViewController = self
        
        self.thisUserLocation = gHomeViewController.thisUserLocation
        
        routeSaveBox = (UIStoryboard(name: "Main3", bundle: nil).instantiateViewController(withIdentifier: "RouteSaveBox") as! RouteSaveBox)
        questionDialog = (UIStoryboard(name: "Main3", bundle: nil).instantiateViewController(withIdentifier: "QuestionDialog") as! QuestionDialog)
        locationLoadingDialog = (UIStoryboard(name: "Main3", bundle: nil).instantiateViewController(withIdentifier: "LocationLoadingDialog") as! LocationLoadingDialog)
        
        startButton.backgroundColor = UIColor.systemCyan
        startButton.layer.cornerRadius = startButton.frame.height / 2
        startButton.setTitleColor(.white, for: .normal)
        startButton.setTitle("START", for: .normal)
        
        panel.layer.cornerRadius = 10
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
            // manager.startUpdatingHeading()
        }
        
    }
    
    @IBAction func moveToMyLocation(_ sender: Any) {
        toMyLocation()
    }
    
    func toMyLocation() {
        if thisUserLocation != nil {
            camera = GMSCameraPosition.camera(withLatitude: (thisUserLocation!.latitude), longitude: (thisUserLocation!.longitude), zoom: 16.0, bearing: 0, viewingAngle: 0)
            map.animate(to: camera!)
        }
    }
    
    func reset() {
        clearPolylines()
    }
    
    func clearPolylines() {
        for polyline in polylines {
            polyline.map = nil
        }
        polylines.removeAll()
    }
    
    @IBAction func back(_ sender: Any) {
//        stopTimer()
        self.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gLocationSharingViewController = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.initMap()
        }
    }
    
    func initMap() {
        if thisUserLocation != nil{
            camera = GMSCameraPosition.camera(withLatitude: (thisUserLocation!.latitude), longitude: (thisUserLocation!.longitude), zoom: 16.0, bearing: 0, viewingAngle: 0)
        }else {
            camera = GMSCameraPosition.camera(withLatitude: 29.131733, longitude: -81.827062, zoom: 16.0, bearing: 0, viewingAngle: 0)
        }
        map = GMSMapView.map(withFrame: self.viewForGMap.frame, camera: camera!)
        map.animate(to: camera!)
        map.delegate = self
        viewForGMap.addSubview(map)
        map.isMyLocationEnabled = true
        map.isBuildingsEnabled = true
        map.settings.myLocationButton = false
        map.mapType = .normal
        
        if gPoints.count > 300 {
            mLoading = true
            showLoadingDialog()
        }
        if !gPoints.isEmpty {
            self.drawRoute()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            let userLocation = locations.last!
            print("My Location = \(userLocation)")
            let center = CLLocationCoordinate2D(latitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude))
            thisUserLocation = center
        }
    }

    @IBAction func toggleRecording (_ sender: Any) {
        if gHomeViewController.isLocationRecording {
            finalizeReport(is8hours: false)
//            stopTimer()
            isLive = false
        } else {
            if gHomeViewController.thisUserLocation == nil {
                return
            }
            startLocationRecording(name: "ROUTE_" + getFormattedDate(date: Date(), format: "yyyy_MM_dd_HH_mm"))
        }
    }
    
    func finalizeReport(is8hours:Bool) {
        startButton.backgroundColor = UIColor.systemCyan
        startButton.layer.cornerRadius = startButton.frame.height / 2
        startButton.setTitleColor(.white, for: .normal)
        startButton.setTitle("START", for: .normal)
        
        gHomeViewController.isLocationRecording = false
        gHomeViewController.disableLocationManager()
        
        gHomeViewController.IS8HOURS = is8hours
        
        if !is8hours {
            if isConnectedToNetwork {
                if gHomeViewController.traces1.count > 0 {
                    uploadRoutePoints(end: true)
                }
            }else {
                gHomeViewController.traces1.removeAll()
                gHomeViewController.traces0.removeAll()
                gHomeViewController.traces.removeAll()
            }
            routeSaveBox.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
            self.addChild(routeSaveBox)
            self.view.addSubview(routeSaveBox.view)
        }else {
            gHomeViewController.sendNotification(title: "SeeFish", body: "Since the log has exceeded 8 hours, it will be automatically stopped.")
            if !isConnectedToNetwork {
                gHomeViewController.traces1.removeAll()
                gHomeViewController.traces0.removeAll()
                gHomeViewController.traces.removeAll()
                return
            }else {
                if gHomeViewController.traces1.count > 0 {
                    uploadRoutePoints(end: true)
                }else {
                    gHomeViewController.endedTime = Date().currentTimeMillis()
                    self.uploadStartOrEndRoute(route_id: gHomeViewController.routeID, member_id: thisUser.idx, name: "", description: "", start_time: String(gHomeViewController.startedTime), end_time: String(gHomeViewController.endedTime), duration: gHomeViewController.duration, distance: gHomeViewController.totalDistance, status: "2", lat:String(thisUserLocation!.latitude), lng:String(thisUserLocation!.longitude), tm: String(gHomeViewController.endedTime))
                }
            }
        }
    }
    
    func startLocationRecording(name:String) {
        gHomeViewController.startedTime = Date().currentTimeMillis()
        gHomeViewController.totalDistance = 0
        gHomeViewController.duration = 0
        gHomeViewController.routeID = 0
        gHomeViewController.endedTime = Date().currentTimeMillis()
        
        gHomeViewController.traces.removeAll()
        gHomeViewController.traces1.removeAll()
        gHomeViewController.traces0.removeAll()
        
        gHomeViewController.IS8HOURS = false
        
        self.uploadStartOrEndRoute(route_id: gHomeViewController.routeID, member_id: thisUser.idx, name: name, description: "", start_time: String(gHomeViewController.startedTime), end_time: String(gHomeViewController.endedTime), duration: gHomeViewController.duration, distance: gHomeViewController.totalDistance, status: "0", lat:String(thisUserLocation!.latitude), lng:String(thisUserLocation!.longitude), tm: String(gHomeViewController.startedTime))
    }
    
    func uploadStartOrEndRoute(route_id:Int64, member_id: Int64, name:String, description:String, start_time:String, end_time:String, duration:Int64, distance:Double, status:String, lat:String, lng:String, tm:String) {
        if Int(status) == 0 || Int(status) == 2 { self.showLoadingView()}
        APIs.uploadStartOrEndRoute(route_id:route_id, member_id: member_id, name:name, description:description, start_time:start_time, end_time:end_time, duration:duration, distance:distance, status:status, lat:lat, lng:lng, tm:tm, handleCallback: { [self]
            route_id, result_code in
            if Int(status) == 0 || Int(status) == 2 { self.dismissLoadingView() }
            
            print(result_code)
            if result_code == "0"{
                gHomeViewController.routeID = Int64(route_id)!
                if Int(status) == 0 {
                    clearPolylines()
                    
                    startButton.backgroundColor = UIColor.red
                    startButton.layer.cornerRadius = startButton.frame.height / 2
                    startButton.setTitleColor(.white, for: .normal)
                    startButton.setTitle("END", for: .normal)
                    
                    gHomeViewController.isLocationRecording = true
                    gHomeViewController.enableLocationManager()
//                    startTimer()
                    isLive = true
                    let point = Point()
                    point.lat = thisUserLocation!.latitude
                    point.lng = thisUserLocation!.longitude
                    point.time = String(Date().currentTimeMillis())
                    latestPoint = point
                }else {
                    if Int(status) == 2 {
                        print("ROUTE ENDED")
                        gHomeViewController.isLocationRecording = false
                        gHomeViewController.disableLocationManager()
//                        stopTimer()
                        isLive = false
                        gHomeViewController.traces0.removeAll()
                        gHomeViewController.traces1.removeAll()
                        gHomeViewController.traces.removeAll()
                        if recent == gLocationRouteHistoryViewController {
                            gLocationRouteHistoryViewController.getMyRoutes()
                            self.dismiss(animated: true)
                        }else if recent == gMyRoutesViewController {
                            gMyRoutesViewController.getMyRoutes()
                            self.dismiss(animated: true)
                        }else {
                            self.to1(strb: "Main2", vc: "LocationRouteHistoryViewController", trans: false, modal: false, anim: true)
                        }
                    }
                }
            }else {
                print("Result: \(result_code)")
            }
            
        })
    }
    
    
    func uploadRoutePoints(end:Bool) {

        let jsonFile = createPointsJsonStr().data(using: .utf8)!

        let params = [
            "route_id":String(gHomeViewController.routeID),
            "member_id":String(thisUser.idx),
            "name":"",
            "description":"",
            "start_time": String(gHomeViewController.startedTime),
            "end_time": String(gHomeViewController.endedTime),
            "duration": String(gHomeViewController.duration),
            "distance": String(gHomeViewController.totalDistance),
            "status": end ? "1" : "0",
        ] as [String : Any]

        let fileDic = ["jsonfile" : jsonFile]
        // Here you can pass multiple image in array i am passing just one
        let fileArray = NSMutableArray(array: [fileDic as NSDictionary])

//        self.showLoadingView()
        APIs().uploadJsonFile(withUrl: SERVER_URL + "ETMupdate", withParam: params, withFiles: fileArray) { (isSuccess, response) in
            // Your Will Get Response here
//            self.dismissLoadingView()
            print("XXXXXXXXXX JSON: \(response)")
            if isSuccess == true {
                let result_code = response["result_code"] as Any
                if result_code as! String == "0"{
                    gHomeViewController.traces1.removeAll()
                    let curtime:Int64 = Date().currentTimeMillis()
                    UserDefaults.standard.set(curtime, forKey: "last_loaded")
                    if end || gHomeViewController.IS8HOURS {
                        print("STATUS/////////111111111111")
                        gHomeViewController.traces.removeAll()
                        gHomeViewController.traces0.removeAll()
                        if gHomeViewController.IS8HOURS {
                            if recent == gLocationRouteHistoryViewController {
                                gLocationRouteHistoryViewController.getMyRoutes()
                                self.dismiss(animated: true)
                            }else if recent == gMyRoutesViewController {
                                gMyRoutesViewController.getMyRoutes()
                                self.dismiss(animated: true)
                            }else {
                                self.to1(strb: "Main2", vc: "LocationRouteHistoryViewController", trans: false, modal: false, anim: true)
                            }
                        }
                    }
                }
            } else {
                print("Error!")                
            }
        }


    }
    
    
    func createPointsJsonStr() -> String {
        var jsonStr = ""
        var jsonArray = [Any]()
        var i = 0
        for rpoint in gHomeViewController.traces1 {
            i += 1
            let jsonObject: [String: String] = [
                "id": String(i),
                "route_id": String(gHomeViewController.routeID),
                "lat": String(rpoint.lat),
                "lng": String(rpoint.lng),
                "time": String(rpoint.time),
                "status": "",
            ]
            jsonArray.append(jsonObject)
        }
        
        let jsonItemsObj:[String: Any] = [
            "points":jsonArray
        ]
        
        jsonStr = stringify(json: jsonItemsObj)
        return jsonStr
    }
    
    //////// End route
    
    func endRoute(desc:String) {
        gHomeViewController.endedTime = Date().currentTimeMillis()
        self.uploadStartOrEndRoute(route_id: gHomeViewController.routeID, member_id: thisUser.idx, name: "", description: desc, start_time: String(gHomeViewController.startedTime), end_time: String(gHomeViewController.endedTime), duration: gHomeViewController.duration, distance: gHomeViewController.totalDistance, status: "2", lat:String(thisUserLocation!.latitude), lng:String(thisUserLocation!.longitude), tm: String(gHomeViewController.endedTime))
    }
    
    

    @IBAction func openList(_ sender: Any) {
        self.to(strb: "Main2", vc: "LocationRouteHistoryViewController", trans: false, modal: false, anim: true)
    }
    
    
    func startTimer() {
        timer.invalidate() // just in case this button is tapped multiple times
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(5), target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    var oldTraces = [Point]()
    
    @objc func timerAction() {
        let path = GMSMutablePath()
        let newTraces = gHomeViewController.traces
        if !oldTraces.isEmpty {
            path.addLatitude(oldTraces.last!.lat, longitude: oldTraces.last!.lng)
        }
        let diff = newTraces.count - oldTraces.count
        if diff > 0 {
            for i in 0..<diff {
                if newTraces.count - diff + i < newTraces.count {
                    let point = newTraces[newTraces.count - diff + i]
                    path.addLatitude(point.lat, longitude: point.lng)
                }
            }
        }
        if path.count() > 1 {
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 5.0
            polyline.strokeColor = UIColor.red
            polyline.geodesic = true
            polyline.map = map
        }
        oldTraces = newTraces
        
//        distanceBox.text = String(format: "%.2f", gHomeViewController.totalDistance) + "km"
        distanceBox.text = String(format: "%.2f", gHomeViewController.totalDistance * ratioKMToMILE) + "mi"
        durationBox.text = getDurationFromMilliseconds(ms: gHomeViewController.duration)
    }
    
    
    var isLive:Bool = false
    var latestPoint:Point!
    
    func drawRoute() {
        let marker1 = GMSMarker()
        marker1.position = CLLocationCoordinate2D(latitude: gPoints[0].lat, longitude: gPoints[0].lng)
        marker1.isFlat = true
        marker1.title = "S"
        marker1.map = self.map
        marker1.appearAnimation = .pop
        map.selectedMarker = marker1
        
        let marker2 = GMSMarker()
        marker2.position = CLLocationCoordinate2D(latitude: gPoints.last!.lat, longitude: gPoints.last!.lng)
        marker2.isFlat = true
        marker2.title = "E"
        marker2.map = self.map
        marker2.appearAnimation = .pop
        map.selectedMarker = marker2
        
//        distanceBox.text = String(format: "%.2f", gRoute.distance) + "km"
        distanceBox.text = String(format: "%.2f", gRoute.distance * ratioKMToMILE) + "mi"
        durationBox.text = getDurationFromMilliseconds(ms: gRoute.duration)
        
        gHomeViewController.totalDistance = gRoute.distance
        gHomeViewController.duration = gRoute.duration
        gHomeViewController.startedTime = Int64(gRoute.start_time)!
        gHomeViewController.endedTime = Int64(gRoute.end_time)!
        gHomeViewController.traces.removeAll()
        gHomeViewController.traces1.removeAll()
        gHomeViewController.routeID = gRoute.idx
        
        var bounds = GMSCoordinateBounds()
        for point in gPoints {
            bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: point.lat, longitude: point.lng))
        }
        let update = GMSCameraUpdate.fit(bounds, withPadding: 10)
        map.animate(with: update)
        
        let path = GMSMutablePath()
        for point in gPoints {
            path.addLatitude(point.lat, longitude: point.lng)
            if point.idx == gPoints.last?.idx {
                latestPoint = point
                if mLoading {
                    dismissLoadingDialog()
                }
                mLoading = false
                if gRoute.status == "" {
                    gHomeViewController.traces.append(point)
                    if gHomeViewController.isLocationRecording {
                        self.startButton.backgroundColor = UIColor.red
                        self.startButton.layer.cornerRadius = self.startButton.frame.height / 2
                        self.startButton.setTitleColor(.white, for: .normal)
                        self.startButton.setTitle("END", for: .normal)
                        gHomeViewController.isLocationRecording = true
                        gHomeViewController.enableLocationManager()
//                        self.startTimer()
                        self.isLive = true
                        self.toMyLocation()
                        marker2.map = nil
                    }else {
                        let msg = """
                        This route recording looks like not ended.
                        Do you want to continue the route
                        recording?
                        """
                        let alert = UIAlertController(title: "Note!", message: msg, preferredStyle: .alert)
                        let noAction = UIAlertAction(title: "No, end it", style: .destructive){(ACTION) in
                            self.finalizeReport(is8hours:false)
                            alert.dismiss(animated: true, completion: nil)
                        }
                        let yesAction = UIAlertAction(title: "Yes", style: .cancel){(ACTION) in
                            self.startButton.backgroundColor = UIColor.red
                            self.startButton.layer.cornerRadius = self.startButton.frame.height / 2
                            self.startButton.setTitleColor(.white, for: .normal)
                            self.startButton.setTitle("END", for: .normal)
                            gHomeViewController.isLocationRecording = true
                            gHomeViewController.enableLocationManager()
//                            self.startTimer()
                            self.isLive = true
                            self.toMyLocation()
                            marker2.map = nil
                            alert.dismiss(animated: true, completion: nil)
                        }
                        alert.addAction(yesAction)
                        alert.addAction(noAction)
                        self.present(alert, animated:true, completion:nil)
                        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 0
                    }
                }
                break
            }
        }
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.strokeColor = .red
        polyline.geodesic = true
        polyline.map = map
    }
    
    func updateRealTimeRoute() {
        if isLive {
//            distanceBox.text = String(format: "%.2f", gHomeViewController.totalDistance) + "km"
            distanceBox.text = String(format: "%.2f", gHomeViewController.totalDistance * ratioKMToMILE) + "mi"
            durationBox.text = getDurationFromMilliseconds(ms: gHomeViewController.duration)
            let path = GMSMutablePath()
            if latestPoint != nil { path.addLatitude(latestPoint.lat, longitude: latestPoint.lng) }
            if gHomeViewController.traces1.count > 0 {
                let newPoint = gHomeViewController.traces1.last
                path.addLatitude(newPoint!.lat, longitude: newPoint!.lng)
                if path.count() > 1 {
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeWidth = 5.0
                    polyline.strokeColor = UIColor.red
                    polyline.geodesic = true
                    polyline.map = map
                }
                latestPoint = newPoint
            }
        }
    }
    
    func showLoadingDialog() {
        locationLoadingDialog.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        locationLoadingDialog.messageBox.text = "DATA LOADING..."
        self.addChild(self.locationLoadingDialog)
        self.view.addSubview(self.locationLoadingDialog.view)
    }
    
    func dismissLoadingDialog() {
        self.locationLoadingDialog.removeFromParent()
        self.locationLoadingDialog.view.removeFromSuperview()
        self.locationLoadingDialog.alertView.alpha = 1
    }
    
    func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLoc = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLoc = CLLocation(latitude: to.latitude, longitude: to.longitude)
        let distanceInMeters = fromLoc.distance(from: toLoc)
        return distanceInMeters
    }
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }

    func getBearingBetweenTwoPoints1(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {
        let pnt1 = CLLocation(latitude: point1.latitude, longitude: point1.longitude)
        let pnt2 = CLLocation(latitude: point2.latitude, longitude: point2.longitude)

        let lat1 = degreesToRadians(degrees: pnt1.coordinate.latitude)
        let lon1 = degreesToRadians(degrees: pnt1.coordinate.longitude)

        let lat2 = degreesToRadians(degrees: pnt2.coordinate.latitude)
        let lon2 = degreesToRadians(degrees: pnt2.coordinate.longitude)

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        return radiansToDegrees(radians: radiansBearing)
    }
    
    
}



