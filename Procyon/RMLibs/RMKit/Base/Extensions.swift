//==========================================================================
//this file hold extensions
import UIKit
import WebKit
import HTML
import CoreText

extension WKWebView{
    func getHTMLString(_ completion:@escaping stringBlock){
        return self.evaluateJavaScript("document.getElementsByTagName('html')[0].innerHTML", completionHandler: { (html, error) -> Void in
            completion("\(html)")
        })
    }
    func load(rmRequest request:RMRequest){
        if let request = request.rawRequest{
            self.load(request)
        }
    }
}

extension UIViewController{
    func show(){
        let window = UIWindow()
        window.becomeKey()
        window.makeKeyAndVisible()
        window.size = screen.size
        window.rootViewController = self
    }
}
extension UIKeyModifierFlags{
    static var none: UIKeyModifierFlags {
        return UIKeyModifierFlags(rawValue: 0)
    }
}
extension CGFloat{
    var int:Int{
        return Int(self)
    }
    var double:Double{
        return Double(self)
    }
    var float:Float{
        return Float(self)
    }
}
extension Float{
    var cgFloat:CGFloat{
        return CGFloat(self)
    }
    var double:Double{
        return Double(self)
    }
    var int:Int{
        return Int(self)
    }
}
extension Double{
    var int:Int{
        return Int(self)
    }
    var float:Float{
        return Float(self)
    }
    var cgFloat:CGFloat{
        return CGFloat(self)
    }
}
extension Int{
    var cgFloat:CGFloat{
        return CGFloat(self)
    }
    var float:Float{
        return Float(self)
    }
    var double:Double{
        return Double(self)
    }
    var string:String{
        return "\(self)"
    }
}
extension Date {
    init(string:String,for format:String){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = format
        let date =  dateFormatter.date(from: string)
        self.init(timeIntervalSinceNow: date?.timeIntervalSinceNow ?? 0)
    }
    static func date(withISO8601String ISO8601String:String)->Date{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        return dateFormatter.date(from: ISO8601String)!
    }
    func string(for format: String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    var age:Int{
        return (Int(Date().timeIntervalSince(self-16*24*60*60)/365/24/60/60))
    }
}
extension URL{
    var request:RMRequest{
        return RMRequest(self)
    }
}
extension NSMutableURLRequest{
    var headers:[String:String] {
        set{
            self.allHTTPHeaderFields = newValue
        }
        get{
            return self.allHTTPHeaderFields ?? [:]
        }
    }
}
extension UIApplication{
    func forceOpenURL(_ url:URL){
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    func end(){fatalError("application was ended by system")}
}
extension UIAlertController{
    
