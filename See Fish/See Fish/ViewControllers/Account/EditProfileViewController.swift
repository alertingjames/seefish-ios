//
//  EditProfileViewController.swift
//  See Fish
//
//  Created by Andre on 11/10/20.
//

import UIKit
import TextFieldEffects
import YPImagePicker
import SwiftyJSON

class EditProfileViewController: BaseViewController {
    
    @IBOutlet weak var pictureView: UIView!
    @IBOutlet weak var pictureBox: UIImageView!
    @IBOutlet weak var reloadView: UILabel!
    
    @IBOutlet weak var nameBox: HoshiTextField!
    @IBOutlet weak var emailBox: HoshiTextField!
    @IBOutlet weak var phoneBox: HoshiTextField!
    @IBOutlet weak var cityBox: HoshiTextField!
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    var showF:Bool = false
    var show = UIImage(named: "eyeunlock")
    var unshow = UIImage(named: "eyelock")
    
    var picker:YPImagePicker!
    var imageFile:Data!
    var ImageArray = NSMutableArray()
    
    var address = ""
    var city = ""
    var lat:String = "0"
    var lng:String = "0"

    override func viewDidLoad() {
        super.viewDidLoad()

        recent = self
        gEditProfileViewController = self

        pictureBox.layer.cornerRadius = pictureBox.frame.height / 2
        loadPicture(imageView: pictureBox, url: URL(string: thisUser.photo_url)!)
        locationBtn.setImageTintColor(primaryLightColor)
        
        nameBox.placeholder = "Name"
        nameBox.minimumFontSize = 5
        nameBox.textColor = .label
        nameBox.font = UIFont(name: "Helvetica", size: 19)
        
        nameBox.text = thisUser.name
                
        emailBox.placeholder = "Email address"
        emailBox.minimumFontSize = 5
        emailBox.textColor = .label
        emailBox.font = UIFont(name: "Helvetica", size: 19)
        emailBox.keyboardType = UIKeyboardType.emailAddress
        
        emailBox.text = thisUser.email
        
        phoneBox.placeholder = "Phone number"
        phoneBox.minimumFontSize = 5
        phoneBox.textColor = .label
        phoneBox.font = UIFont(name: "Helvetica", size: 19)
        phoneBox.keyboardType = .phonePad
        
        phoneBox.text = thisUser.phone_number
        
        cityBox.placeholder = "City/state name"
        cityBox.minimumFontSize = 5
        cityBox.textColor = .label
        cityBox.font = UIFont(name: "Helvetica", size: 19)
        cityBox.isUserInteractionEnabled = false
        cityBox.isEnabled = false
        
        cityBox.text = thisUser.city
        
        address = thisUser.address
        city = thisUser.city
        lat = thisUser.lat
        lng = thisUser.lng
        
        setRoundShadowButton(button: saveBtn, corner: saveBtn.frame.height/2)
        
        var config = YPImagePickerConfiguration()
        config.wordings.libraryTitle = "Gallery"
        config.wordings.cameraTitle = "Camera"
        YPImagePickerConfiguration.shared = config
        picker = YPImagePicker()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(pickPicture))
        pictureView.addGestureRecognizer(tap)
//        reloadView.addGestureRecognizer(tap)
        
    }
    
    @objc func pickPicture(gesture:UITapGestureRecognizer){
        if (gesture.view as? UIView) != nil || (gesture.view as? UILabel) != nil {
            picker.didFinishPicking { [picker] items, _ in
                if let photo = items.singlePhoto {
                    self.pictureBox.image = photo.image
                    self.pictureBox.layer.cornerRadius = 50
                    self.imageFile = photo.image.jpegData(compressionQuality: 0.8)
                }
                picker!.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func openMap(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PickLocationViewController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "PasswordResetViewController")
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func saveProfile(_ sender: Any) {
        if self.imageFile == nil && nameBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == thisUser.name && emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == thisUser.email && phoneBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == thisUser.phone_number && cityBox.text == thisUser.city && address == thisUser.address && lat == thisUser.lat && lng == thisUser.lng { return }
        
        if nameBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "Enter your name.")
            return
        }
        if emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "Enter your email.")
            return
        }
        
        if !isValidEmail(email: (emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) {
            showToast(msg: "Enter a valid email.")
            return
        }
        
        if phoneBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "Enter your phone number.")
            return
        }
        
