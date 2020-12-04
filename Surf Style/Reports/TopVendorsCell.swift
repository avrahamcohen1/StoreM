import UIKit
class TopVendorsCell: UITableViewCell{
    @IBOutlet weak var vNum:  UILabel!
    @IBOutlet weak var vendorName:  UILabel!
    @IBOutlet weak var itemsSold:  UILabel!
    @IBOutlet weak var sales: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var profit:  UILabel!
    @IBOutlet weak var prcnt:  UILabel!
    
    func initialize() {
        setBorder(label: vNum)
        setBorder(label: vendorName)
        setBorder(label: itemsSold)
        setBorder(label: sales)
        setBorder(label: cost)
        setBorder(label: profit)
        setBorder(label: prcnt)
    }
    
    func setBorder(label:UILabel){
        label.layer.borderColor = UIColor.darkGray.cgColor
        label.layer.borderWidth = 0.5
    }
}
