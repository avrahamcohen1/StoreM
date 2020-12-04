import Foundation
import UIKit

class TopVendors: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var weekBtn: UIButton!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var quarterBtn: UIButton!
    @IBOutlet weak var yearBtn: UIButton!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var storeSelect: UIPickerView!
    @IBOutlet weak var topVendorTableView: UITableView!
    var serv: Services = Services()
   
    var vendors = [Vendors]()
    var vendorsNum: Int = 0
    var storeNames = ["All","421", "1670", "1451", "1441", "1332", "1301", "1208", "1155", "1041", "1036", "840", "645"]
    
    var storeSqlFilter: String = ""
    var dateSqlFilter: String = ""
    
    var selectedDate: Int = 2
    var formatStr: String = ""
    var sortByVnum: Bool = true
    var sortByName: Bool = true
    var sortByItemsSold: Bool = true
    var sortBySales: Bool = true
    var sortByCost: Bool = true
    var sortByPrcnt: Bool = true
    var sortByProfit: Bool = true
    
    //==========================================================================================
    //                                       INIT
    //==========================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
        getSqlData()
    }
     
    func initControls(){
        serv.roundContainer(container: mainContainer)
        serv.roundBtn(btn: weekBtn)
        serv.roundBtn(btn: monthBtn)
        serv.roundBtn(btn: quarterBtn)
        serv.roundBtn(btn: yearBtn)
        setBtnsColor(btn:monthBtn, isPicker: false)
        
        if serv.getSettingData(key:"multiStore") == "1"{
            storeSelect.isHidden = true
            storeSqlFilter = "storeName = " + self.serv.getStoreName() + " AND "
           
        }else{
            storeSelect.isHidden = false
            storeSqlFilter = ""
        }
        initDatePickers()
        setSqlDateFilter()
    }
    
    func setBtnsColor(btn:UIButton, isPicker: Bool){
     
        weekBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        monthBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        quarterBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        yearBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        startDatePicker.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        endDatePicker.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        if isPicker == true{
            startDatePicker.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.9568627451, blue: 0.7058823529, alpha: 1)
            endDatePicker.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.9568627451, blue: 0.7058823529, alpha: 1)
        }else{
            btn.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.9568627451, blue: 0.7058823529, alpha: 1)
        }
    }
    
