//
//  ViewController.swift
//  c9
//
//  Created by Uzi Benoliel on 5/5/20.
//  Copyright © 2020 Uzi Benoliel. All rights reserved.
//

import UIKit
import FileProvider
import AVFoundation

class CameraOrder: UIViewController, UIImagePickerControllerDelegate, UITableViewDataSource, UINavigationControllerDelegate {
 
    // =======================================================================================
    //                                          INIT
    // =======================================================================================
    var imagePicker: UIImagePickerController!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var vendorStyle: UITextField!
     
    @IBOutlet weak var userNotes: UITextView!
    @IBOutlet weak var picContainer: UIView!
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var wareBtn: UIButton!
    let tblRows = 5
    var imageWasCreated = false
    var qtyCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(imageTapDetected))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(singleTap)
        initTableViewRows()
        initControls()
    }
    
    func initControls(){
        roundBtnCorner(btn: wareBtn)
        roundContainer(container: picContainer)
        roundContainer(container: tableContainer)
    }
    
    func roundBtnCorner(btn:UIButton){
       btn.layer.borderWidth = 1
       btn.layer.borderColor = UIColor.blue.cgColor
       btn.layer.cornerRadius = 8
    }
   
    func roundContainer(container: UIView){
       let cornerRadius : CGFloat = 15.0
       container.layer.cornerRadius = cornerRadius
       container.layer.shadowColor = UIColor.darkGray.cgColor
       container.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
       container.layer.shadowRadius = 15.0
       container.layer.shadowOpacity = 0.9
    }
    
    // =======================================================================================
    //                                          IMAGE
    // =======================================================================================
    @objc func imageTapDetected() {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera

        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[.originalImage] as? UIImage
        imageWasCreated = true
    }
    
    // =======================================================================================
    //                                      SEND ORDER
    // =======================================================================================
    @IBAction func warehouseOrderClicked(_ sender: Any) {
        sendOrder(orderType: 1)
    }
    
    func sendOrder(orderType: Int){
        let fileName: String
        if imageWasCreated == true &&  vendorStyle.text != nil  && vendorStyle.text!.count > 0 && tableViewHasQty() {
            fileName = savePicLocaly()
            if fileName != "" {
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let localUrl = documentDirectory?.appendingPathComponent(fileName)

                if FileManager.default.fileExists(atPath: localUrl!.path){
                    if let cert = NSData(contentsOfFile: localUrl!.path) {
                        let fData: Data = cert as Data
                        ftpFile( fData: fData, fileName: fileName)
                        sendTableSelections(fileName: fileName, orderType: orderType)
                     }
                }
            }
        }else{
            beep(soundId:1073)
        }
    }
    
    func savePicLocaly()->String{
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        let fileName = getSettingData(key: "storeName") + "_" + dateFormatter.string(from: Date()) + ".jpg"
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        let um:UIImage
        let imgWidth = getSettingData(key:"imgWidth")
        um = resizeImage( image:imageView.image!, newWidth: CGFloat(Double(imgWidth)!))!
        if let data = um.jpegData(compressionQuality: 0), !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try data.write(to: fileURL)
                return fileName
            } catch {
                return ""
            }
        }
        else{
            return ""
        }
    }

    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func ftpFile(fData: Data, fileName: String){
        let ftpIp = getSettingData(key: "ftpIP")
        let ftpPass = getSettingData(key: "ftpPass")
        let ftpC = FTPUpload(baseUrl: ftpIp, userName: "ftpu", password: ftpPass, directoryPath: "/Downloads/Catalog/Orders")
        ftpC.send(data: fData, with: fileName, success: ftpSuccess)
    }
    
    func ftpSuccess( didSuccess: Bool){
    }
    
    // =======================================================================================
    //                                       TABLE VIEW
    // =======================================================================================    
    private var tableData: [String] = []
   
    func initTableViewRows(){
        for _ in 0...tblRows{
            tableData.append("")
        }
        tableView.dataSource = self
    
        var indexPath: IndexPath
        var cell: CameraTableviewCell
            
        indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: false)
        cell = self.tableView.cellForRow(at: indexPath) as! CameraTableviewCell
        cell.qtyPicker.selectRow(11, inComponent: 0, animated: true)
    }
 
    func numberOfSections(in tableView: UITableView)->Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)->Int{
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier") as! CameraTableviewCell
        return cell
    }
    func tableViewHasQty()->Bool{
        var indexPath: IndexPath
        var cell: CameraTableviewCell
        var qtyI: Int = 0
        
        for i in 0...self.tblRows{
            indexPath = IndexPath(row: i, section: 0)
            tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: false)
            cell = self.tableView.cellForRow(at: indexPath) as! CameraTableviewCell
            qtyI = cell.qtyPicker.selectedRow(inComponent: 0)
            if cell.qtyData[qtyI] != "" {
                return true
            }
        }
        return false
    }
 
    //==========================================================================================
    //                                      SEND DATA
    //==========================================================================================
    func sendTableSelections(fileName: String, orderType:Int){
        var indexPath: IndexPath
        var cell: CameraTableviewCell
        var colorI: Int = 0
        var sizeI: Int = 0
        var qtyI: Int = 0
        var orderInfo: String = ""
        
        indexPath = IndexPath(row: 0, section: 0)
        cell = self.tableView.cellForRow(at: indexPath) as! CameraTableviewCell
        
        let clientW = SQLClient.sharedInstance()!
        let storeName = getSettingData(key:"storeName")
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        let vStyleInfo = "'" + vendorStyle.text! + "','" + userNotes.text!
        clientW.disconnect()
              
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) {
            success in
            self.imageWasCreated = false
            for i in 0...self.tblRows{
                indexPath = IndexPath(row: i, section: 0)
              
                self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: false)

                cell = self.tableView.cellForRow(at: indexPath) as! CameraTableviewCell
                                        
                qtyI = cell.qtyPicker.selectedRow(inComponent: 0)
                if cell.qtyData[qtyI] != "" {
                    colorI = cell.colorPicker.selectedRow(inComponent: 0)
                    if cell.colorData[colorI] != ""{
                        sizeI = cell.sizePicker.selectedRow(inComponent: 0)
                        if cell.sizeData[sizeI] != "" {
                                orderInfo = cell.qtyData[qtyI] + " color:" + cell.colorData[colorI] + " size:" + cell.sizeData[sizeI]
                        }else {
                                orderInfo = cell.qtyData[qtyI] + " color:" + cell.colorData[colorI]
                        }
                    }else {
                            orderInfo = cell.qtyData[qtyI]
                    }
                    if i == 0{
                        cell.qtyPicker.selectRow(11, inComponent: 0, animated: true)
                    } else{
                        cell.qtyPicker.selectRow(0, inComponent: 0, animated: true)
                    }
                    
                    cell.colorPicker.selectRow(0, inComponent: 0, animated: true)
                    cell.sizePicker.selectRow(0, inComponent: 0, animated: true)
                    self.imageView.image = #imageLiteral(resourceName: "cam")
                    self.vendorStyle.text = ""
                    self.userNotes.text = ""
        
                    let sql1 = "INSERT INTO storeOrderTBL (storeID, fileName, orderInfo, orderType, vendorStyle, userNotes) VALUES ("
                    let sql2 = storeName + ",'" + fileName + "','" + orderInfo + "',"
                    let sql3 = String(orderType) + "," + vStyleInfo + "')"
                  
                    let sqls = sql1 + sql2 + sql3
                    clientW.execute(sqls) {results in
                        
                    }
                }
            }
            self.beep(soundId:1016)
            clientW.disconnect()
        }
    }
    
    //==========================================================================================
    //                                      GENERAL
    //==========================================================================================
    func beep(soundId: UInt32){
        AudioServicesPlaySystemSound (soundId)
    }

    func getSettingData( key: String)->String{
           let defaults = UserDefaults.standard
                  
           if UserDefaults.standard.object(forKey: key) == nil {
               return ""
           }else{
               return defaults.string(forKey: key)!
           }
    }
    
}