//        if !isValidPhone(phone: (phoneBox.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) {
//            showToast2(msg: "Enter a valid phone number.")
//            return
//        }
        
        if cityBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "Enter your city.")
            return
        }
        
        var userId:Int64 = 0
        if thisUser.idx > 0 { userId = thisUser.idx }
            
        let parameters: [String:Any] = [
            "member_id" : String(userId),
            "name" : nameBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
            "email" : emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
            "password" : thisUser.password,
            "phone_number": phoneBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
            "city" : cityBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
            "address" : self.address as Any,
            "lat" : self.lat as Any,
            "lng" : self.lng as Any
        ]
            
        if self.imageFile != nil{
            
            let ImageDic = ["file" : self.imageFile!]
            // Here you can pass multiple image in array i am passing just one
            ImageArray = NSMutableArray(array: [ImageDic as NSDictionary])
                
            self.showLoadingView()
            APIs().registerWithPicture(withUrl: SERVER_URL + "register", withParam: parameters, withImages: ImageArray) { (isSuccess, response) in
                // Your Will Get Response here
                self.dismissLoadingView()
                print("Response: \(response)")
                if isSuccess == true{
                    let result_code = response["result_code"] as Any
                    if result_code as! String == "0"{
                        let json = JSON(response)
                        self.processData(json: json)                        
                    }else if result_code as! String == "1"{
                        self.showToast(msg: "Someone is using the same email as your new email.")
                    }else {
                        self.showToast(msg: "Something is wrong")
                    }
                }else{
                    let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
                    self.showToast(msg: "Issue: \n" + message)
                }
            }
        }else{
            self.showLoadingView()
            APIs().registerWithoutPicture(withUrl: SERVER_URL + "register", withParam: parameters) { (isSuccess, response) in
                // Your Will Get Response here
                self.dismissLoadingView()
                print("Response: \(response)")
                if isSuccess == true{
                    let result_code = response["result_code"] as Any
                    if result_code as! String == "0"{
                        let json = JSON(response)
                        self.processData(json: json)
                    }else if result_code as! String == "1"{
                        self.showToast(msg: "Someone is using the same email as your new email.")
                    }else {
                        self.showToast(msg: "Something wrong")
                    }
                }else{
                    let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
                    self.showToast(msg: "Issue: \n" + message)
                }
            }
        }
        
        
    }
    
    func processData(json:JSON){
        let data = json["data"].object as! [String: Any]
        
        let user = User()
        user.idx = data["id"] as! Int64
        user.name = data["name"] as! String
        user.email = data["email"] as! String
        user.password = data["password"] as! String
        user.photo_url = data["photo_url"] as! String
        user.phone_number = data["phone_number"] as! String
        user.city = data["city"] as! String
        user.address = data["address"] as! String
        user.lat = data["lat"] as! String
        user.lng = data["lng"] as! String
        user.registered_time = data["registered_time"] as! String
        user.followers = Int64(data["followers"] as! String)!
        user.followings = Int64(data["followings"] as! String)!
        user.feeds = Int64(data["feeds"] as! String)!
        user.fcm_token = data["fcm_token"] as! String
        user.terms = data["terms"] as! String
        user.status = data["status"] as! String
            
        thisUser = user

        UserDefaults.standard.set(thisUser.email, forKey: "email")
        UserDefaults.standard.set(thisUser.password, forKey: "password")
        
        self.dismissViewController()
    }
    
}
