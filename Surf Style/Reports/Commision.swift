import Foundation
import UIKit

class Commision: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var mainContainer: UIView!
    
    @IBOutlet weak var weekBtn: UIButton!
    @IBOutlet weak var twoWeekBtn: UIButton!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var yearBtn: UIButton!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var reportType: UIPickerView!
    
    @IBOutlet weak var commisionTableView: UITableView!
    
    var serv: Services = Services()
    var commision = [CommisionRec]()
    var reportTypeStr = ["Detailed Report", "Total Report"]
    var dateSqlFilter: String = ""
    var reportTypeVal: Int  = 0
    var selectedDate: Int = 2
    
    var sortByCid: Bool = true
    var sortByCDate: Bool = true
    var sortByEmployee: Bool = true
    var sortBySale: Bool = true
    var sortByCommision: Bool = true
    var sortByReceiptNum: Bool = true
    
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
        serv.roundBtn(btn: twoWeekBtn)
        serv.roundBtn(btn: monthBtn)
        serv.roundBtn(btn: yearBtn)
        setBtnsColor(btn:twoWeekBtn, isPicker: false)
    
        initDatePickers()
        setSqlDateFilter()
    }
    
    func setBtnsColor(btn:UIButton, isPicker: Bool){
        weekBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        twoWeekBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        monthBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
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
    commision.removeAll()
            
    let ipPort = serv.getSettingData(key:"localIP") + ":" + serv.getSettingData(key:"localPort")
    let pass = serv.getSettingData(key:"localPass")
    let db = serv.getSettingData(key:"localDb")
    clientW.disconnect()
    clientW.connect(ipPort, username: "sa", password: pass, database: db) {success in
        var sqlStr: String
        if self.reportTypeVal == 0{
            sqlStr = "SELECT commisionValue as tSale, commisionDate, userName, receiptNum FROM commisionTBL LEFT JOIN userTBL ON  userTBL.userID = commisionTBL.userID WHERE " + self.dateSqlFilter +  " ORDER by userName"
        }else{
            sqlStr = "SELECT SUM(commisionValue) as tSale, userName FROM commisionTBL LEFT JOIN userTBL ON userTBL.userID = commisionTBL.userID WHERE " + self.dateSqlFilter + " GROUP BY userName ORDER by userName"
        }
        clientW.execute(sqlStr) {results in
            if results != nil{
                for table in results! as NSArray {
                    for row in table as! NSArray {
                        self.commision.append(CommisionRec(cId: 0, cDate: Date() , employee: "", sale: 0, commisionVal: 0, receiptNum: 0))
                                    
                        let i = self.commision.count - 1
                        self.commision[i].CId = self.commision.count
        
                        for column in row as! NSDictionary {
                            switch column.key as! String{
                                case "userName":
                                    self.commision[i].Employee = (column.value as! NSObject) as? String ?? ""
                                case "tSale":
                                    self.commision[i].Sale = (column.value as! NSObject) as? Double ?? 0
                                case "receiptNum":
                                    self.commision[i].ReceiptNum = (column.value as! NSObject) as? Double ?? 0
                                case "commisionDate":
                                    self.commision[i].CDate = (column.value as! NSObject) as? Date ?? Date()
                             
                            default: let _: Int
                            }
                        }
                    }
                }
            }
           
            self.commisionTableView.reloadData()
            self.removeSpinnerS()
        }
    }
}
    
    
    // =======================================================================================
    //                             TABLE VIEW
    // =======================================================================================
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = commisionTableView.dequeueReusableCell(withIdentifier: "commisionCell", for: indexPath) as! CommisionCell
        
        if commision.count > 0{
            let r: CommisionRec = commision[indexPath.row]
            cell.cId.text = String(r.CId!) + " "
            cell.employee.text = " " + r.Employee!
            cell.sale.text = String(format: "$%.0f ",locale: Locale.current, r.Sale!)
            cell.commisionVal.text = String(format: "$%.2f ",locale: Locale.current, 0.02 * r.Sale!)
            cell.receiptNum.text = String(format: "%.0f", r.ReceiptNum!)
            let df = DateFormatter()
            df.timeZone = TimeZone(identifier: "UTC")
            df.dateFormat = "MM-dd-yyyy h:mm a"
            cell.cDate.text = df.string(from:r.CDate!)
            
            cell.sale.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
            cell.commisionVal.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
            cell.cId.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
            cell.receiptNum.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
            cell.employee.padding = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
            cell.cDate.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
          
        }
        cell.initialize()
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if(indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.05)
        }else {
            cell.backgroundColor = UIColor.white
        }
    }
       
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return commision.count
    }
       
    func numberOfSections(in tableView: UITableView)->Int{
        return 1
    }
    
   

    //==========================================================================================
    //                              DATES BUTTONS
    //==========================================================================================
    
    @IBAction func weekClick(_ sender: Any) {
        setDataByDate(dSelect: 1, btn: weekBtn, isPicker: false)
    }
    @IBAction func twoWeekClick(_ sender: Any) {
        setDataByDate(dSelect: 2, btn: twoWeekBtn, isPicker: false)
    }
    @IBAction func monthClick(_ sender: Any) {
        setDataByDate(dSelect: 3, btn: monthBtn, isPicker: false)
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
       
        eDate = serv.getStrDaysAgo(days:0)
        
        switch selectedDate {
            case 1:
                sDate = serv.getStrDaysAgo(days:7)
                startDatePicker.date = serv.getDateDaysAgo(days: 7)
                endDatePicker.date = serv.getDateDaysAgo(days: 0)
            case 2:
                sDate = serv.getStrDaysAgo(days:14)
                startDatePicker.date = serv.getDateDaysAgo(days: 14)
                endDatePicker.date = serv.getDateDaysAgo(days: 0)
            case 3:
                sDate = serv.getStrDaysAgo(days:30)
                startDatePicker.date = serv.getDateDaysAgo(days: 30)
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
        dateSqlFilter = "[commisionDate] >='" + sDate + "' AND [commisionDate] <= '" + eDate + " 23:59:59'"
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
        return reportTypeStr.count
    }
          
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)->String? {
        return String(reportTypeStr[row])
    }
         
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        reportTypeVal = row
        getSqlData()
    }

    //  ============================================================================
    //                                 SORT
    //  ============================================================================
    @IBAction func sortVNum(_ sender: Any) {
        if sortByCid == true {
            sortByCid = false
            commision.sort(by: { (project1, project2) -> Bool in
                return (project1.CId!) < (project2.CId!)
            })
        }else{
            sortByCid = true
            commision.sort(by: { (project1, project2) -> Bool in
                return (project1.CId!) > (project2.CId!)
            })
        }
        commisionTableView.reloadData()
    }
    @IBAction func sortDate(_ sender: Any) {
        if sortByCDate == true {
            sortByCDate = false
            commision.sort(by: { (project1, project2) -> Bool in
                return (project1.CDate!) < (project2.CDate!)
            })
        }else{
            sortByCDate = true
            commision.sort(by: { (project1, project2) -> Bool in
                return (project1.CDate!) > (project2.CDate!)
            })
        }
        commisionTableView.reloadData()
    }
    @IBAction func sortReceiptNum(_ sender: Any) {
        if sortByReceiptNum == true {
            sortByReceiptNum = false
            commision.sort(by: { (project1, project2) -> Bool in
                return (project1.ReceiptNum!) < (project2.ReceiptNum!)
            })
        }else{
            sortByReceiptNum = true
            commision.sort(by: { (project1, project2) -> Bool in
                return (project1.ReceiptNum!) > (project2.ReceiptNum!)
            })
        }
        commisionTableView.reloadData()
    }
    @IBAction func sortEmployee(_ sender: Any) {
        if sortByEmployee == true {
            sortByEmployee = false
            commision.sort(by: { (project1, project2) -> Bool in
                return (project1.Employee!) < (project2.Employee!)
            })
        }else{
            sortByEmployee = true
            commision.sort(by: { (project1, project2) -> Bool in
                return (project1.Employee!) > (project2.Employee!)
            })
        }
        commisionTableView.reloadData()
    }
   
     
    
    @IBAction func sortCommsion(_ sender: Any) {
        if sortByCommision == true {
            sortByCommision = false
            commision.sort(by: { (project1, project2) -> Bool in
                return (project1.CommisionVal!) < (project2.CommisionVal!)
            })
        }else{
            sortByCommision = true
            commision.sort(by: { (project1, project2) -> Bool in
                return (project1.CommisionVal!) > (project2.CommisionVal!)
            })
        }
        commisionTableView.reloadData()
    }
    
    @IBAction func sortSale(_ sender: Any) {
        if sortBySale == true {
            sortBySale = false
            commision.sort(by: { (project1, project2) -> Bool in
                return (project1.Sale!) < (project2.Sale!)
            })
        }else{
            sortBySale = true
            commision.sort(by: { (project1, project2) -> Bool in
                return (project1.Sale!) > (project2.Sale!)
            })
        }
        commisionTableView.reloadData()
    }
}


