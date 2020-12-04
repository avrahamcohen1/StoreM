
import UIKit
import Charts

class StyleSales: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate{
   

    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var styleContainer: UIView!
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var styleSearchTxt: UITextField!
    @IBOutlet weak var itemName: UILabel!
   
    @IBOutlet weak var weekBtn: UIButton!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var quarterBtn: UIButton!
    @IBOutlet weak var yearBtn: UIButton!
        
    @IBOutlet weak var styleTable: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var totalLBL: UILabel!
    @IBOutlet weak var linesNum: UILabel!
       
    @IBOutlet weak var storeSelect: UIPickerView!
    
    
    var storeNames = ["ALL", "421", "1670", "1451", "1441", "1332", "1301", "1208", "1155", "1051", "1041", "1036", "840", "645"]

    var serv: Services = Services()
    var group = [String]()
    var sales = [Int]()
    var groupNum: Int = 0
    
    var items = [ItemInvn]()
    var itemsNum: Int = 0
    var selectedItemID: Int64 = 0
    var selectedDate: Int = 4
    var styleFilter: String = ""
    var storeFilter: String = ""
    var sortName: Bool = false
    var sortStyle: Bool = false
    var sortColors: Bool = false
    var sortVendorName: Bool = false
    var sortSales: Bool = false

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
    }
   
    func initControls(){
        styleSearchTxt.delegate = self
        serv.roundContainer(container: styleContainer)
        serv.roundContainer(container: tableContainer)
        serv.roundBtn(btn: weekBtn)
        serv.roundBtn(btn: monthBtn)
        serv.roundBtn(btn: quarterBtn)
        serv.roundBtn(btn: yearBtn)
        seBtnsColor(btn:yearBtn, isPicker: false)
        initDatePickerLimits()
        if serv.getSettingData(key:"multiStore") == "1"{
            storeSelect.isHidden = true
            storeFilter = "storeName = " + self.serv.getStoreName() + " AND "
        }else{
            storeSelect.isHidden = false
            storeFilter = ""
        }
    }
    
    func seBtnsColor(btn:UIButton, isPicker: Bool){
        weekBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        monthBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        quarterBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        yearBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        datePicker.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        if isPicker == true{
            datePicker.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.9568627451, blue: 0.7058823529, alpha: 1)
        }else{
            btn.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.9568627451, blue: 0.7058823529, alpha: 1)
        }
    }
    
    @IBAction func searchStyleClicked(_ sender: Any) {
        if styleSearchTxt.text != nil && styleSearchTxt.text != ""{
            styleFilter = "UPPER(vendorStyle) = '" + styleSearchTxt.text!.uppercased() + "'"
            readSqlStyles()
        }
    }
    
    //==========================================================================================
    //                            GET STYLES
    //==========================================================================================
    func readSqlStyles(){
        showSpinnerS(onView: self.view)
        items.removeAll()
        itemsNum = 0
        var total: Int = 0
        let ipPort = serv.getSettingData(key:"officeIP") + ":" + serv.getSettingData(key:"officePort")
        let client = SQLClient.sharedInstance()!
        client.disconnect()
        client.connect(ipPort, username: "sa", password: serv.getSettingData(key:"officePass"), database: serv.getSettingData(key:"officeDb")) { success in
            let dateFilter = self.getDateFilter()
            let s1 = "SELECT itemName, vendorStyle, itemColor, SUM(qty) as ttQty, vendorName FROM allStoresReceiptItemTbl WHERE " + self.storeFilter
            let s2 = self.styleFilter + " AND " + dateFilter + " GROUP BY itemName, vendorStyle, itemColor, vendorName ORDER BY itemColor"
            client.execute(s1 + s2) {results in
                if results != nil{
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            self.items.append(ItemInvn(itemID: 0, itemName: "", vendorStyle: "", itemColors: "", vendorName: "", itemPrice: 0, itemCost: 0, buyRule: "", qty:0, sales:0, itemSize: ""))
                            let i = self.items.count - 1
                            for column in row as! NSDictionary {
                                switch column.key as! String{
                                    case "itemName":
                                        self.items[i].itemName = (column.value as! NSObject) as? String
                                    case "vendorStyle":
                                        self.items[i].vendorStyle = (column.value as! NSObject) as? String
                                    case "itemColor":
                                        self.items[i].itemColors = (column.value as! NSObject) as? String
                                    case "ttQty":
                                        let sales = (column.value as! NSObject) as? Int ?? 0
                                        total += sales
                                        self.items[i].sales = sales
                                    case "vendorName":
                                        self.items[i].vendorName = (column.value as! NSObject) as? String
                                    default: let _: Int
                                }
                            }
                            self.itemsNum += 1
                        }
                    }
                }
                self.styleTable.reloadData()
                self.totalLBL.text =  String(total)
                self.linesNum.text = String(self.itemsNum) + " Colors"
                self.getChartSqlData()
                self.removeSpinnerS()
            }
        }
    }
    
    // =======================================================================================
    //                             TABLE VIEW
    // =======================================================================================
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "styleCell", for: indexPath) as! StyleSalesCell
           if items.count > 0{
               let item: ItemInvn
               item = items[indexPath.row]
               cell.itemName.text =  item.itemName!
               cell.vendorStyle.text = item.vendorStyle
               cell.itemColors.text = item.itemColors
               cell.vendorName.text = item.vendorName
               cell.sales.text = String(item.sales!)
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
       
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        styleTable.deselectRow(at: indexPath, animated: true)
    }
       
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "invnToItemSearch") {
            let vc = segue.destination as? ItemSearch
            let idx = styleTable.indexPathForSelectedRow?.row
            vc!.selectedItemID = items[idx!].itemID!
        }
    }
       
    //==========================================================================================
    //                              DATES BUTTONS
    //==========================================================================================
    @IBAction func weekClick(_ sender: Any) {
        setSalesByDate(dSelect: 1, btn: weekBtn, isPicker: false)
    }
    
    @IBAction func monthClick(_ sender: Any) {
        setSalesByDate(dSelect: 2, btn: monthBtn, isPicker: false)
    }
    
    @IBAction func quarterClick(_ sender: Any) {
        setSalesByDate(dSelect: 3, btn: quarterBtn, isPicker: false)
    }
    
    @IBAction func yearClick(_ sender: Any) {
        setSalesByDate(dSelect: 4, btn: yearBtn, isPicker: false)
    }
    
    func setSalesByDate(dSelect:Int, btn:UIButton, isPicker: Bool){
        selectedDate = dSelect
        seBtnsColor(btn: btn, isPicker: isPicker)
        readSqlStyles()
    }
    
    func getDateFilter()->String{
        var saleDate: String = ""
        
        switch selectedDate {
            case 1:
                saleDate = serv.getStrDaysAgo(days:7)
            case 2:
                saleDate = serv.getStrDaysAgo(days:30)
            case 3:
                saleDate = serv.getStrDaysAgo(days:90)
            case 4:
                saleDate = serv.getStrDaysAgo(days:365)
            case 5:
                saleDate = getDatePicker()
            default: let _: Int
        }
        return("saleDate >='" + saleDate + "'")
    }
    //==========================================================================================
    //                                  GET CHART DATA
    //==========================================================================================
    func getChartSqlData(){
        group.removeAll()
        sales.removeAll()
        groupNum = 0
        let ipPort = serv.getSettingData(key:"officeIP") + ":" + serv.getSettingData(key:"officePort")
        let client = SQLClient.sharedInstance()!
        client.disconnect()
        client.connect(ipPort, username: "sa", password: serv.getSettingData(key:"officePass"), database: serv.getSettingData(key:"officeDb")) { success in
            let dateS = self.serv.getStrDaysAgo(days:365)
            let s1 = "SELECT format(saleDate,'yyyy.MM') AS sDate, SUM(qty) AS ttSales FROM allStoresReceiptItemTbl WHERE " + self.storeFilter
            let s2 = self.styleFilter + " AND saleDate > '" + dateS + "' GROUP BY format(saleDate,'yyyy.MM') ORDER BY format(saleDate,'yyyy.MM')"
            client.execute(s1 + s2) {results in
                if results != nil{
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            self.group.append("")
                            self.sales.append(0)
                            let i = self.group.count - 1
                            for column in row as! NSDictionary {
                                switch column.key as! String{
                                    case "ttSales":
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
        
        barChartView.leftAxis.valueFormatter = YAxisValueFormatter()
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
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let numFormatter: NumberFormatter
        numFormatter = NumberFormatter()
        numFormatter.minimumFractionDigits = 1
        numFormatter.maximumFractionDigits = 1
        return numFormatter.string(from: NSNumber(floatLiteral: value))!
    }
    
    //  ============================================================================
    //                                 PICKERS
    //  ============================================================================
    //==================== DATE ====================
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
      setSalesByDate(dSelect: 5, btn: yearBtn, isPicker: true)
    }
    
    
    //==================== STORE ====================
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
        readSqlStyles()
    }
    
    //==========================================================================================
    //                                      SORT
    //==========================================================================================
    @IBAction func nameClicked(_ sender: Any) {
        if sortName == true {
            sortName = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemName ?? "") < (project2.itemName ?? "")
            })
        }else{
            sortName = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemName ?? "") > (project2.itemName ?? "")
            })
        }
        styleTable.reloadData()
    }
       
    @IBAction func styleClicked(_ sender: Any) {
        if sortStyle == true {
            sortStyle = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.vendorStyle ?? "") < (project2.vendorStyle ?? "")
            })
        }else{
            sortStyle = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.vendorStyle ?? "") > (project2.vendorStyle ?? "")
            })
        }
        styleTable.reloadData()
    }
     
    @IBAction func colorsClicked(_ sender: Any) {
        if sortColors == true {
            sortColors = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemColors ?? "") < (project2.itemColors ?? "")
            })
        }else{
            sortColors = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.itemColors ?? "") > (project2.itemColors ?? "")
            })
        }
        styleTable.reloadData()
    }

    @IBAction func vendorNameClicked(_ sender: Any) {
        if sortVendorName == true {
            sortVendorName = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.vendorName ?? "") < (project2.vendorName ?? "")
            })
        }else{
            sortVendorName = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.vendorName ?? "") > (project2.vendorName ?? "")
            })
        }
        styleTable.reloadData()
    }
       
    @IBAction func salesClicked(_ sender: Any) {
        if sortSales == true {
            sortSales = false
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.sales ?? 0) < (project2.sales ?? 0)
            })
        }else{
            sortSales = true
            items.sort(by: { (project1, project2) -> Bool in
                return (project1.sales ?? 0) > (project2.sales ?? 0)
            })
        }
        styleTable.reloadData()
    }
}

extension StyleSales: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}




class YAxisValueFormatter: NSObject, IAxisValueFormatter {

    let numFormatter: NumberFormatter

    override init() {
        numFormatter = NumberFormatter()
        numFormatter.minimumFractionDigits = 1
        numFormatter.maximumFractionDigits = 1

        // if number is less than 1 add 0 before decimal
        numFormatter.minimumIntegerDigits = 1 // how many digits do want before decimal
        numFormatter.paddingPosition = .beforePrefix
        numFormatter.paddingCharacter = "0"
    }

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return numFormatter.string(from: NSNumber(floatLiteral: value))!
    }
}
