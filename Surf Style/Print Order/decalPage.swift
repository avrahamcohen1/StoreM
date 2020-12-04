//
//  decalPage.swift
//  Surf Style
//
//  Created by avi on 7/23/20.
//  Copyright © 2020 EDY. All rights reserved.
//

import Foundation
import UIKit
 
class DecalPage: UIViewController,  UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var DecalContainer: UIView!
    @IBOutlet weak var colorImg: UIImageView!
    @IBOutlet weak var garmentImg: UIImageView!
    @IBOutlet weak var decalCV: UICollectionView!
    @IBOutlet weak var colorName: UILabel!
    @IBOutlet weak var garmentName: UILabel!
    
    @IBOutlet weak var vendorStyleLBL: UILabel!
    
    var decalId = [Int]()
    var decalsNum: Int = 0
    var selectedGarmentId: Int64 = 0
    var selectedGarmentName: String = ""
    var selectedColorName: String = ""
    var selectedColorID: Int = 0
    var selectedItemID: Int64 = 0
    var selectedDecalId: Int = 0
    var selectedVendorStyle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readSqlDecalData()
        initControls()
    }
     
    func initControls(){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var fileURL = documentsDirectory.appendingPathComponent("Catalog/smallPic/" + String(selectedGarmentId) + ".jpg")
        do{
            let imageData = try Data(contentsOf: fileURL)
            garmentImg.image =  UIImage(data: imageData)
        }catch{}
               
        fileURL = documentsDirectory.appendingPathComponent("Catalog/Colors/" + String(selectedColorID) + ".jpg")
        do{
            let imageData = try Data(contentsOf: fileURL)
            colorImg.image =  UIImage(data: imageData)
        }catch{}
               
        colorName.text = "Color:" + selectedColorName
        garmentName.text = selectedGarmentName
        vendorStyleLBL.text = selectedVendorStyle
        
        roundContainer(container: DecalContainer)
    }
    
    func roundContainer(container: UIView){
        let cornerRadius : CGFloat = 15.0
        container.layer.cornerRadius = cornerRadius
        container.layer.shadowColor = UIColor.darkGray.cgColor
        container.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        container.layer.shadowRadius = 15.0
        container.layer.shadowOpacity = 0.9
    }
    
    //===============================================================
    //============================= SQL ============================
    //==============================================================
    func readSqlDecalData(){
        let clientW = SQLClient.sharedInstance()!
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) {success in
            let sqlFiles = "SELECT decalId FROM decalTBL order BY decalId"
            clientW.execute(sqlFiles) {results in
                if results != nil{
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            self.decalId.append(0)
                            let i = self.decalId.count - 1
                            for column in row as! NSDictionary {
                                self.decalId[i] =  (column.value as! NSObject) as? Int ?? 0
                            }
                        }
                    }
                }
                self.decalsNum = self.decalId.count - 1
                self.decalCV.reloadData()
            }
        }
    }
    
    //==========================================================================================
    //                                      COLLECTION VIEW
    //==========================================================================================
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "decalCell", for: indexPath as IndexPath) as! DecalCell
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if indexPath.row < decalsNum {
            let fileURL = documentsDirectory.appendingPathComponent("Catalog/Decals/" + String(decalId[indexPath.row]) + ".jpg")
              
            do{
                let imageData = try Data(contentsOf: fileURL)
                cell.imgView.image =  UIImage(data: imageData)
                cell.decalName.text = String(decalId[indexPath.row])
            }catch{}
            
            cell.roundContainer()
        }
        return cell
    }
       
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return decalsNum
    }
       
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let vc = segue.destination as? PrintOrderFinal
        vc?.selectedGarmentId = selectedGarmentId
        vc?.selectedGarmentName = selectedGarmentName
        vc?.selectedColorName = selectedColorName
        vc?.selectedColorID = selectedColorID
        vc?.selectedItemID = selectedItemID
        vc?.selectedDecalId = selectedDecalId
        vc?.selectedVendorStyle = selectedVendorStyle
    }
       
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDecalId = decalId[indexPath.row]
        performSegue(withIdentifier: "printingFinalSeguey", sender: indexPath.item)
    }
    
    //==========================================================================================
    //                                      GENERAL
    //==========================================================================================
    func getSettingData( key: String)->String{
        let defaults = UserDefaults.standard
                          
        if UserDefaults.standard.object(forKey: key) == nil {
            return ""
        }else{
            return defaults.string(forKey: key)!
        }
    }
}
