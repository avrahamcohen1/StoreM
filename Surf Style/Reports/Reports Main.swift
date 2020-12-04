import UIKit
import Charts

class ReportsMain: UIViewController{
    @IBOutlet weak var itemsView: UIView!
    @IBOutlet weak var employeeView: UIView!
    @IBOutlet weak var warehouseView: UIView!
    @IBOutlet weak var storeView: UIView!
    @IBOutlet weak var itemsSales: UIButton!
    @IBOutlet weak var vendorSales: UIButton!
    @IBOutlet weak var StyleSales: UIButton!
    @IBOutlet weak var categorySales: UIButton!
    @IBOutlet weak var commision: UIButton!
    @IBOutlet weak var warehouse: UIButton!
    @IBOutlet weak var sameDayLastBtn: UIButton!
    @IBOutlet weak var cashierActivity: UIButton!
    @IBOutlet weak var topVendor: UIButton!
    @IBOutlet weak var outslipList: UIButton!
    @IBOutlet weak var storeSalesGraph: UIButton!
    @IBOutlet weak var storeSales: UIButton!
    @IBOutlet weak var salesAndProfit: UIButton!
    
    var serv: Services = Services()
    
    override func viewDidLoad() {
           super.viewDidLoad()
           initControls()
    }
      
    func initControls(){
        serv.roundContainer(container: itemsView)
        serv.roundContainer(container: employeeView)
        serv.roundContainer(container: warehouseView)
        serv.roundContainer(container: storeView)
        
        serv.roundBtn(btn: itemsSales)
        serv.roundBtn(btn: vendorSales)
        serv.roundBtn(btn: StyleSales)
        serv.roundBtn(btn: categorySales)
        serv.roundBtn(btn: commision)
        serv.roundBtn(btn: warehouse)
        serv.roundBtn(btn: outslipList)
        serv.roundBtn(btn: storeSales)
        serv.roundBtn(btn: storeSalesGraph)
        serv.roundBtn(btn: sameDayLastBtn)
        serv.roundBtn(btn: cashierActivity)
        serv.roundBtn(btn: topVendor)
        serv.roundBtn(btn: salesAndProfit)
        
        if serv.getSettingData(key:"multiStore") == "1"{
            storeView.isHidden = true
            cashierActivity.isHidden = true
        }else{
            storeView.isHidden = false
            cashierActivity.isHidden = false
        }
 
    }
}
  
