
class ItemInvn {
    var itemID: Int64?
    var itemName: String?
    var vendorStyle: String?
    var itemColors: String?
    var vendorName: String?
    var itemPrice: Double?
    var itemCost: Double?
    var buyRule: String?
    var qty: Int?
    var sales: Int?
    var itemSize: String?
    
    init( itemID:Int64?, itemName: String?, vendorStyle: String?, itemColors: String?, vendorName: String?, itemPrice: Double?, itemCost: Double?, buyRule: String?, qty: Int?, sales: Int?, itemSize: String?) {
        
        self.itemID = itemID
        self.itemName = itemName
        self.vendorStyle = vendorStyle
        self.itemColors = itemColors
        self.vendorName = vendorName
        self.itemPrice = itemPrice
        self.itemCost = itemCost
        self.buyRule = buyRule
        self.qty = qty
        self.sales = sales
        self.itemSize = itemSize
    }
}