//==========================================================================================
//                                      GET SQL DATA
//==========================================================================================
func getSqlData(){
    
    showSpinnerS(onView: self.view)
    let clientW = SQLClient.sharedInstance()!
    vendors.removeAll()
            
    let ipPort = serv.getSettingData(key:"officeIP") + ":" + serv.getSettingData(key:"officePort")
    let pass = serv.getSettingData(key:"officePass")
    let db = serv.getSettingData(key:"officeDb")
    clientW.disconnect()
    clientW.connect(ipPort, username: "sa", password: pass, database: db) {success in
        let s1 = "SELECT SUM(qty) As itemsSold, SUM(qty * itemPrice) As tSales, "
        let s2 = "SUM(qty * itemCost) As tCost, vendorName FROM allStoresReceiptItemTBL "
        let s3 = "WHERE " + self.dateSqlFilter + self.storeSqlFilter + "   "
        let s4 = "GROUP BY vendorName ORDER by SUM(qty * itemPrice) DESC"
        let sqlStr = s1 + s2 + s3 + s4
       
        clientW.execute(sqlStr) {results in
            if results != nil{
                for table in results! as NSArray {
                    for row in table as! NSArray {
                        self.vendors.append(Vendors(vNum: 0, vendorId: 0, vendorName: "", itemsSold: 0, sales: 0, cost: 0, profit: 0, prcnt: 0))
                                    
                        let i = self.vendors.count - 1
                        self.vendors[i].vNum = self.vendors.count
                        for column in row as! NSDictionary {
                            switch column.key as! String{
                                case "vendorName":
                                    self.vendors[i].vendorName = (column.value as! NSObject) as? String ?? ""
                                case "itemsSold":
                                    self.vendors[i].itemsSold = (column.value as! NSObject) as? Int ?? 0
                                case "tSales":
                                    self.vendors[i].sales = (column.value as! NSObject) as? Double ?? 0
                                case "tCost":
                                    self.vendors[i].cost = (column.value as! NSObject) as? Double ?? 0
                                 default: let _: Int
                            }
                        }
                    }
                }
            }
            print(self.vendors.count)
            self.topVendorTableView.reloadData()
            self.removeSpinnerS()
        }
    }
}
    
    
    // =======================================================================================
    //                             TABLE VIEW
    // =======================================================================================
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = topVendorTableView.dequeueReusableCell(withIdentifier: "topVendorsCell", for: indexPath) as! TopVendorsCell
        
        if vendors.count > 0{
            
            let r: Vendors = vendors[indexPath.row]
            r.profit = r.sales! - r.cost!
            r.prcnt = r.sales! / (0.001 + r.cost!)
            cell.vNum.text = String(r.vNum!) + " "
            cell.vendorName.text  = " " + r.vendorName!
            cell.itemsSold.text = String(r.itemsSold!)
            cell.sales.text  = String(format: "$%.0f",locale: Locale.current, r.sales!)
            cell.cost.text   = String(format: "$%.0f",locale: Locale.current, r.cost!)
            cell.profit.text = String(format: "$%.0f",locale: Locale.current, r.profit!)
            cell.prcnt.text  = String(format: "%.0f%%",locale: Locale.current,100 * r.prcnt!)

        }
        cell.initialize()
        return cell
    }
       
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return vendors.count
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
        getSqlData()
    }
    
    func setSqlDateFilter(){
        var sDate: String = ""
        var eDate: String = ""
        formatStr = "format(saleDate,'MM/dd/yyyy')"
        eDate = serv.getStrDaysAgo(days:0)
        
        switch selectedDate {
            case 1:
                sDate = serv.getStrDaysAgo(days:7)
                startDatePicker.date = serv.getDateDaysAgo(days: 7)
                endDatePicker.date = serv.getDateDaysAgo(days: 0)
            case 2:
                sDate = serv.getStrDaysAgo(days:30)
                startDatePicker.date = serv.getDateDaysAgo(days: 30)
                endDatePicker.date = serv.getDateDaysAgo(days: 0)
            case 3:
                sDate = serv.getStrDaysAgo(days:90)
                startDatePicker.date = serv.getDateDaysAgo(days: 90)
                endDatePicker.date = serv.getDateDaysAgo(days: 0)
            case 4:
                sDate = serv.getStrDaysAgo(days:365)
                startDatePicker.date = serv.getDateDaysAgo(days: 365)
                endDatePicker.date = serv.getDateDaysAgo(days: 0)
                
            case 5:
                sDate = getStartDatePicker()
                eDate = getEndDatePicker()
               
                
            default: let _: Int
        }
        dateSqlFilter = "[saleDate] >='" + sDate + "' AND [saleDate] <= '" + eDate + " 23:59:59'"
    }
    
    //  ============================================================================
    //                                 PICKERS
    //  ============================================================================
    //  =====================          D A T E                 =====================
    func initDatePickers(){
        startDatePicker.date = serv.getDateDaysAgo(days: 30)
        endDatePicker.date = serv.getDateDaysAgo(days: 0)
    }
    
    func getStartDatePicker()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "MM/dd/yyyy"
        return dateFormatter.string(from: startDatePicker.date)
    }
    func getEndDatePicker()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "MM/dd/yyyy"
        return dateFormatter.string(from: endDatePicker.date)
    }
    
    @IBAction func sDateChanged(_ sender: Any) {
        setDataByDate(dSelect: 5, btn: yearBtn, isPicker: true)
    }
    
    @IBAction func eDateChanged(_ sender: Any) {
        setDataByDate(dSelect: 5, btn: yearBtn, isPicker: true)
    }
    //  =====================     ALL OTHER PICKERS           =====================
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) ->Int{
        return storeNames.count
    }
          
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)->String? {
        return String(storeNames[row])
    }
         
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
     
        if row == 0{
            storeSqlFilter = ""
        }else{
            storeSqlFilter = " AND storeName  = " + storeNames[row] + " "
        }
        getSqlData()
    }

    //  ============================================================================
    //                                 SORT
    //  ============================================================================
    @IBAction func sortVNum(_ sender: Any) {
        if sortByVnum == true {
            sortByVnum = false
            vendors.sort(by: { (project1, project2) -> Bool in
                return (project1.vNum!) < (project2.vNum!)
            })
        }else{
            sortByVnum = true
            vendors.sort(by: { (project1, project2) -> Bool in
                return (project1.vNum!) > (project2.vNum!)
            })
        }
        topVendorTableView.reloadData()
    }
    @IBAction func sortVName(_ sender: Any) {
        if sortByName == true {
            sortByName = false
            vendors.sort(by: { (project1, project2) -> Bool in
                return (project1.vendorName!) < (project2.vendorName!)
            })
        }else{
            sortByName = true
            vendors.sort(by: { (project1, project2) -> Bool in
                return (project1.vendorName!) > (project2.vendorName!)
            })
        }
        topVendorTableView.reloadData()
    }
    @IBAction func sortItemsSold(_ sender: Any) {
        if sortByItemsSold == true {
            sortByItemsSold = false
            vendors.sort(by: { (project1, project2) -> Bool in
                return (project1.itemsSold!) < (project2.itemsSold!)
            })
        }else{
            sortByItemsSold = true
            vendors.sort(by: { (project1, project2) -> Bool in
                return (project1.itemsSold!) > (project2.itemsSold!)
            })
        }
        topVendorTableView.reloadData()
    }
    @IBAction func sortSales(_ sender: Any) {
        if sortBySales == true {
            sortBySales = false
            vendors.sort(by: { (project1, project2) -> Bool in
                return (project1.sales!) < (project2.sales!)
            })
        }else{
            sortBySales = true
            vendors.sort(by: { (project1, project2) -> Bool in
                return (project1.sales!) > (project2.sales!)
            })
        }
        topVendorTableView.reloadData()
    }
    @IBAction func sortCost(_ sender: Any) {
        if sortByCost == true {
            sortByCost = false
            vendors.sort(by: { (project1, project2) -> Bool in
                return (project1.cost!) < (project2.cost!)
            })
        }else{
            sortByCost = true
            vendors.sort(by: { (project1, project2) -> Bool in
                return (project1.cost!) > (project2.cost!)
            })
        }
        topVendorTableView.reloadData()
    }
    @IBAction func sortProfit(_ sender: Any) {
        if sortByProfit == true {
            sortByProfit = false
            vendors.sort(by: { (project1, project2) -> Bool in
                return (project1.profit!) < (project2.profit!)
            })
        }else{
            sortByProfit = true
            vendors.sort(by: { (project1, project2) -> Bool in
                return (project1.profit!) > (project2.profit!)
            })
        }
        topVendorTableView.reloadData()
    }
    @IBAction func sortPrcnt(_ sender: Any) {
        if sortByPrcnt == true {
            sortByPrcnt = false
            vendors.sort(by: { (project1, project2) -> Bool in
                return (project1.prcnt!) < (project2.prcnt!)
            })
        }else{
            sortByPrcnt = true
            vendors.sort(by: { (project1, project2) -> Bool in
                return (project1.prcnt!) > (project2.prcnt!)
            })
        }
        topVendorTableView.reloadData()
    }
}

