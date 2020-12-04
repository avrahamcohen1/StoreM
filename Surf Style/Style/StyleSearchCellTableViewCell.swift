//
//  StyleSearchCellTableViewCell.swift
//  Surf Style
//
//  Created by avi on 6/1/20.
//  Copyright © 2020 EDY. All rights reserved.
//

import UIKit

class StyleSearchCellTableViewCell: UITableViewCell {

    @IBOutlet weak var vendorStyle: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemColors: UILabel!
    @IBOutlet weak var vendorName: UILabel!
    @IBOutlet weak var qty: UILabel!
    @IBOutlet weak var wareOh: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
 
    }

}
