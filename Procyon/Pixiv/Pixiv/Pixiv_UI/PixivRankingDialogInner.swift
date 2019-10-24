import UIKit

class PixivRankingDialogInner: RMView {
    var date:String{
        if let date = _date{return date}
        else{return Date(timeIntervalSinceNow: -2*60*60*24).string(for: "yyyy-MM-dd")}
    }
    var itemType = ItemType.illust
    var type = PixivRankingType.day
    enum ItemType {case illust,novel}
    private var _date:String? = nil
    private let datePicker = UIDatePicker()
    private let typePiker = ADButton()
    private var typeArray:[String]{
        return itemType == .illust ? illusTypeArray : novelTypeArray
    }
    private let illusTypeArray = [
        "ranking_daily".l(),"ranking_weekly".l(),"ranking_monthly".l(),
        "ranking_for_man".l(),"ranking_for_woman".l(),"ranking_original".l(),
        "ranking_rookie".l(),"ranking_r18_daily".l(),"ranking_r18_weekly".l(),
        "ranking_r18_for_man".l(),"ranking_r18_for_woman".l()
    ]
    private let novelTypeArray = [
        "ranking_daily".l(),"ranking_weekly".l(),"ranking_monthly".l(),
        "ranking_for_man".l(),"ranking_for_woman".l(),"ranking_rookie".l()
    ]
    
    func onDidChangeDate(sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self._date = dateFormatter.string(from: sender.date)
    }
    
    override func setup() {
        super.setup()
        self.height = 190
        
        typePiker.size = sizeMake(260, 40)
        typePiker.title = "ranking_daily".l()
        typePiker.titleColor = .text
        typePiker.addAction {[weak self] in
            guard let this = self else {return}
            let menu = ADMenu()
            menu.iconArr = Array(repeating: "sort", count: this.typeArray.count)
            menu.titles = this.typeArray
            menu.maxShowCellCount = this.typeArray.count > 8 ? 8 : 6
            menu.indexAction = {index in
                this.typePiker.title = this.typeArray.index(index) ?? "ranking_daily".l()
                this.type = PixivRankingType(rawValue: index) ?? .day
            }
            menu.show()
            menu.windowLevel = UIWindowLevelAlert+1
        }
        datePicker.height = 150
        datePicker.width = 260
        datePicker.y = 40
        datePicker.timeZone = NSTimeZone.local
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date(string: "2012-09-10", for: "yyyy-MM-dd")
        datePicker.maximumDate = Date(timeIntervalSinceNow: -2*60*60*24)
        datePicker.backgroundColor = .clear
        datePicker.addTarget(self, action: #selector(PixivRankingDialogInner.onDidChangeDate), for: .valueChanged)
        
        addSubview(typePiker)
        addSubview(datePicker)
    }
}
