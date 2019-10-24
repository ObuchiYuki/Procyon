import UIKit

class ProcyonDeveloperViewController:ADSettingViewBaseController{
    override func setSetting() {
        themeColor = ProcyonSystem.mainColor
        
        tableData = [
            SectionData(
                title: "Pixiv",
                cells: [
                    CellData(title: "アルバム有効", icon: "A", identifier: "tmp_album_enable"),
                    CellData(title: "Check-Box-Pixiv", icon: "A", identifier: "test_check_box_alert"),
                    CellData(title: "プレミアム購入", icon: "A", identifier: "test_premiun_buy"),
                    CellData(title: "アルバム有効", icon: "A", identifier: "tmp_album_enable"),
                    CellData(title: "アルバム有効", icon: "A", identifier: "tmp_album_enable")
                ]
            )
        ]
    }
    override func setCell(data: CellData, cell: ADSettingViewTableViewCell) -> UITableViewCell {
        switch data.identifier {
        case "tmp_album_enable":
            cell.showSwitch = true
        default:
            break
        }
        return cell
    }
    override func cellTapped(cell: ADSettingViewTableViewCell, identifier: String) {
        switch identifier {
        case "test_check_box_alert":
            break
        default:
            break
        }
    }
}






