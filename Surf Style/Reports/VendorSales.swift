
import Foundation
import UIKit

class VendorSales: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var weekBtn: UIButton!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var quarterBtn: UIButton!
    @IBOutlet weak var yearBtn: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var storeSelect: UIPickerView!
    @IBOutlet weak var groupByType: UIPickerView!
    @IBOutlet weak var letterPicker: UIPickerView!
    @IBOutlet weak var vendorPicker: UIPickerView!
    @IBOutlet weak var vSalesTableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    var serv: Services = Services()
    var items = [ItemInvn]()
    var vendors = [Vendors]()
    var vendorsNum: Int = 0
    var storeNames = ["All","421", "1670", "1451", "1441", "1332", "1301", "1208", "1155", "1041", "1036", "840", "645"]
    var groupByTypeNames = ["Item ID", "Style", "Style + Color"]
    var letters = ["All", "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

    var storeSqlFilter: String = ""
    var dateSqlFilter: String = ""
    var vendorSqlFilter: String = ""
    
    var groupByNum: Int = 0
    var selectedDate: Int = 2
    var formatStr: String = ""
    var sortByID: Bool = true
    var sortByStyle: Bool = true
    var sortByName: Bool = true
    var sortByColors: Bool = true
    var sortBySales: Bool = true
    var sortByCost: Bool = true
    var sortByPrice: Bool = true
    var sortBySize: Bool = true
    var totalItemsSold: Int = 0
    var totalSales: Double = 0
    
    //==========================================================================================
    //                                       INIT
    //==========================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
        getVSalesInfo()
    }
     
    func initControls(){
        serv.roundContainer(container: mainContainer)
        serv.roundBtn(btn: quarterBtn)
        serv.roundBtn(btn: weekBtn)
        serv.roundBtn(btn: monthBtn)
        serv.roundBtn(btn: yearBtn)
        setBtnsColor(btn:weekBtn, isPicker: false)
        
        if serv.getSettingData(key:"multiStore") == "1"{
            storeSelect.isHidden = true
            storeSqlFilter = "storeName = " + self.serv.getStoreName() + " AND "
           
        }else{
            storeSelect.isHidden = false
            storeSqlFilter = ""
        }
        vendorSqlFilter = ""
        setSqlDateFilter()
    }
    
    func setBtnsColor(btn:UIButton, isPicker: Bool){
        quarterBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        weekBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        monthBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        yearBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        datePicker.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        if isPicker == true{
            datePicker.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.9568627451, blue: 0.7058823529, alpha: 1)
        }else{
            btn.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.9568627451, blue: 0.7058823529, alpha: 1)
        }
    }
    
