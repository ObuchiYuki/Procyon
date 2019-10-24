import UIKit

class PixivSearchSettingViewController: ADSettingViewBaseController {
    var settingData:pixivWorkSearchSettingData! = nil
    var endBlock:(pixivWorkSearchSettingData)->() = {_ in}
    
    private var isEdited = false
    
    override func setSetting() {
        title = "illust_search_setting".l()
        
        tableData = [
            SectionData(
                title: "search_target".l(),
                cells: [CellData(title: "", icon: "merge_type", identifier: "search_target")]
            ),
            SectionData(
                title: "search_sort ()".l(),
                cells: [CellData(title: "", icon: "swap_vert", identifier: "search_sort")]
            ),
            SectionData(
                title: "duration".l(),
                cells: [CellData(title: "", icon: "access_time", identifier: "search_time")]
            )
        ]
    }
    override func setCell(data: CellData, cell: ADSettingViewTableViewCell) -> UITableViewCell {
        switch data.identifier {
        case "search_target":
            switch settingData.target {
            case .title_and_caption: cell.title = "title_and_caption".l()
            case .partial_match_for_tags: cell.title = "partial_match_for_tags".l()
            case .exact_match_for_tags: cell.title = "exact_match_for_tags".l()
            }
        case "search_sort":
            switch settingData.sort {
            case .date_desc: cell.title = "date_desc".l()
            case .date_asc: cell.title = "date_asc".l()
            case .popular_desc: cell.title = "popular_desc".l()
            }
        case "search_time":
            switch settingData.duration {
            case .all: cell.title = "all_duration".l()
            case .within_last_day: cell.title = "within_last_day".l()
            case .within_last_week: cell.title = "within_last_week".l()
            case .within_last_month: cell.title = "within_last_month".l()
            }
        default:
            break
        }
        cell.titleLabel.textColor = ADColor.Blue.P500
        return cell
    }
    func syncSerachOptions(){
        info.set(settingData.sort.rawValue, forKey: "pixiv_search_sort")
        info.set(settingData.target.rawValue, forKey: "pixiv_search_target")
        info.set(settingData.duration.rawValue, forKey: "pixiv_search_duration")
    }
    override func cellTapped(cell: ADSettingViewTableViewCell,identifier: String) {
        switch identifier {
        case "search_target":
            let menu = ADMenu()
            menu.iconArr = Array(repeating: "merge_type", count: 3)
            menu.titles = ["title_and_caption".l(),"partial_match_for_tags".l(),"exact_match_for_tags".l()]
            menu.indexAction = {i in
                self.settingData.target = [
                    PixivSearchTarget.title_and_caption,
                    PixivSearchTarget.partial_match_for_tags,
                    PixivSearchTarget.exact_match_for_tags
                ].index(i) ?? .partial_match_for_tags
                cell.titleLabel.text = menu.titles.index(i) ?? ""
            }
            menu.show()
        case "search_sort":
            let menu = ADMenu()
            menu.iconArr = Array(repeating: "swap_vert", count: 3)
            menu.titles = ["date_desc".l(),"date_asc".l(),"popular_desc".l()]
            menu.indexAction = {i in
                if info.first(forKey: "illust_popular_by_regular") && !PixivSystem.isPremium{
                    let dialog = ADDialog()
                    dialog.title = "人気順検索"
                    dialog.message = "一般会員の人気順検索は20件までです。"
                    dialog.addOKButton {}
                    dialog.show()
                }
                self.settingData.sort = [PixivSearchSort.date_desc,PixivSearchSort.date_asc,PixivSearchSort.popular_desc]
                    .index(i) ?? .date_desc
                
                cell.titleLabel.text = menu.titles.index(i) ?? ""
            }
            menu.show()
        case "search_time":
            let menu = ADMenu()
            menu.iconArr = Array(repeating: "access_time", count: 4)
            menu.titles = ["all_duration".l(),"within_last_day".l(),"within_last_week".l(),"within_last_month".l()]
            menu.indexAction = {i in
                self.settingData.duration = [
                    PixivSearchDuration.all,
                    PixivSearchDuration.within_last_day,
                    PixivSearchDuration.within_last_week,
                    PixivSearchDuration.within_last_month
                ].index(i) ?? .all
                cell.titleLabel.text = menu.titles.index(i) ?? ""
            }
            menu.show()
        default:
            break
        }
        self.isEdited = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        if isEdited {
            syncSerachOptions()
            endBlock(settingData)
        }
    }
    override func setUISetting() {
        if !PixivSystem.isPremium{
            let tip = ADTip(icon: "local_parking")
            tip.addAction {
                PixivSystem.showPremiumAlert()
            }
            addButtonRight(tip)
        }
        showSearchButton = false
        showMenuButton = false
        statusBarColor = .default
        themeColor = .hex("f0f0f0")
    }
}






