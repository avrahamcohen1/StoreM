//
//  ItemInfo.swift
//  c9
//
//  Created by Uzi Benoliel on 5/11/20.
//  Copyright © 2020 Uzi Benoliel. All rights reserved.
//

import UIKit
import AVFoundation

class ItemSearch: UIViewController, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ScanDelegate, UIImagePickerControllerDelegate{
    @IBOutlet weak var qtyPicker: UIPickerView!
    @IBOutlet weak var searchItemID: UITextField!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemColors: UILabel!
    @IBOutlet weak var itemNameLBL: UILabel!
    @IBOutlet weak var itemSize: UILabel!
    @IBOutlet weak var vendorStyle: UILabel!
    @IBOutlet weak var vendorName: UILabel!
    @IBOutlet weak var warehouseOH: UILabel!
    @IBOutlet weak var monthSales: UILabel!
    @IBOutlet weak var yearSales: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemGroup: UILabel!

    @IBOutlet weak var qty: UITextField!
    @IBOutlet weak var orderNotes: UITextView!
    
    @IBOutlet weak var key1: UIButton!
    @IBOutlet weak var key2: UIButton!
    @IBOutlet weak var key3: UIButton!
    @IBOutlet weak var key4: UIButton!
    @IBOutlet weak var key5: UIButton!
    @IBOutlet weak var key6: UIButton!
    @IBOutlet weak var key7: UIButton!
    @IBOutlet weak var key8: UIButton!
    @IBOutlet weak var key9: UIButton!
    @IBOutlet weak var key0: UIButton!
    @IBOutlet weak var scannerBtn: UIButton!
    
    @IBOutlet weak var sizeXS: UIButton!
    @IBOutlet weak var sizeS: UIButton!
    @IBOutlet weak var sizeM: UIButton!
    @IBOutlet weak var sizeL: UIButton!
    @IBOutlet weak var sizeXL: UIButton!
    @IBOutlet weak var size2XL: UIButton!
    
    @IBOutlet weak var placeOrderBtn: UIButton!
    @IBOutlet weak var keyClear: UIButton!
    @IBOutlet weak var keySearch: UIButton!
    @IBOutlet weak var key50000: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var orderContainerView: UIView!
    @IBOutlet weak var keyboardContainer: UIView!
    @IBOutlet weak var infoContainer: UIView!
    
    @IBOutlet weak var uploadPicBtn: UIButton!
    @IBOutlet weak var saveQtyBtn: UIButton!
    @IBOutlet weak var storeSelect: UIPickerView!
    
