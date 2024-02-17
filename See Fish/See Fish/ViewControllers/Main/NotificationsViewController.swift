//
//  NotificationsViewController.swift
//  See Fish
//
//  Created by james on 7/21/23.
//

import UIKit
import Kingfisher
import DropDown
import FirebaseCore
import FirebaseDatabase

class NotificationsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var notiList: UITableView!
    
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var noResult: UILabel!
    
    var messages = [Message]()
    var searchMessages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view_searchbar.isHidden = true
        
        edt_search.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        view_searchbar.backgroundColor = UIColor(rgb: 0x000000, alpha: 0.1)
        
        self.notiList.delegate = self
        self.notiList.dataSource = self
        
        self.notiList.estimatedRowHeight = 80.0
        self.notiList.rowHeight = UITableView.automaticDimension
        
        edt_search.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        self.getNotifications()

    }
    
    @IBAction func tap_search(_ sender: Any) {
        if view_searchbar.isHidden{
            view_searchbar.isHidden = false
            btn_search.setImage(UIImage(named: "ic_cancel.png"), for: .normal)
            lbl_title.isHidden = true
            edt_search.becomeFirstResponder()
            
        }else{
            view_searchbar.isHidden = true
            btn_search.setImage(UIImage(named: "ic_search.png"), for: .normal)
            lbl_title.isHidden = false
            self.edt_search.text = ""
            self.messages = searchMessages
            edt_search.resignFirstResponder()
            
            self.notiList.reloadData()
        }
    }
    
     /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:NotiCell = tableView.dequeueReusableCell(withIdentifier: "NotiCell", for: indexPath) as! NotiCell
        
        self.notiList.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
                
        let index:Int = indexPath.row
                
        if self.messages.indices.contains(index) {
            
            let message = self.messages[index]
                    
            if message.sender.photo_url != ""{
                loadPicture(imageView: cell.img_sender, url: URL(string: message.sender.photo_url)!)
            }
            
            cell.img_sender.layer.cornerRadius = cell.img_sender.frame.height / 2
                    
            cell.lbl_sender_name.text = message.sender.name
                
            cell.lbl_time.text = message.messaged_time
            if gHomeViewController.notifiedUsers.contains(where: {$0.idx == message.sender.idx}){
                cell.lbl_time.text = message.messaged_time + " " + "🔴".decodeEmoji
            }
            if message.sender.city != "" {
                cell.lbl_cohort.visibility = .visible
                cell.lbl_cohort.text = message.sender.city
            }else {
                cell.lbl_cohort.visibility = .gone
            }
            cell.lbl_body.text = message.message
            cell.lbl_body.padding = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
            
            cell.btn_menu.setImageTintColor(UIColor.gray)
                
            cell.btn_menu.tag = index
            cell.btn_menu.addTarget(self, action: #selector(openDropDownMenu), for: .touchUpInside)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tappedView(gesture:)))
            cell.view_content.tag = index
            cell.view_content.addGestureRecognizer(tap)
            cell.view_content.isUserInteractionEnabled = true
            
            cell.view_content.layer.cornerRadius = 5
                    
        }
        
        cell.lbl_body.sizeToFit()
        cell.view_content.sizeToFit()
        cell.view_content.layoutIfNeeded()
                
        return cell
    }
    
    @objc func tappedView(gesture:UITapGestureRecognizer){
        let index = gesture.view?.tag
        let message = self.messages[index!]
        gUser = message.sender
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SendMessageViewController")
        self.present(vc, animated: true, completion: nil)
    }
            
    
    @objc func textFieldDidChange(_ textField: UITextField) {        
        self.messages = filter(keyword: (textField.text?.lowercased())!)
        if messages.isEmpty {
            
        }
        self.notiList.reloadData()
    }
    
    func filter(keyword:String) -> [Message]{
        if keyword == "" {
            return searchMessages
        }
        var filteredMessages = [Message]()
        for message in searchMessages{
            if message.sender.name.lowercased().contains(keyword){
                filteredMessages.append(message)
            }else{
                if message.sender.address.lowercased().contains(keyword){
                    filteredMessages.append(message)
                }else{
                    if message.sender.city.lowercased().contains(keyword){
                        filteredMessages.append(message)
                    }else{
                        if message.messaged_time.contains(keyword){
                            filteredMessages.append(message)
                        }else{
                            if message.message.contains(keyword){
                                filteredMessages.append(message)
                            }
                        }
                    }
                }
            }
        }
        return filteredMessages
    }
    
    @objc func openDropDownMenu(sender:UIButton){
        let index = sender.tag
        let cell = sender.superview?.superviewOfClassType(NotiCell.self) as! NotiCell
            
        let dropDown = DropDown()
        
        let message = self.messages[index]
            
        dropDown.anchorView = cell.btn_menu
        dropDown.dataSource = ["  Read", "  Contact"]
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
            print("Selected item: \(item) at index: \(idx)")
            if idx == 0{
                var ref:DatabaseReference!
                ref = Database.database().reference(fromURL: FIREBASE_URL + "notify").child(String(thisUser.idx)).child(message.key)
                ref.removeValue()
            }else if idx == 1 {
                gUser = message.sender
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SendMessageViewController")
                self.present(vc, animated: true, completion: nil)
            }
        }
            
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.black
        DropDown.appearance().textFont = UIFont.boldSystemFont(ofSize: 13.0)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.gray
        DropDown.appearance().cellHeight = 40
        
        dropDown.separatorColor = UIColor.lightGray
        dropDown.width = 100
            
        dropDown.show()
            
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func getNotifications(){
        self.messages.removeAll()
                
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: FIREBASE_URL + "notify2").child(String(thisUser.idx))
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let value = snapshot.value as! [String: Any]
            
            let message = value["msg"] as! String
            let sender_id = value["sender_id"] as! String
            let sender_name = value["sender_name"] as! String
            let sender_email = value["sender_email"] as! String
            let sender_photo = value["sender_photo"] as! String
            let role = value["role"] as! String
            let type = value["type"] as! String
            let id = value["id"] as! String
            let mes_id = value["mes_id"] as! String
            var timeStamp = String(describing: value["date"])
            timeStamp = timeStamp.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
            let time = self.getDateTimeFromTimeStamp(timeStamp: Double(timeStamp)!/1000)
            let key = snapshot.key

            let user = User()
            user.idx = Int64(sender_id)!
            user.name = sender_name
            user.email = sender_email
            if gHomeViewController.users.contains(where: {$0.email == sender_email}){
                user.city = gHomeViewController.users.filter{user in return user.email == sender_email}[0].city
            }
            user.photo_url = sender_photo
            
            let noti = Message()
            noti.sender = user
            noti.messaged_time = time
            noti.timestamp = Int64(timeStamp)!
            noti.message = message
            noti.key = key
            noti.type = type
            noti.id = id
            if type == "message" {noti.status = "message"}
            else if type == "post" {noti.status = "post"}
            else if type == "route" {noti.status = "route"}
            else {noti.status = type}
            
            if !self.messages.contains(where: {$0.timestamp == noti.timestamp}) {
                self.messages.append(noti)
                self.searchMessages.append(noti)
                self.messages.sort(by: {$0.timestamp > $1.timestamp})
                self.notiList.reloadData()
                self.noResult.isHidden = true
            }
            
            print("Notifications////////////////: \(self.messages.count)")
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let key = snapshot.key
            if self.messages.contains(where: {$0.key == key}){
                self.messages.remove(at: self.messages.firstIndex(where: {$0.key == key})!)
                print("Notified Users////////////////: \(self.messages.count)")
                if self.messages.count > 0{self.messages.sort(by: {$0.timestamp > $1.timestamp})}
                self.notiList.reloadData()
            }
            if self.messages.count == 0 {
                self.noResult.isHidden = false
            }
        })
    }
    
}
