import  UIKit

class PixivAccountSettingViewController: ADSettingViewBaseController {
    override func setSetting() {
        title = "アカウント設定"
        tableData = [
            SectionData(
                title: "setting".l(),
                cells:[
                    CellData(title: "ユーザー設定", icon: "settings", identifier: "account_setting")
                ]
            ),
            SectionData(
                title: "",
                cells:[
                    CellData(title: "アカウントを切り替える", icon: "account_box", identifier: "change_account")
                ]
            )
        ]
    }
    override func setCell(data: CellData, cell: ADSettingViewTableViewCell) -> UITableViewCell {
        switch data.identifier {
        case "change_account":
            cell.showAccessory = true
        default:
            break
        }
        return cell
    }
    override func cellTapped(cell:ADSettingViewTableViewCell,identifier:String){
        switch identifier {
        case "account_setting":
           break// self.go(to: PixivAccountWebViewController(),usePush: false)
        case "change_account":
            self.go(to: PixivAccountChangeViewController())
        default:
            break
        }
    }
    override func setUISetting() {
        showCloseButton = true
    }
    class func instance()->UIViewController{
        return UIStoryboard(name: "PixivAccountMain", bundle: nil).instantiateInitialViewController()!
    }
}
