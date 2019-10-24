/*import UIKit

class NicoSeigaThumbnailCell: RMCollectionViewCell {
    var id = ""
    var image:UIImage?{
        set{
            imageView.image = newValue
        }
        get{
            return imageView.image
        }
    }
    var workData:NicoThumbnailWorkData? = nil{
        didSet {
            if let workData = workData{
                self.id = workData.id
                self.titleLabel.text = workData.title
                self.userNameLabel.text = workData.userName
            }
        }
    }
    
    private let informationView = UIView()
    private let titleLabel = UILabel()
    private let userNameLabel = UILabel()
    private let separator = UIView()
    private let imageView = UIImageView()
    
    func reset(){
        id = ""
        image = nil
        workData = nil
    }
    override func setup() {
        self.unsafeShadowLevel = 1
        self.contentView.removeFromSuperview()
        self.backgroundColor = .white
        
        let thumbnailSize = PixivSystem.thumbnailSize
        
        imageView.size = thumbnailSize
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        informationView.size = sizeMake(thumbnailSize.width, 48)
        informationView.y = thumbnailSize.width-48
        informationView.backgroundColor = .hex("0",alpha: 0.4)
        
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        titleLabel.textColor = .white
        titleLabel.size = sizeMake(thumbnailSize.width-58, 20)
        titleLabel.x = 10
        titleLabel.centerY = 12
        
        separator.backgroundColor = .white
        separator.size = sizeMake(thumbnailSize.width-58, 1)
        separator.x = 10
        separator.centerY = 24
        
        userNameLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        userNameLabel.textColor = .white
        userNameLabel.size = sizeMake(thumbnailSize.width-58, 20)
        userNameLabel.x = 10
        userNameLabel.centerY = 36
        
        informationView.addSubviews(titleLabel,userNameLabel,separator)
        addSubviews(imageView,informationView)
    }
}
*/
