import UIKit

class System: RMAppDelegate{
    
    lazy var passWindow:ProcyonPassCodeWindow = ProcyonPassCodeWindow()
    
    func appLuanch() {
        ProcyonSystem.mode = .procyon
        
        runInNextLoop {
            if info.boolValue(forKey: "enable-pass-code") && info.string(forKey: "procyon-pass-code") != nil{self.passWindow.show()}
            if info.string(forKey: "procyon-pass-code")?.isEmpty ?? true{info.set(false, forKey: "enable-pass-code")}
        }
        info.default = [
            "save-data-connection":true,
            "on-wifi-load-data":true,
            "enable-search-history":true,
            "novel_font_size":14,
            "pixiv-default-account-index":-1
        ]
        
        UIAppearance.setup()
        ProcyonSystem.accounts = info.structArray(type: ProcyonAccountData.self, forKey: "procyon_account_datas")
        application.isIdleTimerDisabled = true
        UIAppearance.useShadowLevel = !info.boolValue(forKey: "use_light_mode")
        device.useVibrate = info.boolValue(forKey: "vibrate")
        
        if !ProcyonSystem.accounts.isEmpty{
            "http://yukibochi.boo.jp/procyon/notification.json".request.getJson{json in
                if json["has_notice"].boolValue && !info.boolValue(forKey: json["id"].stringValue){
                    info.set(true, forKey: json["id"].stringValue)
                    let data = json["notice_data"]
                    let dialog = ADDialog()
                    dialog.title = data["title"].stringValue
                    dialog.message = data["message"].stringValue
                    
                    if let request = data["url"].stringValue.request.rawRequest{
                        let webView = UIWebView()
                        webView.loadRequest(request)
                        webView.height = 200
                        dialog.setCustomView(webView)
                    }
                    dialog.addOKButton()
                    dialog.show()
                }
            }
            if info.contains("last_login_account"){
                ProcyonSystem.accounts.map{a in
                    if a == info.struct(type: ProcyonAccountData.self, forKey: "last_login_account"){PixivSystem.resetAccountData(a)}
                }
                if PixivSystem.accountData == nil{
                    PixivSystem.resetAccountData(ProcyonSystem.accounts.index(0)!)
                }
            }else{
                PixivSystem.resetAccountData(ProcyonSystem.accounts.index(0)!)
            }
            PixivSystem.mode = PixivMode(rawValue: info.stringValue(forKey: "pixiv_last_mdoe")) ?? .illusts
            switch PixivSystem.mode{
            case .illusts, .private: system.mainWindow.rootViewController = PixivMainViewController.instance()
            default : system.mainWindow.rootViewController = PixivNovelMainViewController.instance()
            }
            PixivSystem.getLoginData{_ in
                pixiv.getAppInfo{json in
                    let pixivInfo = json["application_info"]
                    if pixivInfo["update_required"].boolValue && !info.boolValue(forKey: pixivInfo["notice_id"].stringValue){
                        ADDialog.current?.close()
                        let dialog = ADDialog()
                        dialog.title = "エラーの危険性"
                        dialog.message = "Pixiv公式アプリで強制アップデートが行われました。\nAPI変更が行われた可能性があります。不具合が発生した場合\n設定>お問い合わせ\nから開発者への連絡を行って下さい。"
                        dialog.addButton(title: "never_show_again".l()) {info.set(true, forKey: pixivInfo["notice_id"].stringValue)}
                        dialog.addOKButton()
                        dialog.show()
                    }
                }
            }
            run(after: 1){
                if info.count(count: 100, forKey: "procyon_share_dialog") && !ProcyonSystem.shareEnd{
                    let dialog = ADDialog()
                    dialog.title = "please_share_procyon".l()
                    dialog.message = "share_procyon_description".l()
                    dialog.addButton(title: "share".l()){
                        ProcyonSystem.shareEnd = true
                        RMShare.show(text: "share_procyon_text".l(),url: "https://appsto.re/jp/2wvNdb.i".url,type: .share)
                    }
                    dialog.addButton(title: "never_show_again".l())
                    dialog.show()
                }
            }
        }
        else{
            if !info.boolValue(forKey: "first_initial_end"){
                system.mainWindow.rootViewController = ProcyonFirstAnimationViewController()
            }else{
                system.mainWindow.rootViewController = ProcyonFirstNoAccountsViewController()
            }
        }
    }
    func appOpenURL(url:URL) {
        if url.scheme ?? "" == "procyon"{
            let paths = (url.absoluteString.split("://").index(1) ?? "").split("/")
            PixivSystem.UrlType = PixivMode(rawValue: paths.index(0) ?? "") ?? .illusts
            PixivSystem.UrlID = (paths.last ?? "").int ?? -1
            PixivSystem.UrlCallFin = false
            notificationCenter.post(name: Notification.Name(rawValue: "notificationImageURL"), object: nil)
        }
    }
    func appOpen() {
        
    }
    func appClose() {
        if info.boolValue(forKey: "enable-pass-code") && info.string(forKey: "procyon-pass-code") != ""{
            passWindow.show()
        }
    }
}










