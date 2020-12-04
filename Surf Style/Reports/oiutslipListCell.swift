import UIKit
class outslipListCell: UITableViewCell{
    @IBOutlet weak var OutslipID:  UILabel!
    @IBOutlet weak var OutslipDate:  UILabel!
    @IBOutlet weak var Store:  UILabel!
    @IBOutlet weak var Total: UILabel!
    @IBOutlet weak var OutslipType:  UILabel!
    
    func initialize() {
        setBorder(label: OutslipID)
        setBorder(label: OutslipDate)
        setBorder(label: Store)
        setBorder(label: Total)
        setBorder(label: OutslipType)
    }
    
    func setBorder(label:UILabel){
        label.layer.borderColor = UIColor.darkGray.cgColor
        label.layer.borderWidth = 0.5
    }
}

class Outslips{
    var OutslipID: Int64?
    var OutslipDate: Date?
    var Store: String?
    var Items: Int?
    var Total: Double?
    var OutslipType: String?
    
    init( outslipID:Int64?, outslipDate: Date?, store: String?, total: Double?, outslipType: String?) {
        
        self.OutslipID = outslipID
        self.OutslipDate = outslipDate
        self.Store  = store
        self.Total = total
        self.OutslipType = outslipType
    }
}
