import UIKit

class StyleSalesCell: UITableViewCell {
     
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var vendorStyle: UILabel!
    @IBOutlet weak var vendorName: UILabel!
    @IBOutlet weak var itemColors: UILabel!
    @IBOutlet weak var sales: UILabel!
    
    func initialize() {
        setBorder(label: itemName)
        setBorder(label: vendorStyle)
        setBorder(label: itemColors)
        setBorder(label: vendorName)
        setBorder(label: sales)
    }
    
    func setBorder(label:UILabel){
        label.layer.borderColor = UIColor.darkGray.cgColor
        label.layer.borderWidth = 0.5
    }
    
}

