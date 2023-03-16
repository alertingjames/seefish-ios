//
//  PostMapViewController.swift
//  See Fish
//
//  Created by james on 12/6/22.
//

import UIKit
import GoogleMaps
import CoreLocation
import AddressBookUI

class PostMapViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var manager = CLLocationManager()
    var map = GMSMapView()
    @IBOutlet weak var viewForGMap: UIView!
    var marker:GMSMarker? = nil
    var myMarker:GMSMarker? = nil
    var circle:GMSCircle? = nil
    var camera: GMSCameraPosition? = nil
    var thisUserLocation:CLLocationCoordinate2D? = nil
    @IBOutlet weak var view_search: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    var selectedLocation:CLLocationCoordinate2D? = nil
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var mapViewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_title.text = gPost.title

        edt_search.underlined()
        edt_search.returnKeyType = .search
        
        view_search.isHidden = true
        
        mapViewButton.layer.cornerRadius = 5
        mapViewButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        // User Location
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
            // manager.startUpdatingHeading()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.initMap()
        }
    }
    
    func initMap() {
        if gPost.lat != nil && gPost.lng != nil {
            camera = GMSCameraPosition.camera(withLatitude: (gPost.lat), longitude: (gPost.lng), zoom: 16.0, bearing: 0, viewingAngle: 0)
        }else {
            camera = GMSCameraPosition.camera(withLatitude: 29.131733, longitude: -81.827062, zoom: 16.0, bearing: 0, viewingAngle: 0)
        }
        map = GMSMapView.map(withFrame: self.viewForGMap.frame, camera: camera!)
        map.animate(to: camera!)
        map.delegate = self
        self.viewForGMap.addSubview(map)
        map.isMyLocationEnabled = true
        map.isBuildingsEnabled = true
        map.settings.myLocationButton = true
        map.mapType = .normal
        map.padding = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 10)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: gPost.lat, longitude: gPost.lng)
        marker.title = gPost.category
//        marker.snippet = gPost.category
        let image = UIImage(named: "ring")?.withColor(self.hexStringToUIColor(hex: gPost.color))
        marker.icon = image
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.map = self.map
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            self.forwardGeocoding(address: (textField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!)
        }
        return false
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0{
            let userLocation = locations.last!
            print("locations = \(locations)")
            let center = CLLocationCoordinate2D(latitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude))
            
            thisUserLocation = center
            selectedLocation = center
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("Tapped on Map at \(coordinate)")
//        reverseGeocoding(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    func forwardGeocoding(address: String) {
        self.selectedLocation = nil
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error as Any)
                return
            }
            if (placemarks?.count)! > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                let placename = placemark?.name
                print("\nlat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
                if self.marker != nil{
                    self.marker!.map = nil
                }
                self.camera = GMSCameraPosition.camera(withLatitude: (coordinate!.latitude), longitude: (coordinate!.longitude), zoom: 20.0, bearing: 30, viewingAngle: 30)
                self.marker = GMSMarker()
                self.marker?.position = CLLocationCoordinate2D(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
                self.marker?.title = placename
                self.marker!.map = self.map
//                self.marker!.icon = UIImage(named: "marker")
                self.map.animate(to: self.camera!)
                self.selectedLocation = CLLocationCoordinate2D(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
            }
        })
    }
    
    func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        self.edt_search.text = ""
        if self.marker != nil{
            self.marker!.map = nil
        }
        self.camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: 20.0, bearing: 30, viewingAngle: 30)
        self.marker = GMSMarker()
        self.marker?.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        self.marker?.title = addressString
//        self.marker!.snippet = addressString
        self.marker!.map = self.map
        // self.marker!.icon = UIImage(named: "marker")
        self.map.animate(to: self.camera!)
        
        self.selectedLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Custom Location Error+++\(error as Any)")
                return
            }
            else if (placemarks?.count)! > 0 {
                let pm = placemarks![0]
                
                var city = ""
                
                var addArray:[String] = []
                
                if let name = pm.name {
                    addArray.append(name)
                }
//                if let thoroughfare = pm.thoroughfare {
//                    addArray.append(thoroughfare)
//                }
//                if let subLocality = pm.subLocality {
//                    addArray.append(subLocality)
//                }
                if let locality = pm.locality {
                    addArray.append(locality)
                    city = locality
                }
                
                if let postalCode = pm.postalCode {
                    addArray.append(postalCode)
                }
//                if let subAdministrativeArea = pm.subAdministrativeArea {
//                    addArray.append(subAdministrativeArea)
//                }
                if let administrativeArea = pm.administrativeArea {
                    addArray.append(administrativeArea)
                }
                var cntry = ""
                if let country = pm.country {
                    addArray.append(country)
                    cntry = country
                }
                
                let addressString = addArray.joined(separator: ",\n")
                let address = addArray.joined(separator: ", ")
                
                print(addressString)
                
//                self.edt_search.text = addressString
                self.marker?.title = address
                
            }
        })
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
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
    
}
