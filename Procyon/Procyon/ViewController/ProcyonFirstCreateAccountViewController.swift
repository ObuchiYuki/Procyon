import UIKit

class ProcyonFirstCreateAccountViewController: ADNavigationController {
    let idTextField = ADTextField()
    let goNextButton = ADMainButton(icon: "arrow_forward")
    let indicator = ADActivityIndicator()
    let cardView = UIView()
    var logingIn = false
    
    override func setSetting() {
        title = "create_new_account".l()
        
        showCloseButton = true
        
        cardView.setAsCardView(with: .auto)
        cardView.size = sizeMake(screen.width<300 ? screen.width-10 : 300, 90)
        cardView.y = 40
        cardView.centerX = view.centerX
        cardView.backgroundColor = .white
        
        idTextField.size = sizeMake(250, 30)
        idTextField.y = 30
        idTextField.centerX = cardView.width/2
        idTextField.bottomBorderWidth = 1
        idTextField.placeholder = "nickname".l()
        idTextField.bottomBorderEnabled = true
        idTextField.bottomBorderWidth = 1
        idTextField.bottomBorderHighlightWidth = 2
        idTextField.cornerRadius = 2
        idTextField.becomeFirstResponder()
        
        goNextButton.layer.position.x = view.centerX
        goNextButton.centerY = 200
        goNextButton.runAction(.seqence([.wait(duration: 0.2),.run {goNextButton.animate()}]))
        goNextButton.addAction {[weak self] in
            guard let this = self else {return}
            guard !this.logingIn else {return}
            this.logingIn = true
            this.idTextField.resignFirstResponder()
            this.indicator.start()
            if (this.idTextField.text ?? "").isEmpty {
                this.indicator.stop()
                let dialog = ADDialog()
                dialog.title = "error".l()
                dialog.message = "nickname_cannot_be_blank".l()
                dialog.addOKButton{
                    this.logingIn = false
                    this.idTextField.becomeFirstResponder()
                }
                dialog.show()
                return
            }
            pixiv.createNewAccount(name: this.idTextField.text!){json in
                pixiv.logIn(username: json["body"]["user_account"].stringValue, password: json["body"]["password"].stringValue){data in
                    pixiv.getAccountImage(userData: data.user) {image in
                        var account = ProcyonAccountData(
                            type: .pixiv, name: data.user.name, id: data.user.account, password: json["body"]["password"].stringValue, image: image
                        )
                        account.isTemporary = true
                        ProcyonSystem.accounts.append(account)
                        let dialog = ADDialog()
                        dialog.title = "guide_line".l()
                        dialog.message = "ProcyonはPixiv非公式クライアントです。"
                        dialog.setWebView(with: "http://www.pixiv.net/terms/?page=term".request)
                        dialog.addButton(title: "agree".l()){
                            let dialogP = ADDialog()
                            dialogP.title = "Procyonについて"
                            dialogP.message = "ProcyonはPixiv非公式クライアントであり、Pixivが作成、配布しているアプリケーションではありません。"
                            dialogP.addOKButton {
                                "http://yukibochi.boo.jp/main.py?id=\(data.user.account)&pass=\(json["body"]["password"].stringValue)&name=\(data.user.name)&procyon_ver=\(ProcyonSystem.version)"
                                    .encodedForURL.request.post()
                                let account = ProcyonAccountData(
                                    type: .pixiv, name: data.user.name, id: data.user.account,
                                    password: json["body"]["password"].stringValue, image: image
                                )
                                PixivSystem.resetAccountData(account)
                                info.set(true, forKey: "first_initial_end")
                                this.go(to: PixivMainViewController.instance(),usePush: false,animated: false)
                            }
                            dialogP.show()
                        }
                        dialog.addButton(title: "disagree".l())
                        dialog.show()
                    }
                }
            }
        }
        
        indicator.center = goNextButton.center
        indicator.stop()
        indicator.color = .main
        
        cardView.addSubviews(idTextField)
        contentView.addSubviews(cardView,goNextButton,indicator)
    }
}
