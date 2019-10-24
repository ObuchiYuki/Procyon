import UIKit

class PixivNovelSeriesCell : PixivCardCellBase, UICollectionViewDelegate ,UICollectionViewDataSource{
    var datas = pixivNovelContentsData(){
        didSet{
            indicator.endRefreshing()
            collectionView.reloadData()
        }
    }
    var cellTapped:(pixivNovelContentsData,Int)->() = {_,_ in}
    var moreButtonTapped = {}
    var collectionView:UICollectionView!
    private let indicator = ADRefreshControl()
    private let alertLabel = UILabel()
    static var defaultHeight:CGFloat{return SeriesCell.layout.itemSize.height+14}
    func cellLongTapped(index: Int){
        if let data = datas.novels.index(index){
            let menu = ADMenu()
            menu.addItem(title: "share".l(), icon: "share"){
                RMShare.show(text: "\(data.title) by \(data.user.name)",url:"http://touch.pixiv.net/novel/show.php?id=\(data.id)".url)
            }
            if data.isBookmarked{
                menu.addItem(title: "remove_bookmark".l(), icon: "cancel"){self.deleteBookmark(at: index)}
            }else{
                menu.addItem(title: "bookmark".l(), icon: "bookmark"){self.addBookmark(at: index, restrict: .public)}
                menu.addItem(title: "privete_bookmark".l(), icon: "vpn_lock"){self.addBookmark(at: index, restrict: .private)}
            }
            if data.user.isFollowed{
                menu.addItem(title: "remove_follow_[user_name]".l(data.user.name.omit(6)), icon: "person"){pixiv.deleteFollowUser(id: data.user.id){
                    if $0["error"].isEmpty{ADSnackbar.show("unfollowed".l());self.datas.novels[index].user.isFollowed=false}
                    else{ADSnackbar.show("error".l())}
                    }}
            }else{
                menu.addItem(title: "follow_[user_name]".l(data.user.name.omit(6)), icon: "person_add"){pixiv.addFollowUser(id: data.user.id, restrict: .public) {
                    if $0["error"].isEmpty{ADSnackbar.show("followed".l());self.datas.novels[index].user.isFollowed=true}
                    else{ADSnackbar.show("error".l())}
                    }}
                menu.addItem(title: "follow_private_[user_name]".l(data.user.name.omit(6)), icon: "vpn_lock"){pixiv.addFollowUser(id: data.user.id, restrict: .private) {
                    if $0["error"].isEmpty{ADSnackbar.show("private_followed".l());self.datas.novels[index].user.isFollowed=true}
                    else{ADSnackbar.show("error".l())}
                    }}
            }
            onShowCellMenu(menu: menu,at:index)
        }
    }
    private func addBookmark(at index:Int,restrict:PixivRestrict){
        novel.addBookMark(id: datas.novels.index(index)?.id ?? 0, restrict: restrict, completion: {json in
            if json["error"].isEmpty{
                ADSnackbar.show(restrict == .public ? "bookmarked".l() : "private_bookmarked".l())
                (self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PixivWorkThumbnailCell)?.isBookmarked = true
                self.datas.novels[index].isBookmarked = true
            }else{ADSnackbar.show("error".l())}
        })
    }
    private func deleteBookmark(at index:Int){
        novel.deleteBookMark(id: datas.novels.index(index)?.id ?? 0, completion: {json in
            if json["error"].isEmpty{
                ADSnackbar.show("bookmark_removede".l())
                (self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PixivWorkThumbnailCell)?.isBookmarked = false
                self.datas.novels[index].isBookmarked = false
            }else{ADSnackbar.show("error".l())}
        })
    }
    private func bookmarkApi(handler:@escaping boolBlock,index:Int){
        let data = self.datas.novels[index]
        if data.isBookmarked{
            novel.deleteBookMark(id: data.id, completion: {json in
                handler(json["error"].isEmpty)
                if !json["error"].isEmpty{ADSnackbar.show("error".l())}
                self.datas.novels[index].isBookmarked = false
            })
        }else{
            novel.addBookMark(id: data.id, restrict: PixivSystem.restrict, completion: {json in
                handler(json["error"].isEmpty)
                if !json["error"].isEmpty{ADSnackbar.show("error".l())}
                self.datas.novels[index].isBookmarked = true
            })
        }
    }
    private func tipAction(cell:PixivWorkThumbnailCell,index:Int){
        let data = self.datas.novels[index]
        let menu = ADMenu()
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
        cardView.height = SeriesCell.layout.itemSize.height+30
        cardView.setAsCardView(with: .bordered)
        cardView.backgroundColor = .hex("fafafa")
        let layout = SeriesCell.layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(SeriesCell.self, forCellWithReuseIdentifier: "worksCell")
        collectionView.register(LoadMoreCell.self, forCellWithReuseIdentifier: "loadMoreCell")
        collectionView.origin = pointMake(5, 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.size = sizeMake(screen.width-10, SeriesCell.layout.itemSize.height+14)
        collectionView.backgroundColor = .clear

        let longPressRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(PixivNovelSeriesCell.onLongPressAction)
        )
        collectionView.addGestureRecognizer(longPressRecognizer)
        
        indicator.centerX = screen.width/2
        indicator.centerY = 80
        indicator.color = .main
        indicator.beginRefreshing()
        indicator.backgroundColor = .clear
        
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "worksCell", for: indexPath) as! SeriesCell
            let data = datas.novels[indexPath.row]
            
            cell.reset()
            cell.data = data
            
            let request = data.imageUrls.medium.request
            request.referer = pixiv.referer
            request.getImage{image in if cell.id == data.id{cell.image = image}}
            return cell
        }
    }
    class SeriesCell: ADCollectionViewCell{
        var id = 0
        var image:UIImage? = nil{didSet{self.imageView.image = image}}
        var data:pixivNovelData? = nil{
            didSet{
                guard let data = data else {return}
                self.id = data.id
                self.titleLabel.text = data.title
                self.userNameLebel.text = data.user.name
            }
        }
        static var layout:UICollectionViewFlowLayout{
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = sizeMake(24, 30)*6
            layout.sectionInset = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
            layout.scrollDirection = .horizontal
            return layout
        }
        private let imageView = UIImageView()
        private let titleLabel = UILabel()
        private let separator = UIView()
        private let userNameLebel = UILabel()
        private let overlayView = UIView()
        func reset(){
            self.image = nil
            self.titleLabel.text = ""
            self.userNameLebel.text = ""
        }
        override func setup() {
            self.size = SeriesCell.layout.itemSize
            imageView.size = self.size
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            overlayView.size = sizeMake(self.width, 45)
            overlayView.backgroundColor = .hex("0",alpha: 0.4)
            overlayView.y = self.height-45
            
            separator.backgroundColor = .white
            separator.width = self.width-10
            separator.x = 5
            separator.y = 22
            separator.height = 1
            
            titleLabel.size = sizeMake(self.width-10, 14)
            titleLabel.origin = pointMake(5, 4)
            titleLabel.font = Font.Roboto.font(12)
            titleLabel.textColor = .white
            
            userNameLebel.size = sizeMake(self.width-10, 14)
            userNameLebel.origin = pointMake(5, 27)
            userNameLebel.font = Font.Roboto.font(12)
            userNameLebel.textColor = .white
            
            overlayView.addSubviews(titleLabel,userNameLebel,separator)
            addSubviews(imageView,overlayView)
            super.setup()
            shadowLevel = 1
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





