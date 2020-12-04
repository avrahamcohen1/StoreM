//
//  ViewLargeImg.swift
//  Surf Style
//
//  Created by avi on 7/3/20.
//  Copyright © 2020 EDY. All rights reserved.
//

import Foundation
import UIKit
import FileProvider
import AVFoundation

class ViewLargeImg: UIViewController,  UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var itemIdTxt: UILabel!
    @IBOutlet weak var reorderBtn: UIButton!
    @IBOutlet weak var imgView: UIView!
    @IBOutlet weak var reorderView: UIView!
    @IBOutlet weak var largeImg: UIImageView!
    @IBOutlet weak var wareOhLbl: UILabel!
    @IBOutlet weak var orderQTY: UIPickerView!
    @IBOutlet weak var notes: UITextView!
    
    var wareOh:Int = 0
    var selectedItemId:Int64 = 0
    var orderType:Int = 0
    var orderNum:Int = 0
    var imgLocalFileName:String  = ""
    
    let qtyData = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,24,28,30,32,36,40,42,48,50,60,70,80,90,100,120,200]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initForm()
    }
    
    func initForm(){
        if orderType == 3{
            downloadLargeImg()
            setWarehouseOh()
        }else{
            setLocalOrderImg()
        }
        
        roundBtnCorner(btn:reorderBtn)
        roundContainer(container:reorderView)
        roundContainer(container:imgView)
        
        orderQTY.dataSource = self
        orderQTY.delegate = self
        orderQTY.selectRow(11, inComponent: 0, animated: true)
        
    }
    
    func downloadLargeImg(){
       let fileName = "/Catalog/" + String(selectedItemId) + ".jpg"
       let webUrl = URL(string: "http://" + UserDefaults.standard.string(forKey:"wareIP")! + "/Downloads/" + fileName)
                
       if let anUrl = webUrl {
           do{
               let imageData = try Data(contentsOf: anUrl)
               largeImg.image =  UIImage(data: imageData)
           }catch{
               print("Error ftp image")
           }
       }
    }
   
    
    func setLocalOrderImg(){
        var fileURL: URL
       
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            fileURL = documentsUrl.appendingPathComponent(imgLocalFileName)
            do{
                let imageData = try Data(contentsOf: fileURL)
                largeImg.image =  UIImage(data: imageData)
            }catch{}
    
        }
    }
    
    func setWarehouseOh(){
        let clientW = SQLClient.sharedInstance()!
        let sqlItemStr = "SELECT qty, vendorStyle, itemColors, itemName FROM itemTBL WHERE itemID=" + String(selectedItemId)
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        var style: String = ""
        var colors: String = ""
        var itemName: String = ""
        
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) {
            success in
            if success {
                 clientW.execute(sqlItemStr) {
                    results in
                    if results != nil {
                        for table in results! as NSArray {
                            for row in table as! NSArray {
                                for column in row as! NSDictionary {
                                    switch column.key as! String {
                                        case "qty":
                                            self.wareOh = (column.value as! NSObject) as? Int ?? 0
                                            self.wareOhLbl.text = "Warehouse OH:" + String(format: "%d", self.wareOh)
                                        case "itemName":
                                            itemName = "item ID:" + String(self.selectedItemId) + "  Item Name:" + ((column.value as! NSObject) as! String)
                                        case "vendorStyle":
                                            if let strVal = column.value as? String {
                                                style = ", Style:" +  strVal
                                            }
                                       case "itemColors":
                                            if let strVal = column.value as? String {
                                                colors = ", Colors:" +  strVal
                                            }
                                        default:
                                            let _: Int
                                    }
                                }
                                self.itemIdTxt.text = itemName +  style + colors
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendOrderClick(_ sender: Any) {
         let qtyIdx = orderQTY.selectedRow(inComponent: 0)
         let orderQ = qtyData[qtyIdx]
         
         if wareOh < orderQ {
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
        let itemID = String(selectedItemId)
        let notesStr = "'" + notes.text! + "'"
        let qOrder = String(self.qtyData[ self.orderQTY.selectedRow(inComponent: 0)])
        let clientW = SQLClient.sharedInstance()!
        let storeName = getSettingData(key:"storeName")
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) {success in
            if success {
                let sql1 = "INSERT INTO storeOrderTBL (storeID, orderStatus, orderType, userNotes, itemID, qty) VALUES ("
                let sql2 = storeName + ",'Order Placed', 3, " + notesStr + "," + itemID + "," + qOrder + ")"
                let sqls = sql1 + sql2
                
                clientW.execute(sqls) {results in
                    clientW.disconnect()
                    self.beep(soundCode:1016)
                    self.returnHome()                    
                }
            }
        }
    }
        
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
     
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) ->Int{
        return qtyData.count
    }
     
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)->String? {
        return String(qtyData[row])
    }
    
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
    
    func returnHome(){
          if let nav = self.navigationController {
              nav.popViewController(animated: true)
          } else {
              self.dismiss(animated: true, completion: nil)
          }
    }
    func roundBtnCorner(btn:UIButton){
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.blue.cgColor
        btn.layer.cornerRadius = 5
    }
    
    func roundContainer(container: UIView){
        let cornerRadius : CGFloat = 12.0
        container.layer.cornerRadius = cornerRadius
        container.layer.shadowColor = UIColor.darkGray.cgColor
        container.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        container.layer.shadowRadius = 12.0
        container.layer.shadowOpacity = 0.9
    }
}
