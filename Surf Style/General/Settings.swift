import UIKit

class Settings: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate  {
    
    //--------------------------------------------------------------------------
    //                              INIT
    //--------------------------------------------------------------------------
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var ftpIP: UITextField!
    @IBOutlet weak var ftpPass: UITextField!
    @IBOutlet weak var imgWidth: UITextField!
    @IBOutlet weak var wareIP: UITextField!
    @IBOutlet weak var warePort: UITextField!
    @IBOutlet weak var warePass: UITextField!
    @IBOutlet weak var wareDb: UITextField!
    @IBOutlet weak var localIP: UITextField!
    @IBOutlet weak var localPort: UITextField!
    @IBOutlet weak var localPass: UITextField!
    @IBOutlet weak var localDb: UITextField!
    @IBOutlet weak var hideControlsView: UIView!
    @IBOutlet weak var fileCounterLBL: UILabel!
    @IBOutlet weak var groupPicNumber: UILabel!
    @IBOutlet weak var decalPicNumber: UILabel!
    @IBOutlet weak var colorsPicNumber: UILabel!
    
    @IBOutlet weak var officeIP: UITextField!
    @IBOutlet weak var officePort: UITextField!
    @IBOutlet weak var officeDb: UITextField!
    @IBOutlet weak var officePass: UITextField!
    
    @IBOutlet weak var imgDownloadDate: UIDatePicker!
    @IBOutlet weak var storeIdPicker: UIPickerView!
    @IBOutlet weak var viewOrdersPicker: UIPickerView!
    
    @IBOutlet weak var searchItemID: UITextField!
    
    @IBOutlet weak var mutiStoreSelect: UISegmentedControl!
    
    
    
