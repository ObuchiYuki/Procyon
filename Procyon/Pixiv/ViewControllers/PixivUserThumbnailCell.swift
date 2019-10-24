import UIKit

class PixivUserThumbnailCell: ADCollectionViewCell {
    var innerAction:(pixivWorkData)->() = {_ in}
    
    var previewData:pixivUserContentsData.pixivUserPreviewData? = nil{
        didSet {
            guard let previewData = previewData else {return}
            self.id = previewData.user.id
            self.userNameLabel.text = previewData.user.name
            self.followButton.isFollowed = previewData.user.isFollowed
            
            pixiv.getAccountImage(userData: previewData.user, completion: {image in
                if self.id==previewData.user.id{self.userImageView.image=image.resize(to: sizeMake(37, 37)*2)}
            })
            for i in 0...2{
                let request = (previewData.illusts.index(i)?.imageUrls.squareMedium ?? "").request
                request.referer = pixiv.referer
                request.getImage{image in
                    asyncQ {
                        let resizedImage = image.resize(to: PixivSystem.userThumbnailInnerSize*2)
                        mainQ {if self.id==previewData.user.id{self.workPreviewViews[i].image = resizedImage}}
                    }
                    
                }
                workPreviewViews[i].data = previewData.illusts.index(i)
            }
        }
    }
    private var id = 0
    
    let followButton = PixivFollowButton()
    private let userImageView = UIImageView()
    private let userNameLabel = UILabel()
    private let workPreviewViews = [workPreviewView(),workPreviewView(),workPreviewView()]
    
    func reset(){
        id = 0
        userNameLabel.text = nil
        workPreviewViews.map{view in view.reset()}
        followButton.removeAllActions()
    }
    
    override func setup() {
        self.setAsCardView(with: .auto)
        self.contentView.removeFromSuperview()
        self.backgroundColor = .white
        
        let thumbnailSize = PixivSystem.userThumbnailSize
        
        userImageView.size = sizeMake(37, 37)
        userImageView.origin = pointMake(7, 7)
        userImageView.noCorner()
        userImageView.clipsToBounds = true
        userImageView.backgroundColor = .hex("bbb")
        
        userNameLabel.size = sizeMake(thumbnailSize.width-180, 20)
        userNameLabel.centerY = userImageView.centerY
        userNameLabel.x = 60
        
        followButton.centerY = userImageView.centerY
        followButton.size = sizeMake(80, 30)
        followButton.rightX = thumbnailSize.width-10
        followButton.titleLabel?.font = Font.Roboto.font(14)
        
        for (i,view) in workPreviewViews.enumerated(){
            view.addAction{[weak self] in self?.innerAction(view.data!)}
            view.y = 51
            view.x = (i.cgFloat*(PixivSystem.userThumbnailInnerSize.height+5))+5
        }
        
        super.setup()
        addSubviews(userImageView,userNameLabel,followButton)
        addSubviews(viewArr: workPreviewViews)
        
        rippleLayerColor = .hex("bbb")
    }
}

fileprivate class workPreviewView: RMButton{
    var data:pixivWorkData? = nil{
        didSet{
            guard let data = data else {
                self.isHidden = true
                return
            }
            self.isHidden = false
            titelLebel.text = data.title
            countView.count = data.pageCount
        }
    }
    var image:UIImage? = nil{
        didSet{mainImageView.image = image}
    }
    private let mainImageView = UIImageView()
    private let countView = PixivPageCountView()
    private let titelLebel = UILabel()
    private let informationView = UIView()
    
    func reset(){
        titelLebel.text = ""
        image = nil
    }
    
    fileprivate override func setup() {
        super.setup()
        backgroundColor = .hex("bbb")
        size = PixivSystem.userThumbnailInnerSize
        unsafeShadowLevel = 1
        
        mainImageView.size = self.size
        
        countView.y = 2
        countView.rightX = size.width-2
        
        informationView.size = sizeMake(size.width, 20)
        informationView.origin = pointMake(0, size.width-20)
        informationView.backgroundColor = .hex("0",alpha: 0.4)
        
        titelLebel.size = sizeMake(size.width-10, 10)
        titelLebel.origin = pointMake(5, 5)
        titelLebel.textColor = .white
        titelLebel.font = Font.Roboto.font(10,style: .normal)
        
        informationView.addSubview(titelLebel)
        
        addSubview(mainImageView)
        addSubview(countView)
        addSubview(informationView)
    }
}







