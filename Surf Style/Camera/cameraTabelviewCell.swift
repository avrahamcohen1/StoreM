//
//  CustomTableViewCell.swift
//  c9
//
//  Created by Uzi Benoliel on 5/10/20.
//  Copyright © 2020 Uzi Benoliel. All rights reserved.
//

import UIKit

class CameraTableviewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var colorPicker: UIPickerView!
    @IBOutlet weak var sizePicker: UIPickerView!
    @IBOutlet weak var qtyPicker: UIPickerView!
    
    let colorData = ["","Black","White","Red","Green","Blue","Orange","Pink","Purple","Turquoise","Grey","Charcoal","Navy","L Blue","Mint","Coral"]
    let sizeData = ["","XS","S","M","L","XL","2XL","7","8","9","10","11","12","13","1T","2T","3T"]
    let qtyData = ["","1","2","3","4","5","6","7","8","9","10","12","16","18","20","24","36","48","50","60","80","90","100","120","150","200"]
     
    
  

    func initialize() {
        qtyPicker.selectRow(11, inComponent: 0, animated: true)
       }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func numberOfComponentsInPickerView( piclerVierw: UIPickerView)->Int{
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) ->Int{
        switch pickerView{
            case colorPicker:
                return colorData.count
            case sizePicker:
                return sizeData.count
            case qtyPicker:
                return qtyData.count
            default:
                return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)->String?{
        switch pickerView{
            case colorPicker:
                return colorData[row]
            case sizePicker:
                return sizeData[row]
            case qtyPicker:
                return qtyData[row]
            default:
                return ""
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        colorPicker.dataSource = self
        colorPicker.delegate = self
        sizePicker.dataSource = self
        sizePicker.delegate = self
        qtyPicker.dataSource = self
        qtyPicker.delegate = self
    }
   
}
