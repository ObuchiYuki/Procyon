import UIKit

class PixivWorkThumbnailCell: ADCollectionViewCell {
    var id = 0
    var bookMarkAction:(@escaping boolBlock)->() = {_ in}
    var image:UIImage?{
        set{
            imageView.image = newValue
        }
        get{
            return imageView.image
        }
    }
    var workData:pixivWorkData? = nil{
        didSet {
            if workData != nil{
                self.id = workData!.id
                self.titleLabel.text = workData!.title
                self.userNameLabel.text = workData!.user.name
                self.ugoiraIndicator.isHidden = (workData!.type != .ugoira)
                self.pageCountView.count = workData!.pageCount
                self.isBookmarked = workData!.isBookmarked
                
                if workData!.isBookmarked{
                    bookmarkTip.title = "bookmark"
                }else{
                    bookmarkTip.title = "bookmark_border"
                }
            }
        }
    }
    var isBookmarked = false{
        didSet{
            if isBookmarked{
                bookmarkTip.title = "bookmark"
            }else{
                bookmarkTip.title = "bookmark_border"
            }
        }
    }
    let bookmarkTip = ADTip(icon: "bookmark")
    
    private let informationView = UIView()
    private let titleLabel = UILabel()
    private let userNameLabel = UILabel()
    private let separator = UIView()
    private let imageView = UIImageView()
    private var pageCountView = PixivPageCountView()
    private var ugoiraIndicator = PixivUgoiraView()
    
    func reset(){
        id = 0
        image = nil
        workData = nil
        isBookmarked = false
    }
    
    private func bookmarkActionHandler(success:Bool){
        bookmarkTip.returnToButtonFromIndicator()
        if success{isBookmarked<-!}
    }
    
    override func setup() {
        self.contentView.removeFromSuperview()
        self.backgroundColor = .white
        
        let thumbnailSize = PixivSystem.thumbnailSize
        
        imageView.size = thumbnailSize
        
        ugoiraIndicator.origin = pointMake(thumbnailSize.width-25, 5)
        pageCountView.origin = pointMake(thumbnailSize.width-45, 5)
        
        informationView.size = sizeMake(thumbnailSize.width, 48)
        informationView.y = thumbnailSize.width-48
        informationView.backgroundColor = .hex("0",alpha: 0.4)

        titleLabel.font = Font.Roboto.font(12)
        titleLabel.textColor = .white
        titleLabel.size = sizeMake(thumbnailSize.width-58, 20)
        titleLabel.x = 10
        titleLabel.centerY = 12
        
        separator.backgroundColor = .white
        separator.size = sizeMake(thumbnailSize.width-58, 1)
        separator.x = 10
        separator.centerY = 24
        
        userNameLabel.font = Font.Roboto.font(12)
        userNameLabel.textColor = .white
        userNameLabel.size = sizeMake(thumbnailSize.width-58, 20)
        userNameLabel.x = 10
        userNameLabel.centerY = 36
        
        bookmarkTip.x = thumbnailSize.width-48
        bookmarkTip.centerY = separator.centerY
        bookmarkTip.addAction {[weak self] in
            guard let me = self else{return}
            me.bookmarkTip.turnIntoIndicator()
            me.bookMarkAction(me.bookmarkActionHandler)
        }
        
        informationView.addSubviews(
            titleLabel,
            userNameLabel,
            separator,
            bookmarkTip
        )
        
        addSubviews(
            imageView,
            informationView,
            pageCountView,
            ugoiraIndicator
        )
        super.setup()
        self.unsafeShadowLevel = 1
    }
}



