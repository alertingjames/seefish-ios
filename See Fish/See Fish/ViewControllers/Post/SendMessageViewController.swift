//
//  SendMessageViewController.swift
//  See Fish
//
//  Created by Andre on 11/7/20.
//

import UIKit

class SendMessageViewController: BaseViewController {
    
    @IBOutlet weak var img_user: UIImageView!
    @IBOutlet weak var btn_send: UIButton!
    @IBOutlet weak var txv_message: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn_send.isHidden = true

        img_user.layer.cornerRadius = img_user.frame.height / 2
        loadPicture(imageView: img_user, url: URL(string: gUser.photo_url)!)
        
        txv_message.setPlaceholder2(string: "Write something here...")
        txv_message.layer.cornerRadius = 10
        txv_message.delegate = self
        txv_message.textContainerInset = UIEdgeInsets(top: 18, left: 8, bottom: txv_message.textContainerInset.bottom, right: txv_message.textContainerInset.right)
        
        txv_message.becomeFirstResponder()
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.checkPlaceholder()
        if textView.text == ""{
            btn_send.isHidden = true
        }else{
            btn_send.isHidden = false
        }
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if txv_message.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "Please write your message...")
            return
        }
        sendMessage(me_id: thisUser.idx, member_id: gUser.idx, message: txv_message.text.trimmingCharacters(in: .whitespacesAndNewlines))        
    }
    
    func sendMessage(me_id:Int64, member_id: Int64, message:String){
        self.showLoadingView()
        APIs.sendMessage(me_id:me_id, member_id: member_id, message: message, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "Message sent!")
                self.txv_message.text = ""
                self.txv_message.checkPlaceholder()
                self.btn_send.isHidden = true
            }else if result_code == "1"{
                self.showToast(msg: "Your account doesn\'t exist")
                self.logout()
            }else if result_code == "2"{
                self.showToast(msg: "This user doesn\'t exist")
                self.dismissViewController()
            }else if result_code == "101"{
                self.showToast(msg:"This user has already been blocked.")
                self.dismiss(animated: true, completion: nil)
            }else if result_code == "102"{
                self.showToast(msg:"You have already been blocked by this user.")
                self.dismiss(animated: true, completion: nil)
            }else{
                self.showToast(msg: "Something is wrong")
                
            }
        })
    }

}