    var imagePicker: UIImagePickerController!
    var imageWasCreated: Bool = false
    var itemExist: Bool = false
    let qtyData = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,24,28,30,32,36,40,42,48,50,60,70,80,90,100,120,200]
    var storeNames = ["421", "1670", "1451", "1441", "1332", "1301", "1208", "1155", "1051", "1041", "1036", "840", "645"]
    
    var wareOh: Int = 0
    var selectedItemID: Int64 = 0
    var serv: Services = Services()
    
    // ======================================================================================
    //                                      INIT
    // ======================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
        if selectedItemID > 0 {
            searchItemID.text = String(selectedItemID)
            searchItem()
        }
    }
     
    func initControls(){
        searchItemID.layer.borderWidth = 1
        searchItemID.layer.borderColor = UIColor.blue.cgColor
      
        roundLabelCorner( ctrl: itemNameLBL)
        roundLabelCorner( ctrl: itemPrice)
        roundLabelCorner( ctrl: itemSize)
        roundLabelCorner( ctrl: itemColors)
        roundLabelCorner( ctrl: vendorStyle)
        roundLabelCorner( ctrl: vendorName)
        roundLabelCorner( ctrl: warehouseOH)
        roundLabelCorner( ctrl: monthSales)
        roundLabelCorner( ctrl: yearSales)
        roundLabelCorner( ctrl: itemGroup)

        roundBtnCorner(btn:key0)
        roundBtnCorner(btn:key1)
        roundBtnCorner(btn:key2)
        roundBtnCorner(btn:key3)
        roundBtnCorner(btn:key4)
        roundBtnCorner(btn:key5)
        roundBtnCorner(btn:key6)
        roundBtnCorner(btn:key7)
        roundBtnCorner(btn:key8)
        roundBtnCorner(btn:key9)
        roundBtnCorner(btn:key50000)
        roundBtnCorner(btn:keySearch)
        roundBtnCorner(btn:keyClear)
        roundBtnCorner(btn: placeOrderBtn)
        roundBtnCorner(btn:scannerBtn)
        
        roundBtnCorner(btn:sizeXS)
        roundBtnCorner(btn:sizeS)
        roundBtnCorner(btn:sizeM)
        roundBtnCorner(btn:sizeL)
        roundBtnCorner(btn:sizeXL)
        roundBtnCorner(btn:size2XL)
        
        roundContainer(container: containerView)
        roundContainer(container: keyboardContainer)
        roundContainer(container: infoContainer)
        roundContainer(container: orderContainerView)
        
        uploadPicBtn.isHidden = true
        saveQtyBtn.isHidden = true
        
        qtyPicker.selectRow(11, inComponent: 0, animated: true)
        
        if getSettingData(key:"multiStore") == "1"{
            storeSelect.isHidden = true
        }else{
            storeSelect.isHidden = false
        }
    }
   
    func roundLabelCorner(ctrl:UILabel){
        ctrl.layer.borderWidth = 1
        ctrl.layer.borderColor = UIColor.blue.cgColor
        ctrl.layer.cornerRadius = 3
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
       
    // ======================================================================================
    //                                      KEYBOARD
    // ======================================================================================
    @IBAction func click1(_ sender: Any) {
        handleKey(keyNum:1)
    }
    @IBAction func click2(_ sender: Any) {
        handleKey(keyNum:2)
    }
    @IBAction func click3(_ sender: Any) {
        handleKey(keyNum:3)
    }
    @IBAction func click4(_ sender: Any) {
        handleKey(keyNum:4)
    }
    @IBAction func click5(_ sender: Any) {
        handleKey(keyNum:5)
    }
    @IBAction func click6(_ sender: Any) {
        handleKey(keyNum:6)
    }
    @IBAction func click7(_ sender: Any) {
        handleKey(keyNum:7)
    }
    @IBAction func click8(_ sender: Any) {
        handleKey(keyNum:8)
    }
    @IBAction func click9(_ sender: Any) {
        handleKey(keyNum:9)
    }
    @IBAction func click0(_ sender: Any) {
        handleKey(keyNum:0)
    }
    func handleKey(keyNum: Int){
        searchItemID.text = searchItemID.text! + String(keyNum)
    }
    @IBAction func click50000(_ sender: Any) {
        searchItemID.text = "50000"
    }
  
    @IBAction func clickClear(_ sender: Any) {
         ClearAll()
    }
    
    func ClearAll(){
        searchItemID.text = ""
        itemNameLBL.text = ""
        itemPrice.text = ""
        vendorStyle.text = ""
        vendorName.text = ""
        itemColors.text = ""
        qty.text = ""
        warehouseOH.text = ""
        monthSales.text = ""
        yearSales.text = ""
        orderNotes.text = ""
        itemGroup.text = ""
        qtyPicker.selectRow(11, inComponent: 0, animated: true)
        imageView.image = nil
        itemExist = false
        imageWasCreated = false
        uploadPicBtn.isHidden = true
        uploadPicBtn.setTitle("Take Picture", for: .normal)
    }
    
    // ======================================================================================
    //                                      SEARCH
    // ======================================================================================
    @IBAction func clickSearch(_ sender: Any) {
        searchItem()
    }
    
    func searchItem(){
      if searchItemID.text != nil && searchItemID.text != "" {
        uploadPicBtn.isHidden = serv.downloadImg(itemID: searchItemID.text!, imgV: imageView )
        let client = SQLClient.sharedInstance()!
        let sqlItemStr = "SELECT itemName, vendorStyle, itemPrice, itemColors, qty, vendorName FROM itemTBL LEFT JOIN vendorTBL ON vendorTBL.vendorID = itemTBL.vendorID WHERE itemID=" + searchItemID.text!
        let sqlY = "SELECT SUM(qty) as ttY FROM receiptItemTBL WHERE itemID=" + searchItemID.text! + " AND saleDate>='" + getOldDate(intervalDays:365) + "'"
        let sqlM = "SELECT SUM(qty) as ttM FROM receiptItemTBL WHERE itemID=" + searchItemID.text! + " AND saleDate>='" + getOldDate(intervalDays:90) + "'"
     
        let localIpPort = getSettingData(key:"localIP") + ":" + getSettingData(key:"localPort")
        client.disconnect()
        client.connect(localIpPort, username: "sa", password: getSettingData(key:"localPass"), database: getSettingData(key:"localDb")){
            success in
            client.execute(sqlItemStr) {
                results in
                if results != nil {
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            for column in row as! NSDictionary {
                                self.itemExist = true
                                switch column.key as! String{
                                    case "itemName":
                                        self.itemNameLBL.text = (column.value as! NSObject) as? String
                                    case "vendorStyle":
                                        self.vendorStyle.text = (column.value as! NSObject) as? String
                                    case "vendorName":
                                        self.vendorName.text = (column.value as! NSObject) as? String
                                    case "itemPrice":
                                        let iPrice: Double
                                        iPrice = (column.value as! NSObject) as? Double ?? 0.0
                                        self.itemPrice.text = String(format: "$%.02f", iPrice)
                                    case "qty":
                                        let qty: Int
                                        qty = (column.value as! NSObject) as? Int ?? 0
                                        self.qty.text = String(format: "%d", qty)
                                    case "itemColors":
                                        self.itemColors.text = (column.value as! NSObject) as? String
                                    default:
                                        let _: Int
                                }
                            }
                        }
                    }
                }
            }
                
            client.execute(sqlY) {
                results in
                if results != nil {
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            for column in row as! NSDictionary {
                                if column.key as! String == "ttY" {
                                    let salesY: Int
                                        salesY = (column.value as! NSObject) as? Int ?? 0
                                        self.yearSales.text = String(format: "%d", salesY)
                                }
                            }
                        }
                    }
                }
            }
                    
            client.execute(sqlM) {
                results in
                if results != nil {
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            for column in row as! NSDictionary {
                                if column.key as! String == "ttM" {
                                    let salesM: Int
                                    salesM = (column.value as! NSObject) as? Int ?? 0
                                    self.monthSales.text = String(format: "%d", salesM)
                                }
                            }
                        }
                    }
                }
            }
                
            client.disconnect()
            self.setWarehouseOh()
        }
      }
    }
    
    func setWarehouseOh(){
        let clientW = SQLClient.sharedInstance()!
        let sqlItemStr = "SELECT qty, groupName FROM itemTBL LEFT JOIN itemGroupTBL ON itemGroupTBL.groupID = itemTBL.itemGroupID WHERE itemID=" + searchItemID.text!
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
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
                                    switch column.key as! String{
                                        case "qty":
                                            self.wareOh = (column.value as! NSObject) as? Int ?? 0
                                            self.warehouseOH.text = String(format: "%d", self.wareOh)
                                        case "groupName":
                                            self.itemGroup.text = (column.value as! NSObject) as? String
                                        default: let _: Int
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // ======================================================================================
    //                                      SEND ORDER
    // ======================================================================================
    @IBAction func placeOrder(_ sender: Any) {
        let sName = getStoreName()
        let clientW = SQLClient.sharedInstance()!
        let sqlItemStr = "SELECT COUNT(itemID) as countID FROM storeOrderTBL WHERE orderStatus = 'Order Placed' AND storeID= " + sName + " AND itemID=" + searchItemID.text!
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) {success in
            if success {
                clientW.execute(sqlItemStr) {results in
                    if results != nil{
                        for table in results! as NSArray {
                            for row in table as! NSArray {
                                for column in row as! NSDictionary {
                                    switch column.key as! String{
                                            case "countID":
                                                let countId =  (column.value as! NSObject) as? Int ?? 0
                                                if countId > 0 {
                                                    let refreshAlert = UIAlertController(title: "Reorder same item", message: "There is already open order with this item. Are You Sure?", preferredStyle: UIAlertController.Style.alert)
                                                     refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                                                         self.checkSendOrderWithOH()
                                                     }))

                                                     refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                                                     }))

                                                     self.present(refreshAlert, animated: true, completion: nil)
                                                }else{self.checkSendOrderWithOH()}
                                            default: self.checkSendOrderWithOH()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func checkSendOrderWithOH(){
        let qtyIdx = qtyPicker.selectedRow(inComponent: 0)
        let orderQ = qtyData[qtyIdx]
              
        if wareOh < orderQ {
            let refreshAlert = UIAlertController(title: "On Hand Check", message: "Warehouse on hand is lower than the requested order. Are You Sure?", preferredStyle: UIAlertController.Style.alert)
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
        let itemID = String(searchItemID.text!)
        let notes = "'" + orderNotes.text! + "'"
        let qOrder = String(self.qtyData[ self.qtyPicker.selectedRow(inComponent: 0)])
        let clientW = SQLClient.sharedInstance()!
        let storeName = getStoreName()
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) {success in
            if success {
                let sql1 = "INSERT INTO storeOrderTBL (storeID, orderStatus, orderType, userNotes, itemID, qty) VALUES ("
                let sql2 = storeName + ",'Order Placed', 3, " + notes + "," + itemID + "," + qOrder + ")"
                let sqls = sql1 + sql2
                clientW.execute(sqls) {results in
                    self.ClearAll()
                }
                
                self.beep(soundCode:1016)
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
    
    // ======================================================================================
    //                                      PICKERS
    // ======================================================================================
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
     
    @IBAction func qtyChanged(_ sender: Any) {
        saveQtyBtn.isHidden = false
    }
    
    // ======================================================================================
    //                                      GENERAL
    // ======================================================================================
    func getOldDate(intervalDays: Int)->String{
           var dayComponent    = DateComponents()
           dayComponent.day    = -intervalDays
           let theCalendar     = Calendar.current
           let requstedDate    = theCalendar.date(byAdding: dayComponent, to: Date())!
           let df = DateFormatter()
           df.dateFormat = "MM-dd-yyyy"
           let retVal = df.string(from:requstedDate)
           return retVal
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
    
    @IBAction func saveClicked(_ sender: Any) {
        if qty.text != nil {
            saveQtyBtn.isHidden = true
            let itemIDStr = String(searchItemID.text!)
            let client = SQLClient.sharedInstance()!
            let localIpPort = getSettingData(key:"localIP") + ":" + getSettingData(key:"localPort")
                          
            client.disconnect()
            client.connect(localIpPort, username: "sa", password: getSettingData(key:"localPass"), database: getSettingData(key:"localDb")) {success in
                if success {
                    let sqlStr = "UPDATE itemTBL SET qty=" + self.qty.text! + " WHERE itemID =" + itemIDStr
                    client.execute(sqlStr) {results in
                        self.beep(soundCode:1016)
                    }
                               
                    client.disconnect()
                }
            }
        }
    }
    
    // =======================================================================================
    //                                      SCAN
    // =======================================================================================
    func onScannComplete(scannedItemID:String){
        searchItemID.text = scannedItemID
        searchItem()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "itemScanSegue" {
          let vc : Scanner = segue.destination as! Scanner
          vc.delegate = self
       }
    }
        
    // =======================================================================================
    //                                          IMAGE
    // =======================================================================================
    @IBAction func uploadPicClicked(_ sender: Any) {
        if itemExist == true && searchItemID.text != nil && searchItemID.text!.count > 0{
            if imageWasCreated == false{
                 imagePicker =  UIImagePickerController()
                 imagePicker.delegate = self
                 imagePicker.sourceType = .camera

                 present(imagePicker, animated: true, completion: nil)
            }else{
                 ftpUploadImgsAndSave()
                 imageWasCreated = false
                 uploadPicBtn.setTitle("Take Picture", for: .normal)
            }
        }
        
    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[.originalImage] as? UIImage
        imageWasCreated = true
        uploadPicBtn.setTitle("Save Picture", for: .normal)
    }
    
    func ftpUploadImgsAndSave(){
        let ftpIp = getSettingData(key: "ftpIP")
        let ftpPass = getSettingData(key: "ftpPass")
        let imgWidth = getSettingData(key:"imgWidth")
        let fileName = String(searchItemID.text!) + ".jpg"
        
        let um1 = self.resizeImage(image:imageView.image!, newWidth: CGFloat(Double(imgWidth)!))!
        let fData1 = um1.jpegData(compressionQuality: 0)!
          
        let um2 = self.resizeImage(image:um1, newWidth: 150.0)!
        let fData2 = um2.jpegData(compressionQuality: 0)!
          
        let ftpC1 = FTPUpload(baseUrl: ftpIp, userName: "ftpu", password: ftpPass, directoryPath: "/Downloads/Catalog/")
        ftpC1.send(data: fData1, with: fileName, success: ftpSuccess)
          
        let ftpC2 = FTPUpload(baseUrl: ftpIp, userName: "ftpu", password: ftpPass, directoryPath: "/Downloads/Catalog/smallPic")
        ftpC2.send(data: fData2, with: fileName, success: ftpSuccess)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
                     
        let data = um2.jpegData(compressionQuality: 0)
        do {
            try data!.write(to: fileURL)
        } catch {}
        
        sqlUpdateImgStatus()
    }
      
    func ftpSuccess( didSuccess: Bool){
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
    
    func sqlUpdateImgStatus(){
        let itemID = String(searchItemID.text!)
        let clientW = SQLClient.sharedInstance()!
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
            
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) {success in
            if success {
                let date = Date()
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateStr = format.string(from: date)
                let sqlStr = "UPDATE itemTBL SET hasImg = 1, imgDate ='" + dateStr + "' WHERE itemID = " + itemID
                clientW.execute(sqlStr) {results in}
                clientW.disconnect()
            }
        }
    }
    
    // =======================================================================================
    //                                          NOTES
    // =======================================================================================
    
    @IBAction func sizeXS_Clicked(_ sender: Any) {
        orderNotes.text = "Size: XS"
    }
    
    @IBAction func sizeS_Clicked(_ sender: Any) {
         orderNotes.text = "Size: S"
    }
    
    @IBAction func sizeM_Clicked(_ sender: Any) {
         orderNotes.text = "Size: M"
    }
    
    @IBAction func sizeL_Clicked(_ sender: Any) {
         orderNotes.text = "Size: L"
    }
    
    @IBAction func sizeXL_Clicked(_ sender: Any) {
         orderNotes.text = "Size: XL"
    }
    
    @IBAction func size2XL_Clicked(_ sender: Any) {
         orderNotes.text = "Size: 2XL"
    }
    
}
