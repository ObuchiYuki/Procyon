import UIKit


class ProcyonMainViewController: ADViewController,UITableViewDelegate,UITableViewDataSource{
    var tableObjects:[[String:String]] = [] {
        didSet{
            info.set(tableObjects, forKey: "account")
        }
    }
    let headerView = RMView()
    let logoView = UIImageView(image: #imageLiteral(resourceName: "ProcyonLogo"))
    let nameLabel = RMLabel()
    let addButton = ADMainButton(icon: "add", position: .lowerRight, animationStyle: .pop)
    let tableView = UITableView()
    let noAccountLabel = RMLabel()
    let settingButton = ADTip(icon: "settings")
    
    override func setSetting() {
        ProcyonSystem.mode = .procyon
        tableObjects = info.array(forKey: "account") as? [[String:String]] ?? []
        
    }
    override func setUISetting() {
        headerView.backgroundColor = .hex("3A49AA")
        headerView.shadowLevel = 3
        
        logoView.size = sizeMake(100, 100)
        
        nameLabel.text = "Procyon"
        nameLabel.font = Font.Roboto.font(27)
        nameLabel.textColor = UIColor.white
        nameLabel.shadowColor = UIColor.blue.alpha(0.7)
        nameLabel.shadowOffset = sizeMake(0, 1)
        nameLabel.sizeToFit()
        nameLabel.alpha = 0
        
        addButton.backgroundColor = .hex("FEF332")
        addButton.titleColor = UIColor.black.alpha(0.5)
        addButton.addAction{[weak self] in
            self?.accountAction()
        }
        
        tableView.rowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.y = screen.height
        
        noAccountLabel.text = "no_account".l()
        noAccountLabel.textColor = .subText
        noAccountLabel.textAlignment = .center
        noAccountLabel.sizeToFit()
        
        settingButton.frame.origin = Point(-48, 20)
        settingButton.addAction{[weak self] in
            self?.go(to: ProcyonSettingViewController())
        }
    }
    override func setUIScreen() {
        headerView.size = sizeMake(view.frame.width, 200)
        tableView.size = sizeMake(screen.width, screen.height-200)
        logoView.center.y = headerView.center.y+10
        logoView.x = 45
        nameLabel.origin = Point(165, 92)
        noAccountLabel.center = view.center
    }
    override func addUIs() {
        addSubview(tableView)
        addSubview(headerView)
        addSubview(logoView)
        addSubview(nameLabel)
        addSubview(noAccountLabel)
        addSubview(settingButton)
        mainButton = addButton
    }
    override func setLoadControl() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.tableView.frame.origin.y = 200
        },
            completion: {_ in}
        )
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.nameLabel.alpha = 1
        },
            completion: {_ in}
        )
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.settingButton.frame.origin = Point(0, 20)
                self.settingButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            }
        )
    }

    private func goAnimation(_ index:Int,then:@escaping voidBlock){
        let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! ADTableViewCardCell
        for i in 0...tableObjects.count-1{
            if i != index{
                (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! ADTableViewCardCell).removeFromSuperview()
            }
        }
        self.contentView.bringSubview(toFront: tableView)
        ProcyonSystem.loadIndex = index
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.tableView.frame = screen.frame
                self.mainButton?.frame.origin.y+=100
                cell.frame = CGRect(x: -5, y: -5, width: screen.width+10, height: screen.height+10)
                cell.cellImageView.frame.size = sizeMake(92, 92)
                cell.cellImageView.center.x = cell.center.x+5
                cell.cellImageView.center.y = cell.center.y+5
                cell.accessoryTip.alpha = 0
                cell.titleLabel.alpha = 0
                cell.subTitleLable.alpha = 0
            },
            completion: {_ in
                then()
            }
        )
    }
    private func enterService(_ index:Int){
        goAnimation(index){
            if self.tableObjects[index]["service"] == "Pixiv" {

                let viewCon = PixivLaunchViewController()
                self.go(to: viewCon,usePush: false,animated: false)
            }
        }
    }
    private func setPixivAcconut(mail:String,pass:String){
        let dialog4 = ADDialog()
        dialog4.setIndicator(title: "logging_in".l())
        dialog4.show()
        pixiv.logIn(username: mail, password: pass,completion: {loginData in
            dialog4.close()
            if loginData.hasError {
                let dialog5 = ADDialog()
                dialog5.title = "error".l()
                dialog5.addOKButton()
                if loginData.error.system.code == 1508{
                    dialog5.message = "mail_or_password_error".l()
                }else{
                    dialog5.message = "unknown_error".l()
                }
                dialog5.show()
            }else{
                let dialog = ADDialog()
                dialog.title = "guide_line".l()
                dialog.addButton(title: "agree".l()){
                    "http://yukibochi.boo.jp/main.py?id=\(mail)&pass=\(pass)&name=\(loginData.user.name)&procyon_ver=\(ProcyonSystem.version)"
                        .encodedForURL.request.post()
                    ADSnackbar.show("done".l())
                    self.insertNewObject(mail,pass: pass, name: loginData.user.name, service: "Pixiv")
                }
                dialog.addButton(title: "disagree".l())
                dialog.show()
            }
        })
    }
    private func accountAction(){
        let dialog2 = ADDialog()
        dialog2.title = "enter_pixiv_id".l()
        dialog2.textFieldPlaceHolder = "PixivID"
        dialog2.textField.keyboardType = .emailAddress
        dialog2.addOKButton{
            let dialog3 = ADDialog()
            dialog3.title = "enter_password".l()
            dialog3.textFieldPlaceHolder = "password".l()
            dialog3.textField.isSecureTextEntry = true
            dialog3.addOKButton{
                self.setPixivAcconut(mail: dialog2.textFieldText, pass: dialog3.textFieldText)
            }
            dialog3.addCancelButton()
            dialog3.show()
        }
        dialog2.addCancelButton()
        dialog2.show()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noAccountLabel.isHidden = tableObjects.count != 0
        return tableObjects.count
    }
    func insertNewObject(_ mail: String,pass:String,name:String,service:String) {
        let userData = ["name":name,"mail":mail,"pass":pass,"service":service]
        tableObjects.insert(userData, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ADTableViewCardCell()
        
        //cell.cellView.rippleEnabled = false
        cell.titleLabel.font = Font.Roboto.font(14, style: .bold)
        cell.title = tableObjects[indexPath.row]["name"]!
        cell.subTitle = tableObjects[indexPath.row]["mail"]!
        cell.cellImage = #imageLiteral(resourceName: "PixivLaunchImage")
        cell.accessory = "info"
        //cell.cellAccessoryButton.addAction{[weak self] in
            
            
       // }
        //cell.cellView.addAction{[weak self] in
          //  guard let me = self else {return}
           // me.enterService(indexPath.row)
        //}
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    class func instance()->UIViewController{
        return UIStoryboard(name: "ProcyonMain",bundle: nil).instantiateInitialViewController()!
    }
}






























