import UIKit

class PixivNovelThumbnailCell: ADCollectionViewCell {
    var id = 0
    var bookMarkAction:(@escaping boolBlock)->() = {_ in}
    var image:UIImage? = nil{
        didSet{
            asyncQ {
                let image = self.image?.resize(
                    to: sizeMake(PixivSystem.novelThumbnailSize.height*(3/4), PixivSystem.novelThumbnailSize.height)*2
                )
                mainQ {
                    self.imageView.image = image
                }
            }
        }
    }
    var novelData:pixivNovelData? = nil{
        didSet {
            if novelData != nil{
                self.id = novelData!.id
                self.titleLabel.text = novelData!.title
                self.userNameLabel.text = novelData!.user.name
                self.pageCountView.count = novelData!.pageCount
                self.likeCountLabel.text = "\u{f388}  \(novelData!.totalBookmarks)"
                
                self.tagsView.text = novelData?.tags.subArray(to: 5).joined(separator: "・")
                
                if novelData!.isBookmarked{
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
    private let pageCountView = PixivPageCountView()
    private let likeCountLabel = RMLabel()
    private let tagsView = UITextView()
    
    func reset(){
        id = 0
        image = nil
        novelData = nil
    }
    
    private func bookmarkActionHandler(success:Bool){
        bookmarkTip.returnToButtonFromIndicator()
        if success{novelData?.isBookmarked<-!}
    }
    
    override func setup() {
        self.contentView.removeFromSuperview()
        self.backgroundColor = .white
        
        let thumbnailSize = PixivSystem.novelThumbnailSize
        
        imageView.size = sizeMake(thumbnailSize.height*(3/4), thumbnailSize.height)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        informationView.backgroundColor = .hex("0",alpha: 0.4)
        informationView.size = sizeMake(thumbnailSize.width - imageView.width,thumbnailSize.height)
        informationView.x = imageView.width
        
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        titleLabel.textColor = .white
        titleLabel.size = sizeMake(thumbnailSize.width-imageView.width-58, 20)
        titleLabel.x = 10
        titleLabel.centerY = 12
        
        separator.backgroundColor = .white
        separator.size = sizeMake(thumbnailSize.width-imageView.width-58, 1)
        separator.origin = pointMake(10, 34)
        separator.x = 10
        separator.centerY = 24
        
        userNameLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        userNameLabel.textColor = .white
        userNameLabel.size = sizeMake(thumbnailSize.width-imageView.width-58, 20)
        userNameLabel.x = 10
        userNameLabel.centerY = 36
        
        likeCountLabel.size = sizeMake(40, 12)
        likeCountLabel.origin = pointMake(informationView.width-42, informationView.height-20)
        likeCountLabel.font = Font.IonIcons.font(10)
        likeCountLabel.textColor = .white
        likeCountLabel.textAlignment = .center
        
        pageCountView.origin = pointMake(width-pageCountView.width-3, 3)
        
        tagsView.backgroundColor = .clear
        tagsView.isUserInteractionEnabled = false
        tagsView.textColor = .white
        tagsView.noPadding()
        tagsView.origin = pointMake(10, userNameLabel.y+userNameLabel.height)
        tagsView.size = sizeMake(thumbnailSize.width-imageView.width-58, thumbnailSize.height-tagsView.y-8)
        
        bookmarkTip.x = thumbnailSize.width-imageView.width-48
        bookmarkTip.centerY = thumbnailSize.height/2
        bookmarkTip.addAction {[weak self] in
            guard let me = self else{return}
            me.bookmarkTip.turnIntoIndicator()
            me.bookMarkAction(me.bookmarkActionHandler)
        }
        
        informationView.addSubviews(titleLabel,userNameLabel,separator,bookmarkTip,tagsView,likeCountLabel)
        addSubviews(imageView,informationView,pageCountView)
        super.setup()
        self.unsafeShadowLevel = 1
    }
}



