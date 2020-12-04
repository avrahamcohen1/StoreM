//
//  StyleSearch.swift
//  Surf Style
//
//  Created by avi on 6/1/20.
//  Copyright © 2020 EDY. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class StyleSearch: UIViewController, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var styleTxt: UITextField!
    
    @IBOutlet weak var placeBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
   
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var placeOrderVC: UIView!
    @IBOutlet weak var qtyPicker: UIPickerView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var maxOrder: UILabel!
    
    @IBOutlet weak var itemColors: UILabel!
    @IBOutlet weak var vendorStyle: UILabel!
    @IBOutlet weak var itemName: UILabel!
    
    @IBOutlet weak var storeSelect: UIPickerView!
    let qtyData = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,24,28,30,32,36,40,42,48,50,60,70,80,90,100,120,200]
    var storeNames = ["421", "1670", "1451", "1441", "1332", "1301", "1208", "1155", "1051", "1041", "1036", "840", "645"]
    
    var styleDetails = [StyleDetails]()
    var maxWareOh: Int = 0
    var selectedItemID: Int64 = 0
    
    // =================================================
    //              init
    // =================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
    }
    
    func initControls(){
        roundTextCorner(ctrl: styleTxt)
                
        roundContainer(container:imageContainer)
        roundContainer(container:placeOrderVC)
        roundBtnCorner(btn: placeBtn)
        roundBtnCorner(btn: searchBtn)
        
        if getSettingData(key:"multiStore") == "1"{
            storeSelect.isHidden = true
        }else{
            storeSelect.isHidden = false
        }
        clearAll()
    }
    
    func clearAll(){
        qtyPicker.selectRow(11, inComponent: 0, animated: true)
        placeOrderVC.isHidden = true
        imageView.image = nil
        styleDetails.removeAll()
        tableView.reloadData()
    }
    
    func roundLabelCorner(ctrl:UILabel){
        ctrl.layer.borderWidth = 1
        ctrl.layer.borderColor = UIColor.blue.cgColor
        ctrl.layer.cornerRadius = 8
    }
    
    func roundTextCorner(ctrl:UITextField){
        ctrl.layer.borderWidth = 1
        ctrl.layer.borderColor = UIColor.blue.cgColor
        ctrl.layer.cornerRadius = 8
    }
    
    func roundBtnCorner(btn:UIButton){
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.blue.cgColor
        btn.layer.cornerRadius = 8
    }
     
    func roundContainer(container: UIView){
        let cornerRadius : CGFloat = 12.0
        container.layer.cornerRadius = cornerRadius
        container.layer.shadowColor = UIColor.darkGray.cgColor
        container.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        container.layer.shadowRadius = 12.0
        container.layer.shadowOpacity = 0.9
    }
    
    // =================================================
    //                  search
    // =================================================
    @IBAction func searchClicked(_ sender: Any) {
        if styleTxt.text != nil && styleTxt.text != "" {
            clearAll()
            styleTxt.resignFirstResponder()
            let client = SQLClient.sharedInstance()!
            let sqlItemStr = "SELECT itemName, vendorStyle, itemPrice, itemColors, qty, vendorName, itemID FROM itemTBL LEFT JOIN vendorTBL ON vendorTBL.vendorID = itemTBL.vendorID WHERE vendorStyle LIKE '%" + styleTxt.text! + "%' ORDER BY qty DESC"
            let localIpPort = getSettingData(key:"localIP") + ":" + getSettingData(key:"localPort")
            client.disconnect()
            client.connect(localIpPort, username: "sa", password: getSettingData(key:"localPass"), database: getSettingData(key:"localDb")){
                success in
                client.execute(sqlItemStr) {
                    results in
                    if results != nil {
                        for table in results! as NSArray {
                            for row in table as! NSArray {
                                self.styleDetails.append(StyleDetails(itemID:0, itemName: "", qty:0, wareOh:0, vendorStyle:"", itemColors:"", vendorName:"", itemPrice:0))
                                let i = self.styleDetails.count - 1
                                                         
                                for column in row as! NSDictionary {
                                    switch column.key as! String{
                                        case "itemID":
                                            self.styleDetails[i].itemID = (column.value as! NSObject) as? Int64 ?? 0
                                        case "itemName":
                                            self.styleDetails[i].itemName = (column.value as! NSObject) as? String
                                        case "vendorStyle":
                                            self.styleDetails[i].vendorStyle = (column.value as! NSObject) as? String
                                        case "itemPrice":
                                            self.styleDetails[i].itemPrice = (column.value as! NSObject) as? Double ?? 0.0
                                        case "qty":
                                            self.styleDetails[i].qty = (column.value as! NSObject) as? Int ?? 0
                                        case "itemColors":
                                            self.styleDetails[i].itemColors = (column.value as! NSObject) as? String
                                        case "vendorName":
                                            self.styleDetails[i].vendorName = (column.value as! NSObject) as? String
                                        default:
                                            let _: Int
                                    }
                                }
                            }
                        }
                        self.setWarehouseOh()
                    }
                }
                client.disconnect()
            }
        }
    }
    
    func setWarehouseOh(){
        let clientW = SQLClient.sharedInstance()!
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        let db = getSettingData(key:"wareDb")
        let pass = getSettingData(key:"warePass")
        var sqlItemStr: String = ""
        
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: pass, database: db) { success in
            for i in 0...self.styleDetails.count - 1{
                sqlItemStr = "SELECT qty FROM itemTBL WHERE itemID=" + String(self.styleDetails[i].itemID!)
                clientW.execute(sqlItemStr) {results in
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            for column in row as! NSDictionary {
                                self.styleDetails[i].wareOh = (column.value as! NSObject) as? Int ?? 0
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // =================================================
    //                  table view
    // =================================================
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StyleSearchCellTableViewCell
            
        let sDetails: StyleDetails
        sDetails = styleDetails[indexPath.row]
        
        let iPrice: Double = sDetails.itemPrice!
        cell.itemPrice.text = String(format: "$%.02f", iPrice)
        cell.vendorStyle.text = sDetails.vendorStyle
        cell.itemName.text = sDetails.itemName
        cell.itemColors.text = sDetails.itemColors
        cell.vendorName.text = sDetails.vendorName
        cell.qty.text = String(sDetails.qty!)
        cell.wareOh.text = String(sDetails.wareOh!)
        maxWareOh = sDetails.wareOh!
        selectedItemID = sDetails.itemID!
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return styleDetails.count
    }
    
    func numberOfSections(in tableView: UITableView)->Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.05)
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemID = "Catalog/smallPic/" + String(styleDetails[indexPath.row].itemID!) + ".jpg"
        
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsUrl.appendingPathComponent(itemID)
            if fileExist(fileName: itemID){
                do{
                    let imageData = try Data(contentsOf: fileURL)
                    imageView.image =  UIImage(data: imageData)
                }catch{}
            }else{
                imageView.image = nil
            }
            maxWareOh = styleDetails[indexPath.row].wareOh!
            itemName.text = styleDetails[indexPath.row].itemName!
            vendorStyle.text = styleDetails[indexPath.row].vendorStyle!
            itemColors.text = styleDetails[indexPath.row].itemColors!
                              
            maxOrder.text = "Max Order:" + String(maxWareOh)
            
            placeOrderVC.isHidden = false
        }
    }
        
    // =================================================
    //                  place order
    // =================================================
    @IBAction func placeOrder(_ sender: Any) {
        let qtyIdx = qtyPicker.selectedRow(inComponent: 0)
        let orderQ = qtyData[qtyIdx]
           
        if maxWareOh < orderQ {
            let refreshAlert = UIAlertController(title: "Item Order", message: "Warehouse on hand is lower than the requested order. Are You Sure?", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                self.sendOrder()
        }))

        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
        }))

        present(refreshAlert, animated: true, completion: nil)
        }else{
            sendOrder()
        }
    }
    
    func sendOrder(){
        let itemID = String( selectedItemID )
        let noteStr = "'" + notes.text! + "'"
        let qOrder = String(self.qtyData[ self.qtyPicker.selectedRow(inComponent: 0)])
        let clientW = SQLClient.sharedInstance()!
        let sName = getStoreName()
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
           
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) {success in
            let sql1 = "INSERT INTO storeOrderTBL (storeID, orderStatus, orderType, userNotes, itemID, qty) VALUES ("
            let sql2 = sName + ",'Order Placed', 3, " + noteStr + "," + itemID + "," + qOrder + ")"
            let sqls = sql1 + sql2
            clientW.execute(sqls) {results in
                self.clearAll()
                self.beep(soundCode:1016)
                self.styleTxt.text = ""
                clientW.disconnect()
            }
        }
    }
    
    func getStoreName()->String{
        var sName: String = ""
        if getSettingData(key:"multiStore") == "1"{
            sName = getSettingData(key:"storeName")
        }else{
            sName = storeNames[storeSelect.selectedRow(inComponent: 0)]
        }
        return sName
    }
    
    // =================================================
    //                  picker view
    // =================================================
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
       
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) ->Int{
        if pickerView == qtyPicker{
            return qtyData.count
        }else{
            return storeNames.count
        }
    }
       
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)->String? {
        if pickerView == qtyPicker{
            return String(qtyData[row])
        }else{
            return String(storeNames[row])
        }
    }
    
    // =================================================
    //                  general
    // =================================================
    func getSettingData( key: String)->String{
        let defaults = UserDefaults.standard
                    
        if UserDefaults.standard.object(forKey: key) == nil {
               return ""
        }else{
            return defaults.string(forKey: key)!
        }
    }
           
    func beep(soundCode:Int){
        AudioServicesPlaySystemSound( SystemSoundID(soundCode) )
    }
    
    func fileExist(fileName: String)->Bool{
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let localUrl = documentDirectory?.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: localUrl!.path){
            return true
        }else{
            return false
        }
    }

    func downloadImg(itemIDStr:String){
        let ftpPass = getSettingData(key: "ftpPass")
        let ftpIP = getSettingData(key: "ftpIP")
        let url = URL(string: "ftp://ftpu:" + ftpPass + "@" + ftpIP + "/Catalog/" + itemIDStr + ".jpg")
        if let anUrl = url {
            do{
                let imageData = try Data(contentsOf: anUrl)
                imageView.image =  UIImage(data: imageData)
            }catch{
                print("Error ftp image")
            }
        }
    }
}
