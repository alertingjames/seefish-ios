//
//  CategoryListVC.swift
//  See Fish
//
//  Created by james on 12/5/22.
//

import UIKit
import Alamofire
import SwiftyJSON

class CategoryListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var listView: UITableView!
    @IBOutlet weak var view_search: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var noResult: UILabel!
    
    var categories = [FishCategory]()
    var allCategories = [FishCategory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view_search.isHidden = true
        edt_search.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        edt_search.underlined()
        
        listView.delegate = self
        listView.dataSource = self
        listView.estimatedRowHeight = 60.0
        listView.rowHeight = UITableView.automaticDimension
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor(rgb: 0x0BFFFF, alpha: 1.0) ]
        
        categories.removeAll()
        allCategories.removeAll()
        if !gCategoryList.isEmpty {
            for category in gCategoryList {
                categories.append(category)
                allCategories.append(category)
            }
            noResult.isHidden = !categories.isEmpty
        }
        var fc = FishCategory()
        fc.label = ""
        fc.name = "Uncategorized"
        fc.color = "#ffff00"
        categories.insert(fc, at: 0)
        listView.reloadData()
        
        getXIMCategories()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
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
            categories = filter(keyword: "")
            noResult.isHidden = !categories.isEmpty
            listView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FishCategoryCell = tableView.dequeueReusableCell(withIdentifier: "FishCategoryCell", for: indexPath) as! FishCategoryCell
        let index:Int = indexPath.row
        if categories.indices.contains(index) {
            let category = categories[index]
            cell.categoryNameBox.text = category.name
            cell.categoryNameBox.textColor = .black
            cell.colorView.backgroundColor = hexStringToUIColor(hex: category.color)
            if category.name.starts(with: "Uncategorized") {
                cell.categoryNameBox.textColor = .red
                cell.colorView.backgroundColor = .yellow
            }
            cell.colorView.layer.cornerRadius = cell.colorView.frame.height / 2
            cell.colorView.layer.masksToBounds = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(selectCategory(gesture:)))
            cell.containerView.tag = index
            cell.containerView.isUserInteractionEnabled = true
            cell.containerView.addGestureRecognizer(tap)
            
            cell.containerView.sizeToFit()
            cell.containerView.layoutIfNeeded()
        }
        return cell
        
    }
    
    @objc func selectCategory(gesture:UITapGestureRecognizer) {
        let index = gesture.view!.tag
        var category = categories[index]
        if recent == gImageSubmitViewController {
            gImageSubmitViewController.categoryBox.text = category.name
        }else if recent == gEditImagePostViewController {
            gEditImagePostViewController.categoryBox.text = category.name
        }else if recent == gVideoSubmitViewController {
            gVideoSubmitViewController.categoryBox.text = category.name
        }
        self.dismiss(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        categories = filter(keyword: (textField.text?.lowercased())!)
        noResult.isHidden = !categories.isEmpty
        listView.reloadData()
    }
        
    func filter(keyword:String) -> [FishCategory]{
        if keyword == ""{
            return allCategories
        }
        var filteredData = [FishCategory]()
        for category in allCategories {
            if category.name.lowercased().contains(keyword){
                filteredData.append(category)
            }
        }
        return filteredData
    }
    
    
    func getXIMCategories() {
        if gCategoryList.isEmpty { showLoadingView() }
        Alamofire.request(SERVER_URL + "ximlabels", method: .get).responseJSON { response in
            if gCategoryList.isEmpty { self.dismissLoadingView() }
            if response.result.isFailure{
                self.showAlertDialog(title: "Notice", message: "SERVER ERROR 500")
            } else {
                let json = JSON(response.result.value!)
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let id = data["id"] as! String
                        let name = data["name"] as! String
                        let color = data["color"] as! String
                        var category = FishCategory()
                        category.label = id
                        category.name = name
                        category.color = color
                        if !self.categories.contains(where: { $0.name == category.name }) { self.categories.append(category) }
                        if !self.allCategories.contains(where: { $0.name == category.name }) { self.allCategories.append(category) }
                    }
                    gCategoryList = self.allCategories
                    self.noResult.isHidden = !self.categories.isEmpty
                    self.listView.reloadData()
                } else {
                    self.showAlertDialog(title: "Notice", message: "SERVER ERROR 500")
                }
                
            }
        }
    }
    


}



