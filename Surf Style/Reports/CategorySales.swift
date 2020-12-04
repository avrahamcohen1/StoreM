import UIKit
import Charts

class PieChartViewController: UIViewController {    
    @IBOutlet weak var pieChartView: PieChartView!
    var sales = [Double]()
    var group = [String]()
    
    var groupNum: Int = 0
    var serv: Services = Services()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readSqlData()
    }
    
    //==========================================================================================
    //                                      CHART
    //==========================================================================================
    func customizeChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data:  dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }

        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
        
        if serv.isMultiStore() == false{
            pieChartDataSet.drawValuesEnabled = false
        }
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        
        pieChartView.data = pieChartData
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
 
    //==========================================================================================
    //                                      SQL
    //==========================================================================================
    func readSqlData(){
        let client = SQLClient.sharedInstance()!
        let ipPort = serv.getSettingData(key:"officeIP") + ":" + serv.getSettingData(key:"officePort")
        client.disconnect()
        client.connect(ipPort, username: "sa", password: serv.getSettingData(key:"officePass"), database: serv.getSettingData(key:"officeDb")) { success in
            let dStr = self.serv.getStrDaysAgo(days:365)
            let store = self.serv.getSettingData(key:"storeName")
            let s1 = "SELECT TOP 8 Sum(allStoresReceiptItemTBL.qty * allStoresReceiptItemTBL.itemPrice) AS ttSales, groupName FROM (allStoresReceiptItemTBL INNER JOIN itemTBL ON allStoresReceiptItemTBL.itemID = itemTBL.itemID) "
            let s2 = "INNER JOIN itemGroupTBL ON itemTBL.itemGroupID = itemGroupTBL.groupID WHERE saleDate > '" + dStr + "' AND storeName = " + store + " GROUP BY itemGroupTBL.groupName ORDER BY Sum(allStoresReceiptItemTBL.qty * allStoresReceiptItemTBL.itemPrice) DESC"
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
                                        self.sales[i] = (column.value as! NSObject) as? Double ?? 0
                                    case "groupName":
                                        self.group[i] = ((column.value as! NSObject) as? String)!
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
    }
}

