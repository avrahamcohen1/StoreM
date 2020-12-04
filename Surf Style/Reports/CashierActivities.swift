import Foundation
import UIKit

class CashierActivities: UIViewController, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var mainContainer: UIView!
    
    @IBOutlet weak var weekBtn: UIButton!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var quarterBtn: UIButton!
    @IBOutlet weak var yearBtn: UIButton!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    @IBOutlet weak var mainTableView: UITableView!
    
    var serv: Services = Services()
    var cashierAct = [CashierAct]()
  
    var dateSqlFilter: String = ""
    var selectedDate: Int = 1
    
    var sortByCid: Bool = true
    var sortByStore: Bool = true
    var sortByCashier: Bool = true
    var sortByType: Bool = true
    var sortByAmount: Bool = true
    
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
        setBtnsColor(btn:weekBtn, isPicker: false)
    
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
    cashierAct.removeAll()
            
    let ipPort = serv.getSettingData(key:"officeIP") + ":" + serv.getSettingData(key:"officePort")
    let pass = serv.getSettingData(key:"officePass")
    let db = serv.getSettingData(key:"officeDb")
    clientW.disconnect()
    clientW.connect(ipPort, username: "sa", password: pass, database: db) {success in
       var sqlStr: String
       sqlStr = "SELECT COUNT(actType) as amount, storeName, userName, userActTypeName FROM allStoresUserActivityTBL INNER JOIN userActTypeTBL ON userActTypeTBL.userActTypeID = allStoresUserActivityTBL.actType WHERE " + self.dateSqlFilter + " GROUP BY storeName, userName, userActTypeName ORDER BY amount DESC"
        clientW.execute(sqlStr) {results in
            if results != nil{
                for table in results! as NSArray {
                    for row in table as! NSArray {
                        self.cashierAct.append(CashierAct(cId: 0, store: 0, cashier: "", aType: "", amount: 0))
                                    
                        let i = self.cashierAct.count - 1
                        self.cashierAct[i].CId = self.cashierAct.count
        
                        for column in row as! NSDictionary {
                            switch column.key as! String{
                                case "userName":
                                    self.cashierAct[i].Cashier = (column.value as! NSObject) as? String ?? ""
                                case "amount":
                                    self.cashierAct[i].Amount = (column.value as! NSObject) as? Int ?? 0
                                case "userActTypeName":
                                    self.cashierAct[i].AType = (column.value as! NSObject) as? String ?? ""
                                case "storeName":
                                    self.cashierAct[i].Store = (column.value as! NSObject) as? Int ?? 0
                             
                            default: let _: Int
                            }
                        }
                    }
                }
            }
           
            self.mainTableView.reloadData()
            self.removeSpinnerS()
        }
    }
}
    
    
    // =======================================================================================
    //                             TABLE VIEW
    // =======================================================================================
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "cashierActCell", for: indexPath) as! CashierActCell
        
        if cashierAct.count > 0{
            let r: CashierAct = cashierAct[ indexPath.row ]
            cell.cId.text = String(r.CId!)
            cell.store.text = String(r.Store!)
            cell.cashier.text = r.Cashier!
            cell.aType.text = r.AType!
            cell.amount.text = String(r.Amount!)
            
            cell.cId.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
            cell.store.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
            cell.cashier.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
            cell.aType.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
            cell.amount.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
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
        return cashierAct.count
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
        dateSqlFilter = "[actDate] >='" + sDate + "' AND [actDate] <= '" + eDate + " 23:59:59'"
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
    
    //  ============================================================================
    //                                 SORT
    //  ============================================================================
    @IBAction func sortcIdNum(_ sender: Any) {
        if sortByCid == true {
            sortByCid = false
            cashierAct.sort(by: { (project1, project2) -> Bool in
                return (project1.CId!) < (project2.CId!)
            })
        }else{
            sortByCid = true
            cashierAct.sort(by: { (project1, project2) -> Bool in
                return (project1.CId!) > (project2.CId!)
            })
        }
        mainTableView.reloadData()
    }
    @IBAction func sortStore(_ sender: Any) {
        if sortByStore == true {
            sortByStore = false
            cashierAct.sort(by: { (project1, project2) -> Bool in
                return (project1.Store!) < (project2.Store!)
            })
        }else{
            sortByStore = true
            cashierAct.sort(by: { (project1, project2) -> Bool in
                return (project1.Store!) > (project2.Store!)
            })
        }
        mainTableView.reloadData()
    }
    @IBAction func sortCashier(_ sender: Any) {
        if sortByCashier == true {
            sortByCashier = false
            cashierAct.sort(by: { (project1, project2) -> Bool in
                return (project1.Cashier!) < (project2.Cashier!)
            })
        }else{
            sortByCashier = true
            cashierAct.sort(by: { (project1, project2) -> Bool in
                return (project1.Cashier!) > (project2.Cashier!)
            })
        }
        mainTableView.reloadData()
    }
    @IBAction func sortType(_ sender: Any) {
        if sortByType == true {
            sortByType = false
            cashierAct.sort(by: { (project1, project2) -> Bool in
                return (project1.AType!) < (project2.AType!)
            })
        }else{
            sortByType = true
            cashierAct.sort(by: { (project1, project2) -> Bool in
                return (project1.AType!) > (project2.AType!)
            })
        }
        mainTableView.reloadData()
    }
   
     
    
    @IBAction func sortAmount(_ sender: Any) {
        if sortByAmount == true {
            sortByAmount = false
            cashierAct.sort(by: { (project1, project2) -> Bool in
                return (project1.Amount!) < (project2.Amount!)
            })
        }else{
            sortByAmount = true
            cashierAct.sort(by: { (project1, project2) -> Bool in
                return (project1.Amount!) > (project2.Amount!)
            })
        }
        mainTableView.reloadData()
    }
   
}

