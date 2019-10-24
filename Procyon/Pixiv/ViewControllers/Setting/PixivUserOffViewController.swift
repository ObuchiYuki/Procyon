import UIKit

class PixivUserOffViewController: ADNavigationController{
    let tableView = UITableView()
    let addButton = ADMainButton(icon: "add")
    var tableObjects:[pixivUserData]{
        return PixivSystem.hiddenContentsData.hideUsers
    }
    override func setSetting() {
        title = "block_user".l()
        themeColor = ProcyonSystem.mainColor
        
        tableView.register(ADTableViewCardCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 80
        tableView.size = contentSize
        tableView.dataSource = self
        
        addButton.addAction {[weak self] in
            guard let this = self else {return}
            let dialog = ADDialog()
            dialog.title = "enter_user_id".l()
            dialog.textFieldPlaceHolder = "User ID"
            dialog.textField.keyboardType = .numberPad
            dialog.addOKButton {
                let dialog2 = ADDialog()
                dialog2.setIndicator(title: "ユーザーを確認中...")
                dialog2.show()
                if let id = dialog.textFieldText.int{
                    pixiv.getUserData(userID: id){
                        dialog2.close()
                        let data = pixivFullUserData(json: $0)
                        this.tableView.beginUpdates()
                        PixivSystem.addBlockUser(data: data.user)
                        this.tableView.insertRows(at: [.zero], with: .automatic)
                        this.tableView.endUpdates()
                    }
                }
                
            }
            dialog.addCancelButton()
            dialog.show()
        }
        
        addSubview(tableView)
        self.mainButton = addButton
    }
}
extension PixivUserOffViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableObjects.count
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            PixivSystem.removeBlockUser(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ADTableViewCardCell
        let data = self.tableObjects[indexPath.row]
        cell.reset()
        
        cell.title = data.name
        cell.subTitle = "ID: \(data.id)"
        cell.id = data.id
        cell.cellImageView.noCorner()
        cell.cellImageView.clipsToBounds = true
        
        pixiv.getAccountImage(userData: data){if cell.id == data.id{cell.cellImage = $0}}
        
        return cell
    }
}






