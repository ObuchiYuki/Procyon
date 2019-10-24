import UIKit

class PixivCommentViewController: PixivBaseViewController ,UITableViewDelegate, UITableViewDataSource{
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
            pixiv.addComment(id: me.id, comment: comment, completion: {json in
                if json["error"].isEmpty {
                    me.commentData?.reset()
                    pixiv.getComments(id: me.id, completion: {json in
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
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        tableView.register(PixivCommentViewCell.self, forCellReuseIdentifier: "commentViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionFooterHeight = 0
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
        if commentData?.count ?? 0==0{nonCommentLabel.isHidden=false}
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

class PixivCommentPostView: RMView ,UITextViewDelegate{
    var sendButtonTapped:stringBlock = {_ in}
    var completion = {}
    weak var fromDummyTextField:UITextField? = nil
    
    private let profileImageView = UIImageView()
    private let commentTextView = UITextView()
    private let sendButton = ADTip(icon: "send")
    private var canSend = false
    
    func open(){
        fromDummyTextField?.becomeFirstResponder()
        commentTextView.becomeFirstResponder()
    }
    func close(){
        commentTextView.resignFirstResponder()
        fromDummyTextField?.resignFirstResponder()
        completion()
        completion = {}
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            canSend = false
            self.sendButton.titleColor = .hex("aaaaaa")
            
        }else{
            canSend = true
            self.sendButton.titleColor = ADColor.LightBlue.P500
        }
        if commentTextView.contentSize.height<100{
            commentTextView.size = commentTextView.contentSize
        }else{
            commentTextView.height = 100
        }
        self.y = -commentTextView.height+35
        self.height = commentTextView.height+18
    }
    
    override func setup() {
        super.setup()
        self.size = sizeMake(screen.width, 50)
        
        self.backgroundColor = .back
        self.unsafeShadowLevel = 6
        
        profileImageView.size = sizeMake(40, 40)
        profileImageView.origin = Point(15, 5)
        profileImageView.noCorner()
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .hex("777777")
        pixiv.getMyAccountImage {image in
            self.profileImageView.image = image
        }
        
        commentTextView.delegate = self
        commentTextView.textColor = .text
        commentTextView.size = sizeMake(screen.width-70-48, 36)
        commentTextView.origin = pointMake(70, 9)
        commentTextView.cornerRadius = 2
        commentTextView.backgroundColor = .hex("eeeeee")
        commentTextView.font = Font.Roboto.font(17)
        
        sendButton.y = 1
        sendButton.rightX = screen.width
        sendButton.titleColor = .hex("aaaaaa")
        
        sendButton.addAction{[weak self] in
            guard let me = self else {return}
            if me.canSend{
                me.close()
                me.sendButtonTapped(me.commentTextView.text)
                me.commentTextView.text = ""
            }
        }
        
        addSubview(profileImageView)
        addSubview(commentTextView)
        addSubview(sendButton)
    }
}













