import UIKit

protocol PixivUserCollectionViewDelegate: NSObjectProtocol {
    func cellTapped(data:pixivUserData)
    func innerCellTapped(data:pixivWorkData)
}

class PixivUserCollectionViewBaseController: ADViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    //====================================================================
    //public properties
    var nonWorkMassage = "no_users".l(){
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
    weak var delegate:PixivUserCollectionViewDelegate? = nil
    var datas = pixivUserContentsData()
    
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
    func reset(){
        datas.reset()
        if let collectionView = mainCollectionView{
            collectionView.reloadData()
        }
    }
    func remove(at index:Int){
        datas.userPreviews.remove(at: index)
        mainCollectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
    func reload(){
        self.reset()
        self.indicator.start()
        self.runApi(handler: getDataFin)
    }
    func cellLongTapped(index: Int){}
    func cellTapped(index: Int){
        delegate?.cellTapped(data: datas.userPreviews[index].user)
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
    private func followApi(handler:@escaping boolBlock,index:Int,data:pixivUserData){
        if data.isFollowed{
            pixiv.deleteFollowUser(id: data.id, completion: {json in
                handler(json["error"].isEmpty)
                self.datas.userPreviews[index].user.isFollowed = false
            })
        }else{
            pixiv.addFollowUser(id: data.id, restrict: PixivSystem.restrict, completion: {json in
                handler(json["error"].isEmpty)
                self.datas.userPreviews[index].user.isFollowed = true
            })
        }
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
        runApi(handler: getDataFin)
        if let size = size{
            self.view.size = size
        }else{
            self.view.height = screen.height-112
        }
        
        let longPressRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(PixivUserCollectionViewBaseController.onLongPressAction)
        )
        
        mainCollectionView = UICollectionView(frame: .zero, collectionViewLayout: PixivSystem.userLayout)
        mainCollectionView.register(PixivUserThumbnailCell.self, forCellWithReuseIdentifier: "thumbnailCell")
        mainCollectionView.backgroundColor = .clear
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.addGestureRecognizer(longPressRecognizer)
        mainCollectionView.backgroundView = refreshControl
        
        refreshControl.addAction{[weak self] in self?.reload()}
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as! PixivUserThumbnailCell
        let previewData = datas.userPreviews[indexPath.row]
        
        cell.reset()
        cell.previewData = previewData
        cell.innerAction = {[weak self] data in
            self?.delegate?.innerCellTapped(data: data)
        }
        cell.followButton.addAction{[weak self] in
            if previewData.user.isFollowed{
                pixiv.deleteFollowUser(id: previewData.user.id, completion: {json in
                    if json["error"].isEmpty{
                        cell.followButton.isFollowed=false
                        self?.datas.userPreviews[indexPath.row].user.isFollowed = false
                    }else{ADSnackbar.show("error".l())}
                })
            }else{
                pixiv.addFollowUser(id: previewData.user.id, restrict: PixivSystem.restrict, completion: {json in
                    if json["error"].isEmpty{
                        cell.followButton.isFollowed=true
                        self?.datas.userPreviews[indexPath.row].user.isFollowed = true
                    }else{ADSnackbar.show("error".l())}
                })
            }
        }
        
        if indexPath.row+1 == collectionView.numberOfItems(inSection: 0) {
            if !isCallingNewData{
                callNextData(handler: getDataFin)
                isCallingNewData = true
            }
        }
        return cell
    }
}














