
//
//  CustomTableViewCell.swift
//  c9
//
//  Created by Uzi Benoliel on 5/10/20.
//  Copyright © 2020 Uzi Benoliel. All rights reserved.
//

import UIKit

class GarmentColorCell: UITableViewCell {
     
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var colorName: UILabel!
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
