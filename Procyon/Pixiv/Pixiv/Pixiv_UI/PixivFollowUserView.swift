import UIKit

class PixivFollowUserView: RMView,UICollectionViewDelegate, UICollectionViewDataSource {
    
    var cellTapped:(pixivUserData)->() = {_ in}
    
    var data:pixivUserContentsData? = nil{didSet{collectionView.reloadData()}}
    
    let loadMoreButton = ADTip(icon: "chevron_right")
    private let cardView = RMView()
    private var collectionView:UICollectionView! = nil
    private let loadMoreView = RMView()
    private var isLoadingNextData = false

    override func setup() {
        super.setup()
        
        PixivSystem.getLoginData{_ in
            pixiv.getMyFollowUser(restrict: PixivSystem.restrict, completion: {json in
                self.data = pixivUserContentsData(json: json)
            })
        }
        
        self.size = sizeMake(screen.width, 66)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = sizeMake(40, 40)
        layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        layout.scrollDirection = .horizontal
        
        cardView.size = sizeMake(screen.width-10, 60)
        cardView.origin = Point(5, 5)
        cardView.backgroundColor = UIColor.white
        cardView.setAsCardView(with: .auto)
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(PixivFollowUserViewCell.self, forCellWithReuseIdentifier: "followUserViewCell")
        collectionView.size = sizeMake(screen.width-10-48, 60)
        collectionView.origin = Point(5, 5)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        
        loadMoreView.size = sizeMake(107, 58)
        loadMoreView.origin = Point(screen.width-65-48, 6)
        loadMoreView.isUserInteractionEnabled = false
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.hex("1").cgColor, UIColor.hex("1",alpha: 0).cgColor]
        gradientLayer.frame.size = loadMoreView.size
        gradientLayer.startPoint = Point(0.5, 0)
        gradientLayer.endPoint = Point(0, 0)

        loadMoreView.layer.insertSublayer(gradientLayer, at: 0)
        
        loadMoreButton.rightX = screen.width-5
        loadMoreButton.centerY = collectionView.centerY
        loadMoreButton.titleColor = .hex("bbb")
        
        addSubview(cardView)
        addSubview(collectionView)
        addSubview(loadMoreView)
        addSubview(loadMoreButton)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {cellTapped(data!.userPreviews[indexPath.row].user)}
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {return data?.count ?? 0}
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "followUserViewCell", for: indexPath) as! PixivFollowUserViewCell
        let userData = data!.userPreviews[indexPath.row].user
        cell.reset()
        cell.id = userData.id
        pixiv.getAccountImage(userData: userData, completion: {image in if cell.id==userData.id{cell.image=image}})
        
        if indexPath.row >= collectionView.numberOfItems(inSection: 0)-1{
            if !isLoadingNextData{
                isLoadingNextData = true
                pixiv.get((self.data?.nextUrl ?? "").request)
                {self.data?.append($0){self.collectionView.reloadData();self.isLoadingNextData=false}}
            }
        }
        
        return cell
    }
}

fileprivate class PixivFollowUserViewCell: ADCollectionViewCell {
    
    var image:UIImage? = nil{
        didSet{imageView.image = image?.resize(to: sizeMake(40, 40)*2)}
    }
    var id = 0
    private let imageView = UIImageView()
    
    func reset(){
        image = nil
        id = 0
    }
    fileprivate override func setup() {
        super.setup()
        self.size = sizeMake(40, 40)
        self.noCorner()
        self.clipsToBounds = true
        self.backgroundColor = .hex("bbbbbb")
        
        imageView.size = self.size
        
        addSubview(imageView)
    }
}
