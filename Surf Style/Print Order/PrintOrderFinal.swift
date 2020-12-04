
import UIKit
import FileProvider
import AVFoundation

class PrintOrderFinal: UIViewController,  UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var orderContainer: UIView!
    @IBOutlet weak var garmentContainer: UIView!
    @IBOutlet weak var decalContainer: UIView!
    @IBOutlet weak var sizeContainer: UIView!
    @IBOutlet weak var colorContainer: UIView!
    
    @IBOutlet weak var xsP: UIPickerView!
    @IBOutlet weak var sP: UIPickerView!
    @IBOutlet weak var mP: UIPickerView!
    @IBOutlet weak var lP: UIPickerView!
    @IBOutlet weak var xlP: UIPickerView!
    @IBOutlet weak var x2lP: UIPickerView!
    @IBOutlet weak var x3lP: UIPickerView!
    @IBOutlet weak var x4lP: UIPickerView!
    
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var colorImg: UIImageView!
    @IBOutlet weak var garmentImg: UIImageView!
    @IBOutlet weak var decalImg: UIImageView!
    @IBOutlet weak var colorLBL: UILabel!
    @IBOutlet weak var garmentLBL: UILabel!
    @IBOutlet weak var vendorStyle: UILabel!
    
    @IBOutlet weak var storeSelect: UIPickerView!
    
    var selectedGarmentId: Int64 = 0
    var selectedGarmentName: String = ""
    var selectedColorName: String = ""
    var selectedDecalId: Int = 0
    var selectedColorID: Int = 0
    var selectedItemID: Int64 = 0
    var selectedVendorStyle: String = ""
    var totalQtyOrder: Int = 0
    
    let qtyData = ["","1","2","3","4","5","6","7","8","9","10","12","16","18","20","24","36","48","50","60","80","90","100","120","150","200"]
    var storeNames = ["421", "1670", "1451", "1441", "1332", "1301", "1208", "1155", "1051", "1041", "1036", "840", "645"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
    }
    
    func initControls(){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = String(selectedGarmentId) + ".jpg"
        let webUrl = URL(string: "http://" + UserDefaults.standard.string(forKey:"wareIP")! + "/Downloads/Catalog/"  + fileName)
           
        if let anUrl = webUrl {
            do{
                let imageData = try Data(contentsOf: anUrl)
                garmentImg.image =  UIImage(data: imageData)
            }catch{}
        }
        
        var fileURL = documentsDirectory.appendingPathComponent("Catalog/Colors/" + String(selectedColorID) + ".jpg")
        do{
            let imageData = try Data(contentsOf: fileURL)
            colorImg.image =  UIImage(data: imageData)
        }catch{}
        fileURL = documentsDirectory.appendingPathComponent("Catalog/Decals/" + String(selectedDecalId) + ".jpg")
        do{
            let imageData = try Data(contentsOf: fileURL)
            decalImg.image =  UIImage(data: imageData)
        }catch{}
        
        colorLBL.text = selectedColorName
        garmentLBL.text = selectedGarmentName
        vendorStyle.text = "Style:" + selectedVendorStyle
        roundContainer(container: orderContainer)
        roundContainer(container: garmentContainer)
        roundContainer(container: decalContainer)
        roundContainer(container: sizeContainer)
        roundContainer(container: colorContainer)
        roundBtnCorner(btn: sendBtn)
        
        if getSettingData(key:"multiStore") == "1"{
            storeSelect.isHidden = true
        }else{
            storeSelect.isHidden = false
        }
    }
    
  
    @IBAction func sendClick(_ sender: Any) {
        sendSqlData()
        beep()
        returnHome()
    }
        
    func sendSqlData(){
        let notesStr = "'" + notes.text! + "'"
        let orderInfo = getOrderInfo()

        let clientW = SQLClient.sharedInstance()!
        let sName = getStoreName()
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
                 
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) {success in
            if success {
                let sql1 = "INSERT INTO storeOrderTBL (storeID, orderStatus, orderType, userNotes, itemID, qty, orderInfo) VALUES ("
                let sql2 = sName + ",'Order Placed', 3, " + notesStr + "," + String(self.selectedItemID) + ","
                let sql3 = String(self.totalQtyOrder) + ",'" + orderInfo + "')"
                let sqls = sql1 + sql2 + sql3
                clientW.execute(sqls) {results in
                    clientW.disconnect()
                }
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
     
    func getOrderInfo()->String{
        var retVal = ""
        retVal += getSizeInfo(sizePicker: xsP, sizeName: "XS")
        retVal += getSizeInfo(sizePicker: sP, sizeName: "S")
        retVal += getSizeInfo(sizePicker: mP, sizeName: "M")
        retVal += getSizeInfo(sizePicker: lP, sizeName: "L")
        retVal += getSizeInfo(sizePicker: xlP, sizeName: "XL")
        retVal += getSizeInfo(sizePicker: x2lP, sizeName: "2XL")
        retVal += getSizeInfo(sizePicker: x3lP, sizeName: "3XL")
        retVal += getSizeInfo(sizePicker: x4lP, sizeName: "4XL")
        
        return retVal
    }
    
    func getSizeInfo(sizePicker: UIPickerView, sizeName:String)->String{
        var retVal = ""
        let idx =  sizePicker.selectedRow(inComponent: 0)
        if idx > 0{
            totalQtyOrder += Int(qtyData[idx])!
            retVal = "Size:" + sizeName + " qty:" + String(qtyData[idx]) + ", "
        }
        
        return retVal
    }
    
    //====================================PICKER =======================================
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func numberOfComponentsInPickerView( piclerVierw: UIPickerView)->Int{
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) ->Int{
        if pickerView == storeSelect{
            return storeNames.count
        }else{
            return qtyData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)->String?{
         if pickerView == storeSelect{
            return storeNames[row]
         }else{
            return qtyData[row]
        }
    }
   
    //=================================== GENERAL =======================================
    func beep(){
        AudioServicesPlaySystemSound (1016)
    }
    
    func roundBtnCorner(btn:UIButton){
         btn.layer.borderWidth = 1
         btn.layer.borderColor = UIColor.blue.cgColor
         btn.layer.cornerRadius = 8
    }
    
    func roundContainer(container:UIView ){
        let cornerRadius : CGFloat = 10.0
        container.layer.cornerRadius = cornerRadius
        container.layer.shadowColor = UIColor.darkGray.cgColor
        container.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        container.layer.shadowRadius = 10.0
        container.layer.shadowOpacity = 0.9
    }
    
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
}
