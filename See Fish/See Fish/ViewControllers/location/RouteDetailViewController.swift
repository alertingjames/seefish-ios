//
//  RouteDetailViewController.swift
//  See Fish
//
//  Created by james on 12/8/22.
//

import UIKit
import GoogleMaps
import CoreLocation
import AddressBookUI
import Alamofire
import SwiftyJSON

class RouteDetailViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    @IBOutlet weak var mapViewButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var panel: UIView!
    
    var manager = CLLocationManager()
    var map = GMSMapView()
    var myMarker:GMSMarker? = nil
    var circle:GMSCircle? = nil
    var camera: GMSCameraPosition? = nil
    var thisUserLocation:CLLocationCoordinate2D? = nil
    var timer = Timer()
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var durationBox: UILabel!
    @IBOutlet weak var distanceBox: UILabel!
    
    var loadingDialog:LocationLoadingDialog!

    override func viewDidLoad() {
        super.viewDidLoad()

        loadingDialog = (UIStoryboard(name: "Main3", bundle: nil).instantiateViewController(withIdentifier: "LocationLoadingDialog") as! LocationLoadingDialog)
        
        backButton.layer.cornerRadius = 5
        mapViewButton.layer.cornerRadius = 5
        backButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        mapViewButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        panel.layer.cornerRadius = 10
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
            // manager.startUpdatingHeading()
        }
        
        if gPoints.count > 300 {
            showLoadingDialog()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        map = GMSMapView.map(withFrame: self.mapView.frame, camera: camera!)
//        map.animate(to: camera!)
        map.delegate = self
        mapView.addSubview(map)
        map.isMyLocationEnabled = true
        map.isBuildingsEnabled = true
        map.settings.myLocationButton = true
        map.mapType = .normal
        map.padding = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 10)
        
        if !gPoints.isEmpty {
            self.drawRoute()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0{
            let userLocation = locations.last!
            print("My Location = \(userLocation)")
            let center = CLLocationCoordinate2D(latitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude))
            
            thisUserLocation = center
        }
    }
    
    var latestPointIndex:Int64!
    var oldMarker:GMSMarker!
    
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
        
        distanceBox.text = String(format: "%.2f", gRoute.distance) + "km"
        durationBox.text = getDurationFromMilliseconds(ms: gRoute.duration)
        
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
                latestPointIndex = Int64(exactly: gPoints.count)! - 1
                dismissLoadingDialog()
                if gRoute.status == "" {
                    startTimer()
                    marker2.map = nil
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: gPoints.last!.lat, longitude: gPoints.last!.lng)
                    marker.icon = UIImage(named: "mylocationmarker")
                    marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                    marker.map = self.map
                    oldMarker = marker
                }
            }
        }
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.strokeColor = .red
        polyline.geodesic = true
        polyline.map = map
    }
    
    func showLoadingDialog() {
        loadingDialog.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        loadingDialog.messageBox.text = "DATA LOADING..."
        self.addChild(self.loadingDialog)
        self.view.addSubview(self.loadingDialog.view)
    }
    
    func dismissLoadingDialog() {
        self.loadingDialog.removeFromParent()
        self.loadingDialog.view.removeFromSuperview()
        self.loadingDialog.alertView.alpha = 1
    }

    @IBAction func back(_ sender: Any) {
        if self.timer.isValid { self.stopTimer() }
        self.dismiss(animated: true)
    }
    
    @IBAction func toggleMapView(_ sender: Any) {
        if map != nil {
            if map.mapType == .normal {
                map.mapType = .satellite
                mapViewButton.setImage(UIImage(named: "map.png"), for: .normal)
            }else {
                map.mapType = .normal
                mapViewButton.setImage(UIImage(named: "satellite.png"), for: .normal)
            }
        }
    }
    
    func startTimer() {
        timer.invalidate() // just in case this button is tapped multiple times
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(5), target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    @objc func timerAction() {
        APIs.getUpdatedRouteDetails(route_id: gRoute.idx, latest_index: latestPointIndex, handleCallback: { [self]
            route, points, result_code in
            print(result_code)
            if result_code == "0" {
                gRoute = route!
                self.distanceBox.text = String(format: "%.2f", gRoute.distance) + "km"
                self.durationBox.text = self.getDurationFromMilliseconds(ms: gRoute.duration)
                let path = GMSMutablePath()
                for point in points! {
                    path.addLatitude(point.lat, longitude: point.lng)
                }
                if path.count() > 1 {
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeWidth = 5.0
                    polyline.strokeColor = UIColor.red
                    polyline.geodesic = true
                    polyline.map = map
                }
                if oldMarker != nil { oldMarker.map = nil }
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: points!.last!.lat, longitude: points!.last!.lng)
                marker.icon = UIImage(named: "mylocationmarker")
                marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                marker.map = self.map
                oldMarker = marker
                latestPointIndex = Int64(exactly: points!.count)! - 1
            }
        })
    }
    
    
    
    
}
