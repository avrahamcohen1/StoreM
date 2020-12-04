import UIKit

class WareInventory: UIViewController,  UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var invnTableContainer: UIView!
    @IBOutlet weak var invnTable: UITableView!
   
    @IBOutlet weak var letterPicker: UIPickerView!
    @IBOutlet weak var vendorFilter: UIPickerView!
    @IBOutlet weak var searchNameText: UITextField!
    @IBOutlet weak var searchStyleText: UITextField!
  
    var letters = ["All", "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

    var vendors = [Vendors]()
    var vendorsNum: Int = 0
    var items = [ItemInvn]()
    var itemsNum: Int = 0
    var selectedVendorId: Int = 0
    var selectedItemID: Int64 = 0
    var sortId:Bool = false
    var sortName:Bool = false
    var sortStyle:Bool = false
    var sortColors:Bool = false
    var sortVendorName:Bool = false
    var sortPrice:Bool = false
    var sortCost:Bool = false
    var sortBuyRule:Bool = false
    var sortQty:Bool = false
    
    override func viewDidLoad() {
       super.viewDidLoad()
      
       readSqlData(filter:"qty>0")
       readSqlVendorData(filterStr: "")
       initControls()
    }
  
    func initControls(){
        roundContainer(container: invnTableContainer)
        searchNameText.delegate = self
        searchStyleText.delegate = self
        searchNameText.returnKeyType = UIReturnKeyType.search
        searchStyleText.returnKeyType = UIReturnKeyType.search
    }
    
    func setBorder(label:UILabel){
        label.layer.borderColor = UIColor.darkGray.cgColor
        label.layer.borderWidth = 0.5
    }
       
    func roundContainer(container: UIView){
        let cornerRadius : CGFloat = 15.0
        container.layer.cornerRadius = cornerRadius
        container.layer.shadowColor = UIColor.darkGray.cgColor
        container.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        container.layer.shadowRadius = 15.0
        container.layer.shadowOpacity = 0.9
    }
    
    func roundBtn(btn:UIButton){
        let cornerRadius : CGFloat = 5.0
        btn.layer.cornerRadius = cornerRadius
        btn.layer.shadowColor = UIColor.darkGray.cgColor
        btn.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        btn.layer.shadowRadius = 5.0
        btn.layer.shadowOpacity = 0.9
    }
    
    //===============================================================
    //                             SQL
    //==============================================================
    func readSqlData(filter:String){
        items.removeAll()
        itemsNum = 0
        let client = SQLClient.sharedInstance()!
        let ipPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        client.disconnect()
        client.connect(ipPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) { success in
            let sqlStr = "SELECT itemID, itemName, vendorStyle, itemColors, itemPrice, itemCost, qty, vendorName, [rule Name] as buyRule FROM itemTBL LEFT JOIN vendorTBL ON vendorTBL.vendorId = itemTBL.vendorId LEFT JOIN buyForTBL ON buyForTBL.[rule ID] = itemTBL.buyForID  WHERE " + filter
            client.execute(sqlStr) {results in
                if results != nil{
                    self.showSpinnerS(onView: self.view)
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            self.items.append(ItemInvn(itemID: 0, itemName: "", vendorStyle: "", itemColors: "", vendorName: "", itemPrice: 0, itemCost: 0, buyRule: "", qty:0, sales:0, itemSize: ""))
                            let i = self.items.count - 1
                            for column in row as! NSDictionary {
                                switch column.key as! String{
                                    case "itemID":
                                        self.items[i].itemID = (column.value as! NSObject) as? Int64 ?? 0
                                    case "itemName":
                                        self.items[i].itemName = (column.value as! NSObject) as? String
                                    case "vendorStyle":
                                        self.items[i].vendorStyle = (column.value as! NSObject) as? String
                                    case "itemColors":
                                        self.items[i].itemColors = (column.value as! NSObject) as? String
                                    case "vendorName":
                                        self.items[i].vendorName = (column.value as! NSObject) as? String
                                    case "itemPrice":
                                        self.items[i].itemPrice = (column.value as! NSObject) as? Double ?? 0.0
                                    case "itemCost":
                                        self.items[i].itemCost = (column.value as! NSObject) as? Double ?? 0.0
                                    case "buyRule":
                                        self.items[i].buyRule = (column.value as! NSObject) as? String
                                    case "qty":
                                        self.items[i].qty = (column.value as! NSObject) as? Int ?? 0
                                    default: let _: Int
                                }
                            }
                            self.itemsNum += 1
                        }
                    }
                    self.invnTable.reloadData()
                    self.removeSpinnerS()
                }
            }
        }
    }

    func readSqlVendorData(filterStr:String){
        let client = SQLClient.sharedInstance()!
        let ipPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        vendorsNum = 0
        client.disconnect()
        client.connect(ipPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) {success in
            if success {
            let sqlStr = "SELECT vendorId, vendorName FROM vendorTBL " + filterStr + " ORDER by vendorName"
                client.execute(sqlStr) { results in
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
                                        default: let _: Int
                                    }
                                }
                                self.vendorsNum += 1
                            }
                        }
                        self.vendorFilter.reloadAllComponents()
                        if self.vendors.count > 0{
                            let vId = String(self.vendors[0].vendorId!)
                            self.invnTable.reloadData()
                            self.readSqlData(filter:" itemTBL.vendorId=" + vId)
                        }
                    }
                }
            }
        }
    }
       
    // =======================================================================================
    //                             TABLE VIEW
    // =======================================================================================
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "invenCell", for: indexPath) as! InvenCell
        if items.count > 0{
            let item: ItemInvn
            item = items[indexPath.row]
            cell.itemId.text = String(item.itemID!)
            cell.itemName.text =  item.itemName!
            cell.vendorStyle.text = item.vendorStyle
            cell.itemColors.text = item.itemColors
            cell.vendorName.text = item.vendorName
            let iPrice: Double = item.itemPrice!
            cell.itemPrice.text = String(format: "$%.02f", iPrice)
            let iCost: Double = item.itemCost!
            cell.itemCost.text = String(format: "$%.02f", iCost)
            cell.buyRule.text = item.buyRule
            cell.qty.text = String(item.qty!)
        }
        cell.initialize()
        return cell
    }
       
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return items.count
    }
       
    func numberOfSections(in tableView: UITableView)->Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.05)
        }else {
            cell.backgroundColor = UIColor.white
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        invnTable.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "invnToItemSearch") {
            let vc = segue.destination as? ItemSearch
            let idx = invnTable.indexPathForSelectedRow?.row
            vc!.selectedItemID = items[idx!].itemID!
        }
    }
    
    // ======================================================================================
    //                                      PICKERS
    // ======================================================================================
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) ->Int{
        if pickerView == vendorFilter{
            return vendors.count
        }else{
            return letters.count
        }
    }
        
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)->String? {
        if pickerView == vendorFilter{
            return vendors[row].vendorName
         }else{
            return letters[row]
        }
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == vendorFilter{
            let vId = String(vendors[row].vendorId!)
            invnTable.reloadData()
            readSqlData(filter:" itemTBL.vendorId=" + vId)
        }else{
            vendorsNum = 0
            vendors.removeAll()
            vendorFilter.reloadAllComponents()
            let vendorStr = " WHERE vendorName LIKE '" + letters[row] + "%' "
            readSqlVendorData(filterStr: vendorStr)
        }
        searchNameText.text = ""
        searchStyleText.text = ""
    }
    
    //==========================================================================================
    //                                      Search
    //==========================================================================================
    @IBAction func searchName(_ sender: Any) {
        let whereStr = "itemName LIKE '%" + searchNameText.text! + "%' "
        readSqlData(filter: whereStr)
        searchStyleText.text = ""
    }
    
    @IBAction func searchStyle(_ sender: Any) {
        let whereStr = "vendorStyle LIKE '%" + searchStyleText.text! + "%' "
        readSqlData(filter: whereStr)
        searchNameText.text = ""
    }
    
    //==========================================================================================
    //                                      SORT
    //==========================================================================================
    @IBAction func idClicked(_ sender: Any) {
        if sortId == true {
            sortId = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemID ?? 0) < (project2.itemID ?? 0)
            })
        }else{
           sortId = true
           items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemID ?? 0) > (project2.itemID ?? 0)
            })
        }
        invnTable.reloadData()
    }
    
    @IBAction func nameClicked(_ sender: Any) {
        if sortName == true {
            sortName = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemName ?? "") < (project2.itemName ?? "")
            })
        }else{
            sortName = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemName ?? "") > (project2.itemName ?? "")
            })
        }
        invnTable.reloadData()
    }
    
    @IBAction func styleClicked(_ sender: Any) {
        if sortStyle == true {
            sortStyle = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.vendorStyle ?? "") < (project2.vendorStyle ?? "")
            })
        }else{
            sortStyle = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.vendorStyle ?? "") > (project2.vendorStyle ?? "")
            })
        }
        invnTable.reloadData()
    }
  
    @IBAction func colorsClicked(_ sender: Any) {
        if sortColors == true {
            sortColors = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemColors ?? "") < (project2.itemColors ?? "")
            })
        }else{
            sortColors = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemColors ?? "") > (project2.itemColors ?? "")
            })
        }
        invnTable.reloadData()
    }

    @IBAction func vendorNameClicked(_ sender: Any) {
        if sortVendorName == true {
            sortVendorName = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.vendorName ?? "") < (project2.vendorName ?? "")
            })
        }else{
            sortVendorName = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.vendorName ?? "") > (project2.vendorName ?? "")
            })
        }
        invnTable.reloadData()
    }
       
    @IBAction func priceClicked(_ sender: Any) {
        if sortPrice == true {
            sortPrice = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemPrice ?? 0) < (project2.itemPrice ?? 0)
            })
        }else{
            sortPrice = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemPrice ?? 0) > (project2.itemPrice ?? 0)
            })
        }
        invnTable.reloadData()
    }
      
    @IBAction func costClicked(_ sender: Any) {
        if sortCost == true {
            sortCost = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemCost ?? 0) < (project2.itemCost ?? 0)
            })
        }else{
            sortCost = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemCost ?? 0) > (project2.itemCost ?? 0)
            })
        }
        invnTable.reloadData()
    }
    
    @IBAction func buyRuleClicked(_ sender: Any) {
        if sortBuyRule == true {
            sortBuyRule = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.buyRule ?? "") < (project2.buyRule ?? "")
            })
        }else{
            sortBuyRule = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.buyRule ?? "") > (project2.buyRule ?? "")
            })
        }
        invnTable.reloadData()
    }
    
    @IBAction func ohClicked(_ sender: Any) {
        if sortQty == true {
            sortQty = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.qty ?? 0) < (project2.qty ?? 0)
            })
        }else{
            sortQty = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.qty ?? 0) > (project2.qty ?? 0)
            })
        }
        invnTable.reloadData()
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
}

extension WareInventory: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
