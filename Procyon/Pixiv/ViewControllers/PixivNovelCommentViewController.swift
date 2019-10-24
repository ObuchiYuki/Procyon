import UIKit

class PixivNovelCommentViewController: PixivBaseViewController ,UITableViewDelegate, UITableViewDataSource{
    //================================================================
    //properties
    var id = 0
    var commentData:pixivCommentsData? = nil
    
    private var commentViewHeights:[Int:CGFloat] = [:]
    //==============================
    //vies
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let nonCommentLabel = UILabel()
    private let sendButton = ADMainButton(icon: "send")
    private let commentPostView = PixivCommentPostView()
    private let dummyTextField = UITextField()
    //================================================================
    //override func
    override func setUISetting() {
        nonCommentLabel.size = sizeMake(screen.width, 20)
        nonCommentLabel.font = Font.Roboto.font(15)
        nonCommentLabel.textColor = .subText
        nonCommentLabel.centerY = contentSize.height/2
        nonCommentLabel.isHidden = true
        nonCommentLabel.textAlignment = .center
        nonCommentLabel.text = "no_comments".l()
        
        dummyTextField.inputAccessoryView = commentPostView
        
        commentPostView.fromDummyTextField = dummyTextField
        commentPostView.sendButtonTapped = {[weak self] comment in
            guard let me = self else {return}
            novel.addComment(id: me.id, comment: comment, completion: {json in
                if json["error"].isEmpty {
                    me.commentData?.reset()
                    novel.getComments(id: me.id, completion: {json in
                        me.commentData = pixivCommentsData(json: json)
                        me.commentViewHeights = [:]
                        me.tableView.reloadData()
                    })
                }else{ADSnackbar.show("error".l())}
            })
        }
        commentPostView.completion = {[weak self] in
            self?.contentView.removeGestureAction(type: .tap)
        }
        
        tableView.sectionFooterHeight = 0
        tableView.backgroundColor = .clear
        tableView.register(PixivCommentViewCell.self, forCellReuseIdentifier: "commentViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        
        sendButton.addAction {[weak self] in
            self?.commentPostView.open()
            self?.contentView.addGestureAction(.tap, action: {
                self?.commentPostView.close()
            })
        }
    }
    override func setUIScreen() {
        tableView.size = contentSize
    }
    override func addUIs() {
        addSubview(dummyTextField)
        addSubview(tableView)
        addSubview(nonCommentLabel)
        
        mainButton = sendButton
    }
    //================================================================
    //tableView delegates
    func numberOfSections(in tableView: UITableView) -> Int {return 2}
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return PixivHeaderView.withTitleHeight
        case 1: return PixivHeaderView.edgeHeight
        default: return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = PixivHeaderView()
        switch section {
        case 0: header.type = .startSection;header.title = "comment".l()
        case 1: header.type = .endSection
        default: break
        }
        return header
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nonCommentLabel.isHidden = !(commentData?.count ?? 0==0)
        return section == 0 ? commentData?.count ?? 0 : 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = PixivUserViewController()
        viewController.userData = commentData?.comments[indexPath.row].user
        go(to: viewController)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = commentViewHeights[indexPath.row]{
            return height
        }else{
            let height = commentData!.comments[indexPath.row].comment.getHeight(fontSize: 13, width: screen.width-100)+38
            commentViewHeights[indexPath.row] = height
            return height
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentViewCell", for: indexPath) as! PixivCommentViewCell
        let comment = commentData!.comments[indexPath.row]
        cell.reset()
        cell.indexPath = indexPath
        cell.commentData = comment
        pixiv.getAccountImage(userData: comment.user, completion: {image in
            if cell.id == comment.id{cell.userImage = image}
        })
        //======================================
        //if last cell
        if indexPath.row+1 == tableView.numberOfRows(inSection: 0) {
            pixiv.get(commentData!.nextUrl.request){json in
                self.commentData?.appendJson(json: json)
                self.tableView.reloadData()
            }
        }
        
        return cell
    }
}
