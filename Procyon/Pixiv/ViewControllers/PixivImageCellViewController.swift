import UIKit

class PixivImageCellViewController: ADPageCellViewController,UITableViewDelegate, UITableViewDataSource{
    //================================================================
    //properties
    var data:pixivWorkData! = nil
    var id:Int? = nil
    private var commentData:pixivCommentsData? = nil
    private var captionViewHeight:CGFloat? = nil
    private var titleViewHeight:CGFloat? = nil
    private var commentViewHeights:[Int:CGFloat] = [:]
    private var commentCount = 0
    private var relatedWorksDatas = pixivContentsData()
    //==============================
    //vies
    let mainTableView = UITableView(frame: .zero, style: .grouped)
    private let pageNumView = PixivPageCountView()
    private let ugoiraView = PixivUgoiraView()
    private let imageMenuView = PixivImageMenuView()
    //================================================================
    //func
    override func set(data: Any) {
        self.data = data as! pixivWorkData
    }
    private func shareTipAction() {
        let url = "http://touch.pixiv.net/member_illust.php?mode=medium&illust_id=\(data.id)"
        ADMenu.show(animated: true,iconArr: ["link","explore","more_horiz"],titles: ["copy_link".l(),"open_in_safari".l(),"share".l()], actionArr: [
            {clipBoard.text = url;ADSnackbar.show("copied".l())},
            {application.forceOpenURL(url.url!)},
            {RMShare.show(text: "\(self.data.title) by \(self.data.user.name)",url: url.url)}
        ])
    }
    private func albumTipAction(){
        let menu = ADMenu()
        menu.addItem(title: "add_to_album".l(), icon: "playlist_add", action: {PixivSystem.addAlbum(data: self.data)})
        if data.isBookmarked{
            menu.addItem(title: "remove_bookmark".l(), icon: "cancel"){
                pixiv.deleteBookMark(id: self.data.id, completion: {json in
                    if json["error"].isEmpty {ADSnackbar.show("bookmark_removede".l());self.data.isBookmarked = false}
                    else{ADSnackbar.show("error".l())}
                })
            }
        }else{
            menu.addItem(title: "bookmark".l(), icon: "bookmark"){
                pixiv.addBookMark(id: self.data.id, restrict: .public, completion: {json in
                    if json["error"].isEmpty{ADSnackbar.show("bookmarked".l());self.data.isBookmarked = true}
                    else{ADSnackbar.show("error".l())}
                })
            }
            menu.addItem(title: "privete_bookmark".l(), icon: "vpn_lock"){
                pixiv.addBookMark(id: self.data.id, restrict: .private, completion: {json in
                    if json["error"].isEmpty{ADSnackbar.show("bookmarked".l());self.data.isBookmarked = true}
                    else{ADSnackbar.show("error".l())}
                })
            }
        }
        if data.user.isFollowed{
            menu.addItem(title: "remove_follow_[user_name]".l(data.user.name.omit(6)), icon: "person"){pixiv.deleteFollowUser(id: self.data.user.id){
                if $0["error"].isEmpty{ADSnackbar.show("unfollowed".l());self.data.user.isFollowed=true}
                else{ADSnackbar.show("error".l())}
            }}
        }else{
            menu.addItem(title: "follow_[user_name]".l(data.user.name.omit(6)), icon: "person_add"){pixiv.addFollowUser(id: self.data.user.id, restrict: .public) {
                if $0["error"].isEmpty{ADSnackbar.show("followed".l());self.data.user.isFollowed=true}
                else{ADSnackbar.show("error".l())}
            }}
            menu.addItem(title: "follow_private_[user_name]".l(data.user.name.omit(6)), icon: "vpn_lock"){pixiv.addFollowUser(id: self.data.user.id, restrict: .private) {
                if $0["error"].isEmpty{ADSnackbar.show("private_followed".l());self.data.user.isFollowed=true}
                else{ADSnackbar.show("error".l())}
            }}
        }
        menu.useActionArr = true
        menu.show(windowAnimated: true)
    }
    private func menuTipAction(){
        ADMenu.show(animated: true,iconArr: ["save","save","warning"],titles: ["save_all_illust".l(),"save_as_pdf".l(),"send_report".l()],actionArr: [
            {pixivSaveManager.saveAll(data: self.data)},
            {pixivSaveManager.savePDF(data: self.data)},
            {ADDialog.show(title: "report_[work_title]?".l(self.data.title)){ADSnackbar.show("reported".l())}}
        ])
    }
    private func followAction(cell:PixivUserViewCell){
        if data.user.isFollowed{
            pixiv.deleteFollowUser(id: data.user.id){json in
                if json["error"].isEmpty{
                    cell.followButton.isFollowed = false
                    self.data.user.isFollowed = false
                }
            }
        }else{
            pixiv.addFollowUser(id: data.user.id, restrict: PixivSystem.restrict) {json in
                if json["error"].isEmpty{
                    cell.followButton.isFollowed = true
                    self.data.user.isFollowed = true
                }
            }
        }
    }
    private func createView(){
        pageNumView.count = data.pageCount
        ugoiraView.isHidden = data.type != .ugoira
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.reloadData()
        pixiv.getComments(id: data.id){json in
            self.commentData = pixivCommentsData(json: json)
            self.commentCount = self.commentData!.count>=5 ? 5 : self.commentData!.count
            self.mainTableView.reloadSections([5], with: .none)
        }
        pixiv.getRelated(id: data.id){j in self.relatedWorksDatas.append(j){
            self.mainTableView.reloadSections([4], with: .none)
        }}
    }
    //================================================================
    //override func
    override func setUISetting() {
        imageMenuView.shareTip.addAction{[weak self] in self?.shareTipAction()}
        imageMenuView.albumTip.addAction{[weak self] in self?.albumTipAction()}
        imageMenuView.menuTip.addAction{[weak self] in self?.menuTipAction()}
        
        pageNumView.origin = pointMake(screen.width-50, 58)
        
        ugoiraView.origin = pointMake(screen.width-34, 58)
        ugoiraView.isHidden = true
        
        mainTableView.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: #selector(PixivImageCellViewController.longTapAction(_:)))
        )
        mainTableView.separatorStyle = .none
        mainTableView.preservesSuperviewLayoutMargins = false
        mainTableView.layoutMargins = .zero
        mainTableView.backgroundColor = .clear
        mainTableView.sectionFooterHeight = 0
        mainTableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        mainTableView.register(PixivImageViewCell.self, forCellReuseIdentifier: "imageViewCell")
        mainTableView.register(PixivRelatedWorksCell.self, forCellReuseIdentifier: "relatedWorksCell")
        mainTableView.register(PixivTextViewCell.self, forCellReuseIdentifier: "textViewCell")
        mainTableView.register(PixivUserViewCell.self, forCellReuseIdentifier: "userViewCell")
        mainTableView.register(PixivCommentViewCell.self, forCellReuseIdentifier: "commentViewCell")
        mainTableView.register(PixivButtonCell.self, forCellReuseIdentifier: "buttonCell")
        
