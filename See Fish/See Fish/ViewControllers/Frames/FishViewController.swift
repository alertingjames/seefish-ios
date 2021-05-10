//
//  FishViewController.swift
//  See Fish
//
//  Created by Andre on 11/3/20.
//

import UIKit
import ALCameraViewController

class FishViewController: BaseViewController {
    
    @IBOutlet weak var img_fish: UIImageView!
    @IBOutlet weak var btn_camera: UIButton!
    @IBOutlet weak var btn_ruler: UIButton!
    @IBOutlet weak var btn_classification: UIButton!
    @IBOutlet weak var lbl_result: UILabel!
    @IBOutlet weak var btn_share: UIButton!
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    @IBOutlet weak var ic_fish: UIImageView!
    @IBOutlet weak var iconBottom: NSLayoutConstraint!
    var fishPostInputBox:FishPostInputBox!
    
    var imageFile:Data!
    var image:UIImage!
    var deviceID:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gFishViewController = self

        setRoundShadowButton(button: btn_camera, corner: btn_camera.frame.height/2)
        setRoundShadowButton(button: btn_ruler, corner: btn_ruler.frame.height/2)
        setRoundShadowButton(button: btn_share, corner: btn_share.frame.height/2)
        setRoundShadowButton(button: btn_classification, corner: btn_classification.frame.height/2)
        
        btn_classification.setImageTintColor(.white)
        
        fishPostInputBox = (self.storyboard!.instantiateViewController(withIdentifier: "FishPostInputBox") as! FishPostInputBox)
        fishPostInputBox.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        fishPostInputBox.alertView.alpha = 0
        
        if (UIDevice.current.identifierForVendor?.uuidString) != nil {
            deviceID = UIDevice.current.identifierForVendor!.uuidString
            print("Device ID: \(deviceID)")
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear( animated )
        if self.image == nil {
            let orgY = self.ic_fish.center.y
            self.ic_fish.isHidden = true
            self.ic_fish.center.y = self.screenHeight
            self.ic_fish.rotate()
            UIView.animate(withDuration: 1.0, delay: 0, options: UIView.AnimationOptions.curveEaseOut,animations: {
                self.ic_fish.isHidden = false
                self.ic_fish.center.y = orgY
            }, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.image == nil {
            imageFile = nil
            img_fish.image = nil
            lbl_result.text = ""
            resultName = ""
            ic_fish.isHidden = true
        }
    }
    
    @IBAction func openCamera(_ sender: Any) {
        let cameraViewController = CameraViewController { [weak self] image, asset in
            // Do something with your image here.
            self?.image = image
            if image != nil {
                self?.img_fish.image = image
                self?.img_fish.contentMode = .scaleAspectFit
                self?.img_fish.frame.size.width = self!.screenWidth
                self?.img_fish.frame.size.height = self!.screenHeight - 190
                self?.imageFile = image!.jpegData(compressionQuality: 0.8)
                self?.ic_fish.isHidden = true
//                self?.process()
            }
            self?.dismiss(animated: true, completion: nil)
        }
        cameraViewController.modalPresentationStyle = .fullScreen
        present(cameraViewController, animated: true, completion: nil)
    }
    
    @IBAction func classify(_ sender: Any) {
        if self.imageFile != nil {
            self.process()
        }
    }
    
    @IBAction func toMeasurement(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "MeasureViewController")
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func postFish(_ sender: Any) {
        if imageFile == nil {
            return
        }
//        if resultName == "" {
//            return
//        }
        showAlertDialog()
    }
    
    func showAlertDialog(){
        UIView.animate(withDuration: 0.3) { [self] in
            fishPostInputBox.descBox.text = resultName
//            fishPostInputBox.descBox.checkPlaceholder()
            self.addChild(self.fishPostInputBox)
            self.view.addSubview(self.fishPostInputBox.view)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.fishPostInputBox.showAlert()
        }
    }
    
    var resultName = ""
    
    func process() {
        resultName = ""
        if imageFile != nil{
            self.progressBar.isHidden = false
            lbl_result.text = "Identifying..."
            APIs.identifyFish(deviceID: deviceID, file: imageFile, handleCallback: { [self]
                name, prob, result_code in
                self.progressBar.isHidden = true
                print(result_code)
                if result_code == "0"{
                    if Float(prob)! < 0.6 {
                        lbl_result.text = "Not found..."
                    }else {
                        lbl_result.text = "It is " + name
                        resultName = name
                    }
                }
                else{
                    lbl_result.text = "Not found..."
                }
            })
        }else {
            showToast(msg: "Please load a fish picture.")
        }
    }
    
    func postFish(desc:String) {
        let parameters: [String:Any] = [
            "post_id" : "0",
            "member_id" : String(thisUser.idx),
            "content" : desc as Any,
            "pic_count" : "1" as Any,
        ]
        
        let ImageArray:NSMutableArray = []
        ImageArray.add(self.imageFile!)
        
        self.showLoadingView()
        APIs().postImageArrayRequestWithURL(withUrl: SERVER_URL + "createimagepost", withParam: parameters, withImages: ImageArray) { (isSuccess, response) in
            // Your Will Get Response here
            self.dismissLoadingView()
            print("Post Response: \(response)")
            if isSuccess == true{
                let result = response["result_code"] as Any
                print("Result: \(result)")
                if result as! String == "0"{
                    self.showToast(msg: "Your feed posted successfully.")
                    gMainViewController.selectedIndex = 0
                }else if result as! String == "1"{
                    self.showToast(msg: "Your account doesn\'t exist")
                    self.logout()
                }else{
                    self.showToast(msg: "Something is wrong")
                }
            }else{
                let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
                print("Issue: \n" + message)
                self.showToast(msg: "Image file issue")
            }
        }
    }
    
}
