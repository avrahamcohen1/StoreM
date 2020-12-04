class Items {
    var itemID: Int64?
    var itemName: String?
    var vendorStyle: String?
    var itemColors: String?
    var oh: Int?
    var hasImg: Int?
    
    init(itemID:Int64?, itemName: String?, oh:Int, vendorStyle:String?, itemColors:String?, hasImg:Int) {
        self.itemID = itemID
        self.itemName = itemName
        self.oh = oh
        self.vendorStyle = vendorStyle
        self.itemColors = itemColors
        self.hasImg = hasImg
    }
}
