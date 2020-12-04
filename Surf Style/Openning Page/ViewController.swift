//
//  ViewController.swift
//  Surf Style
//
//  Created by Uzi Benoliel on 5/21/20.
//  Copyright © 2020 EDY. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    @IBOutlet weak var onlineStatusLBL: UILabel!
    @IBOutlet weak var orderByVendor: UIButton!
    @IBOutlet weak var orderByCategory: UIButton!
    @IBOutlet weak var cameraOrder: UIButton!
    @IBOutlet weak var itemSearch: UIButton!
    @IBOutlet weak var viewOrders: UIButton!
    @IBOutlet weak var styleSearch: UIButton!    
    @IBOutlet weak var printingOrder: UIButton!
    @IBOutlet weak var reportsBtn: UIButton!
    @IBOutlet weak var inventoryBtn: UIButton!
    @IBOutlet weak var versionLBL: UILabel!
    @IBOutlet weak var StoreLBL: UILabel!
    
    var serv: Services = Services()
    var itemIDs = [Int64]()
    var onlineStatus:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
    }
      
    func initControls(){
        serv.roundBtn(btn: orderByVendor)
        serv.roundBtn(btn: orderByCategory)
        serv.roundBtn(btn: itemSearch)
        serv.roundBtn(btn: viewOrders)
        serv.roundBtn(btn: styleSearch)
        serv.roundBtn(btn: cameraOrder)
        serv.roundBtn(btn: inventoryBtn)
        serv.roundBtn(btn: reportsBtn)
        serv.roundBtn(btn: printingOrder)
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLBL.text = "Version:" + version
        }
        
        checkOnlineStatus()
        setStoreName()
        
    }
    func setStoreName(){
        if serv.getSettingData(key:"multiStore") == "1"{
            StoreLBL.text = " Store " + getSettingData(key:"storeName")
        }else{
            StoreLBL.text = " All Stores"
        }
    }
    
    func roundContainer(container: UIView){
        let cornerRadius : CGFloat = 15.0
        container.layer.cornerRadius = cornerRadius
        container.layer.shadowColor = UIColor.darkGray.cgColor
        container.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        container.layer.shadowRadius = 15.0
        container.layer.shadowOpacity = 0.9
    }
    
    func roundBtnCorner(btn:UIButton){
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.blue.cgColor
        btn.layer.cornerRadius = 3
    }
    
    func checkOnlineStatus(){
        if let url = URL(string: "https://apple.com") {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"

            URLSession(configuration: .default)
               
            .dataTask(with: request) { (_, response, error) -> Void in
                 guard error == nil else {
                    print("Error:", error ?? "")
                    return
                 }
                 
                 guard (response as? HTTPURLResponse)?
                 .statusCode == 200 else {
                     return
                 }
                 DispatchQueue.main.async {
                    self.onlineStatusLBL.text = "ONLINE"
                    self.onlineStatus = true
                    if self.settingsExist() {
                        self.checkImagesByDate()
                    }
                    return
                 }
                   
            }
            .resume()
        }
    }
    
    func checkImagesByDate(){
        showSpinnerS(onView: self.view)
        let clientW = SQLClient.sharedInstance()!
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        let passw = getSettingData(key:"warePass")
        let db = getSettingData(key:"wareDb")
        let lastDownloadDate = getSettingData(key:"imgDownloadDate")
        
        let sqlStr = "SELECT cast(itemID as BIGINT) as itemIdInt FROM itemTBL WHERE hasImg = 1 AND imgDate >='" +  lastDownloadDate  + "'"
        var itemIdx = 0
        itemIDs.removeAll()
        clientW.disconnect()
        clientW.connect(wareIpPort, username: "sa", password: passw, database: db){ success in
            clientW.execute(sqlStr) { results in
                if results != nil{
                    for table in results! as NSArray {
                        for row in table as! NSArray {
                            for column in row as! NSDictionary {
                                let id = (column.value as! NSObject) as? Int64 ?? 0
                                self.itemIDs.append(0)
                                self.itemIDs[ itemIdx ] = id
                                itemIdx += 1
                            }
                        }
                    }
                    clientW.disconnect()
                }
                if itemIdx > 0 {
                    self.downloadAndSavePics(recordNum: itemIdx)
                }
                self.removeSpinnerS()
            }
        }
    }
    
    func downloadAndSavePics(recordNum:Int) {
        print ("Downloading Files:\(recordNum)")
           
        for i in 0...recordNum - 1{
            let fileName = "Catalog/smallPic/" + String(itemIDs[i]) + ".jpg"
               
            removeFile(fileName: fileName)
                       
            WebFileDownloader.downloadFileSync(fileName: fileName) { (path, error) in}
        }
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = format.string(from: date)
        
        UserDefaults.standard.set(formattedDate, forKey: "imgDownloadDate")
    }
    
    
    //  ============================================================================
    //                                 GENERAL
    //  ============================================================================
    func removeFile(fileName: String){
           let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
           let removeURL = documentsUrl.appendingPathComponent(fileName)
           
           do {
               try FileManager.default.removeItem(at: removeURL!)
           } catch let error as NSError { print("Error removing file: \(error.domain)")}
    }
    
    func getSettingData( key: String)->String{
        let defaults = UserDefaults.standard
        
        if UserDefaults.standard.object(forKey: key) == nil {
            return ""
        }else{
            return defaults.string(forKey: key)!
        }
    }
    
    func settingsExist()->Bool{
        if getSettingData(key:"ftpIP") == "" {
            return false
        }else{
            return true
        }
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        exit(1)
    }
   
}

