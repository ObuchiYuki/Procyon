import UIKit

class ProcyonAccountSettingViewController: ADSettingViewBaseController {
    var accountData:ProcyonAccountData
    var currentIndex:Int
    
    init(accountData:ProcyonAccountData,at index:Int){
        self.accountData = accountData
        currentIndex = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSetting() {
        themeColor = ProcyonSystem.mainColor
        showCloseButton = true
        title = self.accountData.name
        tableData = [
            SectionData(
                title: "account".l(),
                cells: [
                    CellData(title: "change_mail_address".l(), icon: "mail", identifier: "change-mail"),
                    CellData(title: "change_password".l(), icon: "lock", identifier: "change-pass")
                ]
            ),
            SectionData(
                title: "",
                cells: [
                    CellData(title: "remove_this_account".l(), icon: "delete", identifier: "delete-account")
                ]
            )
        ]
    }
    override func setCell(data: CellData, cell: ADSettingViewTableViewCell) -> UITableViewCell {
        switch data.identifier {
        case "delete-account":
            cell.titleLabel.textColor = .hex("FE2E2E")
        default:
            break
        }
        return cell
    }
    override func cellTapped(cell: ADSettingViewTableViewCell, identifier: String) {
        let dialog = ADDialog()
        dialog.title = "confirm".l()
        switch identifier {
        case "change-mail":
            dialog.title = "change_mail_address".l()
            dialog.textFieldPlaceHolder = "mail".l()
            dialog.textFieldText = accountData.id
            dialog.message = accountData.isTemporary ? "このアカウントはProcyonによって作成されたため。変更するとログインができなくなります。" : ""
            dialog.addOKButton{ProcyonSystem.accounts[self.currentIndex].id = dialog.textFieldText}
        case "change-pass":
            dialog.title = "change_password".l()
            dialog.textFieldPlaceHolder = "password".l()
            dialog.textFieldText = accountData.password
            dialog.message = accountData.isTemporary ? "このアカウントはProcyonによって作成されたため。変更するとログインができなくなります。" : ""
            dialog.addOKButton{ProcyonSystem.accounts[self.currentIndex].password = dialog.textFieldText}
        default:
            dialog.message = accountData.isTemporary ? "このアカウントはProcyonによって作成されたため。削除すると元に戻せません。削除の前に必ずIDとパスワードのバックアップを取ってください。" : "account_remove_alert".l()
            dialog.addOKButton{
                ProcyonSystem.accounts.remove(at: self.currentIndex)
                self.back()
            }
        }
        dialog.addCancelButton()
        dialog.show()
    }
}















