import UIKit

class PixivPostViewController: ADSettingViewBaseController {
    override func setSetting() {
        tableView.register(PixivPostImageCell.self, forCellReuseIdentifier: "imageCell")
        tableView.register(PixivPostTitleCell.self, forCellReuseIdentifier: "titleCell")
        tableView.register(PixivPostCommentCell.self, forCellReuseIdentifier: "commentCell")
        tableView.register(PixivPostTagCell.self, forCellReuseIdentifier: "tagCell")
    }
    override func setUISetting() {
        
    }
    override func setUIScreen() {
        
    }
    override func addUIs() {
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section==0{return 0}else {return tableView.sectionHeaderHeight}
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["","タグ","詳細"].index(section) ?? ""
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3
        case 1: return 0
        case 2: return 3
        default: return 0
        }
    }
    override func tableView(_ tabeView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell") as! PixivPostImageCell
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell") as! PixivPostTitleCell
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell") as! PixivPostCommentCell
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell") as! PixivPostTagCell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! ADSettingViewTableViewCell
            return cell
        default:
            return UITableViewCell()
        }
    }
}
fileprivate class PixivPostImageCell: RMTableViewCell{
    let postImageView = UIImageView()
    var postImage:UIImage? = nil
    fileprivate override func setup() {
        backgroundColor = .hex("444")
        
    }
    fileprivate override func didFrameChange() {
        
    }
}
fileprivate class PixivPostTagCell: RMTableViewCell {
    let tagLabel = UILabel()
    let deleteTip = ADTip(icon: "delete")
    fileprivate override func setup() {
        tagLabel.origin = pointMake(5, 5)
        tagLabel.font = Font.Roboto.font(13)
        tagLabel.origin = pointMake(5, 5)
        tagLabel.backgroundColor = .red
        
        deleteTip.size = sizeMake(25, 25)
        deleteTip.noCorner()
        
        addSubview(tagLabel)
        addSubview(deleteTip)
    }
    fileprivate override func didFrameChange() {
        tagLabel.size = sizeMake(self.width-40, self.height-10)
        deleteTip.origin = pointMake(self.width-30, 5)
    }
}
fileprivate class PixivPostTitleCell: RMTableViewCell{
    let textField = UITextField()
    
    fileprivate override func setup() {
        textField.origin = pointMake(5, 5)
        textField.font = Font.Roboto.font(13)
        textField.origin = pointMake(5, 5)
        textField.backgroundColor = .red
        addSubview(textField)
    }
    fileprivate override func didFrameChange() {
        textField.size = sizeMake(self.width-10, self.height-10)
    }
}

fileprivate class PixivPostCommentCell: RMTableViewCell{
    let textView = UITextView()
    fileprivate override func setup() {
        textView.textColor = .text
        textView.font = Font.Roboto.font(13)
        textView.origin = pointMake(5, 5)
        textView.backgroundColor = .red
        addSubview(textView)
    }
    fileprivate override func didFrameChange() {
        textView.size = sizeMake(self.width-10, self.height-10)
    }
}
