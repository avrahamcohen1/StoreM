import UIKit
class VendorSalesCell: UITableViewCell{
    @IBOutlet weak var itemID:  UILabel!
    @IBOutlet weak var vendorStyle:  UILabel!
    @IBOutlet weak var itemName:  UILabel!
    @IBOutlet weak var itemColors: UILabel!
    @IBOutlet weak var itemSize:  UILabel!
    @IBOutlet weak var itemPrice:  UILabel!
    @IBOutlet weak var itemCost:  UILabel!
    @IBOutlet weak var sales:  UILabel!
    
    func initialize() {
        setBorder(label: itemID)
        setBorder(label: vendorStyle)
        setBorder(label: itemName)
        setBorder(label: itemColors)
        setBorder(label: itemSize)
        setBorder(label: itemPrice)
        setBorder(label: itemCost)
        setBorder(label: sales)
    }
    
    func setBorder(label:UILabel){
        label.layer.borderColor = UIColor.darkGray.cgColor
        label.layer.borderWidth = 0.5
    }
}
