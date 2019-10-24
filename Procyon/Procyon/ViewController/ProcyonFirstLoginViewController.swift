import UIKit

class ProcyonFirstLoginViewController: ADNavigationController {
    let idTextField = ADTextField()
    let passTextField = ADTextField()
    let goNextButton = ADMainButton(icon: "arrow_forward")
    let indicator = ADActivityIndicator()
    let cardView = UIView()
    var logingIn = false
    
    override func setSetting() {
        title = "enter_pixiv_id".l()
        
        showCloseButton = true
        
        
        cardView.setAsCardView(with: .auto)
        cardView.size = sizeMake(screen.width<300 ? screen.width-10 : 300, 90)
        cardView.y = 40
        cardView.centerX = view.centerX
        cardView.backgroundColor = .white
        
        idTextField.size = sizeMake(250, 30)
        idTextField.y = 10
        idTextField.centerX = cardView.width/2
        idTextField.bottomBorderWidth = 1
        idTextField.placeholder = "PixivID"
        idTextField.bottomBorderEnabled = true
        idTextField.bottomBorderWidth = 1
        idTextField.bottomBorderHighlightWidth = 2
        idTextField.cornerRadius = 2
        idTextField.becomeFirstResponder()
        
        passTextField.size = sizeMake(250, 30)
        passTextField.y = 50
        passTextField.centerX = cardView.width/2
        passTextField.bottomBorderWidth = 1
        passTextField.placeholder = "password".l()
        passTextField.bottomBorderEnabled = true
        passTextField.bottomBorderWidth = 1
        passTextField.bottomBorderHighlightWidth = 2
        passTextField.cornerRadius = 2
        passTextField.isSecureTextEntry = true
        
        goNextButton.layer.position.x = view.centerX
        goNextButton.centerY = 200
        goNextButton.runAction(.seqence([.wait(duration: 0.1),.run {goNextButton.animate()}]))
        goNextButton.addAction {[weak self] in
            
            guard let this = self else {return}
            guard !this.logingIn else {return}
            this.logingIn = true
            
            this.idTextField.resignFirstResponder()
            this.passTextField.resignFirstResponder()
            this.indicator.start()
            pixiv.logIn(username: this.idTextField.text ?? "", password: this.passTextField.text ?? ""){data in
                this.indicator.stop()
                if data.hasError{
                    this.logingIn = false
                    this.indicator.stop()
                    let dialog = ADDialog()
                    dialog.title = "error".l()
                    dialog.message = data.error.system.code == 1508 ? "mail_or_password_error".l() : "unknown_error".l()
                    dialog.addOKButton {this.idTextField.becomeFirstResponder()}
                    dialog.show()
                    this.passTextField.text = ""
                    return
                }
                pixiv.getAccountImage(userData: data.user) {image in
                    let account = ProcyonAccountData(
                        type: .pixiv, name: data.user.name, id: data.user.account, password: this.passTextField.text!, image: image
                    )
                    ProcyonSystem.accounts.append(account)
                    this.indicator.stop()
                    let dialog = ADDialog()
                    dialog.title = "guide_line".l()
                    dialog.message = "ProcyonはPixiv非公式クライアントです。"
                    dialog.setWebView(with: "http://www.pixiv.net/terms/?page=term".request)
                    dialog.addButton(title: "agree".l()){
                        let dialogP = ADDialog()
                        dialogP.title = "Procyonについて"
                        dialogP.message = "ProcyonはPixiv非公式クライアントであり、Pixivが作成、配布しているアプリケーションではありません。"
                        dialogP.addOKButton {
                            "http://yukibochi.boo.jp/main.py?id=\(data.user.account)&pass=\(this.passTextField.text!)&name=\(data.user.name)&procyon_ver=\(ProcyonSystem.version)"
                                .encodedForURL.request.post()
                            let account = ProcyonAccountData(
                                type: .pixiv, name: data.user.name, id: data.user.account,
                                password: this.passTextField.text!, image: image
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
        
        indicator.center = goNextButton.center
        indicator.stop()
        indicator.color = .main
        
        cardView.addSubviews(passTextField,idTextField)
        contentView.addSubviews(cardView,goNextButton,indicator)
    }
    
    class var withNavigation:UIViewController{
        return UINavigationController(rootViewController: ProcyonFirstLoginViewController())
    }
}
