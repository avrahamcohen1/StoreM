import UIKit

class StoreSalesTable: UIViewController, UITableViewDataSource, UITableViewDelegate{
   
    @IBOutlet weak var totalsLBL1A: UILabel!
    @IBOutlet weak var totalsLBL1B: UILabel!
    @IBOutlet weak var totalsLBL1C: UILabel!
    @IBOutlet weak var totalsLBL1D: UILabel!
    @IBOutlet weak var totalsLBL1E: UILabel!
    
    @IBOutlet weak var totalsLBL2A: UILabel!
    @IBOutlet weak var totalsLBL2B: UILabel!
    @IBOutlet weak var totalsLBL2C: UILabel!
    @IBOutlet weak var totalsLBL2D: UILabel!
    @IBOutlet weak var totalsLBL2E: UILabel!
    
    @IBOutlet weak var totalsLBL3A: UILabel!
    @IBOutlet weak var totalsLBL3B: UILabel!
    @IBOutlet weak var totalsLBL3C: UILabel!
    @IBOutlet weak var totalsLBL3D: UILabel!
    @IBOutlet weak var totalsLBL3E: UILabel!
    
    @IBOutlet weak var totalsLBL4A: UILabel!
    @IBOutlet weak var totalsLBL4B: UILabel!
    @IBOutlet weak var totalsLBL4C: UILabel!
    @IBOutlet weak var totalsLBL4D: UILabel!
    @IBOutlet weak var totalsLBL4E: UILabel!
    
    
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var tableHeaderLBL: UILabel!
    @IBOutlet weak var mainTableView: UITableView!
    
    enum DateType{
        case today
        case todayL
        case month
        case momthL
        case year
        case yearL
        case yearC
        case yearCL
    }
    var dateType = DateType.today
    
    var sales = [Sales]()
    var salesSorted = [Sales]()
    var maxStores: Int = 0
    var serv: Services = Services()
    let client = SQLClient.sharedInstance()!
    var officeIpPort: String = ""
    var officePass: String = ""
    var officeDb: String =  ""
    
