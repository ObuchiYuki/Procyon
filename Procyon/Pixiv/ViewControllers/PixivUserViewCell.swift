import UIKit

class PixivUserViewCell: PixivCardCellBase {
    var authorImage:UIImage?{
        set{
            _authorImage = newValue
            asyncQ {
                let resizedImage = newValue?.resize(to: sizeMake(50, 50)*2)
                mainQ {
                    self.authorImageView.image = resizedImage
                }
            }
        }
        get{
            return _authorImage
        }
    }
    let followButton = PixivFollowButton()
    private var authorImageView = UIImageView()
    private var _authorImage:UIImage? = nil
    private var titleLabel = UILabel()
    var data:pixivUserData? = nil{
        didSet{
            guard let data = data else { return }
            titleLabel.text = data.name
            followButton.isFollowed = data.isFollowed
        }
    }
    override func setup() {
        super.setup()
        selectionStyle = .none
        
        titleLabel.size = sizeMake(screen.width-170, 20)
        titleLabel.x = 75
        titleLabel.centerY = 30
        titleLabel.font = Font.Roboto.font(15,style: .normal)
        titleLabel.isUserInteractionEnabled = false
        
        authorImageView.origin = pointMake(14, 5)
        authorImageView.size = sizeMake(50, 50)
        authorImageView.noCorner()
        authorImageView.clipsToBounds = true
        authorImageView.backgroundColor = .hex("bbbbbb")
        authorImageView.isUserInteractionEnabled = false
        
        followButton.rightX = screen.width-20
        followButton.centerY = 30
        
        addSubview(authorImageView)
        addSubview(titleLabel)
        addSubview(followButton)
    }
}
class PixivFollowButton:ADButton{
    var isFollowed = false{
        didSet{
            setAppearance()
        }
    }
    private func setAppearance(){
        if isFollowed{
            layer.borderColor = ADColor.Grey.P500.cgColor
            titleColor = ADColor.Grey.P500
            title = "remove_follow".l()
        }else{
            layer.borderColor = ADColor.Red.P500.cgColor
            titleColor = ADColor.Red.P500
            title = "follow".l()
        }
    }
    override func setup(){
        super.setup()   
        cornerRadius = 5
        titleLabel?.font = Font.Roboto.font(14)
        layer.borderWidth = 1
        size = sizeMake(65, 25)
        setAppearance()
    }
}
