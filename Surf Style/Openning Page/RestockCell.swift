//
//  RestockCell.swift
//  Surf Style
//
//  Created by avi on 6/6/20.
//  Copyright © 2020 EDY. All rights reserved.
//

import UIKit

class RestockCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var imageContainer: UIView!
      
    func roundContainer(){
        let cornerRadius : CGFloat = 10.0
        imageContainer.layer.cornerRadius = cornerRadius
        imageContainer.layer.shadowColor = UIColor.darkGray.cgColor
        imageContainer.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        imageContainer.layer.shadowRadius = 10.0
        imageContainer.layer.shadowOpacity = 0.9
    }
}
