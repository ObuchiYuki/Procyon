import UIKit

protocol PixivNovelCollectionViewDelegate: NSObjectProtocol {
    func cellTapped(datas:pixivNovelContentsData,at index: Int)
}

class PixivNovelCollectionViewBaseController: ADViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    //====================================================================
    //public properties
    var nonWorkMassage = "no_novels".l(){
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
    weak var delegate:PixivNovelCollectionViewDelegate? = nil
    var datas = pixivNovelContentsData()
    
    private var isCallingNewData = false
    private var isAllDataLoaded = false
    //================================
    //views
    private var mainCollectionView : UICollectionView!
    private let refreshControl = RMRefreshControl()
    private let indicator = ADActivityIndicator()
    private let nonWorkLabel = UILabel()
    //====================================================================
    //func
    func runApi(handler:@escaping jsonBlock){}
    func callNextData(handler:@escaping jsonBlock){
        pixiv.get(datas.nextUrl.request, handler)
    }
    func setDatas(datas:pixivNovelContentsData){
        self.datas = datas
        nonWorkLabel.isHidden = !(datas.count == 0)
        isCallingNewData = false
        refreshControl.endRefreshing()
        indicator.stop()
        
        guard let mainCollectionView = mainCollectionView else {return}
        mainCollectionView.reloadData()
    }
    func reset(){
        if mainCollectionView==nil{return}
        datas.reset()
        if let collectionView = mainCollectionView{
            collectionView.reloadData()
        }
    }
    func remove(at index:Int){
        datas.novels.remove(at: index)
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
    func cellTapped(index: Int){
        delegate?.cellTapped(datas: datas,at: index)
    }
    //====================================================================
    //private func
    private func getDataFin(json:JSON){
        isCallingNewData = false
        refreshControl.endRefreshing()
        datas.append(json){
            self.mainCollectionView.reloadData()
            self.nonWorkLabel.isHidden = !(self.datas.count == 0)
            self.indicator.stop()
        }
    }
    private func addBookmark(at index:Int,restrict:PixivRestrict){
        novel.addBookMark(id: datas.novels.index(index)?.id ?? 0, restrict: restrict, completion: {json in
            if json["error"].isEmpty{
                ADSnackbar.show(restrict == .public ? "bookmarked".l() : "private_bookmarked".l())
                (self.mainCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PixivNovelThumbnailCell)?.isBookmarked = true
                self.datas.novels[index].isBookmarked = true
            }else{ADSnackbar.show("error".l())}
        })
    }
    private func deleteBookmark(at index:Int){
        novel.deleteBookMark(id: datas.novels.index(index)?.id ?? 0, completion: {json in
            if json["error"].isEmpty{
                ADSnackbar.show("bookmark_removede".l())
                (self.mainCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PixivNovelThumbnailCell)?.isBookmarked = false
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
    private func tipAction(cell:PixivNovelThumbnailCell,index:Int){
        let data = self.datas.novels[index]
        let menu = ADMenu()
        menu.useActionArr = true
        if data.isBookmarked{
            menu.iconArr.append("cancel")
            menu.titles.append("remove_bookmark".l())
            menu.actionArr.append{
                novel.deleteBookMark(id:  data.id, completion: {json in
                    if json["error"].isEmpty{
                        ADSnackbar.show("bookmark_removede".l())
                        cell.isBookmarked = false
                        self.datas.novels[index].isBookmarked = false
                    }else{ADSnackbar.show("error".l())}
                })
            }
        }else{
            menu.iconArr.append(contentsOf: ["bookmark","vpn_lock"])
            menu.titles.append(contentsOf: ["bookmark".l(),"privete_bookmark".l()])
            menu.actionArr.append(contentsOf: [
                {
                    novel.addBookMark(id: data.id, restrict: .public, completion: {json in
                        if json["error"].isEmpty{
                            ADSnackbar.show("bookmarked".l())
                            cell.isBookmarked = true
                            self.datas.novels[index].isBookmarked = true
                        }else{ADSnackbar.show("error".l())}
                    })
                },
                {
                    novel.addBookMark(id: data.id, restrict: .private, completion: {json in
                        if json["error"].isEmpty{
                            ADSnackbar.show("bookmarked".l())
                            cell.isBookmarked = true
                            self.datas.novels[index].isBookmarked = true
                        }else{ADSnackbar.show("error".l())}
                    })
                }
                ])
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
        runApi(handler: getDataFin)
        if let size = size{
            self.view.size = size
        }else{
            self.view.height = screen.height-112
        }
        
        let longPressRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(PixivNovelCollectionViewBaseController.onLongPressAction)
        )
        
        mainCollectionView = UICollectionView(frame: .zero, collectionViewLayout: PixivSystem.novelLayout)
        mainCollectionView.register(PixivNovelThumbnailCell.self, forCellWithReuseIdentifier: "thumbnailCell")
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as! PixivNovelThumbnailCell
        let novelData = datas.novels[indexPath.row]
        
        cell.reset()
        cell.novelData = novelData
        cell.bookMarkAction = {[weak self] handler in
            guard let me = self else {return}
            me.bookmarkApi(handler: handler, index: indexPath.row)
        }
        cell.bookmarkTip.longTapAction = {[weak self] in self?.tipAction(cell: cell, index: indexPath.row)}
        
        pixiv.getImage(url: novelData.imageUrls.medium){image in if cell.id == novelData.id{cell.image = image}}
        
        if indexPath.row+1 == collectionView.numberOfItems(inSection: 0) {
            if !isCallingNewData{
                callNextData(handler: getDataFin)
                isCallingNewData = true
            }
        }
        return cell
    }
}














