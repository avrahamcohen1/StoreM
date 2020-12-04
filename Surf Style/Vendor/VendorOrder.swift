

import UIKit
class VendorOrder: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBOutlet weak var vendorCV: UICollectionView!
    var vendors = [Vendors]()
    var vendorsNum: Int = 0
    let reuseIdentifier = "vendorCell"
    var selectedVendorId:Int = 0
    var selectedVendorName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readSqlData()
    }
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! VendorCell
        cell.vendorName.text = vendors[indexPath.row].vendorName
        cell.roundContainer()
        return cell
    }

    func readSqlData(){
        let clientW = SQLClient.sharedInstance()!
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        vendorsNum = 0
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) {success in
            if success {
                let sqlStr = "SELECT vendorId, vendorName FROM vendorTBL WHERE isWarehouseVendor = -1 ORDER by vendorName"
                clientW.execute(sqlStr) { results in
                    if results != nil {
                        for table in results! as NSArray {
                            for row in table as! NSArray {
                                self.vendors.append(Vendors(vNum: 0, vendorId: 0, vendorName: "", itemsSold: 0, sales: 0, cost: 0, profit: 0, prcnt: 0))
                                for column in row as! NSDictionary {
                                    switch column.key as! String{
                                        case "vendorId":
                                            self.vendors[self.vendorsNum].vendorId! = (column.value as! NSObject) as? Int ?? 0
                                        case "vendorName":
                                            self.vendors[self.vendorsNum].vendorName! = ((column.value as! NSObject) as! String)
                                        default:
                                            let _: Int
                                    }
                                }
                                self.vendorsNum += 1
                            }
                        }
                    }
                      
                    if self.vendorsNum > 0 {
                        self.vendorCV.reloadData()
                    }
                    
                }
            }
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
        return vendorsNum
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is GroupItems{
            let vc = segue.destination as? GroupItems
            vc?.selectedVendorID = selectedVendorId
            vc?.selectedVendorName = selectedVendorName
            vc?.isVendorCatalog = true
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedVendorId = vendors[indexPath.item].vendorId!
        selectedVendorName = vendors[indexPath.row].vendorName!
        performSegue(withIdentifier: "vendorToGroupSegue", sender: indexPath.item)
    }
}

