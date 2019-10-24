import UIKit

protocol PixivBaesViewControllerDelegate {
    func cellTapped(_ json:JSON,isNovel:Bool)
}

class PixivBaesViewController: ADViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    //====================================================================
    //public properties
    var alertMessage = "イラストがありません"{
        didSet{
            alertLabel.text = alertMessage
        }
    }
    var delegate:PixivBaesViewControllerDelegate? = nil
    var isEnd = false
    var jsons:[JSON] = []
    var nextURL = ""
    
    var collectionView : UICollectionView!
    let indicator = ADRefreshControl()
    let refreshControl = RMRefreshControl()
    let alertLabel = RMLabel()
    //====================================================================
    //method
    func IllustData(_ json: JSON, row: Int) -> JSON {
        let data = json["illusts"][row]
        return data
    }
    func IllustNum(_ json: JSON) -> Int {
        let num = json["illusts"].count
        return num
    }
    func IllustTags(_ json: JSON) -> [String] {
        return json["tags"].arrayValue.map{tag in
            return tag.stringValue
        }
    }
    //====================================================================
    //delegateMethod
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let illustData = jsons[indexPath.row]
        delegate?.cellTapped(illustData,isNovel: false)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jsons.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! PixivThumbnailCell
        
        
        let illustData = jsons[indexPath.row]
        
        cell.image = nil
        cell.title = illustData["title"].stringValue
        cell.authorName = illustData["user"]["name"].stringValue
        cell.illustNum = illustData["page_count"].intValue
        cell.id = illustData["id"].stringValue
        cell.isbookmarked = illustData["isbookmarked"].boolValue
        cell.ugoiraView.isHidden = !(illustData["type"].stringValue == "ugoira")
        
        if let image = cache.image(forKey: illustData["id"].stringValue){
            cell.image = image
        }else{
            let request = illustData["image_urls"]["square_medium"].stringValue.request
            request.headers  = [
                "Referer":pixiv.referer
            ]
            request.getImage{image in
                asyncQ {
                    cache.set(image.resize(to: cell.size*2), forKey: illustData["id"].stringValue)
                    mainQ {
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        }
        //======================================
        //if last cell next
        if indexPath.row+1 == collectionView.numberOfItems(inSection: 0) {
            let request = nextURL.request
            request.headers = pixiv.headers
            request.getJson(getDataFin)
        }
        return cell
    }
    
    func getDataFin(_ json:JSON){
        let illustNum = IllustNum(json)
        alertLabel.text = alertMessage
        alertLabel.isHidden = !(illustNum == 0 && nextURL.isEmpty)
        if !json["has_error"].boolValue && illustNum != 0{
            let Ntags = info.stringArray(forKey: "NtagNew") ?? []
            let NtagsContain = info.array(forKey: "NtagContain") as? [Bool] ?? []
            let Nusers = info.stringArray(forKey: "Nuser") ?? []
            let canShowR18 = !info.boolValue(forKey: "Nshow_r18")
            
            for i in 0...illustNum-1{
                let illustData = IllustData(json, row: i)
                let illustTags = IllustTags(illustData)
                let canAddillust = canAddIllust(
                    tags: illustTags,
                    authorName: illustData["user"]["name"].stringValue,
                    Ntags: Ntags,
                    NtagsContain: NtagsContain,
                    Nusers:Nusers,
                    canShowR18: canShowR18
                )
                if canAddillust{
                    if PixivSystem.inReview {
                        if illustData["sanity_level"].intValue == 2{
                            jsons.append(illustData)
                        }
                    }else{
                        jsons.append(illustData)
                    }
                }
            }
            nextURL = json["next_url"].stringValue
            collectionView.reloadData()
        }
        
        indicator.isHidden = true
        indicator.endRefreshing()
        refreshControl.endRefreshing()
    }
    
    func canAddIllust(tags:[String],authorName:String,Ntags:[String],NtagsContain:[Bool],Nusers:[String],canShowR18:Bool)->Bool{
        for tag in tags{
            if Ntags.count != 0{
                for i in 0...Ntags.count-1{
                    let Ntag = Ntags[i]
                    let NtagContain = NtagsContain[i]
                    if NtagContain{
                        if tag.contains(Ntag){
                            return false
                        }
                    }else if tag == Ntag{
                        return false
                    }else if !canShowR18 && tag == "R-18"{
                        return false
                    }
                }
            }else{
                if !canShowR18 && tag == "R-18"{
                    return false
                }
            }
        }
        for Nuser in Nusers {
            if authorName == Nuser{
                return false
            }
        }
        return true
    }
    //======================================
    //reload {pixiv.get...}
    func reload(){}
    //======================================
    //reloadSuper
    func reloadSuper(){
        isEnd = false
        jsons = []
        collectionView.reloadData()
        nextURL = ""
        reload()
    }
    //====================================================================
    //viewDidLoad {pixiv.get...}
    override func setupSetting_P() {
        super.setupSetting_P()
        //======================================
        //初期設定
        refreshControl.addAction(reloadSuper,forControlEvents: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        view.backgroundColor = UIColor.clear
        
        contentView.backgroundColor = UIColor.clear
        //======================================
        //設定
        indicator.backgroundColor = UIColor.clear
        indicator.layer.position = Point(view.center.x, view.center.y - 100)
        indicator.beginRefreshing()
        indicator.color = AppColor.accentColor
        
        alertLabel.size = sizeMake(200, 30)
        alertLabel.centerX = view.centerX
        alertLabel.centerY = view.centerY-92
        alertLabel.textColor = AppColor.subTextColor
        alertLabel.textAlignment = .center
        alertLabel.isHidden = true
        //===================
        // CollectionViewのレイアウトを生成.
        let layout = UICollectionViewFlowLayout()
        
        if device.isiPad{
            layout.itemSize = sizeMake((screen.width/4)-12, (screen.width/4)-12)
        }else {
            layout.itemSize = sizeMake((screen.width/2)-12, (screen.width/2)-12)
        }
        
        layout.sectionInset = UIEdgeInsetsMake(7, 7, 7, 7)
        
        collectionView = UICollectionView(frame:
            CGRect(
                x: 0,
                y: 0,
                width: view.frame.width,
                height: view.frame.height-72-40
            ),
                                          collectionViewLayout: layout
        )
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(PixivThumbnailCell.self, forCellWithReuseIdentifier: "MyCell")
        collectionView.backgroundView = refreshControl
        collectionView.delegate = self
        collectionView.dataSource = self
        //======================================
        //add
        addSubview(collectionView)
        collectionView.addSubview(indicator)
        collectionView.addSubview(alertLabel)
        reload()
    }
}






















