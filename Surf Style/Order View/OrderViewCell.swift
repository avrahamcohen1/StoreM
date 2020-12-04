//
//  ViewOrderCell.swift
//  c9
//
//  Created by Uzi Benoliel on 5/12/20.
//  Copyright © 2020 Uzi Benoliel. All rights reserved.
//

import UIKit

class OrderViewCell: UITableViewCell {

    @IBOutlet weak var vendorStyle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var orderInfo: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var userNotes: UILabel!
    @IBOutlet weak var qtyLBL: UILabel!
    @IBOutlet weak var orderStatusLBL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func roundContainer(backColor:UIColor){
        let cornerRadius : CGFloat = 7.0
        imageContainer.layer.cornerRadius = cornerRadius
        imageContainer.layer.shadowColor = UIColor.darkGray.cgColor
        imageContainer.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        imageContainer.layer.shadowRadius = 7.0
        imageContainer.layer.shadowOpacity = 0.9
        imageContainer.backgroundColor =  backColor
    }
    
}