//==========================================================================================
//                                      GET SQL DATA
//==========================================================================================
func getVSalesInfo(){
    
    if(vendorSqlFilter != "" && vendorSqlFilter != "vendorID=0 AND " ){
        showSpinnerS(onView: self.view)
        let clientW = SQLClient.sharedInstance()!
        items.removeAll()
            
        let ipPort = serv.getSettingData(key:"officeIP") + ":" + serv.getSettingData(key:"officePort")
        let pass = serv.getSettingData(key:"officePass")
        let db = serv.getSettingData(key:"officeDb")
        clientW.disconnect()
        clientW.connect(ipPort, username: "sa", password: pass, database: db) {success in
            let s1 = "SELECT SUM(T.qty) As tSales, T.itemName, T.vendorStyle, T.itemCost, T.itemPrice"
            var s2:String = ""
            var s7:String = ""
            switch self.groupByNum{
                case 0:
                    s2 = ", T.itemID, T.itemColor, sizeName "
                    s7 = "ORDER BY T.vendorStyle, T.itemColor"
                case 1:
                    s2 = " "
                    s7 = "ORDER BY T.vendorStyle"
                case 2:
                    s2 = ", T.itemColor "
                    s7 = "ORDER BY T.vendorStyle, T.itemColor"
                default: let _:Int
            }
            let s3 = "FROM allStoresReceiptItemTBL as T INNER JOIN itemTBL On T.itemID = itemTBL.itemID "
            let s4 = "LEFT JOIN itemSizeTBL On itemSizeTBL.sizeID =itemTBL.itemSize "
            let s5 = "WHERE " + self.vendorSqlFilter + self.dateSqlFilter + self.storeSqlFilter + "   "
            let s6 = "GROUP BY T.vendorStyle, T.itemName, T.itemCost, T.itemPrice"
            
            let sqlStr = s1 + s2 + s3 + s4 + s5 + s6 + s2 + s7
            
            clientW.execute(sqlStr) {results in
                if results != nil{
                        for table in results! as NSArray {
                            for row in table as! NSArray {
                                self.items.append(ItemInvn(itemID: 0, itemName: "", vendorStyle: "", itemColors: "", vendorName:"", itemPrice: 0, itemCost: 0, buyRule:"", qty:0, sales:0, itemSize:""))
                                let i = self.items.count - 1
                                for column in row as! NSDictionary {
                                    switch column.key as! String{
                                        case "itemID":
                                            self.items[i].itemID = (column.value as! NSObject) as? Int64 ?? 0
                                        case "itemName":
                                            self.items[i].itemName = (column.value as! NSObject) as? String ?? ""
                                        case "vendorStyle":
                                            self.items[i].vendorStyle = (column.value as! NSObject) as? String ?? ""
                                        case "itemColor":
                                            self.items[i].itemColors = (column.value as! NSObject) as? String ?? ""
                                        case "sizeName":
                                            self.items[i].itemSize = (column.value as! NSObject) as? String ?? ""
                                        case "itemPrice":
                                            self.items[i].itemPrice = (column.value as! NSObject) as? Double ?? 0
                                            self.totalSales += self.items[i].itemPrice! * Double(self.items[i].sales!)
                                        case "itemCost":
                                            self.items[i].itemCost = (column.value as! NSObject) as? Double ?? 0
                                        case "tSales":
                                            self.items[i].sales = (column.value as! NSObject) as? Int ?? 0
                                            self.totalItemsSold += self.items[i].sales!
                                           
                                        default: let _: Int
                                    }
                                }
                            }
                        }
                    }
                    self.vSalesTableView.reloadData()
                    self.setTotalLabel()
                    self.removeSpinnerS()
                }
            }
        }
    }
    
    func readSqlVendorNames(filterStr:String){
        let client = SQLClient.sharedInstance()!
        let ipPort = serv.getSettingData(key:"officeIP") + ":" + serv.getSettingData(key:"officePort")
        vendorsNum = 0
        client.disconnect()
        client.connect(ipPort, username: "sa", password: serv.getSettingData(key:"officePass"), database: serv.getSettingData(key:"officeDb")) {success in
            if success {
            let sqlStr = "SELECT vendorId, vendorName FROM vendorTBL " + filterStr + " ORDER by vendorName"
                client.execute(sqlStr) { results in
                    if results != nil {
                        self.vendors.append(Vendors(vNum: 0, vendorId: 0, vendorName: " Select", itemsSold: 0, sales: 0, cost: 0, profit: 0, prcnt: 0))
                        self.vendorsNum = 1
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
                        if (self.vendorsNum > 1){
                            self.vendorPicker.reloadAllComponents()
                            self.vSalesTableView.reloadData()
                            self.vendorSqlFilter = "vendorID=" + String(self.vendors[0].vendorId!) + " AND "
                            self.getVSalesInfo()
                        }
                        else{
                            self.vendorSqlFilter = ""
                        }
                    }
                }
            }
        }
    }
    public func setTotalLabel(){
        totalLabel.text = "Number of Items:" + String(items.count) + " ,Total items Sold:" + String(totalItemsSold) + " ,Total Sales:" + String(format: "$%.02f", totalSales)
    }
    // =======================================================================================
    //                             TABLE VIEW
    // =======================================================================================
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = vSalesTableView.dequeueReusableCell(withIdentifier: "vendorSalesCell", for: indexPath) as! VendorSalesCell
        if items.count > 0{
            
            let r: ItemInvn
            r = items[indexPath.row]
         
            cell.itemID.text = String(r.itemID!)
            cell.itemName.text  = r.itemName!
            cell.vendorStyle.text = r.vendorStyle!
            cell.itemColors.text = r.itemColors!
            cell.itemSize.text = r.itemSize!
            var t: Double = r.itemCost!
            cell.itemCost.text = String(format: "$%.02f", t)
            
            t = r.itemPrice!
            cell.itemPrice.text = String(format: "$%.02f", t)
            
            cell.sales.text = String(r.sales!)
 
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

    //==========================================================================================
    //                              DATES BUTTONS
    //==========================================================================================
    
    @IBAction func weekClick(_ sender: Any) {
        setDataByDate(dSelect: 1, btn: weekBtn, isPicker: false)
    }
    
    @IBAction func monthClick(_ sender: Any) {
        setDataByDate(dSelect: 2, btn: monthBtn, isPicker: false)
    }
  
    @IBAction func quarterClick(_ sender: Any) {
        setDataByDate(dSelect: 3, btn: quarterBtn, isPicker: false)
    }
   
    @IBAction func yearClick(_ sender: Any) {
        setDataByDate(dSelect: 4, btn: yearBtn, isPicker: false)
    }

    func setDataByDate(dSelect:Int, btn:UIButton, isPicker: Bool){
        selectedDate = dSelect
        setSqlDateFilter()
        setBtnsColor(btn: btn, isPicker: isPicker)
        getVSalesInfo()
    }
    
    func setSqlDateFilter(){
        var sDate: String = ""
        formatStr = "format(saleDate,'yyyy/MM/dd')"
        switch selectedDate {
            case 1:
                sDate = serv.getStrDaysAgo(days:7)
            case 2:
                sDate = serv.getStrDaysAgo(days:30)
            case 3:
                sDate = serv.getStrDaysAgo(days:90)
            case 4:
                sDate = serv.getStrDaysAgo(days:365)
            case 5:
                sDate = getDatePicker()
            default: let _: Int
        }
    
        let today = serv.getStrDaysAgo(days:0)
        dateSqlFilter = "[saleDate] >='" + sDate + "' AND [saleDate] <= '" + today + " 23:59:59'"
        
    }
    
    //  ============================================================================
    //                                 PICKERS
    //  ============================================================================
    //  =====================          D A T E                 =====================
    func initDatePickerLimits(){
        datePicker.maximumDate = serv.getDateDaysAgo(days: 1)
    }
       
    func getDatePicker()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "MM/dd/yyyy 00:00:00"
        return dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        setDataByDate(dSelect: 5, btn: yearBtn, isPicker: true)
    }
      
    //  =====================     ALL OTHER PICKERS           =====================
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) ->Int{
        var retVal:Int = 0
        
        switch pickerView {
            case vendorPicker:
                retVal = vendors.count
            case storeSelect:
                retVal = storeNames.count
            case letterPicker:
                retVal = letters.count
            case groupByType:
                retVal = groupByTypeNames.count
            default:
                retVal = 0
        }
        return retVal
    }
          
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)->String? {
        var retVal: String = ""
        switch pickerView {
            case vendorPicker:
                retVal = String(vendors[row].vendorName!)
            case storeSelect:
                retVal = String(storeNames[row])
            case letterPicker:
                retVal = String(letters[row])
            case groupByType:
                retVal = String(groupByTypeNames[row])
            default:
                retVal = ""
        }
        return retVal
    }
         
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
            case vendorPicker:
                if row == 0{
                    vendorSqlFilter = ""
                }else{
                    let vId = String(vendors[row].vendorId!)
                    vendorSqlFilter =  "T.vendorID=" + vId + " AND "
                }
                getVSalesInfo()
            case storeSelect:
                if row == 0{
                    storeSqlFilter = ""
                }else{
                    storeSqlFilter = " AND storeName  = " + storeNames[row] + " "
                }
                getVSalesInfo()
            case letterPicker:
                vendorsNum = 0
                vendors.removeAll()
                vendorPicker.reloadAllComponents()
                let v = " WHERE vendorName LIKE '" + letters[row] + "%' "
                readSqlVendorNames(filterStr: v)
            case groupByType:
                groupByNum = row
                getVSalesInfo()
            default: let _: Int
                
        }
    }

    //  ============================================================================
    //                                 SORT
    //  ============================================================================
    @IBAction func sortItemID(_ sender: Any) {
        if sortByID == true {
            sortByID = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemID!) < (project2.itemID!)
            })
        }else{
            sortByID = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemID!) > (project2.itemID!)
            })
        }
        vSalesTableView.reloadData()
    }
    @IBAction func sortItemName(_ sender: Any) {
        if sortByName == true {
            sortByName = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemName!) < (project2.itemName!)
            })
        }else{
            sortByName = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemName!) > (project2.itemName!)
            })
        }
        vSalesTableView.reloadData()
    }
    @IBAction func sortVendorStyle(_ sender: Any) {
        if sortByStyle == true {
            sortByStyle = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.vendorStyle!) < (project2.vendorStyle!)
            })
        }else{
            sortByStyle = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.vendorStyle!) > (project2.vendorStyle!)
            })
        }
        vSalesTableView.reloadData()
    }
    @IBAction func sortColors(_ sender: Any) {
        if sortByColors == true {
            sortByColors = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemColors!) < (project2.itemColors!)
            })
        }else{
            sortByColors = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemColors!) > (project2.itemColors!)
            })
        }
        vSalesTableView.reloadData()
    }
    @IBAction func sortSize(_ sender: Any) {
        if sortBySize == true {
            sortBySize = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemSize!) < (project2.itemSize!)
            })
        }else{
            sortBySize = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemSize!) > (project2.itemSize!)
            })
        }
        vSalesTableView.reloadData()
    }
    @IBAction func sortPrice(_ sender: Any) {
        if sortByPrice == true {
            sortByPrice = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemPrice!) < (project2.itemPrice!)
            })
        }else{
            sortByPrice = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemPrice!) > (project2.itemPrice!)
            })
        }
        vSalesTableView.reloadData()
    }
    @IBAction func sortCost(_ sender: Any) {
        if sortByCost == true {
            sortByCost = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemCost!) < (project2.itemCost!)
            })
        }else{
            sortByCost = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemCost!) > (project2.itemCost!)
            })
        }
        vSalesTableView.reloadData()
    }
    @IBAction func sortSales(_ sender: Any) {
        if sortBySales == true {
            sortBySales = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.sales!) < (project2.sales!)
            })
        }else{
            sortBySales = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.sales!) > (project2.sales!)
            })
        }
        vSalesTableView.reloadData()
    }
}

