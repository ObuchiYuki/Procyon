import UIKit

class PixivAccountView: RMControl {
    
    var userData:pixivFullUserData? = nil{
        didSet{
            if let userData = userData{
                pixiv.getImage(url: userData.profile.backgroundImageUrl){self.bacgroundImageView.image = $0}
                accountNameLabel.text = userData.user.name
                pixiv.getAccountImage(userData: userData.user, completion: {image in
                    self.accountImageView.image = image.resize(to: sizeMake(37, 37)*2)
                })
            }
        }
    }
    private let bacgroundImageView = UIImageView()
    private let accountImageView = UIImageView()
    private let accountNameLabel = UILabel()
    
    override func setup(){
        super.setup()
        self.size = sizeMake(screen.width, 90)
        
        bacgroundImageView.frame.size = self.frame.size
        bacgroundImageView.frame.origin = CGPoint.zero
        bacgroundImageView.contentMode = .scaleAspectFill
        bacgroundImageView.clipsToBounds = true
        bacgroundImageView.image = #imageLiteral(resourceName: "HOMEBGImage")
        
        accountImageView.frame.size = sizeMake(37, 37)
        accountImageView.frame.origin = Point(20, 20)
        accountImageView.noCorner()
        accountImageView.backgroundColor = .hex("bbbbbb")
        accountImageView.clipsToBounds = true
        
        accountNameLabel.frame.size = sizeMake(self.frame.width-100, 20)
        accountNameLabel.textColor = UIColor.white
        accountNameLabel.font = Font.Roboto.font(16,style: .normal)
        accountNameLabel.frame.origin = Point(20, 60)
        accountNameLabel.layer.shadowColor = UIColor.black.cgColor
        accountNameLabel.layer.shadowRadius = 2
        accountNameLabel.layer.shadowOffset = .zero
        accountNameLabel.layer.shadowOpacity = 0.75
        
        addSubview(bacgroundImageView)
        addSubview(accountImageView)
        addSubview(accountNameLabel)
    }
}














