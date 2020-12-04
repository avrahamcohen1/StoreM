
import Foundation
import UIKit

class SalesAndProfit: UIViewController, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var mainContainer: UIView!
    
    @IBOutlet weak var weekBtn: UIButton!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var quarterBtn: UIButton!
    @IBOutlet weak var yearBtn: UIButton!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var tSalesWCost: UILabel!
    @IBOutlet weak var tSalesNCost: UILabel!
    @IBOutlet weak var tProfitWCost: UILabel!
    @IBOutlet weak var tProfitNCost: UILabel!
    @IBOutlet weak var tProfit: UILabel!
    @IBOutlet weak var tProfitPrcnt: UILabel!
  
    var serv: Services = Services()
    var saleProfit = [SalesProfit]()
  
    var dateSqlFilter: String = ""
    var selectedDate: Int = 2
    
    var sortByCid: Bool = true
    var sortByStore: Bool = true
    var sortBySaleWCost: Bool = true
    var sortByProfitWCost: Bool = true
    var sortBySaleNCost: Bool = true
    var sortByProfitNCost: Bool = true
    var sortByTotalProfit: Bool = true
    var sortByProfitPrcnt: Bool = true
    
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
    saleProfit.removeAll()
            
    let ipPort = serv.getSettingData(key:"officeIP") + ":" + serv.getSettingData(key:"officePort")
    let pass = serv.getSettingData(key:"officePass")
    let db = serv.getSettingData(key:"officeDb")
    clientW.disconnect()
    clientW.connect(ipPort, username: "sa", password: pass, database: db) {success in
       var sqlStr: String
       sqlStr = "SELECT storeName, SUM(qty*itemPrice) as salesWCost, SUM(qty*(itemPrice-ItemCost)) as profitWCost FROM allStoresReceiptItemTBL WHERE (itemCost IS NOT NULL AND itemCost>0) AND " + self.dateSqlFilter + " GROUP BY storeName"
        clientW.execute(sqlStr) {results in
            if results != nil{
                for table in results! as NSArray {
                    for row in table as! NSArray {
                        self.saleProfit.append(SalesProfit(cId: 0, store: 0, salesWCost: 0, profitWCost: 0, salesNCost: 0, profitNCost: 0, totalProfit: 0, totalProfitPrcnt: 0))
                                   
                        let i = self.saleProfit.count - 1
                        self.saleProfit[i].CId = self.saleProfit.count
        
                        for column in row as! NSDictionary {
                            switch column.key as! String{
                                case "storeName":
                                    self.saleProfit[i].Store = (column.value as! NSObject) as? Int ?? 0
                                case "salesWCost":
                                    self.saleProfit[i].salesWCost = (column.value as! NSObject) as? Double ?? 0
                                case "profitWCost":
                                    self.saleProfit[i].profitWCost = (column.value as! NSObject) as? Double ?? 0
                                default: let _: Int
                            }
                        }
                    }
                }
            
                sqlStr = "SELECT storeName, SUM(qty*itemPrice) as salesNCost FROM allStoresReceiptItemTBL WHERE (itemCost IS NULL OR itemCost=0) AND " + self.dateSqlFilter + " GROUP BY storeName"
                clientW.execute(sqlStr) {results in
                    if results != nil{
                        var storeIdx: Int = 0
                        for table in results! as NSArray {
                            for row in table as! NSArray {
                                for column in row as! NSDictionary {
                                    switch column.key as! String{
                                        case "storeName":
                                            let store = (column.value as! NSObject) as? Int ?? 0
                                            storeIdx = -1
                                            for i in 0...self.saleProfit.count - 1{
                                                if store == self.saleProfit[i].Store{
                                                    storeIdx = i
                                                    break
                                                }
                                            }
                                            if storeIdx == -1{
                                                storeIdx = self.saleProfit.count - 1
                                                self.saleProfit.append(SalesProfit(cId: 0, store: store, salesWCost: 0, profitWCost: 0, salesNCost: 0, profitNCost: 0, totalProfit: 0, totalProfitPrcnt: 0))
                                            }
                                         case "salesNCost":
                                            self.saleProfit[storeIdx].salesNCost = (column.value as! NSObject) as? Double ?? 0
                                            self.saleProfit[storeIdx].profitNCost = self.saleProfit[storeIdx].salesNCost! * 2 / 3
                                        default: let _: Int
                                    }
                                }
                            }
                        }
                    }
               
                    self.mainTableView.reloadData{self.setTotalLine()}
                    self.removeSpinnerS()
                }
            }
        }
    }
}
    func setTotalLine(){
        var tdSalesWCost:Double = 0
        var tdSalesNCost:Double = 0
        var tdProfitWCost:Double = 0
        var tdProfitNCost:Double = 0
        var tdProfit:Double = 0
        var tdProfitPrcnt:Double = 0
        
        for i in 0...saleProfit.count - 1{
            tdSalesWCost += saleProfit[i].salesWCost!
            tdProfitWCost += saleProfit[i].profitWCost!
            tdSalesNCost += saleProfit[i].salesNCost!
            tdProfitNCost += saleProfit[i].profitNCost!
            tdProfit += saleProfit[i].totalProfit!
            tdProfitPrcnt += saleProfit[i].totalProfitPrcnt!
        }
        
        tSalesWCost.text = serv.getCurrency(number: tdSalesWCost, len:23)
        tProfitWCost.text = serv.getCurrency(number: tdProfitWCost, len:23)
        tSalesNCost.text = serv.getCurrency(number: tdSalesNCost, len:23)
        tProfitNCost.text = serv.getCurrency(number: tdProfitNCost, len:23)
        tProfit.text = serv.getCurrency(number: tdProfit, len:23)
        tProfitPrcnt.text = serv.getPrecent(number: 100 * tdProfitPrcnt/Double((saleProfit.count - 1)), isZero: tdProfitPrcnt < 1, len: 15)
      
    }
    
    // =======================================================================================
    //                             TABLE VIEW
    // =======================================================================================
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "salesAndProfitCell", for: indexPath) as! SalesAndProfitCell
        
        if saleProfit.count > 0{
            let r: SalesProfit = saleProfit[ indexPath.row ]
            cell.cId.text = String(r.CId!)
            cell.store.text = String(r.Store!)
            cell.salesWCost.text =  String(format: "$%.0f",locale: Locale.current, r.salesWCost!)
            cell.profitWCost.text = String(format: "$%.0f",locale: Locale.current, r.profitWCost!)
            cell.salesNCost.text =  String(format: "$%.0f",locale: Locale.current, r.salesNCost!)
            cell.profitNCost.text = String(format: "$%.0f",locale: Locale.current, r.profitNCost!)
            
            r.totalProfit = r.profitWCost! + r.profitNCost!
            cell.totalProfit.text =  String(format: "$%.0f",locale: Locale.current, r.totalProfit!)
          
            let tSale = r.salesWCost! + r.salesNCost!
            let tProfit = r.profitWCost! + r.profitNCost! + 0.001
            r.totalProfitPrcnt = tSale / (tSale - tProfit)
            cell.totalProfitPrcnt.text = String(format: "%.0f%%",locale: Locale.current, 100 * r.totalProfitPrcnt!)
           
            cell.cId.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
            cell.store.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
            cell.salesWCost.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
            cell.profitWCost.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
            cell.salesNCost.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
            cell.profitNCost.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
            cell.totalProfit.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
            cell.totalProfitPrcnt.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
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
        return saleProfit.count
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
    
    //  ============================================================================
    //                                 SORT
    //  ============================================================================
    @IBAction func sortcIdNum(_ sender: Any) {
        if sortByCid == true {
            sortByCid = false
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.CId!) < (project2.CId!)
            })
        }else{
            sortByCid = true
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.CId!) > (project2.CId!)
            })
        }
        mainTableView.reloadData()
    }
    @IBAction func sortStore(_ sender: Any) {
        if sortByStore == true {
            sortByStore = false
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.Store!) < (project2.Store!)
            })
        }else{
            sortByStore = true
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.Store!) > (project2.Store!)
            })
        }
        mainTableView.reloadData()
    }
    @IBAction func sortSalesWItems(_ sender: Any) {
        if sortBySaleWCost == true {
            sortBySaleWCost = false
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.salesWCost!) < (project2.salesWCost!)
            })
        }else{
            sortBySaleWCost = true
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.salesWCost!) > (project2.salesWCost!)
            })
        }
        mainTableView.reloadData()
    }
    @IBAction func sortProfitWitems(_ sender: Any) {
        if sortByProfitWCost == true {
            sortByProfitWCost = false
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.profitWCost!) < (project2.profitWCost!)
            })
        }else{
            sortByProfitWCost = true
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.profitWCost!) > (project2.profitWCost!)
            })
        }
        mainTableView.reloadData()
    }
       
    @IBAction func sortSalesNCost(_ sender: Any) {
        if sortBySaleNCost == true {
            sortBySaleNCost = false
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.salesNCost!) < (project2.salesNCost!)
            })
        }else{
            sortBySaleNCost = true
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.salesNCost!) > (project2.salesNCost!)
            })
        }
        mainTableView.reloadData()
    }
    @IBAction func sortProfitNCost(_ sender: Any) {
        if sortByProfitNCost == true {
            sortByProfitNCost = false
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.profitNCost!) < (project2.profitNCost!)
            })
        }else{
            sortByProfitNCost = true
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.profitNCost!) > (project2.profitNCost!)
            })
        }
        mainTableView.reloadData()
    }
    @IBAction func sortTotalProfit(_ sender: Any) {
        if sortByTotalProfit == true {
            sortByTotalProfit = false
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.totalProfit!) < (project2.totalProfit!)
            })
        }else{
            sortByTotalProfit = true
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.totalProfit!) > (project2.totalProfit!)
            })
        }
        mainTableView.reloadData()
    }
    @IBAction func sortProfitPrcnt(_ sender: Any) {
        if sortByProfitPrcnt == true {
            sortByProfitPrcnt = false
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.totalProfitPrcnt!) < (project2.totalProfitPrcnt!)
            })
        }else{
            sortByProfitPrcnt = true
            saleProfit.sort(by: { (project1, project2) -> Bool in
                return (project1.totalProfitPrcnt!) > (project2.totalProfitPrcnt!)
            })
        }
        mainTableView.reloadData()
    }
    
 
}

    extension UITableView {
       func reloadData(completion:@escaping ()->()) {
           UIView.animate(withDuration: 0, animations: { self.reloadData() })
               { _ in completion() }
       }
    }
