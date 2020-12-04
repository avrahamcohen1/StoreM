import UIKit

class DecalCell: UICollectionViewCell {
     
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var decalName: UILabel!
    @IBOutlet weak var imageContainer: UIView!
      
    func roundContainer(){
        let cornerRadius : CGFloat = 8.0
        imageContainer.layer.cornerRadius = cornerRadius
        imageContainer.layer.shadowColor = UIColor.darkGray.cgColor
        imageContainer.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        imageContainer.layer.shadowRadius = 8.0
        imageContainer.layer.shadowOpacity = 0.9
    }
}
