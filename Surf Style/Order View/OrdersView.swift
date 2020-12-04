//
//  ViewOrders.swift
//  c9
//
//  Created by Uzi Benoliel on 5/12/20.
//  Copyright © 2020 Uzi Benoliel. All rights reserved.
//

import Foundation
import UIKit
import FileProvider

class OrdersView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var viewOrdersTableView: UITableView!
    @IBOutlet weak var openOrdersBtn: UIButton!
    @IBOutlet weak var oldOrderFirstBtn: UIButton!
    @IBOutlet weak var canceledOrdersBtn: UIButton!
    @IBOutlet weak var allOrdersBtn: UIButton!
    @IBOutlet weak var approvedOrdersBtn: UIButton!

    @IBOutlet weak var showAllBtn: UIButton!
    var selectedImgFileName:String = ""
    var selectedItemId:Int64 = 0
    var selectedOrderType:Int = 0
    var baseSqlStr:String = ""
    var viewOldestFirst:Bool = false
    
    var viewOrders = [Orders]()
    var showOrders = [Orders]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initForm()
        readSqlData(sqlStr: baseSqlStr + " ORDER BY storeOrderID DESC")
    }
    
    func initForm(){
        roundBtnCorner(btn: oldOrderFirstBtn)
        roundBtnCorner(btn: openOrdersBtn)
        roundBtnCorner(btn: canceledOrdersBtn)
        roundBtnCorner(btn: allOrdersBtn)
        roundBtnCorner(btn: approvedOrdersBtn)
        viewOldestFirst = true
        
        let monthNum = (getSettingData(key:"viewOrdersMonth") as NSString).integerValue
        let lastMonthDate = getOldDate(intervalDays: monthNum * 30)
        
        baseSqlStr = "SELECT storeOrderId, orderInfo, userNotes, orderStatus, vendorStyle, orderType, itemID, qty, orderDate, fileName FROM storeOrderTBL WHERE storeID =" + getSettingData(key:"storeName")  + " AND orderDate >'" + lastMonthDate + "'"
        allOrdersBtn.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    }
    
    func readSqlData(sqlStr: String){
        let clientW = SQLClient.sharedInstance()!
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) {success in
             
            clientW.execute(sqlStr) {results in
                if results != nil{
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            self.viewOrders.append(Orders(orderId:0, orderDate:nil, orderInfo: "", vendorStyle: "", orderStatus: "", imageFileName: "", itemID: 0, qty: 0, orderType: 0, userNotes:""))
                            let i = self.viewOrders.count - 1
                            for column in row as! NSDictionary {
                                switch column.key as! String{
                                    case "storeOrderId":
                                        self.viewOrders[i].orderId = (column.value as! NSObject) as? Int64 ?? 0
                                    case "itemID":
                                        self.viewOrders[i].itemID = (column.value as! NSObject) as? Int64 ?? 0
                                        self.viewOrders[i].vendorStyle = "Item ID:" + String(self.viewOrders[i].itemID!)
                                    case "qty":
                                        self.viewOrders[i].qty! = (column.value as! NSObject) as? Int ?? 0
                                    case "orderType":
                                        self.viewOrders[i].orderType = (column.value as! NSObject) as? Int ?? 0
                                    case "orderInfo":
                                        self.viewOrders[i].orderInfo = (column.value as! NSObject) as? String
                                    case "userNotes":
                                        self.viewOrders[i].userNotes = ((column.value as! NSObject) as? String)!
                                    case "vendorStyle":
                                        self.viewOrders[i].vendorStyle = (column.value as! NSObject) as? String
                                    case "orderStatus":
                                        self.viewOrders[i].orderStatus = (column.value as! NSObject) as? String
                                    case "fileName":
                                        self.viewOrders[i].imageFileName = (column.value as! NSObject) as? String
                                    case "orderDate":
                                        self.viewOrders[i].orderDate = (column.value as! NSObject) as? Date
                                    
                                    default:
                                        let _: Int
                                }
                            }
                        }
                    }
                }
                self.showOrders = self.viewOrders.sorted( by: { $0.orderId > $1.orderId})
               	self.viewOrdersTableView.reloadData()
                self.allOrdersBtn.setTitle("Show all " + String(self.showOrders.count) + " orders", for: .normal)
            }
        }
    }
    
    //==================================================================
    //                      Table
    //==================================================================
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = viewOrdersTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderViewCell
        let order: Orders
        var fileURL: URL
        var fileName:String
        order = showOrders[indexPath.row]
        
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            if order.orderType == 3 {
               fileName = "Catalog/smallPic/" + String(order.itemID!) + ".jpg"
               
            }else{
               fileName = order.imageFileName!
            }
            fileURL = documentsUrl.appendingPathComponent(fileName)
            let df = DateFormatter()
            df.timeZone = TimeZone(identifier: "UTC")
            df.dateFormat = "MM-dd-yyyy h:mm a"
            cell.orderDate.text = df.string(from:order.orderDate!)
           
            cell.orderInfo.text = order.orderInfo
            cell.qtyLBL.text = "QTY:" + String(order.qty!)
            cell.vendorStyle.text = order.vendorStyle
            cell.userNotes.text = order.userNotes
            cell.orderStatusLBL.text = order.orderStatus
            do{
                let imageData = try Data(contentsOf: fileURL)
                cell.imgView.image =  UIImage(data: imageData)
            }catch{}
                
            let cl:UIColor
            switch order.orderStatus{
                case "Order Placed" :
                    cl = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                case "Declined" :
                    cl = #colorLiteral(red: 1, green: 0.4862745098, blue: 0.4862745098, alpha: 1)
                case  "Warehouse Approved":
                    cl = #colorLiteral(red: 0.5176470588, green: 0.9568627451, blue: 0.7058823529, alpha: 1)
                default:
                    cl = UIColor.white
            }
            cell.roundContainer(backColor: cl)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return showOrders.count
    }
    
    func numberOfSections(in tableView: UITableView)->Int{
         return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let i = indexPath.row
        selectedItemId = showOrders[i].itemID!
        selectedOrderType = showOrders[i].orderType!
        if selectedOrderType == 1{
            selectedImgFileName = showOrders[i].imageFileName!
        }
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)

        performSegue(withIdentifier: "viewLargeImgSegue", sender: cell)
        
    }
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let vc = segue.destination as? ViewLargeImg
        vc?.selectedItemId = selectedItemId
        vc?.orderType = selectedOrderType
        vc?.imgLocalFileName = selectedImgFileName
    }
    
    //==================================================================
    //                      General
    //==================================================================
    func getSettingData( key: String)->String{
        let defaults = UserDefaults.standard
        if UserDefaults.standard.object(forKey: key) == nil {
            return ""
        }else{
            return defaults.string(forKey: key)!
        }
    }
    
    func returnHomePage(){
           if let nav = self.navigationController {
               nav.popViewController(animated: true)
           } else {
               self.dismiss(animated: true, completion: nil)
           }
    }
    
    func roundBtnCorner(btn:UIButton){
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.blue.cgColor
        btn.layer.cornerRadius = 5
    }
    
    func getOldDate(intervalDays: Int)->String{
        var dayComponent    = DateComponents()
        dayComponent.day    = -intervalDays
        let theCalendar     = Calendar.current
        let requstedDate    = theCalendar.date(byAdding: dayComponent, to: Date())!
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        let retVal = df.string(from:requstedDate)
        return retVal
    }
    
    //==================================================================
    //                      SORT AND FILTER
    //==================================================================
    @IBAction func sortOrderClicked(_ sender: Any) {
        if viewOldestFirst == true {
           viewOldestFirst = false
           showOrders = viewOrders.sorted( by: { $0.orderId < $1.orderId})
           viewOrdersTableView.reloadData()
            
        }else{
           viewOldestFirst = true
           showOrders = viewOrders.sorted( by: { $0.orderId > $1.orderId})
           viewOrdersTableView.reloadData()
        }
    }
    
    @IBAction func openOrdersClicked(_ sender: Any) {
        clearBtnsColor()
        openOrdersBtn.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        showOrders = viewOrders.filter { order in
            return order.orderStatus == "Order Placed"
        }
        viewOrdersTableView.reloadData()
    }
    
    @IBAction func approvedOrdersClicked(_ sender: Any) {
        clearBtnsColor()
        approvedOrdersBtn.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.9568627451, blue: 0.7058823529, alpha: 1)
        showOrders = viewOrders.filter { order in
            return order.orderStatus == "Warehouse Approved"
        }
        viewOrdersTableView.reloadData()
    }
    
    @IBAction func cancledClicked(_ sender: Any) {
        clearBtnsColor()
        canceledOrdersBtn.backgroundColor = #colorLiteral(red: 1, green: 0.4862745098, blue: 0.4862745098, alpha: 1)
        showOrders = viewOrders.filter { order in
            return order.orderStatus == "Declined"
        }
        viewOrdersTableView.reloadData()
    }
    
    @IBAction func allOrdersClicked(_ sender: Any) {
        clearBtnsColor()
        allOrdersBtn.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        showOrders = viewOrders
        viewOrdersTableView.reloadData()
    }
    
    func clearBtnsColor(){
        openOrdersBtn.backgroundColor = UIColor.white
        canceledOrdersBtn.backgroundColor = UIColor.white
        allOrdersBtn.backgroundColor = UIColor.white
        approvedOrdersBtn.backgroundColor = UIColor.white
    }
    
}


