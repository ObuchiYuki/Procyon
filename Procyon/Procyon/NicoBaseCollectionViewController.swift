/*import UIKit
import HTML

protocol NicoSeigaCollectionViewDelegate: NSObjectProtocol{
    func cellTapped(datas: NicoContentsData,at index: Int)
}

class NicoSeigaBaseCollectionViewController: ADViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var size:CGSize? = nil{
        didSet{
            guard let size = size else {return}
            self.view.size = size
            self.mainCollectionView.size = size
        }
    }
    weak var delegate:NicoSeigaCollectionViewDelegate? = nil
    var datas = NicoContentsData()
    
    private var page = 1
    private var isCallingNewData = false
    //================================
    //views
    var mainCollectionView : UICollectionView!
    private let indicator = ADRefreshControl()
    //====================================================================
    //func
    func reload(){
        page = 1
        self.datas = NicoContentsData()
        self.indicator.beginRefreshing()
        self.runApi(page: page, handler: getDataFin)
    }
    func runApi(page:Int,handler:@escaping htmlBlock){}
    func cellTapped(index: Int){
        delegate?.cellTapped(datas: datas,at: index)
    }
    //====================================================================
    //private func
    private func getDataFin(html:HTML){
        isCallingNewData = false
        datas.append(html: html)
        indicator.endRefreshing()   
        mainCollectionView.reloadData()
    }
    //====================================================================
    //override func
    final override func setupSetting_P() {
        super.setupSetting_P()
        contentView.backgroundColor = .clear
        view.backgroundColor = .clear
        self.runApi(page: 1, handler: getDataFin)
        
        if let size = size{
            self.view.size = size
        }else{
            self.view.height = screen.height-112
        }
        
        mainCollectionView = UICollectionView(frame: .zero, collectionViewLayout: PixivSystem.layout)
        mainCollectionView.register(NicoSeigaThumbnailCell.self, forCellWithReuseIdentifier: "thumbnailCell")
        mainCollectionView.backgroundColor = .clear
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        indicator.beginRefreshing()
        
        addSubview(indicator)
        addSubview(mainCollectionView)
    }
    final override func setupScreen_P() {
        super.setupScreen_P()
        
        indicator.center = contentView.center
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as! NicoSeigaThumbnailCell
        let workData = datas.works[indexPath.row]
        
        cell.reset()
        cell.workData = workData
        workData.imageUrl.request.getImage{image in if cell.id == workData.id{cell.image = image}}
        
        if indexPath.row+1 == collectionView.numberOfItems(inSection: 0) && !isCallingNewData{
            isCallingNewData = true;page+=1
            runApi(page: page, handler: getDataFin)
        }
        
        return cell
    }
}
class TestInner: NicoSeigaBaseCollectionViewController{
    var word = "東方"
    override func runApi(page:Int, handler: @escaping htmlBlock) {
        nico.search(word: word, sort: .image_view, page: page, completion: handler)
    }
}






*/
