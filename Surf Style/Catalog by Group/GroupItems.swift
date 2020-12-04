import UIKit
var vSpinner : UIView?
 

class GroupItems: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{

    @IBOutlet weak var groupItemsCV: UICollectionView!
    var items = [Items]()
    var itemsNum:Int = 0
    let reuseIdentifier = "itemCell"
    var selectedGroupID: Int = 0
    var selectedGroupName: String = ""
    var selectedVendorID: Int = 0
    var selectedVendorName: String = ""
    var isVendorCatalog:Bool = false
    var selectedItemID: String = ""
    
    @IBOutlet weak var navBarItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readSqlData()
        if isVendorCatalog == false{
            navBarItem.title = selectedGroupName
        }else{
            navBarItem.title = selectedVendorName
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! GroupItemsCell
        var fileName: String
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if indexPath.row < itemsNum {
            fileName = "Catalog/smallPic/" + String(items[indexPath.row].itemID!) + ".jpg"
            
            if fileExist(fileName: fileName) == false{
               fileName = "Catalog/smallPic/2.jpg"
            }
            
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            do{
                let imageData = try Data(contentsOf: fileURL)
                cell.imageView.image =  UIImage(data: imageData)
                cell.itemName.text = items[indexPath.row].itemName
                cell.vendorStyle.text = items[indexPath.row].vendorStyle
                cell.itemColors.text = items[indexPath.row].itemColors
                cell.itemID.text = String(items[indexPath.row].itemID!)
                cell.oh.text = String(items[indexPath.row].oh!)
            }catch{}
               
            cell.roundContainer()
        }
        return cell
    }

    func readSqlData(){
        let clientW = SQLClient.sharedInstance()!
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        itemsNum = 0
        var filterStr: String = ""
        if isVendorCatalog == false{
            filterStr = "itemGroupID = " + String(self.selectedGroupID) + " ORDER by vendorStyle"
        }else{
            filterStr = "vendorID = " + String(self.selectedVendorID) + " ORDER by vendorStyle"
        }
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")){success in
               if success {
                let sqlStr = "SELECT itemID, itemName, qty, ISNULL(vendorStyle,'') AS vStyle, ISNULL(itemColors,'') AS iColors FROM itemTBL WHERE isPrintingItem = 0 AND qty > 0 AND " + filterStr
                    clientW.execute(sqlStr) { results in
                       if results != nil {
                           for table in results! as NSArray {
                               for row in table as! NSArray {
                                self.items.append(Items(itemID: 0, itemName: "", oh: 0, vendorStyle: "", itemColors: "" , hasImg:0))
                                   for column in row as! NSDictionary {
                                        switch column.key as! String{
                                               case "itemID":
                                                    self.items[self.itemsNum].itemID! = (column.value as! NSObject) as? Int64 ?? 0
                                               case "qty":
                                                    self.items[self.itemsNum].oh! = (column.value as! NSObject) as? Int ?? 0
                                               case "itemName":
                                                    self.items[self.itemsNum].itemName! = ((column.value as! NSObject) as! String)
                                               case "vStyle":
                                                    self.items[self.itemsNum].vendorStyle! = ((column.value as! NSObject) as! String)
                                               case "iColors":
                                                    self.items[self.itemsNum].itemColors! = ((column.value as! NSObject) as! String)
                                               case "hasImg":
                                                    self.items[self.itemsNum].hasImg! = (column.value as! NSObject) as? Int ?? 0
                                               default:
                                                    let _: Int
                                        }

                                   }
                                   self.itemsNum += 1
                               }
                           }
                       }
                       if self.itemsNum  > 0 {
                           for i in 0...self.itemsNum - 1{
                                if self.items[i].hasImg == 1{
                                   let fileName =  "Catalog/smallPic/" + String(self.items[i].itemID!) + ".jpg"
                                   if self.fileExist(fileName: fileName) == false{
                                       WebFileDownloader.downloadFileSync(fileName: fileName) { (path, error) in}
                                   }
                                }
                           }
                       }
                       self.groupItemsCV.reloadData()
                }
            }
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
       
    func getSettingData( key: String)->String{
        let defaults = UserDefaults.standard
               
        if UserDefaults.standard.object(forKey: key) == nil {
            return ""
        }else{
            return defaults.string(forKey: key)!
        }
    }
      
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsNum
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is ItemView{
            let vc = segue.destination as? ItemView
            vc?.itemIDStr = selectedItemID
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let i = indexPath.item
        let id = items[i].itemID
        
        selectedItemID = String(id!)
        performSegue(withIdentifier: "itemViewSegue", sender: indexPath.item)
    }
}


