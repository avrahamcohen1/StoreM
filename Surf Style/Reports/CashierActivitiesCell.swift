import UIKit
class CashierActCell: UITableViewCell{
    @IBOutlet weak var cId:  UILabel!
    @IBOutlet weak var store:  UILabel!
    @IBOutlet weak var cashier:  UILabel!
    @IBOutlet weak var aType: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    func initialize() {
        setBorder(label: cId)
        setBorder(label: store)
        setBorder(label: cashier)
        setBorder(label: aType)
        setBorder(label: amount)
    }
    
    func setBorder(label:UILabel){
        label.layer.borderColor = UIColor.darkGray.cgColor
        label.layer.borderWidth = 0.5
    }
}

class CashierAct{
    var CId: Int?
    var Store: Int?
    var Cashier: String?
    var AType: String?
    var Amount: Int?
    
    init(cId: Int, store:Int, cashier:String, aType:String, amount:Int){
        self.CId = cId
        self.Store = store
        self.Cashier = cashier
        self.AType = aType
        self.Amount = amount
    }
}
