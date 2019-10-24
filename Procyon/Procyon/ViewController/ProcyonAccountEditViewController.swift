import UIKit
import WebKit

class ProcyonAccountEditViewController: ADNavigationController {
    let tableView = UITableView()
    let addButton = ADMainButton(icon: "add")
    var withAction = true
    
    func addContent(_ accountData:ProcyonAccountData){
        tableView.beginUpdates()
        ProcyonSystem.accounts.insert(accountData, at: 0)
        tableView.insertRows(at: [.zero], with: .automatic)
        tableView.endUpdates()
    }
    
    override func setSetting() {
        title = "edit_account".l()
        showCloseButton = true
        themeColor = ProcyonSystem.mainColor
    }
    override func setUISetting() {
        tableView.register(AccountCell.self, forCellReuseIdentifier: "accountCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 90
        tableView.size = self.contentSize
        
        addButton.addAction {
            let dialog = ADDialog()
            dialog.title = "add_account".l()
            dialog.setTableView(titles: ["login_with_created_account".l(),"create_new_account".l()], style: .select, actions:
            [
                {
                    let dialog1 = ADDialog()
                    dialog1.title = "enter_pixiv_id".l()
                    dialog1.textFieldPlaceHolder = "PixivID"
                    dialog1.textField.keyboardType = .emailAddress
                    dialog1.addOKButton{
                        let dialog3 = ADDialog()
                        dialog3.title = "enter_password".l()
                        dialog3.textFieldPlaceHolder = "password".l()
                        dialog3.textField.isSecureTextEntry = true
                        dialog3.addOKButton{
                            let dialog4 = ADDialog()
                            dialog4.setIndicator(title: "logging_in".l())
                            dialog4.show()
                            pixiv.logIn(username: dialog1.textFieldText, password: dialog3.textFieldText){data in
                                if data.hasError{
                                    dialog4.close()
                                    ADDialog.error(message: "mail_or_password_error".l())
                                    
                                    return
                                }
                                pixiv.getAccountImage(userData: data.user){image in
                                    dialog4.close()
                                    if data.hasError {
                                        ADDialog.error(message: data.error.message)
                                    }else{
                                        let dialog = ADDialog()
                                        dialog.title = "guide_line".l()
                                        dialog.setWebView(with: "http://www.pixiv.net/terms/?page=term".request )
                                        dialog.addButton(title: "agree".l()){
                                            let dialogP = ADDialog()
                                            dialogP.title = "Procyonについて"
                                            dialogP.message = "ProcyonはPixiv非公式クライアントであり、Pixivが作成、配布しているアプリケーションではありません。"
                                            dialogP.addOKButton {
                                                "http://yukibochi.boo.jp/main.py?id=\(dialog1.textFieldText)&pass=\(dialog3.textFieldText)&name=\(data.user.name)&procyon_ver=\(ProcyonSystem.version)"
                                                    .encodedForURL.request.post()
                                                let account = ProcyonAccountData(
                                                    type: .pixiv, name: data.user.name, id: data.user.account,
                                                    password: dialog3.textFieldText, image: image
                                                )
                                                self.addContent(account)
                                                ADSnackbar.show("done".l())
                                            }
                                            dialogP.show()
                                        }
                                        dialog.addButton(title: "disagree".l())
                                        dialog.show()
                                    }
                                }
                            }
                        }
                        dialog3.addCancelButton()
                        dialog3.show()
                    }
                    dialog1.addCancelButton()
                    dialog1.show()
                },
                {
                    let dialog1 = ADDialog()
                    dialog1.title = "enter_nickname".l()
                    dialog1.textFieldPlaceHolder = "nickname".l()
                    dialog1.addOKButton {
                        if !(dialog1.textFieldText).isEmpty{
                            let dialog2 = ADDialog()
                            dialog2.setIndicator(title: "creating_account".l())
                            dialog2.show()
                            pixiv.createNewAccount(name: dialog1.textFieldText){json in
                                let data = pixivCreatedAccountData(json: json)
                                if data.error{ADDialog.error(message: data.message);return}
                                pixiv.logIn(username: data.body.userAccount, password: data.body.password){ldata in
                                    pixiv.getAccountImage(userData: ldata.user){image in
                                        var account = ProcyonAccountData(
                                            type: .pixiv, name: ldata.user.name, id: ldata.user.account, password: data.body.password, image: image
                                        )
                                        account.isTemporary = true
                                        dialog2.close()
                                        "http://yukibochi.boo.jp/main.py?id=\(dialog1.textFieldText)&pass=\(data.body.password)&name=\(ldata.user.name)&procyon_ver=\(ProcyonSystem.version)&other_data=Created_accouont"
                                            .encodedForURL.request.post()
                                        ADSnackbar.show("account_[name]_created".l(ldata.user.name))
                                        self.addContent(account)
                                    }
                                }
                            }
                        }else{
                            let dialog2 = ADDialog()
                            dialog2.title = "error".l()
                            dialog2.message = "nickname_cannot_be_blank".l()
                            dialog2.addOKButton()
                            dialog2.show()
                        }
                    }
                    dialog1.show()
                }
            ])
            dialog.addCancelButton()
            dialog.show()
        }
        
        addSubview(tableView)
        mainButton = addButton
    }
    override func setLoadControl() {
        tableView.reloadData()
    }
}
extension ProcyonAccountEditViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {return 1}
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return ProcyonSystem.accounts.count}
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountCell
        cell.accountData = ProcyonSystem.accounts.index(indexPath.row)
        cell.infoTip.removeAllActions()
        cell.infoTip.addAction {[weak self] in
            self?.go(to: ProcyonAccountSettingViewController(accountData: ProcyonSystem.accounts[indexPath.row],at: indexPath.row))
        }
        cell.infoTip.isHidden = !withAction
        return cell
    }
    class AccountCell: RMTableViewCell {
        var accountData:ProcyonAccountData? = nil{
            didSet{
                guard let accountData = accountData else {return}
                nameLabel.text = accountData.name
                subTextLabel.text = accountData.id
                accountIconView.image = accountData.image?.resize(to: sizeMake(30, 30)*2)
                switch accountData.type {
                case .pixiv: typeIconView.image = #imageLiteral(resourceName: "PixivLaunchImage")
                }
            }
        }
        let cardView = ADCardView()
        let nameLabel = UILabel()
        let subTextLabel = UILabel()
        let typeIconView = UIImageView()
        let accountIconView = UIImageView()
        let infoTip = ADTip(icon: "info")
        
        override func setup() {
            super.setup()
            selectionStyle = .none
            separator.isHidden = true
   
            cardView.size = sizeMake(screen.width-10, 85)
            cardView.origin = pointMake(5, 2.5)
            
            typeIconView.size = sizeMake(60, 60)
            typeIconView.centerY = cardView.height/2
            typeIconView.x = 10
            
            accountIconView.size = sizeMake(30, 30)
            accountIconView.setAsCardView(with: .cornerd,.bordered)
            accountIconView.noCorner()
            accountIconView.clipsToBounds = true
            accountIconView.origin = pointMake(50, 43)
            
            nameLabel.size = sizeMake(200, 20)
            nameLabel.origin = pointMake(95, 26)
            nameLabel.textColor = .text
            nameLabel.font = Font.Roboto.font(13,style: .normal)
            
            subTextLabel.size = sizeMake(200, 20)
            subTextLabel.origin = pointMake(95, 49)
            subTextLabel.textColor = .subText
            subTextLabel.font = Font.Roboto.font(12)
            
            infoTip.titleColor = .subText
            infoTip.x = cardView.width-52
            infoTip.centerY = cardView.height/2
            
            
            cardView.addSubviews(typeIconView,nameLabel,subTextLabel,accountIconView,infoTip)
            addSubviews(cardView)
        }
    }
}