        createView()
    }
    override func setUIScreen() {
        mainTableView.size = contentSize
    }
    override func addUIs() {
        addSubviews(mainTableView,pageNumView,ugoiraView,imageMenuView)
    }
    override func setLoadControl() {
        pixivInternalApi.addHistory(restrict: PixivSystem.restrict, work: self.data)
    }
    //================================================================
    //tableView delegates
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageNumView.y = scrollView.contentOffset.y-35>screen.height-164 ? -scrollView.contentOffset.y+screen.height-72-34+35 : 58
        ugoiraView.y = self.pageNumView.y
        self.imageMenuView.y = scrollView.contentOffset.y-35>screen.height-72-48 ? -scrollView.contentOffset.y+screen.height-72-48+35 : 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    @objc private func longTapAction(_ recognizer: UILongPressGestureRecognizer){
        guard let indexPath = mainTableView.indexPathForRow(at: recognizer.location(in: mainTableView)) else {return}
        switch indexPath.section {
        case 2:
            let dialog = ADDialog()
            dialog.title = data.user.name
            dialog.message = "make_this_user_hide?".l()
            dialog.addOKButton {[weak self] in
                guard let this = self else {return}
                PixivSystem.addBlockUser(data: this.data.user)
                ADSnackbar.show("done".l())
                this.pageViewController?.back()
                (this.pageViewController as? PixivImageViewController)?.datas.collectionViewController?.reload()
            }
            dialog.addCancelButton()
            dialog.show()
        case 3:
            let tag = data.tags[indexPath.row]
            let dialog = ADDialog()
            dialog.title = tag
            dialog.setTableView(titles: ["open_in_pixiv_dic".l(),"open_in_nico_dic".l(),"make_hide_tag".l()],style: .select){[weak self] i in
                switch i {
                case 0,1:
                    guard let me = self else {return}
                    let viewController = PixivEncyclopediaViewController()
                    viewController.openNico = i == 1
                    viewController.word = me.data.tags[indexPath.row]
                    self?.pageViewController?.go(to: viewController,usePush: false)
                case 2:
                    PixivSystem.showHideTagDialog(tag: tag)
                default: break
                }
            }
            dialog.addCancelButton()
            dialog.show()
        default:
            break
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0
        case 3,4,5: return PixivHeaderView.withTitleHeight
        case 1,6: return PixivHeaderView.edgeHeight
        default:return PixivHeaderView.defaultHeight
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = PixivHeaderView()
        switch section {
        case 1: header.type = .startSection
        case 3:
            header.title = "tag_(long_press_to_dict)".l()
            header.buttonTitle = "tag_bookmark".l()
            header.actionButton.addAction {[weak self] in PixivSystem.tagBookmark(tags: self?.data.tags ?? [], id: self?.data.id ?? 0)}
        case 4:
            header.title = relatedWorksDatas.works.isEmpty ? "no_releted_illust".l() : "releted_illusts".l()
            if !relatedWorksDatas.works.isEmpty{header.buttonTitle = "view_all".l()}
            header.lowerCardView.backgroundColor = .hex("fafafa")
            header.actionButton.addAction {[weak self] in
                guard let me = self else {return}
                let viewController = PixivRelatedWorksViewController()
                viewController.inner.datas = me.relatedWorksDatas
                viewController.title = "releted_illsts_of_[work_title]".l(me.data.title)
                viewController.id = me.data.id
                me.sendToRoot(identifier: "go", info: viewController)
            }
        case 5:
            header.upperCardView.backgroundColor = .hex("fafafa")
            header.title = "comment".l()
        case 6: header.type = .endSection
        default:
            break
        }
        return header
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {return 0}
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 3
        case 2: return 1
        case 3: return data.tags.count
        case 4: return self.relatedWorksDatas.works.isEmpty ? 0 : 1
        case 5: return commentCount+1
        default:return 0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if data.type == .ugoira{
                let imagePageViewController = PixivUgoiraViewController()
                imagePageViewController.data = data
                self.sendToRoot(identifier: "go", info: imagePageViewController)
            }else{
                let imagePageViewController = PixivImagePageViewController()
                imagePageViewController.data = data
                self.sendToRoot(identifier: "go", info: imagePageViewController)
            }
        case 2:
            let userViewController = PixivUserViewController()
            userViewController.id = data.user.id
            userViewController.userData = data.user
            self.sendToRoot(identifier: "go", info: userViewController)
        case 3:
            let tag = data.tags[indexPath.row]
            let viewController = PixivSearchViewController()
            viewController.isTag = true
            if let m = Re.search("(.*)[1-9][0-9]+users入り", tag){
                let menu = ADMenu()
                menu.titles = [
                    "\(m.group(1))100users入り",
                    "\(m.group(1))500users入り",
                    "\(m.group(1))1000users入り",
                    "\(m.group(1))5000users入り",
                    "\(m.group(1))10000users入り",
                    "other".l()
                ]
                menu.iconArr = Array(repeating: "person", count: 6)
                menu.indexAction = {[weak self] index in
                    if index != 5{
                        viewController.word = menu.titles.index(index) ?? ""
                        self?.sendToRoot(identifier: "go", info: viewController)
                    }else{
                        let dialog = ADDialog()
                        dialog.title = "select".l()
                        dialog.textFieldPlaceHolder = "users入り"
                        dialog.textField.keyboardType = .numberPad
                        dialog.addOKButton{
                            if let num = dialog.textFieldText.int{
                                viewController.word = "\(m.group(1))\(num)users入り"
                                self?.sendToRoot(identifier: "go", info: viewController)
                            }else{ADSnackbar.show("error".l())}
                        }
                        dialog.addCancelButton()
                        dialog.show()
                    }
                }
                menu.show()
            }
            else if let m = Re.search("(.*)[id|illust_id]\\s*[\\s|:|;|=]\\s*([0-9]+)", tag){
                application.openURL("procyon://illusts/\(m.group(2))".url!)
                ADSnackbar.show("id_[id]_illust_is_showing".l(m.group(2)))
            }else{
                viewController.word = tag
                self.sendToRoot(identifier: "go", info: viewController)
            }
        case 5:
            switch indexPath.row {
            case commentCount:
                let viewController = PixivCommentViewController()
                viewController.title = "comments_of_[title]".l(data.title)
                viewController.commentData = commentData
                viewController.id = data.id
                self.sendToRoot(identifier: "go", info: viewController)
            default:
                let userData = commentData!.comments[indexPath.row].user
                let viewController = PixivUserViewController()
                viewController.id = userData.id
                viewController.userData = userData
                self.sendToRoot(identifier: "go", info: viewController)
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return view.height
        case 1:
            switch indexPath.row {
            case 0:
                return 25
            case 1:
                if let height = titleViewHeight{
                    return height
                }else{
                    let height = data.title.getHeight(fontSize: 12, width: contentSize.width)-3
                    self.titleViewHeight = height
                    return height
                }
            case 2:
                if let height = captionViewHeight{
                    return height
                }else{
                    let height = PixivTextViewCell.getHight(withAttributText: data.caption.htmlAttributedString)-3
                    self.captionViewHeight = height
                    return height
                }
            default:
                return 0
            }
        case 2: return 60
        case 3: return 23
        case 4: return PixivRelatedWorksCell.defaultHeight
        case 5:
            switch indexPath.row {
            case commentCount:
                return 50
            default:
                if let height = commentViewHeights[indexPath.row]{
                    return height
                }else{
                    let height = commentData!.comments[indexPath.row].comment.getHeight(fontSize: 13, width: screen.width-100)+38
                    commentViewHeights[indexPath.row] = height
                    return height
                }
            }
        default:
            return tableView.rowHeight
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageViewCell", for: indexPath) as! PixivImageViewCell
            
            let request = data.imageUrls.large.request
            request.referer = pixiv.referer
            request.getImage{image in cell.illustImage = image}
            return cell
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath) as! PixivTextViewCell
                cell.reset()
                cell.textView.textColor = .subText
                cell.title = "image_descriptions_[total_view,total_bookmarks,created_date]"
                    .l(data.totalView,data.totalBookmarks,data.createDate.string(for: "yyyy/MM/dd"))
                cell.indexPath = indexPath
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath) as! PixivTextViewCell
                cell.reset()
                cell.title = data.title
                cell.indexPath = indexPath
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath) as! PixivTextViewCell
                cell.reset()
                cell.textView.isUserInteractionEnabled = true
                cell.textView.isSelectable = true
                cell.attributCaption = data.caption
                cell.indexPath = indexPath
                return cell
            default:
                return UITableViewCell()
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "userViewCell", for: indexPath) as! PixivUserViewCell
            cell.data = data.user
            cell.followButton.addAction {[weak self] in self?.followAction(cell: cell)}
            pixiv.getAccountImage(userData: data.user, completion: {image in
                cell.authorImage = image
            })
            cell.indexPath = indexPath
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as! PixivButtonCell
            cell.reset()
            cell.title = data.tags[indexPath.row]
            cell.fontSize = 12
            cell.textAlign = .left
            cell.titleColor = .text
            cell.showDisclosure = true
            cell.indexPath = indexPath
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "relatedWorksCell", for: indexPath) as! PixivRelatedWorksCell
            cell.cellTapped = {[weak self] datas,index in
                let imageController = PixivImageViewController()
                imageController.datas = datas
                imageController.index = index
                self?.sendToRoot(identifier: "go", info: imageController)
            }
            cell.moreButtonTapped = {[weak self] in
                guard let me = self else {return}
                let viewController = PixivRelatedWorksViewController()
                viewController.inner.datas = me.relatedWorksDatas
                viewController.title = "releted_illsts_of_[work_title]".l(me.data.title)
                viewController.id = me.data.id
                me.sendToRoot(identifier: "go", info: viewController)
            }
            cell.datas = self.relatedWorksDatas
            cell.indexPath = indexPath
            return cell
        case 5:
            switch indexPath.row {
            case commentCount:
                let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as! PixivButtonCell
                cell.reset()
                cell.title = "comments_view".l()
                cell.showDisclosure = true
                cell.indexPath = indexPath
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "commentViewCell", for: indexPath) as! PixivCommentViewCell
                let comment = commentData!.comments[indexPath.row]
                cell.reset()
                cell.commentData = comment
                pixiv.getAccountImage(userData: comment.user, completion: {image in
                    if cell.id == comment.id{cell.userImage = image}
                })
                cell.indexPath = indexPath
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
}
