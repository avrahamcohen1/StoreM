class  StyleDetails {
    var itemID: Int64?
    var itemName: String?
    var vendorStyle: String?
    var itemColors: String?
    var qty: Int?
    var wareOh: Int?
    var vendorName: String?
    var itemPrice: Double?
   
    
    init(itemID:Int64?, itemName: String?, qty:Int, wareOh:Int, vendorStyle:String?, itemColors:String?, vendorName:String?, itemPrice:Double) {
        self.itemID = itemID
        self.itemName = itemName
        self.qty = qty
        self.wareOh = wareOh
        self.vendorStyle = vendorStyle
        self.itemColors = itemColors
        self.vendorName = vendorName
        self.itemPrice = itemPrice
    }
}
