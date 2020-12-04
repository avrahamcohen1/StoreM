
import UIKit
import Charts

class LastYear: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    @IBOutlet weak var storeSelect: UIPickerView!
    @IBOutlet weak var lineChart: LineChartView!
    
    var serv: Services = Services()
    var x1 = [String]()
    var x2 = [String]()
    var y1 = [Double]()
    var y2 = [Double]()
    var storeNames = ["All","421", "1670", "1451", "1441", "1332", "1301", "1208", "1155", "1051", "1041", "1036", "840", "645"]
    var storeSqlFilter: String = ""
    var dateSqlFilter: String = ""
    
    //==========================================================================================
    //                                       INIT
    //==========================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
        getAllSalesData()
    }
     
    func initControls(){
        if serv.getSettingData(key:"multiStore") == "1"{
            storeSelect.isHidden = true
            storeSqlFilter = "storeName = " + self.serv.getStoreName() + " AND "
        }else{
            storeSelect.isHidden = false
            storeSqlFilter = ""
        }
    }
    
    //==========================================================================================
    //                                      GET DATA
    //==========================================================================================
    func getAllSalesData(){
        var i:Int = 0
        
        x1.removeAll()
        y1.removeAll()
        x2.removeAll()
        y2.removeAll()
        
        let ipPort = serv.getSettingData(key:"officeIP") + ":" + serv.getSettingData(key:"officePort")
        let client = SQLClient.sharedInstance()!
        client.disconnect()
        client.connect(ipPort, username: "sa", password: serv.getSettingData(key:"officePass"), database: serv.getSettingData(key:"officeDb")) { success in
            self.setSqlDateFilter(offset:0)
            
            let s1 = "SELECT YEAR(saleDate) [Year], MONTH(saleDate) [Month], DATENAME(MONTH,saleDate) [Month Name],  SUM(totalSale) AS ttSales FROM allStoresReceiptTbl WHERE " + self.storeSqlFilter
            let s2 = " GROUP BY YEAR(saleDate), MONTH(saleDate), DATENAME(MONTH, saleDate) ORDER BY 1,2"
            
            client.execute(s1 + self.dateSqlFilter + s2) {results in
                if results != nil{
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            self.x1.append("")
                            self.y1.append(0)
                            i = self.x1.count - 1
                            for column in row as! NSDictionary {
                                switch column.key as! String{
                                    case "Month Name":
                                         self.x1[i] = (column.value as! NSObject) as? String ?? ""
                                    case "ttSales":
                                        self.y1[i] = (column.value as! NSObject) as? Double ?? 0
                                    default: let _: Int
                                }
                            }
                        }
                    }
                }
                
                self.setSqlDateFilter(offset:365)
                client.execute(s1 + self.dateSqlFilter + s2) {results in
                    if results != nil{
                        for table in results! as NSArray {
                            for row in table as! NSArray {
                                self.x2.append("")
                                self.y2.append(0)
                                i = self.x2.count - 1
                                for column in row as! NSDictionary {
                                    switch column.key as! String{
                                        case "sDate":
                                            self.x2[i] = (column.value as! NSObject) as? String ?? ""
                                        case "ttSales":
                                            self.y2[i] = (column.value as! NSObject) as? Double ?? 0
                                        default: let _: Int
                                    }
                                }
                            }
                        }
                    }
                    self.customizeChart()
                }
            }
        }
    }

    func setSqlDateFilter(offset:Int){
        let sDate = serv.getStrDaysAgo(days:365 + offset)
        let eDate = serv.getStrDaysAgo(days:1 + offset)
        dateSqlFilter = "saleDate >='" + sDate + "' AND saleDate <= '" + eDate + "'"
    }
       
    //==========================================================================================
    //                                      CHART
    //==========================================================================================
    func customizeChart() {
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
        
        //  ========= LINE 1 =========
        var lineChartEntry1 = [ChartDataEntry]()

        for i in 0..<x1.count {
            lineChartEntry1.append(ChartDataEntry(x: Double(i), y: y1[i]))
        }
        let line1 = LineChartDataSet(entries: lineChartEntry1, label: "This Year   ")
        line1.colors = [NSUIColor.blue]
        line1.valueFont = UIFont(name: "Verdana", size: 10.0)!
        line1.valueFormatter = valuesNumberFormatter
        line1.valueFont = line1.valueFont.withSize(10.0)
        
        //  ========= LINE 2 =========
        var lineChartEntry2 = [ChartDataEntry]()
        for i in 0..<x2.count {
            lineChartEntry2.append(ChartDataEntry(x: Double(i), y: y2[i]))
        }
        let line2 = LineChartDataSet(entries: lineChartEntry2, label: "   Last Year  ")
        line2.colors = [NSUIColor.green]
        line2.valueFont = UIFont(name: "Verdana", size: 10.0)!
       
        line2.valueFormatter = valuesNumberFormatter
        line2.valueFont = line1.valueFont.withSize(10.0)
        
        let lineChartData = LineChartData(dataSets: [line1, line2])
       
        lineChart.data = lineChartData
             
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:x1)
        lineChart.rightAxis.enabled = false
            
        lineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
         
        lineChart.legend.font = UIFont(name: "Verdana", size: 12.0)!
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
    
    //  ============================================================================
    //                                 PICKER
    //  ============================================================================
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
            storeSqlFilter = "storeName = " + storeNames[row] + " AND "
        }
        getAllSalesData()
    }
}

class ChartValueFormatter: NSObject, IValueFormatter {
    fileprivate var numberFormatter: NumberFormatter?

    convenience init(numberFormatter: NumberFormatter) {
        self.init()
        self.numberFormatter = numberFormatter
    }

    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        guard let numberFormatter = numberFormatter
            else {
                return ""
        }
        return numberFormatter.string(for: value)!
    }
}
