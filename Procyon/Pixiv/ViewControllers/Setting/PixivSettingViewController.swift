import UIKit

class PixivSettingViewController: ADSettingViewBaseController {
    override func setSetting() {
        title = "Pixiv"
        themeColor = ProcyonSystem.mainColor
        tableData = [
            SectionData(
                title: "general_setting".l(),
                cells: [
                    CellData(title: "dont_show_r18".l(), icon: "warning", identifier: "show-R18"),
                    CellData(title: "dont_show_r18_on_cellular".l(), icon: "signal_cellular_off", identifier: "NshowR18on3G"),
                    CellData(title: "block_tag".l(), icon: "block", identifier: "block-tags"),
                    CellData(title: "block_user".l(), icon: "pan_tool", identifier: "block-user")
                ]
            ),
            SectionData(
                title: "pixiv_account_setting".l(),
                cells: [CellData(title: "pixiv_account_setting".l(), icon: "account_circle", identifier: "account_setting"),]
            )
        ]
        if !PixivSystem.isPremium{
            tableData[1].cells.append(
                CellData(title: "resister_pixiv_premium".l(), icon: "local_parking", identifier: "register_pixiv_premium")
            )
        }
    }
    override func setCell(data: CellData, cell: ADSettingViewTableViewCell) -> UITableViewCell {
        switch data.identifier {
        case "show-R18":
            cell.showSwitch = true
            cell.identifier = "Nshow_r18"
        case "NshowR18on3G":
            cell.showSwitch = true
        default:
            cell.showAccessory = true
        }
        return cell
    }
    override func cellTapped(cell: ADSettingViewTableViewCell?, identifier: String) {
        switch identifier {
        case "block-tags":
            self.go(to: PixivTagOffViewController())
        case "block-user":
            self.go(to: PixivUserOffViewController())
        case "account_setting":
            self.go(to: PixivAccountWebViewController(),usePush: false)
        case "register_pixiv_premium":
            PixivSystem.showPremiumAlert()
        default:
            break
        }
    }
}















