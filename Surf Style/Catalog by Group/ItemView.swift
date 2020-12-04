import UIKit
import AVFoundation

class ItemView: UIViewController , UIPickerViewDataSource, UIPickerViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
   
    @IBOutlet weak var itemID: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var vendorStyle: UILabel!
    @IBOutlet weak var itemColors: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var warehouseOH: UILabel!
    @IBOutlet weak var sizeName: UILabel!
  
    @IBOutlet weak var size2XL: UIButton!
    @IBOutlet weak var sizeXL: UIButton!
    @IBOutlet weak var sizeL: UIButton!
    @IBOutlet weak var sizeM: UIButton!
    @IBOutlet weak var sizeS: UIButton!
    @IBOutlet weak var sizeXS: UIButton!
    @IBOutlet weak var uploadPicBtn: UIButton!
    @IBOutlet weak var notesMulti: UITextView!
    
    @IBOutlet weak var orderContainer: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var qtyPicker: UIPickerView!
    @IBOutlet weak var placeOrderBtn: UIButton!
    
    @IBOutlet weak var storeSelect: UIPickerView!
    
    var ftpData: Data? = nil
    var itemIDStr: String = ""
    var wareOh: Int=0
    var imgExist: Bool = false
    let qtyData = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,24,28,30,32,36,40,42,48,50,60,70,80,90,100,120,200]
    let storeNames = ["421", "1670", "1451", "1441", "1332", "1301", "1208", "1155", "1051", "1041", "1036", "840", "645"]
    var imagePicker: UIImagePickerController!
    
    // ======================================================================================
    //                                      INIT
    // ======================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        readItemData()
        downloadImg()
        setControls()
    }
    
    func setControls(){
         qtyPicker.selectRow(11, inComponent: 0, animated: true)
        
        if getSettingData(key:"multiStore") == "1"{
            storeSelect.isHidden = true
        }else{
            storeSelect.isHidden = false
            storeSelect.selectRow(11, inComponent: 0, animated: true)
        }
        
        roundBtnCorner(btn:placeOrderBtn)
        roundBtnCorner(btn:sizeXS)
        roundBtnCorner(btn:sizeS)
        roundBtnCorner(btn:sizeM)
        roundBtnCorner(btn:sizeL)
        roundBtnCorner(btn:sizeXL)
        roundBtnCorner(btn:size2XL)
          
        roundContainer(container: containerView)
        roundContainer(container: infoView)
        roundContainer(container: orderContainer)
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
    
    func downloadImg(){
       let fileName = "/Catalog/" + itemIDStr + ".jpg"
       let webUrl = URL(string: "http://" + UserDefaults.standard.string(forKey:"wareIP")! + "/Downloads/" + fileName)
       
        if let anUrl = webUrl {
            do{
                let imageData = try Data(contentsOf: anUrl)
                imageView.image =  UIImage(data: imageData)
                imgExist = true
                uploadPicBtn.isHidden = true
            }catch{
                imgExist = false
                uploadPicBtn.isHidden = false
            }
        }
    }
   
    func readItemData(){
        let clientW = SQLClient.sharedInstance()!
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        itemID.text = itemIDStr
        let wareDB = getSettingData(key:"wareDb")
        let warePass = getSettingData(key:"warePass")
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password:warePass, database: wareDB){success in
               if success {
                let sqlStr = "SELECT itemName, vendorStyle, itemPrice, itemColors, sizeName, qty FROM itemTBL LEFT JOIN itemSizeTBL ON itemSizeTBL.sizeID = itemTBL.itemSize  WHERE itemID=" + self.itemIDStr
                clientW.execute(sqlStr) { results in
                    if results != nil {
                        for table in results! as NSArray {
                            for row in table as! NSArray {
                                for column in row as! NSDictionary {
                                       switch column.key as! String{
                                            case "itemName":
                                                self.itemName.text = ((column.value as! NSObject) as? String)
                                            case "vendorStyle":
                                                self.vendorStyle.text = ((column.value as! NSObject) as? String)
                                            case "itemColors":
                                                self.itemColors.text = ((column.value as! NSObject) as? String)
                                            case "sizeName":
                                                self.sizeName.text = ((column.value as! NSObject) as? String)
                                            case "qty":
                                                self.wareOh = (column.value as! NSObject) as? Int ?? 0
                                                self.warehouseOH.text = "Warehouse On Hand:" + String(self.wareOh)
                                            case "itemPrice":
                                                    let iPrice: Double
                                                    iPrice = (column.value as! NSObject) as? Double ?? 0.0
                                                    self.itemPrice.text = String(format: "$%.02f", iPrice)
                                            default:
                                                let _: Int
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
    @IBAction func sendClick(_ sender: Any) {
        let sName = getStoreName()
        let clientW = SQLClient.sharedInstance()!
        let sqlItemStr = "SELECT COUNT(itemID) as countID FROM storeOrderTBL WHERE orderStatus = 'Order Placed' AND storeID= " + sName + " AND itemID=" + itemIDStr
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
        let notes = "'" + notesMulti.text! + "'"
        let qOrder = String(self.qtyData[ self.qtyPicker.selectedRow(inComponent: 0)])
        let clientW = SQLClient.sharedInstance()!
        let sName = getStoreName()
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
           
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) {success in
            if success {
                let sql1 = "INSERT INTO storeOrderTBL (storeID, orderStatus, orderType, userNotes, itemID, qty) VALUES ("
                let sql2 = sName + ",'Order Placed', 3, " + notes + "," + self.itemIDStr + "," + qOrder + ")"
                let sqls = sql1 + sql2
                clientW.execute(sqls) {results in
                    self.returnHome()
                }
                   
                self.beep()
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
    //                                      GENERAL
    // ======================================================================================
    func returnHome(){
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
       
    func getSettingData( key: String)->String{
        let defaults = UserDefaults.standard
               
        if UserDefaults.standard.object(forKey: key) == nil {
            return ""
        }else{
            return defaults.string(forKey: key)!
        }
    }

    func beep(){
        AudioServicesPlaySystemSound (1016)
    }
    
    
    
    // =======================================================================================
    //                           Pickers
    // =======================================================================================
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
    
    // =======================================================================================
    //                           CATCH IMAGE AND UPLOAD TO SERVER
    // =======================================================================================
   @IBAction func uploadPicClicked(_ sender: Any) {
        if imgExist == false{
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera

            present(imagePicker, animated: true, completion: nil)
        }else{
            ftpUploadImgsAndSave()
            uploadPicBtn.setTitle("Take Picture", for: .normal)
        }
    }
     
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[.originalImage] as? UIImage
        uploadPicBtn.setTitle("Save Picture", for: .normal)
        imgExist  = true
    }
      
    func ftpUploadImgsAndSave(){
        let ftpIp = getSettingData(key: "ftpIP")
        let ftpPass = getSettingData(key: "ftpPass")
        let imgWidth = getSettingData(key:"imgWidth")
        let fileName = String(itemID.text!) + ".jpg"
          
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
        let iID = String(itemID.text!)
        let clientW = SQLClient.sharedInstance()!
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
            
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) {success in
            if success {
                let date = Date()
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateStr = format.string(from: date)
                let sqlStr = "UPDATE itemTBL SET hasImg = 1, imgDate ='" + dateStr + "' WHERE itemID = " + iID
                clientW.execute(sqlStr) {results in}
                clientW.disconnect()
            }
        }
    }
    
    
    @IBAction func size2XL_clicked(_ sender: Any) {
        notesMulti.text = "Size: 2XL"
    }
    @IBAction func sizeXL_clicked(_ sender: Any) {
        notesMulti.text = "Size: XL"
    }
    @IBAction func sizeXS_clicked(_ sender: Any) {
        notesMulti.text = "Size: XS"
    }
    @IBAction func sizeL_clicked(_ sender: Any) {
        notesMulti.text = "Size: L"
    }
    @IBAction func sizeS_clicked(_ sender: Any) {
        notesMulti.text = "Size: S"
    }
    @IBAction func sizeM_clicked(_ sender: Any) {
        notesMulti.text = "Size: 2XL"
    }
}

