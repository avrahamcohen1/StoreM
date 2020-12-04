
import Foundation
import UIKit

class outslipList: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var weekBtn: UIButton!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var yearBtn: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var storeSelect: UIPickerView!
    @IBOutlet weak var outslipTableView: UITableView!
    
    var serv: Services = Services()
    var outslips = [Outslips]()
    var storeNames = ["All","421", "1670", "1451", "1441", "1332", "1301", "1208", "1155", "1041", "1036", "840", "645"]
    var storeSqlFilter: String = ""
    var dateSqlFilter: String = ""
    var selectedDate: Int = 2
    var formatStr: String = ""
    var sortByID: Bool = true
    var sortByDate: Bool = true
    var sortByStore: Bool = true
    var sortByTotal: Bool = true
    var sortByType: Bool = true
    
    //==========================================================================================
    //                                       INIT
    //==========================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
        getOutslipInfo()
    }
     
    func initControls(){
        serv.roundContainer(container: mainContainer)
        serv.roundBtn(btn: todayBtn)
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
        
        setSqlDateFilter()
    }
    
    func setBtnsColor(btn:UIButton, isPicker: Bool){
        todayBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
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
func getOutslipInfo(){
    showSpinnerS(onView: self.view)
    let clientW = SQLClient.sharedInstance()!
    outslips.removeAll()
        
    let wareIpPort = serv.getSettingData(key:"wareIP") + ":" + serv.getSettingData(key:"warePort")
    let pass = serv.getSettingData(key:"warePass")
    let db = serv.getSettingData(key:"wareDb")
    clientW.disconnect()
    clientW.connect(wareIpPort, username: "sa", password: pass, database: db) {success in
        let sqlStr = "SELECT outslipAutoID, clientID, [Date] as outslipDate, total, outslipType FROM outslipTBL WHERE " + self.storeSqlFilter +  self.dateSqlFilter + " ORDER BY outslipAutoID DESC"
            clientW.execute(sqlStr) {results in
            if results != nil{
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            self.outslips.append(Outslips(outslipID: 0, outslipDate: Date(), store: "", total: 0, outslipType: ""))
                            let i = self.outslips.count - 1
                            for column in row as! NSDictionary {
                                switch column.key as! String{
                                    case "outslipAutoID":
                                        self.outslips[i].OutslipID = (column.value as! NSObject) as? Int64 ?? 0
                                    case "clientID":
                                        let c = (column.value as! NSObject) as? Int ?? 0
                                        self.outslips[i].Store = String(c)
                                    case "outslipDate":
                                        self.outslips[i].OutslipDate = (column.value as! NSObject) as? Date ?? Date()
                                    case "total":
                                        self.outslips[i].Total = (column.value as! NSObject) as? Double ?? 0
                                    case "outslipType":
                                        let t = (column.value as! NSObject) as? Int ?? 0
                                        if t == 2{
                                            self.outslips[i].OutslipType = "Printing"
                                        }else{
                                            self.outslips[i].OutslipType = "Warehouse"
                                        }
                                    default: let _: Int
                                }
                            }
                        }
                    }
                }
                self.outslipTableView.reloadData()
                self.removeSpinnerS()
            }
        }
    }
    
    // =======================================================================================
    //                             TABLE VIEW
    // =======================================================================================
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = outslipTableView.dequeueReusableCell(withIdentifier: "outslipListCell", for: indexPath) as! outslipListCell
        if outslips.count > 0{
            let o: Outslips
            o = outslips[indexPath.row]
         
            cell.OutslipID.text = String(o.OutslipID!)
            
            let df = DateFormatter()
            df.timeZone = TimeZone(identifier: "UTC")
            df.dateFormat = "MM-dd-yyyy h:mm a"
            cell.OutslipDate.text = df.string(from:o.OutslipDate!)
        
            cell.Store.text = String(o.Store!)
          
            let t: Double = o.Total!
            cell.Total.text = String(format: "$%.02f", t)
            
            cell.OutslipType.text = o.OutslipType!
         
        }
        cell.initialize()
        return cell
    }
       
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return outslips.count
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
    @IBAction func todayClick(_ sender: Any) {
        setOutslipByDate(dSelect: 1, btn: todayBtn, isPicker: false)
    }
    
    @IBAction func weekClick(_ sender: Any) {
        setOutslipByDate(dSelect: 2, btn: weekBtn, isPicker: false)
    }
    
    @IBAction func monthClick(_ sender: Any) {
        setOutslipByDate(dSelect: 3, btn: monthBtn, isPicker: false)
    }
    
    @IBAction func yearClick(_ sender: Any) {
        setOutslipByDate(dSelect: 4, btn: yearBtn, isPicker: false)
    }

    func setOutslipByDate(dSelect:Int, btn:UIButton, isPicker: Bool){
        selectedDate = dSelect
        setSqlDateFilter()
        setBtnsColor(btn: btn, isPicker: isPicker)
        getOutslipInfo()
    }
    
    func setSqlDateFilter(){
        var sDate: String = ""
        formatStr = "format(saleDate,'yyyy/MM/dd')"
        switch selectedDate {
            case 1:
                sDate = serv.getStrDaysAgo(days:0)
            case 2:
                sDate = serv.getStrDaysAgo(days:7)
            case 3:
                sDate = serv.getStrDaysAgo(days:30)
            case 4:
                sDate = serv.getStrDaysAgo(days:365)
            case 5:
                sDate = getDatePicker()
            default: let _: Int
        }
        
   
        let today = serv.getStrDaysAgo(days:0)
        dateSqlFilter = "[Date] >='" + sDate + "' AND [Date] <= '" + today + " 23:59:59'"
        
    }
    
    //  ============================================================================
    //                                 PICKERS
    //  ============================================================================
    func initDatePickerLimits(){
        datePicker.maximumDate = serv.getDateDaysAgo(days: 1)
    }
       
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func getDatePicker()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "MM/dd/yyyy 00:00:00"
        return dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        setOutslipByDate(dSelect: 5, btn: yearBtn, isPicker: true)
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
            storeSqlFilter = "clientID = " + storeNames[row] + " AND "
        }
        getOutslipInfo()
       
    }

    //  ============================================================================
    //                                 SORT
    //  ============================================================================
    @IBAction func sortOutslipID(_ sender: Any) {
        if sortByID == true {
            sortByID = false
            outslips.sort(by: { (project1, project2) -> Bool in
                return (project1.OutslipID ?? 0) < (project2.OutslipID ?? 0)
            })
        }else{
            sortByID = true
            outslips.sort(by: { (project1, project2) -> Bool in
                return (project1.OutslipID ?? 0) > (project2.OutslipID ?? 0)
            })
        }
        outslipTableView.reloadData()
    }
    
    @IBAction func sortDate(_ sender: Any) {
        if sortByDate == true {
            sortByDate = false
            outslips.sort(by: { (project1, project2) -> Bool in
                return (project1.OutslipDate!) < (project2.OutslipDate!)
            })
        }else{
            sortByDate = true
            outslips.sort(by: { (project1, project2) -> Bool in
                return (project1.OutslipDate!) > (project2.OutslipDate!)
            })
        }
        outslipTableView.reloadData()
    }
    
    @IBAction func sortStore(_ sender: Any) {
        if sortByStore == true {
            sortByStore = false
            outslips.sort(by: { (project1, project2) -> Bool in
                return (project1.Store!) < (project2.Store!)
            })
        }else{
            sortByStore = true
            outslips.sort(by: { (project1, project2) -> Bool in
                return (project1.Store!) > (project2.Store!)
            })
        }
        outslipTableView.reloadData()
    }
    
    @IBAction func sortTotal(_ sender: Any) {
        if sortByTotal == true {
            sortByTotal = false
            outslips.sort(by: { (project1, project2) -> Bool in
                return (project1.Total ?? 0) < (project2.Total ?? 0)
            })
        }else{
            sortByTotal = true
            outslips.sort(by: { (project1, project2) -> Bool in
                return (project1.Total ?? 0) > (project2.Total ?? 0)
            })
        }
        outslipTableView.reloadData()
    }
    
    @IBAction func sortType(_ sender: Any) {
        if sortByType == true {
            sortByType = false
            outslips.sort(by: { (project1, project2) -> Bool in
                return (project1.OutslipType!) < (project2.OutslipType!)
            })
        }else{
            sortByType = true
            outslips.sort(by: { (project1, project2) -> Bool in
                return (project1.OutslipType!) > (project2.OutslipType!)
            })
        }
        outslipTableView.reloadData()
    }
}

