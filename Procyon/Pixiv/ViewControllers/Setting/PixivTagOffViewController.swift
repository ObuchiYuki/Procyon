import UIKit

class PixivTagOffViewController: ADNavigationController,UITableViewDelegate,UITableViewDataSource{
    
    private let tableView = UITableView()
    private let addButton = ADMainButton(icon: "add", position: .lowerRight, animationStyle: .pop)
    
    var hideTags = PixivSystem.hiddenContentsData.hideTags
    
    func update(){
        var data = PixivSystem.hiddenContentsData
        data.hideTags = hideTags
        PixivSystem.setHideContentsData(data: data)
    }
    
    override func setSetting() {
        title = "hidden_tags".l()
    }   
    override func setUISetting() {
        themeColor = ProcyonSystem.mainColor 
        showSearchButton = false
        tableView.rowHeight = 63
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .back
        
        func showAlert(){
            let dialog = ADDialog()
            dialog.title = "hidden_tags".l()
            dialog.addOKButton({
                let text = dialog.textFieldText
                if text == "procyon_test_album_enable"{
                    PixivSystem.tmpAlbumEnable = true
                }
                if text.isEmpty{
                    let dialog2 = ADDialog()
                    dialog2.title = "error".l()
                    dialog2.message = "you_can_not_add_blank_tag".l()
                    dialog2.addOKButton(showAlert)
                    dialog2.show()
                }else{
                    guard let tableView = dialog.customView as? ADDialog.TableView else {return}
                    self.insertNewObject(text,allowInclude: tableView.enableCheckBoxIndexes[0] ?? false)
                }
            })
            dialog.setTableView(titles: ["contain_tag_name".l()]) {_ in}
            dialog.addCancelButton()
            dialog.textFieldPlaceHolder = "tag".l()
            dialog.show()
        }
        
        addButton.addAction(showAlert)
    }
    override func setUIScreen() {
        tableView.frame = fullContentsFrame
    }
    override func addUIs() {
        mainButton = addButton
        addSubview(tableView)
    }
    
    func insertNewObject(_ sender: String,allowInclude:Bool) {
        hideTags.insert(pixivHiddenContentsData.TagData(tagName: sender, includingContains: allowInclude), at: 0)
        self.tableView.insertRows(at: [.zero], with: .automatic)
        self.update()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hideTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = hideTags[indexPath.row]
        let cell = ADTableViewCardCell()
        cell.margin = UIEdgeInsetsMake(5, 5, 5, 5)
        cell.title = data.tagName
        if data.includingContains {
            let indicator = UILabel()
            indicator.text = "tag_contains_[name]".l("")
            indicator.textColor = .subText
            indicator.font = Font.Roboto.font(12)
            indicator.sizeToFit()
            indicator.frame.origin.x = cell.frame.width - indicator.frame.width - 20
            indicator.frame.origin.y = cell.frame.height - indicator.frame.height
            cell.cardView.addSubview(indicator)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            hideTags.remove(at: indexPath.row)
            self.update()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {}
    }
}































