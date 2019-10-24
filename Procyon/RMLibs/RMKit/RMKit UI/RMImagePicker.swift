import UIKit
import Photos

protocol RMImagePickerDelegate {
    func didLoadStart(_ imagePicker:RMImagePicker)
    func didLoadEnd(_ imagePicker:RMImagePicker)
}

class RMImagePicker: RMViewController ,UICollectionViewDelegate,UICollectionViewDataSource{
    
    var completion:([UIImage])->() = {_ in}
    var didSelect = {}
    var selectedIndexes:[Int]{return getSelectedIndexes()}
    var delegate:RMImagePickerDelegate? = nil
    
    func endPickingImage(){
        self.makeImageArray()
    }
    var size = CGSize(){
        didSet{
            collectionView.size = size
        }
    }
    var frame = CGRect(){
        didSet{
            collectionView.frame = frame
        }
    }
    private var collectionView:UICollectionView! = nil
    private var count = 0{
        didSet{
            collectionView.reloadData()
        }
    }
    private let imageManager = PHImageManager()
    private static var images:[String:UIImage] = [:]
    private var assets:[PHAsset] = []
    private var selectedIndexesDict:[Int:Bool] = [:]
    private var fullImageArray:[UIImage] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! RMImagePickerCell
        cell.isselected = !cell.isselected
        selectedIndexesDict[indexPath.row] = cell.isselected
        self.didSelect()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! RMImagePickerCell
        let image = RMImagePicker.images["\(indexPath.row)_Asset"]

        cell.isselected = selectedIndexesDict[indexPath.row] != nil && selectedIndexesDict[indexPath.row]!
        if image != nil{
            cell.image = image!
        }
        return cell
    }
    private func makeImageArray(){
        let selectedIndexes = self.selectedIndexes
        var loopCount = 0
        func setImageToArray(){
            imageManager.requestImageData(
                for: assets[selectedIndexes[loopCount]],
                options: nil,
                resultHandler: {data,_,_,_ in
                    self.fullImageArray.append(UIImage(data: data!)!)
                    if loopCount==selectedIndexes.count-1{
                        self.completion(self.fullImageArray)
                    }else{
                        loopCount+=1
                        setImageToArray()
                    }
                }
            )
        }
        if selectedIndexes.count != 0{
            setImageToArray()
        }else{
            completion([])
        }
    }
    
    private func getSelectedIndexes()->[Int]{
        var selectedIndexes = [Int]()
        
        for i in 0...count{
            if self.selectedIndexesDict[i] != nil && self.selectedIndexesDict[i]!{
                selectedIndexes.append(i)
            }
        }
        return selectedIndexes
    }
    private func getAllPhotosInfo() {
        delegate?.didLoadStart(self)
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        let assets = PHAsset.fetchAssets(with: .image, options: options)
        self.count = assets.count
        asyncQ({
            assets.enumerateObjects({asset, index, stop in
                self.assets.insert(asset , at: index)
                self.imageManager.requestImage(
                    for: asset ,
                    targetSize: CGSize(width: screen.width/4-2, height: screen.width/4-2),
                    contentMode: PHImageContentMode.aspectFill,
                    options: nil,
                    resultHandler: {image,info in
                        RMImagePicker.images["\(index)_Asset"] = image
                        mainQ{
                            self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                            if self.count == index-1{
                                self.delegate?.didLoadEnd(self)
                            }
                        }
                    }
                )
            })
        })
    }
    override func setSetting() {
        
    }
    override func setUISetting() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.zero
        layout.itemSize = CGSize(width: screen.width/4-2, height: screen.width/4-2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 2
        
        collectionView = UICollectionView(frame: fullScreenSize.rect, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(RMImagePickerCell.self, forCellWithReuseIdentifier: "MyCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        getAllPhotosInfo()
    }
    override func setUIScreen() {
        
    }
    override func addUIs() {
        addFullScreenView(collectionView)
    }
}
private class RMImagePickerCell:UICollectionViewCell{
    var image = UIImage(){
        didSet{
            self.imageView.image = image
        }
    }
    var isselected: Bool{
        set{
            rawSelected = newValue
            selectedIcon.isHidden = !newValue
            selectedView.isHidden = !newValue
        }
        get{
            return rawSelected
        }
    }
    private var rawSelected = false
    
    private let imageView = UIImageView()
    private let selectedView = UIView()
    private let selectedIcon = UIImageView(image: UIImage(named: "selected_icon")!)
    
    private func setup(){
        imageView.size = self.size
        selectedView.size = self.size
        selectedView.backgroundColor = .hex("1", alpha: 0.2)
        selectedView.isUserInteractionEnabled = false
        selectedIcon.size = sizeMake(35, 35)
        selectedIcon.origin = Point(self.width-35, self.height-35)
        
        isselected = false
        
        addSubview(imageView)
        addSubview(selectedView)
        addSubview(selectedIcon)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
