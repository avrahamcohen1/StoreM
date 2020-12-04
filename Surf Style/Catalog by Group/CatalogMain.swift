//
//  ViewController.swift
//  catalog3
//
//  Created by Uzi Benoliel on 5/17/20.
//  Copyright © 2020 Uzi Benoliel. All rights reserved.
//

import UIKit

class CatalogMain: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var catalogCV: UICollectionView!
    
    var groups = [Groups]()
    var groupsNum: Int = 0
    let reuseIdentifier = "cell"
    var selectedGroupID:Int = 0
    var selectedGroupName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readSqlDataAndDownloadImgs()
    }
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! GroupCell

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if indexPath.row < groupsNum {
            let fileURL = documentsDirectory.appendingPathComponent("Catalog/Groups/" + String(groups[indexPath.row].groupID!) + ".jpg")
            
            do{
                let imageData = try Data(contentsOf: fileURL)
                cell.imageView.image =  UIImage(data: imageData)
                cell.groupName.text = groups[indexPath.row].groupName
            }catch{}
            
            cell.roundContainer()
        }
        return cell
    }

    func readSqlDataAndDownloadImgs(){
        let clientW = SQLClient.sharedInstance()!
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        groupsNum = 0
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: getSettingData(key:"warePass"), database: getSettingData(key:"wareDb")) {success in
            if success {
                let sqlStr = "SELECT groupID, groupName FROM itemGroupTBL ORDER by orderID"
                clientW.execute(sqlStr) { results in
                    if results != nil {
                        for table in results! as NSArray {
                            for row in table as! NSArray {
                                self.groups.append(Groups(groupID: 0, groupName: ""))
                                for column in row as! NSDictionary {
                                    switch column.key as! String{
                                        case "groupID":
                                            self.groups[self.groupsNum].groupID! = (column.value as! NSObject) as? Int ?? 0
                                        case "groupName":
                                            self.groups[self.groupsNum].groupName! = ((column.value as! NSObject) as! String)
                                        default:
                                            let _: Int
                                    }
                                }
                                self.groupsNum += 1
                            }
                        }
                    }
                     
                    if self.groupsNum > 0 {
                        for i in 0...self.groupsNum - 1{
                            let fileName =  "Catalog/Groups/" + String(self.groups[i].groupID!) + ".jpg"
                            if self.fileExist(fileName: fileName) == false{
                                WebFileDownloader.downloadFileSync(fileName: fileName) { (path, error) in}
                            }
                        }
                        self.catalogCV.reloadData()
                    }
                    
                }
            }
        }
    }
    
    func fileExist(fileName:String)->Bool{
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func getSettingData( key: String)->String{
        let defaults = UserDefaults.standard
            
        if UserDefaults.standard.object(forKey: key) == nil {
            return ""
        }else{
            return defaults.string(forKey: key)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupsNum
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is GroupItems{
            let vc = segue.destination as? GroupItems
            vc?.selectedGroupID = selectedGroupID
            vc?.selectedGroupName = selectedGroupName
            vc?.isVendorCatalog = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedGroupID = groups[indexPath.item].groupID!
        selectedGroupName = groups[indexPath.row].groupName!
        performSegue(withIdentifier: "groupItemsSegue", sender: indexPath.item)
    }
}
