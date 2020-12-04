//
//  GroupCell.swift
//  catalog3
//
//  Created by Uzi Benoliel on 5/20/20.
//  Copyright © 2020 Uzi Benoliel. All rights reserved.
//


import UIKit
class GroupCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var groupName: UILabel!
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
