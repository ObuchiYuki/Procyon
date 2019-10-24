import UIKit

class PixivDrawerViewController: ADDrawerViewController{
    var accountView = AccountView()
    var isAccountViewEnable = false
    var fullUserData:pixivFullUserData? = nil
    
    func changeToAccountView(){
        if !isAccountViewEnable{
            isAccountViewEnable = true
            UIView.animate(withDuration: 0.2){self.tableView.y = screen.height}
            UIView.animate(withDuration: 0.4){self.headerView.actionButton.transform = CGAffineTransform(rotationAngle: π)}
            run(after: 0.2){UIView.animate(withDuration: 0.2){self.accountView.y = 160}}
        }else{
            isAccountViewEnable = false
            UIView.animate(withDuration: 0.2){self.accountView.y = screen.height}
            UIView.animate(withDuration: 0.4){self.headerView.actionButton.transform = CGAffineTransform(rotationAngle: 0)}
            run(after: 0.2){UIView.animate(withDuration: 0.2){self.tableView.y = 160}}
        }
    }
    
    override func setSetting(){
        
        drawerController?.didStateChange = {state in
            self.accountView.tableView.reloadData()
        }
        
        drawerController?.screenEdgePanGestureEnabled = false
        tableView.data = [
            TableView.SectionData(cells: [
                CellData(title: "account".l(), icon: "account_circle", action: {[weak self] in self?.changeToAccountView()})
            ]),
            TableView.SectionData(cells: [
                CellData(title: "illust".l(), icon: "photo", action: {
                    PixivSystem.mode = .illusts
                    self.go(PixivMainViewController.instance())
                }),
                CellData(title: "private_illust".l(), icon: "vpn_lock", action: {
                    PixivSystem.mode = .private
                    self.go(PixivMainViewController.instance())
                }),
                CellData(title: "novel".l(), icon: "book", action: {
                    PixivSystem.mode = .novels
                    self.go(PixivNovelMainViewController.instance())
                }),
                CellData(title: "private_novel".l(), icon: "vpn_lock", action: {
                    PixivSystem.mode = .privateNovel
                    self.go(PixivNovelMainViewController.instance())
                })
            ]),
            TableView.SectionData(cells: [
                CellData(title: "setting".l(), icon: "settings", action: {self.go(ProcyonSettingViewController.instance(),animated: true)}),
                CellData(title: "opne_url".l(), icon: "link", action: {
                    let dialog = ADDialog()
                    dialog.title = "enter_url".l()
                    dialog.textFieldText = clipBoard.text 
                    dialog.textFieldPlaceHolder = "url"
                    dialog.addOKButton {
                        let url = dialog.textFieldText
                        if let m = Re.search("(.*)illust_id=([0-9]+)", url){
                            self.drawerController?.close()
                            run(after: 0.25){application.openURL("procyon://illusts/\(m.group(2))".url!)}
                        }else if let m = Re.search("(.*)novel/show.php\\?id=([0-9]+)", url){
                            self.drawerController?.close()
                            run(after: 0.25){application.openURL("procyon://novels/\(m.group(2))".url!)}
                        }else if let m = Re.search("(.*)[member|member_illust]\\.php\\?id=([0-9]+)", url){
                            self.drawerController?.close()
                            run(after: 0.25){application.openURL("procyon://users/\(m.group(2))".url!)}
                        }else{
                            ADDialog.error(message: "URLを解析できませんでした。")
                        }
                    }
                    dialog.addCancelButton()
                    dialog.show()
                })
            ])
        ]
        
        accountView.y = screen.height
        accountView.addAccountTip.addAction {[weak self] in self?.go(ProcyonAccountEditViewController(),animated: true)}
        accountView.indexAction = {i in
            PixivSystem.resetAccountData(ProcyonSystem.accounts[i])
            switch PixivSystem.mode {
            case .illusts , .private: self.go(PixivMainViewController.instance())
            case .novels,.privateNovel: self.go(PixivNovelMainViewController.instance())
            default: break
            }
        }
        
        view.addSubview(accountView)
        
        PixivSystem.getLoginData{data in
            self.headerView.userNameLabel.text = data.user.name
            self.headerView.userIDLabel.text = data.user.account
            pixiv.getAccountImage(userData: data.user){image in self.headerView.userImageView.image=image.resize(to: sizeMake(65, 65)*2)}
            
            pixiv.getUserData(userID: data.user.id, completion: {json in
                self.fullUserData = pixivFullUserData(json: json)
                let request = self.fullUserData!.profile.backgroundImageUrl.request
                request.referer = pixiv.referer
                request.getImage{image in self.headerView.imageView.image = image}
            })
            
            self.headerView.actionButton.addAction {[weak self] in self?.changeToAccountView()}
        }
    }
    class AccountView: RMView ,UITableViewDelegate, UITableViewDataSource{
        let tableView = UITableView()
        let addAccountTip = ADTip(icon: "settings")
        var indexAction:intBlock = {_ in}
        override func setup() {
            super.setup()
            self.size = sizeMake(260, screen.height-160)
            tableView.size = self.size
            tableView.register(CardCell.self, forCellReuseIdentifier: "cardCell")
            tableView.rowHeight = 70
            tableView.dataSource = self
            tableView.delegate = self
            
            addAccountTip.bottomY = screen.height-160
            addAccountTip.titleColor = .subText
            
            addSubview(tableView)
            addSubview(addAccountTip)
        }
        func numberOfSections(in tableView: UITableView) -> Int {return 1}
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {indexAction(indexPath.row)}
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return ProcyonSystem.accounts.count}
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as! CardCell
            cell.accountData = ProcyonSystem.accounts.index(indexPath.row)
            return cell
        }
    }
    class CardCell: RMTableViewCell {
        var accountData:ProcyonAccountData? = nil{
            didSet{
                guard let accountData = accountData else {return}
                titleLabel.text = accountData.name
                subTextLabel.text = accountData.id
                switch accountData.type {
                case .pixiv: iconView.image = #imageLiteral(resourceName: "PixivLaunchImage")
                }
                subIconView.image = accountData.image?.resize(to: sizeMake(25, 25)*2)
            }
        }
        let cardView = ADCardView()
        let titleLabel = UILabel()
        let subTextLabel = UILabel()
        let iconView = UIImageView()
        let subIconView  = UIImageView()
        
        override func setup() {
            super.setup()
            selectionStyle = .none
            separator.isHidden = true
            
            cardView.size = sizeMake(250, 60)
            cardView.origin = pointMake(5, 10)
            
            titleLabel.size = sizeMake(180, 20)
            titleLabel.origin = pointMake(70, 10)
            titleLabel.font = Font.Roboto.font(13)
            titleLabel.textColor = .text
            
            subTextLabel.size = sizeMake(180, 20)
            subTextLabel.origin = pointMake(70, 30)
            subTextLabel.font = Font.Roboto.font(12)
            subTextLabel.textColor = .subText
            
            iconView.size = sizeMake(45, 45)
            iconView.origin = pointMake(7.5, 7.5)
            
            subIconView.size = sizeMake(25, 25)
            subIconView.center = pointMake(43, 35)
            subIconView.noCorner()
            subIconView.clipsToBounds = true
            subIconView.layer.borderColor = UIColor.hex("ccc").cgColor
            subIconView.layer.borderWidth = 1
            
            
            cardView.addSubviews(titleLabel,subTextLabel,iconView)
            iconView.addSubview(subIconView)
            addSubviews(cardView)
        }
    }
    
}
