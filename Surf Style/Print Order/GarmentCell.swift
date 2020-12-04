
//
//  CustomTableViewCell.swift
//  c9
//
//  Created by Uzi Benoliel on 5/10/20.
//  Copyright © 2020 Uzi Benoliel. All rights reserved.
//

import UIKit

class GarmentCell: UICollectionViewCell {
     
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var vendorStyle: UILabel!
    
    func roundContainer(){
          let cornerRadius : CGFloat = 3.0
          imageContainer.layer.cornerRadius = cornerRadius
          imageContainer.layer.shadowColor = UIColor.darkGray.cgColor
          imageContainer.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
          imageContainer.layer.shadowRadius = 3.0
          imageContainer.layer.shadowOpacity = 0.9
      }
}