    func close(){
        self.dismiss(animated: true, completion: nil)
    }
}
extension String {
    func getHeight(fontSize:CGFloat, width:CGFloat, padding:CGFloat = 0) -> CGFloat {
        let tmpTextView = UITextView()
        tmpTextView.text = self
        tmpTextView.font = Font.Roboto.font(fontSize)
        return tmpTextView.sizeThatFits(sizeMake(width, 100000)).height
    }
    subscript (_ index:Int)->String{
        return self.substring(to: index+1).last
    }
    var intValue:Int{
        return Int(self) ?? 0
    }
    var int:Int?{
        return Int(self)
    }
    var request:RMRequest{
        return RMRequest(URL(string: self))
    }
    //=================================
    //return NSURL
    var characterArray:[Character]{
        return Array(self.characters).map{char in char}
    }
    var stringArray:[String]{
        return characterArray.map{String($0)}
    }
    var url: URL? {
        return URL(string: self)
    }
    var encodedForURL: String {
        return addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    var decodedFromURL: String{
        return removingPercentEncoding ?? ""
    }
    var data_utf8: Data {
        return self.data(using: String.Encoding.utf8)!
    }
    var data_eucJP: Data {
        return self.data(using: String.Encoding.japaneseEUC)!
    }
    var htmlAttributedString:NSAttributedString{
        do{
            let htmlData = self.data(using: String.Encoding.utf8, allowLossyConversion:true)!
            let options = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject, NSCharacterEncodingDocumentAttribute: NSNumber(value: String.Encoding.utf8.rawValue) as AnyObject ]
            let attributedString = try NSAttributedString(data: htmlData, options: options as [String : AnyObject], documentAttributes:nil)
            return attributedString
        }catch{
            return NSAttributedString()
        }
    }
    func l(_ item: Any...)->String{
        var base = NSLocalizedString(self, comment: "")
        _=item.enumerated().map{i,item in base = base.replace(of: "$\(i)", with: "\(item)")}
        return base
    }
}
extension IndexPath{
    static var zero:IndexPath{
        return IndexPath(row: 0, section: 0)
    }
}
extension NSAttributedString{
    var rawString:String{
        var textView:UITextView? = UITextView()
        textView?.attributedText = self
        let text = textView!.text
        textView = nil
        return text!
    }
}

extension String {//String自体
    func removeLast()->String{
        return substring(to: count-1)
    }
    func index(_ index:Int)->String{
        return self.substring(to: index+1).substring(to: 1)
    }
    public var count:Int{
        return self.characters.count
    }
    func replace(of:String,with:String)->String{
        return self.replacingOccurrences(of: of, with: with)
    }
    func remove(_ target:String)->String{
        return self.replace(of: target, with: "")
    }
    func split(_ by:String)->[String]{
        return self.components(separatedBy: by)
    }
    var first:String{
        return substring(to: 1)
    }
    var last:String{
        return substring(to: count-1)
    }
    func omit(_ range:Int)->String{
        return count>=range ? ns.substring(to: range)+"…" : self
    }
    func substring(to index: Int) -> String {
        return count>=index ? ns.substring(to: index) : self
    }
    private var ns: NSString {
        return (self as NSString)
    }
    /*static func generateRandom(length: Int) -> String {
        let randomBaseString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        (0..<length).map{_ in
            randomString+=  arc4random_uniform(UInt32(randomBaseString.count))
        }
        
        for _ in 0..<length {
            let randomValue =
            randomString += "\(base[base.startIndex.advanced()])"
        }
        return randomString
    }*/
}
extension Array where Element: UIImage{
    func createPDF(_ completion:@escaping dataBlock){
        asyncQ{
            let pdfData = NSMutableData()
            
            var mediaSize = CGRect(x: 0, y: 0, width: 2000, height: 1000)
            let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!
            let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaSize, nil)!
            
            for i in 0..<self.count{
                var rect = CGRect(origin: .zero, size: self[i].size)
                pdfContext.beginPage(mediaBox: &rect)
                pdfContext.draw(self[i].cgImage!, in: CGRect(origin: .zero, size: self[i].size))
                pdfContext.endPage()
            }
            pdfContext.closePDF()
            
            mainQ {completion(pdfData as Data)}
        }
    }
}
extension Collection{
    //=================================
    //you can get "safe" value from CollectionType
    //if the index you requested is out of range
    //this return nil
    
    //=================================
    //you can map and run closure for each element
    //in the CollectionType object
    func map(_ block:(Iterator.Element)->()){
        for item in self{
            block(item)
        }
    }
}
extension Sequence where Iterator.Element == String {
    func join(_ separator:String)->String {return reduce("", +)}
}
extension Sequence where Iterator.Element == Int {
    var sum: Int{return reduce(0, +)}
}
extension Sequence where Iterator.Element == Double {
    var sum: Double{return reduce(0, +)}
}
extension Sequence where Iterator.Element == CGFloat {
    var sum: CGFloat{return reduce(0, +)}
}
extension Sequence where Iterator.Element == Float {
    var sum: Float{return reduce(0, +)}
}
extension Array where Element: Equatable {
    //=================================
    //you can remove the element
    //like
    //
    // let array = ["foo", "bar"]
    // array.remove(element: "foo")// array = ["bar"]
    mutating func remove(_ element: Element) {
        guard let index = self.index(of: element) else {return}
        self.remove(at: index)
    }
    mutating func remove(_ elements: [Element]) {
        for element in elements {
            remove(element)
        }
    }
}
extension UICollectionViewFlowLayout{
    var width:CGFloat{
        set{
            self.itemSize.width = newValue
        }
        get{
            return itemSize.width
        }
    }
    var height:CGFloat{
        set{
            self.itemSize.height = newValue
        }
        get{
            return itemSize.height
        }
    }
}
extension Array {
    func subArray(to index:Int)->[Element]{
        var tmp = [Element]()
        for i in 0..<index{if let item = self.index(i){tmp.append(item)}}
        return tmp
    }
    func index(_ index:Int)->Element?{
        return self.count > index && index >= 0 ? self[index] : nil
    }
    mutating func remove(_ index:Int){
        if containsIndex(index){remove(at: index)}
        else{debugPrint("Array Error: index out of range")}
    }
    func containsIndex(_ index:Int)->Bool{
        return self.count > index && index >= 0
    }
}
extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (key, value) in pairs {
            self[key] = value
        }
    }
}

