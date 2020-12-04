
import UIKit

class InvenCell: UITableViewCell {
     
    @IBOutlet weak var itemId: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var vendorStyle: UILabel!
    @IBOutlet weak var vendorName: UILabel!
    @IBOutlet weak var itemColors: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemCost: UILabel!
    @IBOutlet weak var buyRule: UILabel!
    @IBOutlet weak var qty: UILabel!
    
    func initialize() {
        setBorder(label: itemId)
        setBorder(label: itemName)
        setBorder(label: vendorStyle)
        setBorder(label: itemColors)
        setBorder(label: vendorName)
        setBorder(label: itemPrice)
        setBorder(label: itemCost)
        setBorder(label: buyRule)
        setBorder(label: qty)
    }
    
    func setBorder(label:UILabel){
        label.layer.borderColor = UIColor.darkGray.cgColor
        label.layer.borderWidth = 0.5
    }
    
}