    // Totals of last year of All stores
    var tDayA:   Double = 1
    var tMonthA: Double = 1
    var tYearA:  Double = 1
    var tYearCA: Double = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPage()
        readSqlData()
    }
    
    func initPage(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let sDate = dateFormatter.string(from: Date())
        tableHeaderLBL.text = tableHeaderLBL.text! + "        " + sDate
        serv.roundContainer(container: mainContainer)
    }
        
    func readSqlData(){
        officeIpPort = getSettingData(key:"officeIP") + ":" + getSettingData(key:"officePort")
        officePass = getSettingData(key:"officePass")
        officeDb = getSettingData(key:"officeDb")
        
        client.disconnect()
        client.connect(officeIpPort, username: "sa", password: officePass, database: officeDb) { success in
            self.client.execute("SELECT CAST(shortName AS INT) as storeName FROM storeTBL WHERE enablePolling=1 AND CAST(nameCodeStr AS INT) > 0") { results in
                if results != nil {
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            self.sales.append( Sales(storeId: 0, today: 0, todayL: 0, week: 0, weekL: 0, month:0, monthL: 0, year: 0, yearL: 0, cYear:0, cYearL:0))
                         
                            for column in row as! NSDictionary {
                                self.sales[self.maxStores].storeId = ((column.value as! NSObject) as? Int)!
                            }
                            self.maxStores += 1
                        }
                    }
                    self.sales.append( Sales(storeId: 0, today: 0, todayL: 0, week: 0, weekL: 0, month:0, monthL: 0, year: 0, yearL: 0, cYear:0, cYearL:0))
                                           
                    self.readSqlForEachStore()
                }
            }
        }
    }
    
    func readSqlForEachStore(){
        showSpinnerS(onView: self.view)
        var dRange: String = ""
        let qryStr1 = "SELECT CAST(storeName AS INT) AS storeName, SUM(totalSale) AS salesVal FROM allStoresReceiptTBL WHERE saleDate "
        let qryStr2 = " GROUP BY CAST(storeName AS INT)"
           
        // Today
        dRange = self.getDateRange(sNum:0, eNum:1)
        self.excSqlQuery(dType: .today,  qry: qryStr1 + dRange + qryStr2)
                         
        // Last year Today
        dRange = self.getLastYearToday()
        self.excSqlQuery(dType: .todayL, qry: qryStr1 + dRange + qryStr2)
                        
        // Month
        dRange = self.getDateRange(sNum:-30, eNum:0)
        self.excSqlQuery(dType: .month,  qry: qryStr1 + dRange + qryStr2)
                         
        // Last year Month
        dRange = self.getDateRange(sNum:-365-30, eNum:-365)
        self.excSqlQuery(dType: .momthL, qry: qryStr1 + dRange + qryStr2)
                         
        // Year
        dRange = self.getDateRange(sNum:-365, eNum:0)
        self.excSqlQuery(dType: .year,   qry: qryStr1 + dRange + qryStr2)
                         
        // Last year Year
        dRange = self.getDateRange(sNum:-365 - 365, eNum:-365)
        self.excSqlQuery(dType: .yearL,  qry: qryStr1 + dRange + qryStr2)
              
        // Calendar Year
        dRange = self.getCalendarDateRange(sNum: 0, eNum: 0)
        self.excSqlQuery(dType: .yearC,  qry: qryStr1 + dRange + qryStr2)
                         
        // Calendar Last year Year
        dRange = self.getCalendarDateRange(sNum: -365, eNum: -365)
        self.excSqlQuery(dType: .yearCL, qry: qryStr1 + dRange + qryStr2)
    }
    
    func excSqlQuery( dType:DateType, qry:String){
        var sales: Double = 0
        var sName: Int = 0
        var selectedIdx:Int = 0
        client.execute(qry) { results in
            if results != nil {
                for table in results! as NSArray {
                    for row in table as! NSArray {
                        for column in row as! NSDictionary {
                            switch column.key as! String{
                                case "storeName":
                                    sName = ((column.value as! NSObject) as? Int)!
                                    selectedIdx = self.maxStores
                                    for i in 0...self.maxStores - 1 {
                                        if self.sales[i].storeId == sName{
                                            selectedIdx  = i
                                            break
                                        }
                                    }
                                case "salesVal":
                                    sales = ((column.value as! NSObject) as? Double)!
                                    switch dType {
                                        case .today:
                                            self.sales[selectedIdx].today  = sales
                                        case .todayL:
                                            self.sales[selectedIdx].todayL = sales
                                        case .month:
                                            self.sales[selectedIdx].month  = sales
                                        case .momthL:
                                            self.sales[selectedIdx].monthL = sales
                                        case .year:
                                            self.sales[selectedIdx].year   = sales
                                        case .yearL:
                                            self.sales[selectedIdx].yearL  = sales
                                        case .yearC:
                                            self.sales[selectedIdx].cYear  = sales
                                        case .yearCL:
                                            self.sales[selectedIdx].cYearL = sales
                                    }
                                default: let _: Int
                            }
                        }
                    }
                }
                if dType == .yearCL{
                    self.readSqlAllTotals()
                }
            }
        }
    }
    func readSqlAllTotals(){
        readSqlTotalForDates(dataType:1, dateFilter: getLastYearToday())
        readSqlTotalForDates(dataType:2, dateFilter: getDateRange(sNum:-365-30, eNum:-365))
        readSqlTotalForDates(dataType:3, dateFilter: getDateRange(sNum:-365-365, eNum:-365))
        let d = getCalendarDateRange(sNum:-365, eNum: -365)
        print (d)
        readSqlTotalForDates(dataType:4, dateFilter: d)
    }
    
    public func readSqlTotalForDates(dataType:Int, dateFilter:String){
        officeIpPort = getSettingData(key:"officeIP") + ":" + getSettingData(key:"officePort")
        officePass = getSettingData(key:"officePass")
        officeDb = getSettingData(key:"officeDb")
        
        client.disconnect()
        client.connect(officeIpPort, username: "sa", password: officePass, database: officeDb) { success in
            let sqlStr = "SELECT SUM(totalSale) AS salesVal FROM allStoresReceiptTBL WHERE saleDate " + dateFilter
             
            self.client.execute(sqlStr) { results in
                if results != nil {
                    var total:Double = 0
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            for column in row as! NSDictionary {
                                total  += ((column.value as! NSObject) as? Double)!
                            }
                        }
                    }
                    
                    switch dataType{
                        case 1:
                            self.tDayA = total
                        case 2:
                            self.tMonthA = total
                        case 3:
                            self.tYearA = total
                        case 4:
                            self.tYearCA  = total
                            self.setTotalLabel()
                           
                        default: let _: Int
                    }
                    
                }
            }
        }
    }
    
   
    func setTotalLabel(){
        // Totals of this year
        var tDay:     Double = 0
        var tMonth:   Double = 0
        var tYear:    Double = 0
        var tYearC:   Double = 0
        
        // Totals of last year of Existing stores
        var tDayE:   Double = 0
        var tMonthE: Double = 0
        var tYearE:  Double = 0
        var tYearCE: Double = 0
        
        // Calculate the existig stores totals
        for i in 0...maxStores - 1 {
            tDay    += sales[i].today
            tDayE   += sales[i].todayL + 0.001
            tMonth  += sales[i].month
            tMonthE += sales[i].monthL + 0.001
            tYear   += sales[i].year
            tYearE  += sales[i].yearL + 0.001
            tYearC  += sales[i].cYear
            tYearCE += sales[i].cYearL + 0.001
        }
        
        // Format the current year totals
        totalsLBL1A.text = serv.getCurrency(number: tDay, len:31)
        totalsLBL2A.text = serv.getCurrency(number: tMonth, len:31)
        totalsLBL3A.text = serv.getCurrency(number: tYear, len:31)
        totalsLBL4A.text = serv.getCurrency(number: tYearC, len:31)
        
        // Format the last year totals Existing Stores
        totalsLBL1B.text = serv.getCurrency(number: tDayE, len:31)
        totalsLBL2B.text = serv.getCurrency(number: tMonthE, len:31)
        totalsLBL3B.text = serv.getCurrency(number: tYearE, len:31)
        totalsLBL4B.text = serv.getCurrency(number: tYearCE, len:31)

        // Format the precent of last year Existing Store vs this year
        totalsLBL1C.text = serv.getPrecent(number: 100 * tDay / tDayE, isZero: tDayE < 1, len: 30)
        totalsLBL2C.text = serv.getPrecent(number: 100 * tMonth / tMonthE, isZero: tMonthE < 1, len: 30)
        totalsLBL3C.text = serv.getPrecent(number: 100 * tYear / tYearE, isZero: tYearE < 1, len: 30)
        totalsLBL4C.text = serv.getPrecent(number: 100 * tYearC / tYearCE, isZero: tYearCE < 1, len: 30)
        
        // Format the last year totals All Stores
        totalsLBL1D.text = serv.getCurrency(number: tDayA, len:31)
        totalsLBL2D.text = serv.getCurrency(number: tMonthA, len:31)
        totalsLBL3D.text = serv.getCurrency(number: tYearA, len:31)
        totalsLBL4D.text = serv.getCurrency(number: tYearCA, len:31)
       
        // Format the precent of last year All Store vs this year
        totalsLBL1E.text = serv.getPrecent(number: 100 * tDay / tDayA, isZero: tDayA < 1, len: 30)
        totalsLBL2E.text = serv.getPrecent(number: 100 * tMonth / tMonthA, isZero: tMonthA < 1, len: 30)
        totalsLBL3E.text = serv.getPrecent(number: 100 * tYear / tYearA, isZero: tYearA < 1, len: 30)
        totalsLBL4E.text = serv.getPrecent(number: 100 * tYearC / tYearCA, isZero: tYearCA < 1, len: 30)
 
        // Finish up: Sort the data, reload the main table and remove the spinner
        sales = self.sales.sorted(by: { $0.today > $1.today })
        mainTableView.reloadData()
        removeSpinnerS()
    }
    
  
    // =======================================================================================
    //                                       TABLE VIEW
    // =======================================================================================
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StoreSalesCell
        let i = indexPath.row
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
        currencyFormatter.locale = Locale.current
        
        let prcntFormatter = NumberFormatter()
        prcntFormatter.usesGroupingSeparator = true
        prcntFormatter.numberStyle = .percent
        prcntFormatter.maximumFractionDigits = 0
        
        cell.store.text = String(sales[i].storeId!)
        
        cell.today.text = currencyFormatter.string(from: NSNumber(value: sales[i].today))
        cell.todayL.text = currencyFormatter.string(from: NSNumber(value:sales[i].todayL))
        if sales[i].todayL < 1{
            cell.todayP.text = ""
        }else{
            cell.todayP.text = prcntFormatter.string(from: NSNumber(value: sales[i].today / (sales[i].todayL)))
        }
        
        cell.month.text = currencyFormatter.string(from: NSNumber(value: sales[i].month))
        cell.monthL.text = currencyFormatter.string(from: NSNumber(value:sales[i].monthL))
        if sales[i].monthL < 1{
            cell.monthP.text = ""
        }else{
            cell.monthP.text = prcntFormatter.string(from: NSNumber(value: sales[i].month / (sales[i].monthL)))
        }
        
        cell.year.text = currencyFormatter.string(from: NSNumber(value: sales[i].year))
        cell.yearL.text = currencyFormatter.string(from: NSNumber(value:sales[i].yearL))
        if sales[i].yearL < 1{
            cell.yearP.text = ""
        }else{
            cell.yearP.text = prcntFormatter.string(from: NSNumber(value: sales[i].year / (sales[i].yearL)))
        }
        
        cell.cYear.text = currencyFormatter.string(from: NSNumber(value: sales[i].cYear))
        cell.cYearL.text = currencyFormatter.string(from: NSNumber(value:sales[i].cYearL))
        if sales[i].cYearL < 1{
            cell.cYearP.text = ""
        }else{
            cell.cYearP.text = prcntFormatter.string(from: NSNumber(value: sales[i].cYear / (sales[i].cYearL)))
        }
        
        return cell
    }
    
   func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.05)
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return maxStores
    }
          
    func numberOfSections(in tableView: UITableView)->Int{
        return 1
    }
    
    // =======================================================================================
    //                                       GENERAL
    // =======================================================================================
    func getSettingData( key: String)->String{
        let defaults = UserDefaults.standard
                
        if UserDefaults.standard.object(forKey: key) == nil {
            return ""
        }else{
            return defaults.string(forKey: key)!
        }
    }
    
    func getDateRange(sNum: Int, eNum: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
        let startDate = Calendar.current.date(byAdding: .day, value: sNum, to: Date())!
        let sDate = dateFormatter.string(from: startDate)
    
        let endDate = Calendar.current.date(byAdding: .day, value: eNum, to: Date())!
        let eDate = dateFormatter.string(from: endDate)
                
        return "BETWEEN '" + sDate + " 02:00:00' AND '" + eDate + " 02:00:00'"
    }
    
    func getCalendarDateRange(sNum: Int, eNum:Int) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        dateFormatter.dateFormat = "01-01-yyyy"
        let startDate = Calendar.current.date(byAdding: .day, value: sNum, to: Date())!
        let sDate = dateFormatter.string(from: startDate)
        
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let endDate = Calendar.current.date(byAdding: .day, value: eNum, to: Date())!
        let eDate = dateFormatter.string(from: endDate)
                
        let retVal = "BETWEEN '" + sDate + " 2:00:00' AND '" + eDate + " 2:00:00'"
        
        return retVal
    }
    
    func getLastYearToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MM-dd-yyyy"
          
        let startDate = Calendar.current.date(byAdding: .weekOfYear, value: -52, to: Date())!
        let sDate = dateFormatter.string(from: startDate)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        let eDate = dateFormatter.string(from: endDate)
        let retVal = " >= '" + sDate + " 02:00:00' AND saleDate <='" + eDate + " 02:00:00'"
        return retVal
     }
}

