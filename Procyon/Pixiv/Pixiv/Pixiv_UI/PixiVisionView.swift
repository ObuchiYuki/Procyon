import UIKit

class PixiVisionView: RMView,UICollectionViewDelegate, UICollectionViewDataSource {
    
    var cellTapped:(pixiVisionData)->() = {_ in}
    
    var data:pixiVisionContentsData? = nil{
        didSet{collectionView.reloadData()}
    }
    
    private var isCallingNewData = false
    
    private var collectionView:UICollectionView! = nil
    private let pixiVisionTitleImage = UIImage()
    private let cardView = RMView()
    private let loadMoreView = RMView()
    private let loadMoreTip = ADTip(icon: "chevron_right")
    
    override func setup() {
        super.setup()
        pixivOther.getPixiVision{self.data=pixiVisionContentsData(json: $0)}
        
        self.size = sizeMake(screen.width, 130)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = sizeMake(160, 110)
        layout.sectionInset = UIEdgeInsetsMake(8, 13, 8, 8)
        layout.scrollDirection = .horizontal
        
        cardView.size = sizeMake(screen.width-10, 120)
        cardView.origin = Point(5, 5)
        cardView.backgroundColor = UIColor.white
        cardView.setAsCardView(with: .auto)
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(PixiVisionViewCell.self, forCellWithReuseIdentifier: "pixiVisionCell")
        collectionView.size = sizeMake(screen.width-5, 120)
        collectionView.origin = Point(0, 5)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        
        loadMoreView.size = sizeMake(60, 118)
        loadMoreView.origin = Point(screen.width-65, 6)
        loadMoreView.isUserInteractionEnabled = false
        
        loadMoreTip.origin = pointMake(screen.width-35, 0)
        loadMoreTip.size = sizeMake(35, 35)
        loadMoreTip.noCorner()
        loadMoreTip.titleLabel?.font = Font.MaterialIcons.font(20)
        loadMoreTip.titleColor = .hex("666")
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.hex("1").cgColor, UIColor.hex("1",alpha: 0).cgColor]
        gradientLayer.frame.size = loadMoreView.size
        gradientLayer.startPoint = Point(1, 0)
        gradientLayer.endPoint = Point(0, 0)
        
        loadMoreView.layer.insertSublayer(gradientLayer, at: 0)
        
        addSubview(cardView)
        addSubview(collectionView)
        addSubview(loadMoreView)
        //addSubview(loadMoreTip)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellTapped(data!.spotlightArticles[indexPath.row])
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pixiVisionCell", for: indexPath) as! PixiVisionViewCell
        let data = self.data!.spotlightArticles[indexPath.row]
        cell.reset()
        cell.data = data
        
        let request = data.thumbnail.request
        request.referer = pixiv.referer
        request.getImage {image in if cell.id==data.id{cell.image=image}}
        
        if indexPath.row+1 == collectionView.numberOfItems(inSection: 0) {
            if !isCallingNewData{
                isCallingNewData = true
                pixiv.get(self.data!.nextUrl.request) {json in
                    self.data?.appendJson(json)
                    self.collectionView.reloadData()
                    self.isCallingNewData = false
                }
            }
        }
        return cell
    }
}

private class PixiVisionViewCell: ADCollectionViewCell{
    var data:pixiVisionData? = nil{
        didSet{
            guard let data = data else {return}
            titleView.text = data.title
            typeLabel.text = data.subcategoryLabel
            typeLabel.sizeToFit()
            typeLabel.width += 10
            switch data.category {
            case .spotlight:
                self.themeColor = .hex("0E79FE")
            case .inspiration:
                self.themeColor = .hex("FB4107")
            case .tutorial:
                self.themeColor = .hex("1BD197")
            }
        }
    }
    var id:Int{
        return data?.id ?? 0
    }
    var image: UIImage? = nil{
        didSet{self.imageView.image = image}
    }
    private var themeColor:UIColor? = nil{
        didSet{
            coloredView.backgroundColor = themeColor
            typeLabel.backgroundColor = themeColor
            bottomColoredView.backgroundColor = themeColor?.alpha(0.75)
        }
    }
    private let coloredView = UIView()
    private let bottomColoredView = UIView()
    private let titleView = UITextView()
    private let imageView = UIImageView()
    private let typeLabel = UILabel()
    
    func reset(){
        titleView.text = ""
        imageView.image = nil
        typeLabel.text = ""
        typeLabel.backgroundColor = .clear
    }
    
    fileprivate override func setup() {
        coloredView.size = sizeMake(self.width, 5)
        
        bottomColoredView.size = sizeMake(self.width, 42)
        bottomColoredView.y = self.height - 42
        
        imageView.size = sizeMake(self.width, self.height-5)
        imageView.y = 5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .hex("bbb")
        
        titleView.origin = pointMake(2, self.height-40)
        titleView.size = sizeMake(self.width-6, 38)
        titleView.textColor = .white
        titleView.backgroundColor = .clear
        titleView.font = Font.Roboto.font(11,style: .normal)
        titleView.noPadding()
        titleView.isUserInteractionEnabled = false
        
        typeLabel.origin = pointMake(0, 5)
        typeLabel.size = sizeMake(40, 13)
        typeLabel.textAlignment = .center
        typeLabel.textColor = .white
        typeLabel.font = Font.Roboto.font(11,style: .normal)
        
        addSubview(imageView)
        addSubview(coloredView)
        addSubview(bottomColoredView)
        addSubview(titleView)
        addSubview(typeLabel)
        
        super.setup()
        unsafeShadowLevel = 1
        cornerRadius = 2
    }
}

