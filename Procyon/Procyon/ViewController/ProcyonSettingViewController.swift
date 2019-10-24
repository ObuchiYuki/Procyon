import UIKit

class ProcyonSettingViewController:ADSettingViewBaseController{
    override func setSetting() {
        themeColor = ProcyonSystem.mainColor
        showCloseButton = true
        
        tableData = [
            SectionData(
                title: "Pixiv",
                cells: [
                    CellData(title: "Pixiv", icon: "P", identifier: "pixiv")
                ]
            ),
            SectionData(
                title: "account".l(),
                cells: [
                    CellData(title: "account".l(), icon: "account_circle", identifier: "account_settings")
                ]
            ),
            SectionData(
                title: "system".l(),
                cells: [
                    CellData(title: "use_light_mode".l(), icon: "toys", identifier: "use_light_mode"),
                    CellData(title: "remove_cache".l(), icon: "delete", identifier: "remove-cache"),
                    CellData(title: "enable_vibration".l(), icon: "vibration", identifier: "vibrate")
                ]
            ),
            SectionData(
                title: "security".l(),
                cells: [
                    CellData(title: "enable_passcode".l(), icon: "lock", identifier: "enable-pass-code")
                ]
            ),
            SectionData(
                title: "support".l(),
                cells: [
                    CellData(title: "information".l(), icon: "info", identifier: "info"),
                    CellData(title: "contact_us".l(), icon: "email", identifier: "mail"),
                    CellData(title: "share".l(), icon: "share", identifier: "share")
                ]
            )
        ]
        if !ProcyonSystem.isPremium{
            tableData.insert(
                SectionData(
                    title: "premium".l(),
                    cells: [
                        CellData(title: "purchase_album".l(), icon: "store", identifier: "buy_procyon_premium"),
                        CellData(title: "restore".l(), icon: "restore", identifier: "restore_procyon_premium")
                    ]
                ),
                at: 0
            )
        }
    }
    override func setCell(data: CellData, cell: ADSettingViewTableViewCell) -> UITableViewCell {
        switch data.identifier {
        case "pixiv","account_settings":
            cell.showAccessory = true
        case "enable-pass-code","hide-home-button",
             "enable-auto-sleep","save-data-connection",
             "on-wifi-load-data","vibrate","use_light_mode":
            cell.showSwitch = true
        default:
            break
        }
        return cell
    }
    override func cellTapped(cell: ADSettingViewTableViewCell, identifier: String) {
        switch identifier {
        case "use_light_mode":
            let dialog = ADDialog()
            dialog.title = "Alert"
            dialog.message = "この設定は次回起動時から有効になります。"
            dialog.addOKButton ()
            dialog.show()
        case "account_settings":
            self.go(to: ProcyonAccountEditViewController())
        case "share":
            let dialog = ADDialog()
            dialog.title = "please_share_procyon".l()
            dialog.message = "share_procyon_description".l()
            dialog.addButton(title: "share".l()){
                ProcyonSystem.shareEnd = true
                RMShare.show(text: "share_procyon_text".l(),url: "https://appsto.re/jp/2wvNdb.i".url, type: .share)
            }
            dialog.addCancelButton()
            dialog.show()
        case "buy_procyon_premium":
            if PixivSystem.tmpAlbumEnable{ADDialog.show(title: "Dialog",message: "開発モードです。購入は必要ありません。");return}
            ProcyonSystem.buyPremiun {
                self.tableView.beginUpdates()
                self.tableData.remove(at: 0)
                self.tableView.deleteSections([0], with: .fade)
                self.tableView.endUpdates()
            }
        case "restore_procyon_premium":
            if PixivSystem.tmpAlbumEnable{ADDialog.show(title: "Dialog",message: "開発モードです。復元は必要ありません。");return}
            store.restore(id: "procyon_premium", completion: {success in
                if success{
                    ADDialog.show(title: "done".l(),message: "restore_was_succeeded".l())
                    self.tableView.beginUpdates()
                    self.tableData.remove(at: 0)
                    self.tableView.deleteSections([0], with: .fade)
                    self.tableView.endUpdates()
                }else{
                    ADDialog.show(title: "error".l(),message: "restore_was_failed".l())
                }
            })
        case "remove-cache":
            let dialog = ADDialog()
            dialog.title = "remove?".l()
            dialog.addOKButton {
                let snack = ADSnackbar()
                snack.duration = -1
                snack.title = "removing".l()
                snack.show()
                asyncQ {
                    file.rm("tmp.pdf", atPath: .tmp)
                    file.rm("ugoiraData/", atPath: .document)
                    file.rm("yuki.pixiloid/", atPath: .cache)
                    mainQ {cache.removeAll{ADSnackbar.show("removed".l());snack.close()}}
                }
            }
            dialog.addCancelButton()
            dialog.show()
        case "vibrate":
            device.useVibrate = cell.switchOn
            device.shortVibrate()
        case "enable-pass-code":
            let viewCon = ADSetPassViewController.instance
            viewCon.chackText = info.string(forKey: "procyon-pass-code") ?? ""
            viewCon.useForCancel = !cell.switchOn
            viewCon.endSettingPass = {type in
                switch type{
                case .cancel:
                    cell.SettingSwitch.on = !cell.switchOn
                case let .end(value):
                    info.set(value, forKey: "procyon-pass-code")
                }
            }
            self.go(to: viewCon.navigationController!,usePush: false)
        case "info":
            let dialog = ADDialog()
            dialog.title = "information".l()
            dialog.message = "Procyon ver. \(ProcyonSystem.version)\nDeveloped by ARANO YUME\nKorean translation by kyono\n© 2016 \nProcyonは\nPixivの非公式クライアントアプリであり、Pixivが配布、作成しているアプリではありません。＠DreamCreators"
            dialog.addOKButton()
            dialog.addButton(title: "Twitter"){
                application.openURL("https://twitter.com/HihuSnow".url!)
            }
            dialog.show()
        case "mail":
            RMMailSender.send(self, to: "Procyoncontact@gmail.com", title: "お問い合わせ", message:
                "Procyon ver. \(ProcyonSystem.version) \n\(device.modelType.rawValue) (\(device.version))\n開発者が今年受験のためすぐに対応できない場合がございます。よろしくお願いします。"
            )
        case "pixiv":
            go(to: PixivSettingViewController())
        case "copy-prefix-data":
            var dataStr = ""
            let dict = info.dict
            for key in dict.keys{
                let value = dict[key]
                if key != "account"{
                    if key.contains("History"){
                        let jsonArr = value as! [Data]
                        for data in jsonArr{
                            dataStr+="=========================\n"
                            dataStr+="history\n"
                            dataStr+="\(JSON(data: data))\n"
                        }
                    }else{
                        dataStr+="\(key): \(value)\n"
                    }
                }
            }
            clipBoard.text = dataStr
            
            let dialog = ADDialog()
            dialog.title = "done".l()
            dialog.addOKButton()
            dialog.show()
            
        default:
            break
        }
    }
    class func instance()->UIViewController{return UINavigationController(rootViewController: self.init())}
}






