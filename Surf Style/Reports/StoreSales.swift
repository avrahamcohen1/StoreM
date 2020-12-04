import UIKit
import Charts

class StoreSales: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var weekBtn: UIButton!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var quarterBtn: UIButton!
    @IBOutlet weak var yearBtn: UIButton!
    @IBOutlet weak var hourBtn: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var storeSelect: UIPickerView!
    @IBOutlet weak var lineChart: LineChartView!
    
    var serv: Services = Services()
    var group = [String]()
    var sales = [Double]()
    var groupNum: Int = 0
    var storeNames = ["All","421", "1670", "1451", "1441", "1332", "1301", "1208", "1155", "1051", "1041", "1036", "840", "645"]
    var storeSqlFilter: String = ""
    var dateSqlFilter: String = ""
    var selectedDate: Int = 2
    var formatStr: String = ""
    
    //==========================================================================================
    //                                       INIT
    //==========================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
        getSalesInfo()
    }
     
    func initControls(){
        serv.roundContainer(container: mainContainer)
        serv.roundBtn(btn: weekBtn)
        serv.roundBtn(btn: monthBtn)
        serv.roundBtn(btn: quarterBtn)
        serv.roundBtn(btn: yearBtn)
        serv.roundBtn(btn: hourBtn)
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
        weekBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        monthBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        quarterBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        yearBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        hourBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        datePicker.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        if isPicker == true{
            datePicker.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.9568627451, blue: 0.7058823529, alpha: 1)
        }else{
            btn.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.9568627451, blue: 0.7058823529, alpha: 1)
        }
    }
    
    //==========================================================================================
    //                                      GET DATA
    //==========================================================================================
    func getSalesInfo(){
        showSpinnerS(onView: self.view)
        group.removeAll()
        sales.removeAll()
        groupNum = 0
        let ipPort = serv.getSettingData(key:"officeIP") + ":" + serv.getSettingData(key:"officePort")
        let client = SQLClient.sharedInstance()!
        client.disconnect()
        client.connect(ipPort, username: "sa", password: serv.getSettingData(key:"officePass"), database: serv.getSettingData(key:"officeDb")) { success in
            let s1 = "SELECT " + self.formatStr + " AS sDate, SUM(totalSale) AS ttSales FROM allStoresReceiptTbl WHERE " + self.storeSqlFilter
            let s2 = self.dateSqlFilter + " GROUP BY " + self.formatStr + " ORDER BY " + self.formatStr
     
            client.execute(s1 + s2) {results in
                if results != nil{
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            self.group.append("")
                            self.sales.append(0)
                            let i = self.group.count - 1
                            for column in row as! NSDictionary {
                                switch column.key as! String{
                                    case "sDate":
                                        if self.selectedDate == 1{
                                            let h = (column.value as! NSObject) as? Int ?? 0
                                            self.group[i] = String(h) + ":00"
                                            
                                        }else{
                                            let s = (column.value as! NSObject) as? String ?? ""
                                            let start = s.index(s.startIndex, offsetBy: 5)
                                            let end = s.index(s.endIndex, offsetBy: -3)
                                            let range = start..<end
                                            let m = s[range]
                                            let d = s.suffix(2)
                                            let y = s.prefix(4)
                                            let fullD = m + "/" + d + "/" + y
                                            
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "MM/dd/yyyy"
                                            let date = dateFormatter.date(from: fullD)
                                            dateFormatter.dateFormat = "EE"
                                            let weekDay = dateFormatter.string(from:date!)
                                            self.group[i] = weekDay + " " + m + "/" + d
                                        }
                                    case "ttSales":
                                        self.sales[i] = (column.value as! NSObject) as? Double ?? 0
                                    default: let _: Int
                                }
                            }
                            self.groupNum += 1
                        }
                    }
                }
                self.removeSpinnerS()
                self.customizeChart(dataPoints: self.group, numbers: self.sales.map{ Double($0) })
            }
        }
    }
    
    //==========================================================================================
    //                              DATES BUTTONS
    //==========================================================================================
    @IBAction func hourClick(_ sender: Any) {
        setSalesByDate(dSelect: 1, btn: hourBtn, isPicker: false)
    }
    
    @IBAction func weekClick(_ sender: Any) {
        setSalesByDate(dSelect: 2, btn: weekBtn, isPicker: false)
    }
    
    @IBAction func monthClick(_ sender: Any) {
        setSalesByDate(dSelect: 3, btn: monthBtn, isPicker: false)
    }
    
    @IBAction func quarterClick(_ sender: Any) {
        setSalesByDate(dSelect: 4, btn: quarterBtn, isPicker: false)
    }
    
    @IBAction func yearClick(_ sender: Any) {
        setSalesByDate(dSelect: 5, btn: yearBtn, isPicker: false)
    }

    func setSalesByDate(dSelect:Int, btn:UIButton, isPicker: Bool){
        selectedDate = dSelect
        setSqlDateFilter()
        setBtnsColor(btn: btn, isPicker: isPicker)
        getSalesInfo()
    }
    
    func setSqlDateFilter(){
        var sDate: String = ""
        formatStr = "format(saleDate,'yyyy/MM/dd')"
        switch selectedDate {
            case 1:
                sDate = serv.getStrDaysAgo(days:1)
                formatStr = "DATEPART(hh,saleDate)"
            case 2:
                sDate = serv.getStrDaysAgo(days:7)
            case 3:
                sDate = serv.getStrDaysAgo(days:30)
            case 4:
                sDate = serv.getStrDaysAgo(days:90)
            case 5:
                sDate = serv.getStrDaysAgo(days:365)
            case 6:
                sDate = getDatePicker()
            default: let _: Int
        }
        
        let df = DateFormatter()
        df.timeZone = TimeZone(identifier: "UTC")
        df.dateFormat = "yyyy/MM/dd 00:00:00"
        let lDate = df.date(from: sDate) ?? Date()
        datePicker.date = lDate
        
        let yesterday = serv.getStrDaysAgo(days:0)
        dateSqlFilter = "saleDate >='" + sDate + "' AND saleDate < '" + yesterday + "'"
        
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
        dateFormatter.dateFormat =  "yyyy/MM/dd 00:00:00"
        return dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        if selectedDate != 1{
            setSalesByDate(dSelect: 6, btn: yearBtn, isPicker: true)
        }else{
            let yesterday = serv.getStrDaysAgo(days:0)
            dateSqlFilter = "saleDate >='" + getDatePicker() + "' AND saleDate < '" + yesterday + "'"
            getSalesInfo()
        }
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
            storeSqlFilter = "storeName = " + storeNames[row] + " AND "
        }
        getSalesInfo()
    }
       
    //==========================================================================================
    //                                      CHART
    //==========================================================================================
    func customizeChart(dataPoints: [String], numbers: [Double]) {
        let valFormatter = NumberFormatter()
        valFormatter.numberStyle = .currency
        valFormatter.maximumFractionDigits = 0
        valFormatter.currencySymbol = "$"
        lineChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: valFormatter)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.locale = Locale.current
        let valuesNumberFormatter = ChartValueFormatter(numberFormatter: numberFormatter)
        
        var lineCharEntry = [ChartDataEntry]()
        for i in 0..<numbers.count {
            let value = ChartDataEntry(x: Double(i), y: numbers[i])
            lineCharEntry.append(value)
        }
        
        let line1 = LineChartDataSet(entries: lineCharEntry, label: "Number")
        line1.colors = [NSUIColor.blue]
        line1.valueFormatter = valuesNumberFormatter
        line1.valueFont = line1.valueFont.withSize(10.0)
        
        let data = LineChartData()
        data.addDataSet(line1)
        
        lineChart.data = data
      
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        lineChart.rightAxis.enabled = false
            
        lineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChart.legend.enabled = false
        lineChart.extraTopOffset = 10
        lineChart.extraRightOffset = 10
        lineChart.extraLeftOffset = 10
        
        lineChart.leftAxis.labelFont = UIFont.systemFont(ofSize: 13.0, weight: .bold)
        lineChart.leftAxis.labelTextColor = .orange
        lineChart.xAxis.labelFont = UIFont.systemFont(ofSize: 10.0, weight: .bold)
        lineChart.xAxis.labelTextColor = .orange
        lineChart.getAxis(.right).labelFont = UIFont.init(name: "AvenirNext-Heavy", size: 10)!
         
        lineChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
    }
     
        
    override func viewWillAppear(_ animated: Bool) {
        lineChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
}
