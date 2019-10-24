import UIKit

class PixivRelatedWorksCell : PixivCardCellBase, UICollectionViewDelegate ,UICollectionViewDataSource{
    var datas = pixivContentsData(){
        didSet{
            indicator.endRefreshing()
            collectionView.reloadData()
        }
    }
    var cellTapped:(pixivContentsData,Int)->() = {_,_ in}
    var moreButtonTapped = {}
    var collectionView:UICollectionView!
    private let indicator = ADRefreshControl()
    private let alertLabel = UILabel()
    static var defaultHeight:CGFloat{
        return PixivSystem.layout.itemSize.height+20
    }
    func cellLongTapped(index: Int){
        if let data = datas.works.index(index){
            let menu = ADMenu()
            menu.addItem(title: "share".l(), icon: "share"){
                RMShare.show(text: "\(data.title) by \(data.user.name)",url:"http://touch.pixiv.net/member_illust.php?mode=medium&illust_id=\(data.id)".url)
            }
            menu.addItem(title: "add_to_album".l(), icon: "playlist_add"){PixivSystem.addAlbum(data: data)}
            if data.isBookmarked{
                menu.addItem(title: "remove_bookmark".l(), icon: "cancel"){self.deleteBookmark(at: index)}
            }else{
                menu.addItem(title: "bookmark".l(), icon: "bookmark"){self.addBookmark(at: index, restrict: .public)}
                menu.addItem(title: "privete_bookmark".l(), icon: "vpn_lock"){self.addBookmark(at: index, restrict: .private)}
            }
            if data.user.isFollowed{
                menu.addItem(title: "remove_follow_[user_name]".l(data.user.name.omit(6)), icon: "person"){pixiv.deleteFollowUser(id: data.user.id){
                    if $0["error"].isEmpty{ADSnackbar.show("unfollowed".l());self.datas.works[index].user.isFollowed=false}
                    else{ADSnackbar.show("error".l())}
                    }}
            }else{
                menu.addItem(title: "follow_[user_name]".l(data.user.name.omit(6)), icon: "person_add"){pixiv.addFollowUser(id: data.user.id, restrict: .public) {
                    if $0["error"].isEmpty{ADSnackbar.show("followed".l());self.datas.works[index].user.isFollowed=true}
                    else{ADSnackbar.show("error".l())}
                    }}
                menu.addItem(title: "follow_private_[user_name]".l(data.user.name.omit(6)), icon: "vpn_lock"){pixiv.addFollowUser(id: data.user.id, restrict: .private) {
                    if $0["error"].isEmpty{ADSnackbar.show("private_followed".l());self.datas.works[index].user.isFollowed=true}
                    else{ADSnackbar.show("error".l())}
                    }}
            }
            onShowCellMenu(menu: menu,at:index)
        }
    }
    private func addBookmark(at index:Int,restrict:PixivRestrict){
        pixiv.addBookMark(id: datas.works.index(index)?.id ?? 0, restrict: restrict, completion: {json in
            if json["error"].isEmpty{
                ADSnackbar.show(restrict == .public ? "bookmarked".l() : "private_bookmarked".l())
                (self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PixivWorkThumbnailCell)?.isBookmarked = true
                self.datas.works[index].isBookmarked = true
            }else{ADSnackbar.show("error".l())}
        })
    }
    private func deleteBookmark(at index:Int){
        pixiv.deleteBookMark(id: datas.works.index(index)?.id ?? 0, completion: {json in
            if json["error"].isEmpty{
                ADSnackbar.show("bookmark_removede".l())
                (self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PixivWorkThumbnailCell)?.isBookmarked = false
                self.datas.works[index].isBookmarked = false
            }else{ADSnackbar.show("error".l())}
        })
    }
    private func bookmarkApi(handler:@escaping boolBlock,index:Int){
        let data = self.datas.works[index]
        if data.isBookmarked{
            pixiv.deleteBookMark(id: data.id, completion: {json in
                handler(json["error"].isEmpty)
                if !json["error"].isEmpty{ADSnackbar.show("error".l())}
                self.datas.works[index].isBookmarked = false
            })
        }else{
            pixiv.addBookMark(id: data.id, restrict: PixivSystem.restrict, completion: {json in
                handler(json["error"].isEmpty)
                if !json["error"].isEmpty{ADSnackbar.show("error".l())}
                self.datas.works[index].isBookmarked = true
            })
        }
    }
    private func tipAction(cell:PixivWorkThumbnailCell,index:Int){
        let data = self.datas.works[index]
        let menu = ADMenu()
        menu.addItem(title: "add_to_album".l(), icon: "playlist_add", action: {PixivSystem.addAlbum(data: data)})
        if data.isBookmarked{
            menu.addItem(title: "remove_bookmark".l(), icon: "cancel", action: {self.deleteBookmark(at: index)})
        }else{
            menu.addItem(title: "bookmark".l(), icon: "bookmark", action: {self.addBookmark(at: index, restrict: .public)})
            menu.addItem(title: "privete_bookmark".l(), icon: "vpn_lock", action: {self.addBookmark(at: index, restrict: .private)})
        }
        menu.show(windowAnimated: true)
    }
    @objc private func onLongPressAction(sender: UILongPressGestureRecognizer){
        let point = sender.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            self.cellLongTapped(index: indexPath.row)
        }
    }
    func onShowCellMenu(menu: ADMenu,at index:Int){menu.show(windowAnimated: true)}
    override func setup() {
        super.setup()
        cardView.height = 200
        cardView.setAsCardView(with: .bordered)
        cardView.backgroundColor = .hex("fafafa")
        let layout = PixivSystem.layout
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PixivWorkThumbnailCell.self, forCellWithReuseIdentifier: "worksCell")
        collectionView.register(LoadMoreCell.self, forCellWithReuseIdentifier: "loadMoreCell")
        collectionView.origin = pointMake(5, 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.size = sizeMake(screen.width-10, PixivSystem.layout.itemSize.height+20)
        collectionView.backgroundColor = .clear
        
        
        let longPressRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(PixivRelatedWorksCell.onLongPressAction)
        )
        collectionView.addGestureRecognizer(longPressRecognizer)
        
        indicator.centerX = screen.width/2
        indicator.centerY = 80
        indicator.color = .main
        indicator.beginRefreshing()
        
        addSubviews(indicator,collectionView)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellTapped(datas,indexPath.row)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count+1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == datas.count{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadMoreCell", for: indexPath) as! LoadMoreCell
            cell.button.removeAllActions()
            cell.button.addAction {[weak self] in self?.moreButtonTapped()}
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "worksCell", for: indexPath) as! PixivWorkThumbnailCell
            let workData = datas.works[indexPath.row]
            
            cell.reset()
            cell.workData = workData
            cell.bookMarkAction = {[weak self] handler in self?.bookmarkApi(handler: handler, index: indexPath.row)}
            cell.bookmarkTip.longTapAction = {[weak self] in self?.tipAction(cell: cell,index: indexPath.row)}
            
            let request = workData.imageUrls.squareMedium.request
            request.referer = pixiv.referer
            request.getImage{image in if cell.id == workData.id{cell.image = image}}
            return cell
        }
    }
    class LoadMoreCell: RMCollectionViewCell {
        let button = ADButton()
        let label = UILabel()
        override func setup() {
            super.setup()
            self.backgroundColor = .clear
            self.size = PixivSystem.thumbnailSize
            
            button.title = "arrow_forward"
            button.titleLabel?.font = Font.MaterialIcons.font(26)
            button.titleColor = .main
            button.size = sizeMake(55, 55)
            button.noCorner()
            button.backgroundColor = .white
            button.layer.borderColor = UIColor.hex("eee").cgColor
            button.layer.borderWidth = 1
            button.layer.shadowRadius = 0.1
            button.layer.shadowOffset = sizeMake(0, 0.5)
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.2
            button.center = pointMake(self.width/2-10, self.height/2-20)
            
            label.font = Font.Roboto.font(14)
            label.textColor = .subText
            label.text = "view_all".l()
            label.size = sizeMake(100, 30)
            label.centerX = button.centerX
            label.textAlignment = .center
            label.y = button.bottomY+10
            
            
            addSubviews(button,label)
        }
    }
}