extension Sequence where Iterator.Element == voidBlock {
    //=================================
    //you can run all block in Array<voibBlock>
    //これは便利
    func runAll(){
        for block in self{
            block()
        }
    }
}
extension NSObject {
    //=================================
    //you can get class name
    class var classDescribing: String {return String(describing: self)}
    var className: String {return "\(type(of: self))"}
}
extension NSObjectProtocol where Self: NSObject {
    //=================================
    //you can get all propaties names of the object
    var propatyNames: String {
        let mirror = Mirror(reflecting: self)
        return mirror.children.map {e in
            return "\(e.label ?? "Unknown"): \(e.value)"
        }.join("\n")
    }
    //=================================
    //you can get all propaties value with the property name
    var propaties: [String:Any]{
        let mirror = Mirror(reflecting: self)
        var values:[String:Any] = [:]
        mirror.children.map {element in
            values[element.label!] = element.value
        }
        return values
    }
}
extension CGRect{
    var center:CGPoint{
        get{
            return Point(origin.x+size.width/2.0, origin.y+size.height/2.0)
        }
        set(value){
            origin = Point(origin.x+size.width/2.0, origin.y+size.height/2.0)
        }
    }
}
extension Data{
    var string:String{return String(NSString(data: self, encoding: String.Encoding.utf8.rawValue)!)}
    var json:JSON{return JSON(data: self)}
    //var html:HTML{return HTML(data: self) ?? HTML(string: "<html></html>")!}
    func save(withName name:String,atPath path: RMFile.Dir,completion:@escaping (URL)->()){
        asyncQ{
            _=file.mkFile(name, contents: self, atPath: path)
            mainQ{completion(URL(fileURLWithPath: path.raw()+"/"+name))}
        }
    }
}
extension UIViewController{
    var center:CGPoint{
        return self.view.layer.position
    }
}
extension UIEdgeInsets{
    static var zero:UIEdgeInsets{
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}
extension UIView {
    var x:CGFloat{
        get{
            return self.frame.origin.x
        }
        set{
            self.frame.origin.x = newValue
        }
    }
    var y:CGFloat{
        get{
            return self.frame.origin.y
        }
        set{
            self.frame.origin.y = newValue
        }
    }
    var centerX:CGFloat{
        get{
            return center.x
        }
        set{
            self.center.x = newValue
        }
        
    }
    var centerY:CGFloat{
        get{
            return center.y
        }
        set{
            self.center.y = newValue
        }
    }
    var bottomY:CGFloat{
        get{
            return height+y
        }
        set{
            self.y = newValue-height
        }
    }
    var rightX:CGFloat{
        get{
            return width+x
        }set{
            self.x = newValue-width
        }
    }
    var origin:CGPoint{
        get{
            return self.frame.origin
        }
        set{
            self.frame.origin = newValue
        }
    }
    var size:CGSize{
        get{return self.frame.size}
        set{self.frame.size = newValue}
    }
    var width:CGFloat{
        get{return self.frame.size.width}
        set{
            self.frame.size.width = newValue
        }
    }
    var height:CGFloat{
        get{
            return self.frame.size.height
        }
        set{
            self.frame.size.height = newValue
        }
    }
    func vibrate(_ block:@escaping voidBlock = {}){
        UIView.animate(
            withDuration: 0.04,
            delay: 0,
            options: [],
            animations: {
                self.transform = CGAffineTransform(translationX: -10, y: 0)
        },
            completion: {_ in}
        )
        UIView.animate(
            withDuration: 0.04,
            delay: 0.04,
            options: [],
            animations: {
                self.transform = CGAffineTransform(translationX: 8, y: 0)
        },
            completion: {_ in}
        )
        UIView.animate(
            withDuration: 0.04,
            delay: 0.08,
            options: [],
            animations: {
                self.transform = CGAffineTransform(translationX: -6, y: 0)
        },
            completion: {_ in}
        )
        UIView.animate(
            withDuration: 0.04,
            delay: 0.1,
            options: [],
            animations: {
                self.transform = CGAffineTransform(translationX: 4, y: 0)
        },
            completion: {_ in}
        )
        UIView.animate(
            withDuration: 0.04,
            delay: 0.14,
            options: [],
            animations: {
                self.transform = CGAffineTransform(translationX: -2, y: 0)
        },
            completion: {_ in}
        )
        UIView.animate(
            withDuration: 0.04,
            delay: 0.18,
            options: [],
            animations: {
                self.transform = CGAffineTransform(translationX: 0, y: 0)
        },
            completion: {_ in
                block()
        }
        )
    }
    func addSubviews(_ views:UIView...){
        for view in views{
            self.addSubview(view)
        }
    }
    func addSubviews(viewArr:[UIView]){
        for view in viewArr{
            self.addSubview(view)
        }
    }
    var shadowLevel:Int{
        set(value){
            if UIAppearance.useShadowLevel{
                self.layer.shadowOffset = CGSize(width: 0, height: Double(value)*0.7)
                self.layer.shadowColor = UIColor.black.cgColor
                if value<5 {
                    self.layer.shadowOpacity = 0.4
                }else{
                    self.layer.shadowOpacity = 0.6
                }
                self.layer.shadowRadius = CGFloat(value)*0.7
            }
        }
        get{
            return Int(layer.shadowRadius/0.7)
        }
    }
    enum CardViewOption {
        case none
        case bordered
        case cornerd
        case resizable
        case shadowed
        case auto
    }
    func setAsCardView(with options:CardViewOption...){//call after sized
        if UIAppearance.useShadowLevel {
            var options = options
            if options.contains(.auto){
                options = [.shadowed,.bordered,.cornerd]
            }
            if options.contains(.bordered){
                self.layer.borderColor = UIColor.hex("e1e1e1").cgColor
                self.layer.borderWidth = 1
            }
            if options.contains(.shadowed){
                self.layer.shadowRadius = 0.2
                self.layer.shadowOffset = sizeMake(0, 0.5)
                self.layer.shadowOpacity = 1
                self.layer.shadowColor = UIColor.hex("ccc").cgColor
            }
            if options.contains(.cornerd){
                self.layer.cornerRadius = 3
            }else if !options.contains(.resizable){
                self.layer.shouldRasterize = true
                self.layer.rasterizationScale = UIScreen.main.scale
            }
            if options.contains(.none){
                self.layer.borderColor = nil
                self.layer.borderWidth = 0
                self.layer.shadowColor = nil
                self.layer.shadowOffset = .zero
                self.layer.shadowRadius = 0
                self.layer.shadowOpacity = 1 
            }
        }else{
            self.layer.borderColor = UIColor.hex("e1e1e1").cgColor
            self.layer.borderWidth = 1
        }
    }
    //=================================
    //you can set light shadow
    var unsafeShadowLevel:Int{
        set(value){
            if !UIAppearance.useShadowLevel {return}
            self.layer.shadowPath = UIBezierPath(rect:self.layer.bounds).cgPath
            self.layer.shouldRasterize = true
            self.layer.rasterizationScale = UIScreen.main.scale
            self.layer.shadowOffset = CGSize(width: 0, height: Double(value)*0.7)
            self.layer.shadowColor = UIColor.black.cgColor
            
            if value<5 {
                self.layer.shadowOpacity = 0.4
            }else{
                self.layer.shadowOpacity = 0.6
            }
            self.layer.shadowRadius = CGFloat(value)*0.7
        }
        get{
            return Int(layer.shadowRadius/0.7)
        }
    }
    var imageContext:UIImage{
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return capturedImage!
    }
    //=================================
    //you can set radius level
    var safeCornerRadius:CGFloat{
        get{
            return self.layer.cornerRadius
        }
        set(value){
            self.layer.cornerRadius = value
            if unsafeShadowLevel != 0 {
                unsafeShadowLevel = unsafeShadowLevel+0
            }
        }
    }
    var cornerRadius:CGFloat{
        get{
            return self.layer.cornerRadius
        }
        set{
            self.layer.cornerRadius = newValue
        }
    }
    func noCorner(){
        var minSide = self.frame.width
        if minSide>self.frame.height {
            minSide = self.frame.height
        }
        self.layer.cornerRadius = minSide/2
    }
    func animate(_ duration:TimeInterval,options:UIViewKeyframeAnimationOptions,animation:@escaping voidBlock,completion:@escaping voidBlock){
        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: animation,
            completion:{_ in
                completion()
        }
        )
    }
    //=================================
    //you can remove all subViews from the superview
    func removeAllSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    //=================================
    //you can set radius to selectable corners
    func set(Radius cornerRadius:CGFloat, Corners:UIRectCorner){
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: Corners,
            cornerRadii: sizeMake(cornerRadius, cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
extension Size{
    var biggerScale:CGFloat{
        if self.width>height{
            return width
        }else{
            return height
        }
    }
    var smallerScale:CGFloat{
        if self.width<height{
            return width
        }else{
            return height
        }
    }
}
extension UITextView {
    class func heightBy(_ Width:CGFloat,text:String)->CGFloat{
        var textView:UITextView? = UITextView()
        textView?.width = Width
        textView?.text = text
        textView?.sizeToFit()
        let height = textView?.height
        textView = nil
        return height!
    }

    func _firstBaselineOffsetFromTop() {}
    func _baselineOffsetFromBottom() {}
    
    func dissableFunctions(){
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isSelectable = false
        isEditable = false
        isScrollEnabled = false
    }
    //=================================
    //you can make UITextView no padding
    func noPadding(){
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
    var lineSpacing:CGFloat{
        get{
            return 0
        }
        set(value){
            let style = NSMutableParagraphStyle()
            style.lineSpacing = value
            let attributes = [NSParagraphStyleAttributeName : style]
            attributedText = NSAttributedString(string: self.text,attributes: attributes)
        }
    }
}
extension CGRect{
    var width:CGFloat{
        get{
            return self.size.width
        }
        set{
            self.size.width = newValue
        }
    }
    var height:CGFloat{
        get{
            return self.size.height
        }
        set{
            self.size.width = height
        }
    }
}
extension UITextField{
    //=================================
    //you can set padding width
    func set(paddingWidth width:CGFloat){
        let paddingView = UIView()
        paddingView.frame.size = sizeMake(width, frame.height)
        leftView = paddingView
        leftViewMode = .always
    }
}
extension UIColor {
    //=================================
    //if the Color is dark
    //return true
    var isDark:Bool{
        var tmp = false
        let v = max(r*0.53, g*0.8, b*0.4)
        if v<0.5 {
            tmp = true
        }
        return tmp
    }
    //=================================
    //you can set alpha property
    func alpha(_ alpha: CGFloat)->UIColor{
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
    //=================================
    //return the color's red
    var r:CGFloat{
        let colorSpace = self.cgColor.colorSpace
        let colorSpaceModel = colorSpace!.model
        if colorSpaceModel.rawValue == 1 {
            let x = self.cgColor.components
            return x![0]
        }else{
            return 0
        }
    }
    //=================================
    //return the color's green
    var g:CGFloat{
        let colorSpace = self.cgColor.colorSpace
        let colorSpaceModel = colorSpace!.model
        if colorSpaceModel.rawValue == 1 {
            let x = self.cgColor.components
            return x![1]
        }else{
            return 0
        }
    }
    //=================================
    //return the color's blue
    var b:CGFloat{
        let colorSpace = self.cgColor.colorSpace
        let colorSpaceModel = colorSpace!.model
        if colorSpaceModel.rawValue == 1 {
            let x = self.cgColor.components
            return x![2]
        }else{
            return 0
        }
    }
    //=================================
    //return the color's alpha
    var a:CGFloat{
        let colorSpace = self.cgColor.colorSpace
        let colorSpaceModel = colorSpace!.model
        if colorSpaceModel.rawValue == 1 {
            let x = self.cgColor.components
            return x![3]
        }else{
            return 0
        }
    }
    //=================================
    //you can make color from hex
    class func hex(int hex : UInt32, alpha:CGFloat = 1) -> UIColor {
        let hex = String(hex, radix: 16)
        let scanner = Scanner(string: hex as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        }else{
            return UIColor(white: 1, alpha: alpha)
        }
    }
    //=================================
    //you can make color from hex String
    //like css
    class func hex(_ hex:String, alpha:CGFloat = 1) -> UIColor {
        var color = UIColor()
        switch hex {
        case "0":
            color = UIColor(red: 0, green: 0, blue: 0, alpha: alpha)
        case "1":
            color = UIColor(red: 1, green: 1, blue: 1, alpha: alpha)
        case "r":
            color = UIColor(red: 1, green: 0, blue: 0, alpha: alpha)
        case "g":
            color = UIColor(red: 0, green: 1, blue: 0, alpha: alpha)
        case "b":
            color = UIColor(red: 0, green: 0, blue: 1, alpha: alpha)
        default:
            var hex = hex.remove("#")
            if hex.count == 3{
                hex = hex[0]*2+hex[1]*2+hex[2]*2
            }else if hex.count == 2{
                hex = hex*3
            }
            let scanner = Scanner(string: hex)
            var colorNum: UInt32 = 0
            if scanner.scanHexInt32(&colorNum) {
                let r = CGFloat((colorNum & 0xFF0000) >> 16) / 255.0
                let g = CGFloat((colorNum & 0x00FF00) >> 8) / 255.0
                let b = CGFloat(colorNum & 0x0000FF) / 255.0
                color = UIColor(red:r,green:g,blue:b,alpha:alpha)
            }else{
                color = UIColor(white: 1, alpha: alpha)
            }
        }
        return color
    }
    //=================================
    //you can make color from hex Value
    convenience  init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
extension UIImageView{
    var rmImage:RMImage?{
        set{
            if newValue == nil{
                self.image = nil
            }else{
                self.image = UIImage(cgImage: newValue!.cgImage!)
            }
        }
        get{
            if self.image == nil {
                return nil
            }else{
                return RMImage(cgImage: self.image!.cgImage!)
            }
        }
    }
}
extension CGRect{
    var path:CGPath{
        return CGPath(rect: self, transform: nil)
    }
}
extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width: width, height: height)
    }
    var rect:CGRect{
        return CGRect(origin: .zero, size: self)
    }
}
extension CGPoint{
    init(_ x:CGFloat,_ y:CGFloat) {
        self.init(x: x, y: y)
    }
}
extension UIImage {
    func scaled(toSize size:CGSize)->UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
    func scaled(toFitSize size:CGSize)->UIImage{
        let aspect = self.size.width / self.size.height;
        if size.width/aspect <= size.height{
            return self.scaled(toSize: sizeMake(size.width,size.width/aspect))
        }else{
            return self.scaled(toSize: sizeMake(size.height*aspect, size.height))
        }
    }
    
    var string:String{
        return self.jpgData.base64EncodedString(options: .lineLength64Characters)
    }
    var pngData:Data{
        return UIImagePNGRepresentation(self)!
    }
    var jpgData:Data{
        return UIImageJPEGRepresentation(self, 1)!
    }
    func saveToPhotoAlbum(){
        UIImageWriteToSavedPhotosAlbum(self, nil, nil, nil)
    }
    func getPixelColor(atPosition position: CGPoint) -> UIColor {
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(position.y)) + Int(position.x)) * 4
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    func masked(byImage maskImage:UIImage)->UIImage{
        let maskRef = maskImage.cgImage!
        let mask = CGImage(
            maskWidth: maskRef.width,
            height: maskRef.height,
            bitsPerComponent: maskRef.bitsPerComponent,
            bitsPerPixel: maskRef.bitsPerPixel,
            bytesPerRow: maskRef.bytesPerRow,
            provider: maskRef.dataProvider!,
            decode: nil,
            shouldInterpolate: false
            )!
        let maskedImageRef = self.cgImage!.masking(mask)!
        let maskedImage = UIImage(cgImage: maskedImageRef)
        
        return maskedImage
    }
    func resize(to size: CGSize) -> UIImage {
        let widthRatio = size.width / self.size.width
        let heightRatio = size.height / self.size.height
        let ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio
        let resizedSize = CGSize(width: (self.size.width * ratio), height: (self.size.height * ratio))
        UIGraphicsBeginImageContext(resizedSize)
        draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    func resizeImage(_ ratio: CGFloat) -> UIImage {
        let resizedSize = CGSize(width: Int(self.size.width * ratio), height: Int(self.size.height * ratio))
        UIGraphicsBeginImageContext(resizedSize)
        draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}
extension UIScreen{
    var width:CGFloat{
        return UIScreen.main.bounds.size.width
    }
    var height:CGFloat{
        return UIScreen.main.bounds.size.height
    }
    var size:CGSize{
        return UIScreen.main.bounds.size
    }
    var frame:CGRect{
        return UIScreen.main.bounds
    }
    var currentViewController:UIViewController? {
        var tc = application.keyWindow?.rootViewController
        if tc == nil{
            return nil
        }
        while ((tc!.presentedViewController) != nil) {
            tc = tc!.presentedViewController
        }
        return tc!
    }
}
extension DispatchQueue {
    class func mainSyncSafe(execute work: () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }
}
extension CFRange{
    static var zero:CFRange{
        return CFRangeMake(0, 0)
    }
}























