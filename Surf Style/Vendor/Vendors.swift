

class Vendors {
    var vNum: Int?
    var vendorId: Int?
    var vendorName: String?
    var itemsSold: Int?
    var sales: Double?
    var cost: Double?
    var profit: Double?
    var prcnt: Double?
    
    init(vNum: Int?, vendorId:Int?, vendorName: String?, itemsSold: Int?, sales: Double?, cost: Double?, profit:Double, prcnt:Double) {
        self.vendorId = vendorId
        self.vendorName = vendorName
        self.vNum = vNum
        self.itemsSold = itemsSold
        self.sales = sales
        self.cost = cost
        self.profit = profit
        self.prcnt = prcnt

    }
}
