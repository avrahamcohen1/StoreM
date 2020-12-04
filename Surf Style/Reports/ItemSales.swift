import UIKit
import Charts

class ItemSales: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, ScanDelegate{
  
    @IBOutlet weak var salesContainer: UIView!
    @IBOutlet weak var itemContainer: UIView!
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var itemSearchTxt: UITextField!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var style: UILabel!
    @IBOutlet weak var colors: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var promo: UILabel!
    @IBOutlet weak var oh: UILabel!
    @IBOutlet weak var vendorName: UILabel!
    @IBOutlet weak var weekSales: UILabel!
    @IBOutlet weak var monthSales: UILabel!
    @IBOutlet weak var quarterSales: UILabel!
    @IBOutlet weak var yearSales: UILabel!
    
    @IBOutlet weak var imgContainer: UIView!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var storeSelect: UIPickerView!
    
    var clientO = SQLClient.sharedInstance()!
    var serv: Services = Services()
    var group = [String]()
    var sales = [Int]()
    var groupNum: Int = 0
    var storeNames = ["All","421", "1670", "1451", "1441", "1332", "1301", "1208", "1155", "1051", "1041", "1036", "840", "645"]
    var storeFilter: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
    }
   
    func initControls(){
        itemSearchTxt.delegate = self
        serv.roundContainer(container: salesContainer)
        serv.roundContainer(container: itemContainer)
        serv.roundContainer(container: imgContainer)
        serv.roundBtn(btn: scanBtn)
        if serv.getSettingData(key:"multiStore") == "1"{
            storeSelect.isHidden = true
            storeFilter = "storeName = " + self.serv.getStoreName() + " AND "
        }else{
            storeSelect.isHidden = false
            storeFilter = ""
        }
    }
    
    @IBAction func searchItemClicked(_ sender: Any) {
        getItemInfo()
    }
    
    //==========================================================================================
    //                            GET ITEM INFO
    //==========================================================================================
    func getItemInfo(){
        let ipPort = serv.getSettingData(key:"localIP") + ":" + serv.getSettingData(key:"localPort")
        let client = SQLClient.sharedInstance()!
        client.disconnect()
        client.connect(ipPort, username: "sa", password: serv.getSettingData(key:"localPass"), database: serv.getSettingData(key:"localDb")) { success in
            let idFilter = "WHERE itemID =" + self.itemSearchTxt.text!
            let s1 = "SELECT itemName, vendorStyle, itemColors, itemPrice, itemCost, qty, vendorName, [rule name] as buyRule FROM itemTBL "
            let s2 = "LEFT JOIN vendorTBL ON vendorTBL.vendorId = itemTBL.vendorId LEFT JOIN buyForTBL ON buyForTBL.[rule ID] = itemTBL.buyForID " + idFilter
              
            client.execute(s1 + s2) {results in
                if results != nil{
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            for column in row as! NSDictionary {
                                switch column.key as! String{
                                    case "itemName":
                                        self.itemName.text = (column.value as! NSObject) as? String
                                    case "vendorStyle":
                                        self.style.text = (column.value as! NSObject) as? String
                                    case "itemColors":
                                        self.colors.text = (column.value as! NSObject) as? String
                                    case "vendorName":
                                        self.vendorName.text = (column.value as! NSObject) as? String
                                    case "itemPrice":
                                        self.price.text = "$" + String((column.value as! NSObject) as? Double ?? 0.0)
                                    case "itemCost":
                                        self.cost.text = "$" + String((column.value as! NSObject) as? Double ?? 0.0)
                                    case "qty":
                                        self.oh.text = String((column.value as! NSObject) as? Int ?? 0)
                                    case "buyRule":
                                        self.promo.text = (column.value as! NSObject) as? String
                                       
                                    default: let _: Int
                                }
                            }
                        }
                    }
                    self.getSalesData()
                    self.serv.downloadImg(itemID: self.itemSearchTxt.text!, imgV: self.imgView)
                }
            }
        }
    }
    
    //==========================================================================================
    //                            GET SALES DATA
    //==========================================================================================
    func getSalesData(){
        let ipPort = serv.getSettingData(key:"officeIP") + ":" + serv.getSettingData(key:"officePort")
        clientO.disconnect()
        clientO.connect(ipPort, username: "sa", password: serv.getSettingData(key:"officePass"), database: serv.getSettingData(key:"officeDb")) { success in
            self.executeSql(days:7,   label: self.weekSales)
            self.executeSql(days:30,  label: self.monthSales)
            self.executeSql(days:90,  label: self.quarterSales)
            self.executeSql(days:365, label: self.yearSales)
            self.getChartSqlData()
        }
    }
    
    func executeSql(days:Int, label: UILabel){
        let dateFilter = "saleDate >='" + serv.getStrDaysAgo(days:days) + "' AND "
        let idFilter = "itemID =" + itemSearchTxt.text!
        let sqlStr = "SELECT Sum(qty) AS ttQty FROM allStoresReceiptItemTBL WHERE " + dateFilter + storeFilter + idFilter
        clientO.execute(sqlStr) {results in
            if results != nil{
                for table in results! as NSArray {
                    for row in table as! NSArray {
                        for column in row as! NSDictionary {
                            label.text = String((column.value as! NSObject) as? Int ?? 0)
                        }
                    }
                }
            }
        }
    }
    
    //==========================================================================================
    //                                  GET CHART DATA
    //==========================================================================================
    func getChartSqlData(){
        let dateFilter = "saleDate >= '" + self.serv.getStrDaysAgo(days:365) + "' AND "
        let idFilter = "itemID = " + self.itemSearchTxt.text!
        let s1 = "SELECT format(saleDate,'yyyy.MM') AS sDate, SUM(qty) AS ttQty FROM allStoresReceiptItemTBL WHERE " + dateFilter + storeFilter + idFilter
        let s2 = "GROUP BY format(saleDate,'yyyy.MM') ORDER BY format(saleDate,'yyyy.MM')"
        clientO.execute(s1 + s2) { results in
            if results != nil{
                for table in results! as NSArray {
                    for row in table as! NSArray {
                        self.group.append("")
                        self.sales.append(0)
                        let i = self.group.count - 1
                        for column in row as! NSDictionary {
                            switch column.key as! String{
                                case "ttQty":
                                    self.sales[i] = (column.value as! NSObject) as? Int ?? 0
                                case "sDate":
                                    let s = (column.value as! NSObject) as? String ?? ""
                                    self.group[i] = s.suffix(2) + " " + s.prefix(4)
                                default: let _: Int
                            }
                        }
                        self.groupNum += 1
                    }
                }
                self.customizeChart(dataPoints: self.group, values: self.sales.map{ Double($0) })
            }
        }
    }
        
    //==========================================================================================
    //                                      CHART
    //==========================================================================================
    func customizeChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Bar Chart View")
        let chartData = BarChartData(dataSet: chartDataSet)
        
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        barChartView.leftAxis.enabled = false
        barChartView.rightAxis.enabled = false
         
        barChartView.xAxis.gridColor = .clear
        barChartView.leftAxis.gridColor = .clear
        barChartView.rightAxis.gridColor = .clear
        
        barChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        barChartView.legend.enabled = false
        barChartView.data = chartData
    }
       
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        var colors: [UIColor] = []
        for _ in 0..<numbersOfColor {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        return colors
    }
    
    override func viewWillAppear(_ animated: Bool) {
        barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
    
    //  ============================================================================
    //                                 PICKERS
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
            storeFilter = ""
        }else{
            storeFilter = "storeName = " + storeNames[row] + " AND "
        }
        getItemInfo()
    }
    
    //  ============================================================================
    //                                 SCAN
    //  ============================================================================
    func onScannComplete(scannedItemID:String){
        itemSearchTxt.text = scannedItemID
         getItemInfo()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemSalesScanSegue" {
            let vc : Scanner = segue.destination as! Scanner
            vc.delegate = self
        }
    }
}

extension ItemSales: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
