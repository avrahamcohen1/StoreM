import UIKit
class GroupItemsCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
  
    @IBOutlet weak var oh: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var vendorStyle: UILabel!
    @IBOutlet weak var itemColors: UILabel!
    @IBOutlet weak var itemID: UILabel!
    
    func roundContainer(){
        let cornerRadius : CGFloat = 8.0
        imageContainer.layer.cornerRadius = cornerRadius
        imageContainer.layer.shadowColor = UIColor.darkGray.cgColor
        imageContainer.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        imageContainer.layer.shadowRadius = 8.0
        imageContainer.layer.shadowOpacity = 0.9
    }
    
}

