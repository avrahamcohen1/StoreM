import UIKit
class StoreSalesCell: UITableViewCell{
    
    @IBOutlet weak var store:  UILabel!
    @IBOutlet weak var today:  UILabel!
    @IBOutlet weak var todayL: UILabel!
    @IBOutlet weak var todayP: UILabel!
    @IBOutlet weak var month:  UILabel!
    @IBOutlet weak var monthL: UILabel!
    @IBOutlet weak var monthP: UILabel!
    @IBOutlet weak var year:   UILabel!
    @IBOutlet weak var yearL:  UILabel!
    @IBOutlet weak var yearP:  UILabel!
    @IBOutlet weak var cYear:  UILabel!
    @IBOutlet weak var cYearL: UILabel!
    @IBOutlet weak var cYearP: UILabel!
    
    override func awakeFromNib() {
           super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)
    }
}

class Sales{
    var storeId: Int?
    var today: Double
    var todayL: Double
    var month: Double
    var monthL: Double
    var year: Double
    var yearL: Double
    var cYear: Double
    var cYearL: Double
     
    init(storeId: Int?, today: Double, todayL: Double, week: Double, weekL: Double, month: Double, monthL: Double, year: Double, yearL: Double, cYear:Double, cYearL:Double) {
        self.storeId = storeId
        self.today = today
        self.todayL = todayL
        self.month = month
        self.monthL = monthL
        self.year = year
        self.yearL = yearL
        self.cYear = cYear
        self.cYearL = cYearL
    }
}