    var storeNames = ["421", "1670", "1451", "1441", "1332", "1301", "1208", "1155", "1051", "1041", "1036", "840", "645"]
    var viewOrdersMonth = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "12", "18", "24", "36"]
    let pAdmin = "surf421421"
    let pMulti = "edymed421"
    let pServ = "421Miamisurf$"
    let defPort = "12345"
    var ftpPassword: String = ""
    var ftpIpAddr: String = ""
    var generalIdx: Int = 0
    var itemIDs = [Int64]()
    var onlineS: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSettings()
    }
    
    func initSettings(){
        if settingsExist(){
            // Get the following values in order to enable images ftp download
            ftpPassword = getSettingData(key: "ftpPass")
            ftpIpAddr = getSettingData(key: "ftpIP")
        
            initDatePicker()
            initViewOrdersPicker()
            getNumberOfPics()
           
        }
        hideControlsView.isHidden = true
    }
    
    //--------------------------------------------------------------------------
    //                           CONFIGURATION SETUP
    //--------------------------------------------------------------------------
    @IBAction func loginClick(_ sender: Any) {
        if loginPassword.text == pAdmin || loginPassword.text == pMulti {
             setAdminControls()
        }
    }
    
    func setAdminControls(){
        let defaults = UserDefaults.standard
        if  defaults.string(forKey: "ftpIP") == nil {
            
            ftpIP.text = "174.61.6.2"
            ftpPass.text = pServ
            
            wareIP.text = "174.61.6.2"
            warePort.text = defPort
            warePass.text = pAdmin
            wareDb.text = "zxSQL"
            
            localIP.text = "192.168.1.100"
            localPort.text = defPort
            localPass.text = pAdmin
            localDb.text = "zxSQL"
        
            officeIP.text = "216.189.184.203"
            officePort.text = defPort
            officePass.text = pServ
            officeDb.text = "allStores"
                
            imgWidth.text = "400"
            
            storeIdPicker.selectRow(1, inComponent: 0, animated: true)
            viewOrdersPicker.selectRow(1, inComponent: 0, animated: true)
            
            mutiStoreSelect.selectedSegmentIndex = 0
        
        } else {
            ftpIP.text = defaults.string(forKey: "ftpIP")!
            ftpPass.text = defaults.string(forKey: "ftpPass")!
            
            wareIP.text = defaults.string(forKey: "wareIP")!
            warePort.text = defaults.string(forKey: "warePort")!
            warePass.text = defaults.string(forKey: "warePass")!
            wareDb.text = defaults.string(forKey: "wareDb")!

            localIP.text = defaults.string(forKey: "localIP")!
            localPort.text = defaults.string(forKey: "localPort")!
            localPass.text = defaults.string(forKey: "localPass")!
            localDb.text = defaults.string(forKey: "localDb")!
            if defaults.string(forKey: "officeIP") != nil{
                officeIP.text = defaults.string(forKey: "officeIP")!
                officePort.text = defaults.string(forKey: "officePort")!
                officePass.text = defaults.string(forKey: "officePass")!
                officeDb.text = defaults.string(forKey: "officeDb")!
            }
            imgWidth.text = defaults.string(forKey: "imgWidth")!
            
            var idx = Int(defaults.string(forKey: "storeID")!)!
            storeIdPicker.selectRow(idx, inComponent: 0, animated: true)
            
            if defaults.string(forKey: "viewOrdersMonth") != nil{
                idx = Int(defaults.string(forKey: "viewOrdersMonth")!)!
            }else{
                idx = 0
            }
            viewOrdersPicker.selectRow(idx, inComponent: 0, animated: true)
            
            if defaults.string(forKey: "multiStore") != nil{
                idx = Int(defaults.string(forKey: "multiStore")!)!
            }else{
                idx = 0
            }
            mutiStoreSelect.selectedSegmentIndex = idx
       
        }
        hideControlsView.isHidden = false
        
        if loginPassword.text == pMulti {
            mutiStoreSelect.isHidden = false
        }else{
            mutiStoreSelect.isHidden = true
        }
    }
    
    @IBAction func saveBtnClick(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        defaults.set(ftpIP.text!, forKey: "ftpIP")
        defaults.set(ftpPass.text!, forKey: "ftpPass")
        
        defaults.set(wareIP.text!, forKey: "wareIP")
        defaults.set(warePort.text!, forKey: "warePort")
        defaults.set(warePass.text!, forKey: "warePass")
        defaults.set(wareDb.text!, forKey: "wareDb")
        
        defaults.set(localIP.text!, forKey: "localIP")
        defaults.set(localPort.text!, forKey: "localPort")
        defaults.set(localPass.text!, forKey: "localPass")
        defaults.set(localDb.text!, forKey: "localDb")

        defaults.set(officeIP.text!, forKey: "officeIP")
        defaults.set(officePort.text!, forKey: "officePort")
        defaults.set(officePass.text!, forKey: "officePass")
        defaults.set(officeDb.text!, forKey: "officeDb")
        
        defaults.set(imgWidth.text!, forKey: "imgWidth")
        
        defaults.set(getDatePicker(), forKey: "imgDownloadDate")
       
        let storeIdIdx = String(storeIdPicker.selectedRow(inComponent: 0))
        let storeN = storeNames[ Int(storeIdIdx)! ]
        defaults.set( storeIdIdx, forKey: "storeID")
        defaults.set( storeN, forKey: "storeName")
        
        let viewOrdersIdx = String(viewOrdersPicker.selectedRow(inComponent: 0))
        defaults.set( viewOrdersIdx, forKey: "viewOrdersMonth")
        
        defaults.set( mutiStoreSelect.selectedSegmentIndex, forKey: "multiStore")
        
        returnHome()
    }
    
    @IBAction func resetToDefaults(_ sender: Any) {
        if loginPassword.text == pAdmin {
            let refreshAlert = UIAlertController(title: "Settings", message: "Reset To Defaults. Are You Sure?", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                let defaults = UserDefaults.standard
                let dictionary = defaults.dictionaryRepresentation()
                dictionary.keys.forEach { key in
                    defaults.removeObject(forKey: key)
                }
                self.setAdminControls()
                self.returnHome()
            }))

            refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            }))

            present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    //--------------------------------------------------------------------------
    //                           DOWNLOAD PICTURES
    //--------------------------------------------------------------------------
    @IBAction func clickItemPics(_ sender: Any) {
        let df = DateFormatter()
        df.timeZone = TimeZone(identifier: "UTC")
        df.dateFormat = "MM-dd-yyyy h:mm a"
        let dateStr = df.string(from:Date())
        
        createDir(dirName: "Catalog/smallPic")
        
        let sqlStr = "SELECT cast(itemID as BIGINT) as itemIdInt FROM itemTBL WHERE hasImg = 1 AND imgDate >='" +  getDatePicker() + "'"
        sqlReadDownloadAndSavePics(sqlStr: sqlStr, typeDirectory: "smallPic")
        UserDefaults.standard.set(dateStr, forKey: "imgDownloadDate")
    }
    
    @IBAction func clicGroupPics(_ sender: Any) {
        removeDir(dirName: "Catalog/Groups")
        createDir(dirName: "Catalog/Groups")
        sqlReadDownloadAndSavePics(sqlStr: "SELECT groupID FROM itemGroupTBL", typeDirectory: "Groups")
    }
    @IBAction func clicColorPics(_ sender: Any) {
        removeDir(dirName: "Catalog/Colors")
        createDir(dirName: "Catalog/Colors")
        sqlReadDownloadAndSavePics(sqlStr: "SELECT colorID FROM itemColorTBL", typeDirectory: "Colors")
    }
    @IBAction func clicDecalPics(_ sender: Any) {
        removeDir(dirName: "Catalog/Decals")
        createDir(dirName: "Catalog/Decals")
        sqlReadDownloadAndSavePics(sqlStr: "SELECT decalId FROM decalTBL", typeDirectory: "Decals")
    }
    
    func sqlReadDownloadAndSavePics(sqlStr: String, typeDirectory: String){
        showSpinnerS(onView: self.view)
        let clientW = SQLClient.sharedInstance()!
        
        let wareIpPort = getSettingData(key:"wareIP") + ":" + getSettingData(key:"warePort")
        let passw = getSettingData(key:"warePass")
        let db = getSettingData(key:"wareDb")
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
                    self.downloadAndSavePics(recordNum: itemIdx, typeDirectory: typeDirectory)
                }
                self.removeSpinnerS()
                self.msgBox(msgTxt: typeDirectory + " Pictures Download \(itemIdx) images")
            }
        }
    }
    
    func downloadAndSavePics(recordNum:Int, typeDirectory: String) {
        print ("Downloading Files:\(recordNum)")
        
        for i in 0...recordNum - 1{
            let fileName = "Catalog/" + typeDirectory + "/" + String(itemIDs[i]) + ".jpg"
            
            removeFile(fileName: fileName)
             
            WebFileDownloader.downloadFileSync(fileName: fileName) { (path, error) in}
        }
        getNumberOfPics()
    }
    
        
    //  ============================================================================
    //                                 PICKERS
    //  ============================================================================
    func initDatePicker(){
        let defaults = UserDefaults.standard
        if  defaults.string(forKey: "ftpIP") == nil {
            setDatePicker(key: "imgDownloadDate",   dPicker: imgDownloadDate,   dateStr: "2020/01/01 12:00:00")
        }else{
            setDatePicker(key: "imgDownloadDate",   dPicker: imgDownloadDate,   dateStr: defaults.string(forKey: "imgDownloadDate")!)
        }
    }
       
    func initViewOrdersPicker(){
        let defaults = UserDefaults.standard
        if UserDefaults.standard.object(forKey: "viewOrdersMonth") != nil{
            let idx = Int(defaults.string(forKey: "viewOrdersMonth")!)!
            viewOrdersPicker.selectRow(idx, inComponent: 0, animated: true)
        }else{
            viewOrdersPicker.selectRow(1, inComponent: 0, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) ->Int{
        if pickerView == viewOrdersPicker{
            return viewOrdersMonth.count
        }else{
            return storeNames.count
        }
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)->String? {
        if pickerView == viewOrdersPicker{
            return viewOrdersMonth[row]
        }else{
            return storeNames[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == viewOrdersPicker{
            let defaults = UserDefaults.standard
            let idx = viewOrdersPicker.selectedRow(inComponent: 0)
            defaults.set(idx, forKey: "viewOrdersMonth")
        }
    }
    
    func setDatePicker(key:String, dPicker:UIDatePicker, dateStr:String){
        let df = DateFormatter()
        df.timeZone = TimeZone(identifier: "UTC")
        df.dateFormat = "MM-dd-yyyy h:mm a"
        let lDate = df.date(from: dateStr) ?? Date()
        dPicker.setDate(lDate, animated: false)
    }
     
    func getDatePicker()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy/MM/dd 00:00:00"
        return dateFormatter.string(from: imgDownloadDate.date)
    }
    
    //  ============================================================================
    //                                 GENERAL
    //  ============================================================================
    func returnHome(){
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
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
    
    func msgBox(msgTxt:String){
        let alert = UIAlertController(title: "Surf Style", message: msgTxt, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    func removeDir(dirName:String){
        let fileManager = FileManager.default
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(dirName)
        
        do {
            try fileManager.removeItem(at: fileURL)
        } catch let error as NSError {
            print("Error removing files: \(error)")
        }
    }
    
    func createDir(dirName:String){
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath =  tDocumentDirectory.appendingPathComponent("\(dirName)")
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                    print("Couldn't create document directory")
                }
            }
        }
    }
    
    func getNumberOfPics(){
        fileCounterLBL.text = String( getDirPicsNum(dirName: "/Catalog/smallPic/" )) + " pictures"
        groupPicNumber.text = String( getDirPicsNum(dirName: "/Catalog/Groups/" )) + " pictures"
        colorsPicNumber.text = String( getDirPicsNum(dirName: "/Catalog/Colors/" )) + " pictures"
        decalPicNumber.text = String( getDirPicsNum(dirName: "/Catalog/Decals/" )) + " pictures"
    }
    
    func getDirPicsNum(dirName:String)->Int{
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = dirPaths[0]
        let folder = documentDirectory.appending(dirName)

        let fileList = try? FileManager.default.contentsOfDirectory(atPath: folder)
        if fileList != nil{
            return fileList!.count
        }else{
            return 0
        }
    }
    
    func settingsExist()->Bool{
        if getSettingData(key:"ftpIP") == "" {
            return false
        }else{
            return true
        }
    }
    
    func removeJpgFiles(dirName:String){
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let tempFolderPath = documentsUrl.appendingPathComponent(dirName)
        
         do {
               let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath!.path)
               for filePath in filePaths {
                    try fileManager.removeItem(atPath: tempFolderPath!.path + "/" + filePath)
               }
         } catch { print("Could not clear folder: \(error)")}
    }
    
    func removeFile(fileName: String){
        
        // Get destination url in document directory for file
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let documentDirectoryFileUrl = documentsDirectory.appendingPathComponent(fileName)

        // Delete file in document directory
        if FileManager.default.fileExists(atPath: documentDirectoryFileUrl.path) {
            do {
                try FileManager.default.removeItem(at: documentDirectoryFileUrl)
            } catch {print("Could not delete file: \(error)")}
        }
        
    }
    
    @IBAction func listFilesClicked(_ sender: Any) {
        listFiles(fileDir:"Catalog/smallPic/")
    }
    
    @IBAction func listGroupFiles(_ sender: Any) {
        listFiles(fileDir:"Catalog/Groups/")
    }
    
    @IBAction func listColorFiles(_ sender: Any) {
        listFiles(fileDir:"Catalog/Colors/")
    }
    
    @IBAction func listDecalFiles(_ sender: Any) {
        listFiles(fileDir:"Catalog/Decals/")
    }
    
    func listFiles(fileDir:String){
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let subURL =  documentsUrl.appendingPathComponent(fileDir)
               
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: subURL, includingPropertiesForKeys: nil)
            print(directoryContents)
        } catch {print(error)}
    }
    
    @IBAction func printItemIdFilesClicked(_ sender: Any) {
        if searchItemID.text != nil{
            listFiles(fileDir:"Catalog/smallPic/" + searchItemID.text! + ".jpg")
        }
    }
    
}
//868d3f5ca023a1d67c14f5426151de830241b0dc
