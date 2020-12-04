import UIKit
class CommisionCell: UITableViewCell{
    @IBOutlet weak var cId:  UILabel!
    @IBOutlet weak var cDate:  UILabel!
    @IBOutlet weak var employee:  UILabel!
    @IBOutlet weak var sale: UILabel!
    @IBOutlet weak var commisionVal: UILabel!
    @IBOutlet weak var receiptNum: UILabel!
    
   
    
    func initialize() {
        setBorder(label: cId)
        setBorder(label: cDate)
        setBorder(label: employee)
        setBorder(label: sale)
        setBorder(label: commisionVal)
        setBorder(label: receiptNum)
        
    }
    
    func setBorder(label:UILabel){
        label.layer.borderColor = UIColor.darkGray.cgColor
        label.layer.borderWidth = 0.5
    }
}
class CommisionRec{
    var CId: Int?
    var CDate: Date?
    var Employee: String?
    var Sale: Double?
    var CommisionVal: Double?
    var ReceiptNum: Double?
    
    init(cId: Int, cDate:Date, employee:String, sale:Double, commisionVal:Double, receiptNum:Double){
        self.CId = cId
        self.CDate = cDate
        self.Employee = employee
        self.Sale = sale
        self.CommisionVal = commisionVal
        self.ReceiptNum = receiptNum
    }
}
