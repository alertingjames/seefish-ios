//
//  SignupViewController.swift
//  See Fish
//
//  Created by Andre on 10/31/20.
//

import UIKit
import TextFieldEffects
import YPImagePicker
import SwiftyJSON

class SignupViewController: BaseViewController {
    
    @IBOutlet weak var pictureBox: UIImageView!
    
    @IBOutlet weak var nameBox: HoshiTextField!
    @IBOutlet weak var emailBox: HoshiTextField!
    @IBOutlet weak var passwordBox: HoshiTextField!
    @IBOutlet weak var showBtn: UIButton!
    @IBOutlet weak var phoneBox: HoshiTextField!
    @IBOutlet weak var cityBox: HoshiTextField!
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var termsCheckBox: UIImageView!
    @IBOutlet weak var termsView: UIView!
    var isTermsChecked:Bool = false
    @IBOutlet weak var inputContainer: UIView!
    
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

        showBtn.setImageTintColor(primaryLightColor)
        locationBtn.setImageTintColor(primaryLightColor)
        backBtn.setImageTintColor(.white)
        
        inputContainer.roundCorners(corners: [.topLeft], radius: 40)
        
        pictureBox.layer.cornerRadius = pictureBox.frame.height / 2
        
        nameBox.placeholder = "Name"
        nameBox.minimumFontSize = 5
        nameBox.textColor = primaryDarkColor
        nameBox.font = UIFont(name: "Helvetica", size: 17)
                
        emailBox.placeholder = "Email address"
        emailBox.minimumFontSize = 5
        emailBox.textColor = primaryDarkColor
        emailBox.font = UIFont(name: "Helvetica", size: 17)
        emailBox.keyboardType = UIKeyboardType.emailAddress
        
        passwordBox.placeholder = "Password"
        passwordBox.minimumFontSize = 5
        passwordBox.paddingRightCustom = 35
        passwordBox.textColor = primaryDarkColor
        passwordBox.font = UIFont(name: "Helvetica", size: 17)
        passwordBox.isSecureTextEntry = true
        
        phoneBox.placeholder = "Phone number"
        phoneBox.minimumFontSize = 5
        phoneBox.textColor = primaryDarkColor
        phoneBox.font = UIFont(name: "Helvetica", size: 17)
        phoneBox.keyboardType = .phonePad
        
        cityBox.placeholder = "City/state name"
        cityBox.minimumFontSize = 5
        cityBox.textColor = primaryDarkColor
        cityBox.font = UIFont(name: "Helvetica", size: 17)
        cityBox.isUserInteractionEnabled = false
        cityBox.isEnabled = false
        
        setRoundShadowButton(button: signupBtn, corner: signupBtn.frame.height/2)
        
        var config = YPImagePickerConfiguration()
        config.wordings.libraryTitle = "Gallery"
        config.wordings.cameraTitle = "Camera"
        YPImagePickerConfiguration.shared = config
        picker = YPImagePicker()
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(pickPicture))
        pictureBox.isUserInteractionEnabled = true
        pictureBox.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(checkTerms))
        termsView.isUserInteractionEnabled = true
        termsView.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recent = self
        gSignupViewController = self
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func checkTerms() {
        if !isTermsChecked {
            to(strb: "Main", vc: "TermsViewController", trans: true, modal: false, anim: false)
        }
    }
    
    func acceptTerms() {
        thisUser.terms = "read_terms"
        termsCheckBox.image = UIImage(systemName: "checkmark.square.fill")
        termsCheckBox.tintColor = primaryColor
        isTermsChecked = true
    }
    
    @objc func pickPicture(gesture:UITapGestureRecognizer){
        if (gesture.view as? UIView) != nil {
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
    
    @IBAction func togglePasswordShowing(_ sender: Any) {
        if showF == false{
            showBtn.setImage(unshow, for: UIControl.State.normal)
            showF = true
            passwordBox.isSecureTextEntry = false
        }else{
            showBtn.setImage(show, for: UIControl.State.normal)
            showF = false
            passwordBox.isSecureTextEntry = true
        }
        showBtn.setImageTintColor(primaryLightColor)
    }
    
    @IBAction func openMap(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PickLocationViewController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismissViewController()
    }
    
    @IBAction func signup(_ sender: Any) {
        if nameBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "Please enter your name.")
            return
        }
        if emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "Please enter your email.")
            return
        }
        
        if !isValidEmail(email: (emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) {
            showToast(msg: "Please enter a valid email.")
            return
        }
        
        if passwordBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "Please enter your password.")
            return
        }
        
        if (passwordBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count)! <= 5 {
            showToast(msg: "Please enter characters more than 5.")
            return
        }
        
        if phoneBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "Please enter your phone number.")
            return
        }
        
//        if !isValidPhone(phone: (phoneBox.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) {
//            showToast2(msg: "Enter a valid phone number.")
//            return
//        }
        
        if cityBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "Please enter your city.")
            return
        }
        
        if !isTermsChecked {
            showToast(msg: "Please read Terms and Privacy Policy.")
            return
        }
        
        var userId:Int64 = 0
        if thisUser.idx > 0 { userId = thisUser.idx }
            
        let parameters: [String:Any] = [
            "member_id" : String(userId),
            "name" : nameBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
            "email" : emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
            "password" : passwordBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
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
                        thisUser.idx = 0
                        self.showToast(msg: "Someone is using the same email.")
                    }else {
                        thisUser.idx = 0
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
                        thisUser.idx = 0
                        self.showToast(msg: "Someone is using the same email.")
                    }else {
                        thisUser.idx = 0
                        self.showToast(msg: "Something is wrong")
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
        
        let msg = """
        We have sent a verification link to
        your email. Please check your email.
        """
        
        let alert = UIAlertController(title: "Notice", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel){(ACTION) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.dismissViewController()
            }
        }
        alert.addAction(okAction)
        self.present(alert, animated:true, completion:nil);
    }
    
    
}
