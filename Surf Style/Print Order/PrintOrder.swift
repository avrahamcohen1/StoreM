import UIKit
import FileProvider
import AVFoundation

class PrintOrder: UIViewController,  UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var GarmentContainer: UIView!
    @IBOutlet weak var garmentCollectionView: UICollectionView!
    @IBOutlet weak var ColorContainer: UIView!
    @IBOutlet weak var colorTableView: UITableView!
    
    var garments = [Garments]()
    var gColors = [GarmentColors]()
    var garmentsNum: Int = 0
    var selectedGarmentId: Int64 = 0
    var selectedGarmentName: String = ""
    var selectedColorName: String = ""
    var selectedColorID: Int = 0
    var selectedItemID: Int64 = 0
    var selectedVendorStyle: String = ""
    var garmentNum: Int = 0
    var colorsNum: Int = 0
    let reuseIdentifier = "garmentCell"
    let reuseIdentifierColor = "garmentColorCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSpinnerS(onView: self.view)
        readSqlGarmentData()
        initControls()
    }
    
    func initControls(){
        roundContainer(container: GarmentContainer)
        roundContainer(container: ColorContainer)
        ColorContainer.isHidden = true
    }
    
    func roundContainer(container: UIView){
        let cornerRadius : CGFloat = 15.0
        container.layer.cornerRadius = cornerRadius
        container.layer.shadowColor = UIColor.darkGray.cgColor
        container.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        container.layer.shadowRadius = 15.0
        container.layer.shadowOpacity = 0.9
    }
    
    //===============================================================
    //                             SQL
    //==============================================================
    func readSqlGarmentData(){
        let clientW = SQLClient.sharedInstance()!
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) { success in
            var sqlStr = "SELECT vendorStyle FROM itemTBL WHERE qty > 0 AND vendorStyle IS NOT NULL AND isPrintingItem > 0 GROUP BY vendorStyle ORDER BY vendorStyle"
            clientW.execute(sqlStr) {results in
                if results != nil{
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            self.garments.append(Garments(itemID: 0, itemName: "", vendorStyle: ""))
                            
                            for column in row as! NSDictionary {
                                    self.garments[self.garmentsNum].vendorStyle = ((column.value as! NSObject) as? String)!
                            }
                            self.garmentsNum += 1
                        }
                    }
                    
                    for i in 0...self.garmentsNum-1{
                        let vStyle = self.garments[i].vendorStyle
                        sqlStr = "SELECT TOP 1 itemId, itemName FROM itemTBL WHERE isPrintingItem > 0 AND vendorStyle='" + vStyle! + "'"
                        
                        clientW.execute(sqlStr) {results in
                            if results != nil{
                                for table in results! as NSArray {
                                    for row in table as! NSArray {
                                        for column in row as! NSDictionary {
                                            switch column.key as! String{
                                                case "itemId":
                                                   self.garments[i].itemID = (column.value as! NSObject) as? Int64 ?? 0
                                                case "itemName":
                                                   self.garments[i].itemName = ((column.value as! NSObject) as? String)!
                                                default:let _: Int
                                            }
                                        }
                                    }
                                }
                                if i >= self.garmentsNum-1{
                                    self.garmentCollectionView.reloadData()
                                    self.removeSpinnerS()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func reardSqlColorDataForStyle(){
        let clientW = SQLClient.sharedInstance()!
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
       
        let sqlStr = "SELECT itemID, itemColorTBL.colorName AS cName, itemColorTBL.colorID AS cID FROM itemTBL LEFT JOIN itemColorTBL ON itemColorTBL.colorName = itemTBL.itemColors WHERE isPrintingItem > 0 AND vendorStyle ='" + self.selectedVendorStyle + "'"
        gColors.removeAll()
        colorsNum = 0
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) { success in
              clientW.execute(sqlStr) {results in
                if results != nil{
                   
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            self.gColors.append(GarmentColors(colorName:"", colorID: 0, itemID: 0))
                             
                            for column in row as! NSDictionary {
                                switch column.key as! String{
                                    case "cName":
                                        self.gColors[self.colorsNum].colorName = ((column.value as! NSObject) as? String)
                                    case "cID":
                                        self.gColors[self.colorsNum].colorID = (column.value as! NSObject) as? Int ?? 0
                                    case "itemID":
                                        self.gColors[self.colorsNum].itemID = (column.value as! NSObject) as? Int64 ?? 0
                                    default: let _: Int
                                }
                            }
                            self.colorsNum += 1
                        }
                    }
                    self.colorTableView.reloadData()
                }
            }
        }
    }
     
    //==========================================================================================
    //                                 GARMENT COLLECTION VIEW
    //==========================================================================================
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! GarmentCell
                   
        if indexPath.row < self.garmentsNum{
            cell.itemName.text = String(garments[indexPath.row].itemName!)
            cell.vendorStyle.text = String(garments[indexPath.row].vendorStyle!)
            
            var fileName = "Catalog/smallPic/" + String(garments[indexPath.row].itemID!) + ".jpg"
            if fileExist(fileName: fileName) == false{
                fileName = "Catalog/smallPic/2.jpg"
            }
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
             
            do{
                let imageData = try Data(contentsOf: fileURL)
                cell.imgView.image =  UIImage(data: imageData)
            }catch{}
            
            cell.roundContainer()
        }
        return cell
    }
          
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.garmentsNum
    }
      
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedGarmentId = garments[indexPath.item].itemID!
        selectedGarmentName = garments[indexPath.item].itemName!
        selectedVendorStyle = garments[indexPath.item].vendorStyle!
        ColorContainer.isHidden = false
        reardSqlColorDataForStyle()
    }
        
    // =======================================================================================
    //                                      COLOR TABLE VIEW
    // =======================================================================================
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierColor, for: indexPath) as! GarmentColorCell
        let gColor: GarmentColors
        gColor =  gColors[indexPath.row]
        cell.colorName.text = gColor.colorName
        if gColor.colorID! > 0 {
            var fileName = "Catalog/Colors/" + String(gColor.colorID!) + ".jpg"
            
            if fileExist(fileName: fileName) == false{
                fileName = "Catalog/smallPic/2.jpg"
            }
               
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            do{
                let imageData = try Data(contentsOf: fileURL)
                cell.imgView.image =  UIImage(data: imageData)
            }catch { print("Color Error: \(error)")}
                
            cell.roundContainer()
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return colorsNum
    }
    
    func numberOfSections(in tableView: UITableView)->Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedColorName = gColors[indexPath.row].colorName!
        selectedColorID = gColors[indexPath.row].colorID!
        selectedItemID = gColors[indexPath.row].itemID!
        performSegue(withIdentifier: "decalPageSeguey", sender: indexPath.item)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let vc = segue.destination as? DecalPage
        vc?.selectedGarmentId = selectedGarmentId
        vc?.selectedGarmentName = selectedGarmentName
        vc?.selectedColorName = selectedColorName
        vc?.selectedColorID = selectedColorID
        vc?.selectedItemID = selectedItemID
        vc?.selectedVendorStyle = selectedVendorStyle
    }
    
    //==========================================================================================
    //                                      GENERAL
    //==========================================================================================
    func getSettingData( key: String)->String{
        let defaults = UserDefaults.standard
                       
        if UserDefaults.standard.object(forKey: key) == nil {
            return ""
        }else{
            return defaults.string(forKey: key)!
        }
    }
    
    func fileExist(fileName:String)->Bool{
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
           
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                return true
            } else {
                    return false
            }
        } else {
                return false
        }
    }
}
 
