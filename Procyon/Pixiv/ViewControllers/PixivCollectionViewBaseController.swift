import UIKit

protocol PixivWorkCollectionViewDelegate: NSObjectProtocol{
    func cellTapped(datas: pixivContentsData,at index: Int)
}

class PixivCollectionViewBaseController: ADViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    //====================================================================
    //public properties
    var nonWorkMassage = "no_illusts".l(){
        didSet{
            nonWorkLabel.text = nonWorkMassage
        }
    }
    var size:CGSize? = nil{
        didSet{
            guard let size = size else {return}
            self.view.size = size
            self.mainCollectionView.size = size
        }
    }
    var headerView:UIView? = nil{
        didSet{
            guard let headerView = headerView else { return }
            headerView.y = -headerView.height
            headerViewHeight = headerView.height
            mainCollectionView.addSubview(headerView)
        }
    }
    var isHeaderViewScrollable = true{
        didSet{
            if !isHeaderViewScrollable{
                guard let headerView = headerView else { return }
                headerView.removeFromSuperview()
                headerView.y = 0
                addSubview(headerView)
            }
        }
    }
    var headerViewHeight:CGFloat = 0{
        didSet{
            refreshControl.y = headerViewHeight
            mainCollectionView.contentInset.top  = headerViewHeight
        }
    }
    var datas = pixivContentsData()
    weak var delegate:PixivWorkCollectionViewDelegate? = nil
    
    private var isCallingNewData = false
    private var isAllDataLoaded = false
    //================================
    //views
    var mainCollectionView : UICollectionView!
    private let refreshControl = RMRefreshControl()
    private let indicator = ADActivityIndicator()
    private let nonWorkLabel = UILabel()
    //====================================================================
    //func
    func runApi(handler:@escaping jsonBlock){}
    func callNextData(handler:@escaping jsonBlock){
        pixiv.get(datas.nextUrl.request, handler)
    }
    func reset(){
        if mainCollectionView==nil{return}
        datas.reset()
        isAllDataLoaded = false
        if let collectionView = mainCollectionView{
            collectionView.reloadData()
        }
    }
    func remove(at index:Int){
        if mainCollectionView==nil{return}
        datas.works.remove(at: index)
        mainCollectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
    func reload(){
        if mainCollectionView==nil{return}
        self.reset()
        self.indicator.start()
        self.runApi(handler: getDataFin)
    }
    func onShowCellMenu(menu: ADMenu,at index:Int){menu.show(windowAnimated: true)}
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
    func cellTapped(index: Int){
        delegate?.cellTapped(datas: datas,at: index)
    }
    func setDatas(datas:pixivContentsData){
        self.datas = datas
        nonWorkLabel.isHidden = !(datas.count == 0)
        isCallingNewData = false
        refreshControl.endRefreshing()
        indicator.stop()
        
        guard let mainCollectionView = mainCollectionView else {return}
        mainCollectionView.reloadData()
    }
    func getDataFin(json:JSON){
        isCallingNewData = false
        refreshControl.endRefreshing()
        datas.append(json) {[weak self] in
            guard let me = self else {return}
            me.mainCollectionView.reloadData()
            me.nonWorkLabel.isHidden = !(me.datas.count == 0)
            me.indicator.stop()
        }
        if json["illusts"].count == 0 {
            isAllDataLoaded=true
        }
    }
    //====================================================================
    //private func
    private func addBookmark(at index:Int,restrict:PixivRestrict){
        pixiv.addBookMark(id: datas.works.index(index)?.id ?? 0, restrict: restrict){json in
            if json["error"].isEmpty{
                ADSnackbar.show(restrict == .public ? "bookmarked".l() : "private_bookmarked".l())
                (self.mainCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PixivWorkThumbnailCell)?.isBookmarked = true
                self.datas.works[index].isBookmarked = true
            }else{ADSnackbar.show("error".l())}
        }
    }
    private func deleteBookmark(at index:Int){
        pixiv.deleteBookMark(id: datas.works.index(index)?.id ?? 0){json in
            if json["error"].isEmpty{
                ADSnackbar.show("bookmark_removede".l())
                (self.mainCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PixivWorkThumbnailCell)?.isBookmarked = false
                self.datas.works[index].isBookmarked = false
            }else{ADSnackbar.show("error".l())}
        }
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
        let point = sender.location(in: mainCollectionView)
        if let indexPath = mainCollectionView.indexPathForItem(at: point) {
            self.cellLongTapped(index: indexPath.row)
        }
    }
    //====================================================================
    //override func
    final override func setupSetting_P() {
        super.setupSetting_P()
        contentView.backgroundColor = .clear
        view.backgroundColor = .clear
        datas.collectionViewController = self
        self.runApi(handler: getDataFin)
        
        if let size = size{
            self.view.size = size
        }else{
            self.view.height = screen.height-112
        }
        
        let longPressRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(PixivCollectionViewBaseController.onLongPressAction)
        )
        
        mainCollectionView = UICollectionView(frame: .zero, collectionViewLayout: PixivSystem.layout)
        mainCollectionView.register(PixivWorkThumbnailCell.self, forCellWithReuseIdentifier: "thumbnailCell")
        mainCollectionView.backgroundColor = .clear
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.addGestureRecognizer(longPressRecognizer)
        mainCollectionView.backgroundView = refreshControl
        
        refreshControl.addAction{[weak self] in self?.reload()}
        
        indicator.lineWidth = 2
        indicator.size = sizeMake(30, 30)
        indicator.color = .accent
        indicator.start()
        
        nonWorkLabel.textAlignment = .center
        nonWorkLabel.text = nonWorkMassage
        nonWorkLabel.textColor = .subText
        nonWorkLabel.isHidden = true
        
        addSubview(indicator)
        addSubview(nonWorkLabel)
        addSubview(mainCollectionView)
    }
    final override func setupScreen_P() {
        super.setupScreen_P()
        
        indicator.center = contentView.center
        
        nonWorkLabel.size = sizeMake(screen.width, 30)
        nonWorkLabel.center = contentView.center
        
        mainCollectionView.size = contentSize
    }
    //====================================================================
    //delegate method
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellTapped(index: indexPath.row)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionView.collectionViewLayout.invalidateLayout()
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as! PixivWorkThumbnailCell
        let workData = datas.works[indexPath.row]
        
        cell.reset()
        cell.workData = workData
        cell.bookMarkAction = {[weak self] handler in self?.bookmarkApi(handler: handler, index: indexPath.row)}
        cell.bookmarkTip.longTapAction = {[weak self] in self?.tipAction(cell: cell,index: indexPath.row)}
        
        let request = workData.imageUrls.squareMedium.request
        request.referer = pixiv.referer
        request.getImage{image in
            if cell.id == workData.id{cell.image = image}
        }
        
        if indexPath.row+1 == collectionView.numberOfItems(inSection: 0) {
            if !isCallingNewData && !isAllDataLoaded{
                callNextData(handler: getDataFin)
                isCallingNewData = true
            }
        }
        return cell
    }
}














