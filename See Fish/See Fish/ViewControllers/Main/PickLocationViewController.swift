//
//  PickLocationViewController.swift
//  See Fish
//
//  Created by Andre on 11/1/20.
//

import UIKit
import GoogleMaps
import CoreLocation
import AddressBookUI

extension UITextField {
    // Next step here
    func underlined(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

class PickLocationViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
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
    @IBOutlet weak var btn_ok: UIButton!
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    
    @IBOutlet weak var btn_location: UIButton!
    var selectedLocation:CLLocationCoordinate2D? = nil
    var startF:Bool = false
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchIcon: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setRoundShadowButton(button: btn_ok, corner: 25)
        edt_search.underlined()
        edt_search.returnKeyType = .search
        
        view_search.isHidden = true
        
        view_search.layer.cornerRadius = view_search.frame.height / 2
        view_search.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.3)
        
        // User Location
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.allowDeferredLocationUpdates(untilTraveled: 0, timeout: 0)
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
            // manager.startUpdatingHeading()
        }
        
    }
    
    @IBAction func openSearch(_ sender: Any) {
        if view_search.isHidden{
            view_search.isHidden = false
            btn_search.setImage(UIImage(named: "ic_cancel"), for: .normal)
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
    
    func showHint(){
        let alert = UIAlertController(title: "HINT", message: "Please select correct location.\nYou can type the address to search or your can click on the map to select correct location.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel){(ACTION) in
            
        }
        alert.addAction(okAction)
        self.present(alert, animated:true, completion:nil);
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            self.forwardGeocoding(address: (textField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!)
        }
        return false
    }
    
    @IBAction func showMyLocation(_ sender: Any) {
        camera = GMSCameraPosition.camera(withLatitude: (thisUserLocation!.latitude), longitude: (thisUserLocation!.longitude), zoom: 20.0, bearing: 30, viewingAngle: 30)
        //  map.camera = camera!
        map.animate(to: camera!)
        self.selectedLocation = thisUserLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0{
            let userLocation = locations.last!
            print("locations = \(locations)")
            let center = CLLocationCoordinate2D(latitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude))
            
            if thisUserLocation == nil{
                camera = GMSCameraPosition.camera(withLatitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude), zoom: 20.0, bearing: 30, viewingAngle: 30)
                map = GMSMapView.map(withFrame: self.viewForGMap.frame, camera: camera!)
                map.animate(to: camera!)
                map.delegate = self
                self.viewForGMap.addSubview(map)
                map.isMyLocationEnabled = true
                map.isBuildingsEnabled = true
                map.settings.myLocationButton = true
                map.mapType = .normal
                map.padding = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 10)
            }else{
                let currentZoom = self.map.camera.zoom;
                camera = GMSCameraPosition.camera(withLatitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude), zoom: currentZoom, bearing: 30, viewingAngle: 30)
            }
            
            thisUserLocation = center
            
            self.selectedLocation = center
        }
        
        if !startF{
            startF = true
            showHint()
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("Tapped on Map at \(coordinate)")
        reverseGeocoding(latitude: coordinate.latitude, longitude: coordinate.longitude)
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
    
    @IBAction func ok_loc(_ sender: Any) {
        if self.selectedLocation == nil{
            showToast(msg: "Please pick your location.")
            return
        }
        reverseGeocoding(latitude: self.selectedLocation!.latitude, longitude: self.selectedLocation!.longitude)
        return
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
                self.showAlertDialog(addressStr: addressString, address:address, country: cntry, city: city, lat: String(latitude), lng: String(longitude))
            }
        })
    }
    
    func showAlertDialog(addressStr:String, address:String, country:String, city:String, lat:String, lng:String){
        let alert = UIAlertController(title: "Location Info", message: addressStr, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        let regAction = UIAlertAction(title: "Select", style: .destructive, handler: { alert -> Void in
            self.addLocation(member_id: thisUser.idx, address: address, country: country, city: city, lat: lat, lng: lng)
        })
        
        alert.addAction(regAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addLocation(member_id:Int64, address:String, country:String, city:String, lat:String, lng:String) {
        if recent == gSignupViewController {
            gSignupViewController.address = address
            gSignupViewController.lat = lat
            gSignupViewController.lng = lng
            gSignupViewController.city = city
            gSignupViewController.cityBox.text = city + "," + country
        }else if recent == gEditProfileViewController {
            gEditProfileViewController.address = address
            gEditProfileViewController.lat = lat
            gEditProfileViewController.lng = lng
            gEditProfileViewController.city = city
            gEditProfileViewController.cityBox.text = city + "," + country
        }
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}




















































