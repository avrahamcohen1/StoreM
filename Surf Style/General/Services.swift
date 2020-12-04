import UIKit
  

class Services  {
    
    
    func getSettingData( key: String)->String{
        let defaults = UserDefaults.standard
                    
        if UserDefaults.standard.object(forKey: key) == nil {
            return ""
        }else{
               return defaults.string(forKey: key)!
        }
    }
    func isMultiStore()->Bool{
        if getSettingData(key:"multiStore") == "1"{
            return false
        }else{
            return true
        }
    }
    
    func getStrDaysAgo(days:Int)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        var dateComponents = DateComponents()
        dateComponents.setValue(-days, for: .day)
        let now = Date()
        let prevDate = Calendar.current.date(byAdding: dateComponents, to: now)
        let dStr = formatter.string(from: prevDate!)
        return dStr
    }
    func getDaysAgo(days:Int)->Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        var dateComponents = DateComponents()
        dateComponents.setValue(-days, for: .day)
        let now = Date()
        let prevDate = Calendar.current.date(byAdding: dateComponents, to: now)
        
        return prevDate!
    }
    func getDateDaysAgo(days:Int)->Date{
        var dateComponents = DateComponents()
        dateComponents.setValue(-days, for: .day)
        let prevDate = Calendar.current.date(byAdding: dateComponents, to: Date())!
        return prevDate
    }
    
    func getStoreName()->String{
           return getSettingData(key:"storeName")
    }
    
    func roundContainer(container: UIView){
        let cornerRadius : CGFloat = 15.0
        container.layer.cornerRadius = cornerRadius
        container.layer.shadowColor = UIColor.darkGray.cgColor
        container.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        container.layer.shadowRadius = 15.0
        container.layer.shadowOpacity = 0.9
    }
         
    func roundBtn(btn:UIButton){
        let cornerRadius : CGFloat = 5.0
        btn.layer.cornerRadius = cornerRadius
        btn.layer.shadowColor = UIColor.darkGray.cgColor
        btn.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        btn.layer.shadowRadius = 9.0
        btn.layer.shadowOpacity = 0.9
    }
    
    func downloadImg(itemID: String, imgV: UIImageView)->Bool{
        let fileName = "/Catalog/" + itemID + ".jpg"
        let webUrl = URL(string: "http://" + UserDefaults.standard.string(forKey:"wareIP")! + "/Downloads/" + fileName)
        var retVal:Bool = false
        
        if let anUrl = webUrl {
            do{
                let imageData = try Data(contentsOf: anUrl)
                imgV.image =  UIImage(data: imageData)
                retVal  = true
            }catch{
                imgV.image = nil
                retVal = false
            }
        }
        return retVal
    }
    
    func getCurrency(number: Double, len:Int)->String{
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.maximumFractionDigits = 0
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        let s = currencyFormatter.string(from: NSNumber(value: number))
        return(s!.leftPadding(toLength: len - s!.count, withPad: " "))
    }
    
    func getPrecent(number: Double, isZero: Bool, len:Int)->String{
        var retVal: String = ""
        if isZero{
            retVal = (retVal.leftPadding(toLength: len, withPad: " ")) + "%"
        }else{
            let s = String(format: "%.0f", number) + "%"
            retVal = (s.leftPadding(toLength: len - s.count, withPad: " "))
        }
        return(retVal)
    }
}


extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}
extension UILabel {
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }

    public var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    override open func draw(_ rect: CGRect) {
        if let insets = padding {
            self.drawText(in: rect.inset(by: insets))
        } else {
            self.drawText(in: rect)
        }
    }

    override open var intrinsicContentSize: CGSize {
        guard let text = self.text else { return super.intrinsicContentSize }

        var contentSize = super.intrinsicContentSize
        var textWidth: CGFloat = frame.size.width
        var insetsHeight: CGFloat = 0.0
        var insetsWidth: CGFloat = 0.0

        if let insets = padding {
            insetsWidth += insets.left + insets.right
            insetsHeight += insets.top + insets.bottom
            textWidth -= insetsWidth
        }

        let newSize = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                        attributes: [NSAttributedString.Key.font: self.font], context: nil)

        contentSize.height = ceil(newSize.size.height) + insetsHeight
        contentSize.width = ceil(newSize.size.width) + insetsWidth

        return contentSize
    }
}

