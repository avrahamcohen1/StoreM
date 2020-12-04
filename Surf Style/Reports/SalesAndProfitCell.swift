 import UIKit
 class SalesAndProfitCell: UITableViewCell{
     @IBOutlet weak var cId:  UILabel!
     @IBOutlet weak var store:  UILabel!
     @IBOutlet weak var salesWCost:  UILabel!
     @IBOutlet weak var profitWCost: UILabel!
     @IBOutlet weak var salesNCost: UILabel!
     @IBOutlet weak var profitNCost: UILabel!
     @IBOutlet weak var totalProfit: UILabel!
     @IBOutlet weak var totalProfitPrcnt: UILabel!
    
     func initialize() {
         setBorder(label: cId)
         setBorder(label: store)
         setBorder(label: salesWCost)
         setBorder(label: profitWCost )
         setBorder(label: salesNCost)
         setBorder(label: profitNCost)
         setBorder(label: totalProfit)
         setBorder(label: totalProfitPrcnt)
     }
     
     func setBorder(label:UILabel){
         label.layer.borderColor = UIColor.darkGray.cgColor
         label.layer.borderWidth = 0.5
     }
 }

 class SalesProfit{
     var CId: Int?
     var Store: Int?
     var salesWCost: Double?
     var profitWCost: Double?
     var salesNCost: Double?
     var profitNCost: Double?
     var totalProfit: Double?
     var totalProfitPrcnt: Double?
     
     
    init(cId: Int, store:Int, salesWCost:Double, profitWCost: Double?, salesNCost: Double?, profitNCost: Double?, totalProfit: Double?, totalProfitPrcnt: Double?){
         self.CId = cId
         self.Store = store
         self.salesWCost  = salesWCost
         self.profitWCost = profitWCost
         self.salesNCost  = salesNCost
         self.profitNCost = profitNCost
         self.totalProfit = totalProfit
         self.totalProfitPrcnt  = totalProfitPrcnt
     }
 }

