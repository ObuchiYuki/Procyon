import UIKit

class PixivAlbumCell: ADTableViewCell {
    var firstImage:UIImage? = nil{
        didSet{
            asyncQ {
                let image = self.firstImage?.resize(to: sizeMake(50, 50)*2)
                mainQ{
                    self.firstImageView.image = image
                }
            }
        }
    }
    
    private var firstImageView = UIImageView()
    private var titleLabel = UILabel()
    private let subTitleLabel = UILabel()
    
    var data:pixivAlbumData? = nil{
        didSet{
            guard let data = data else { return }
            titleLabel.text = data.title
            titleLabel.sizeToFit()
            subTitleLabel.text = "\(data.count)つの作品"
        }
    }
    var id:Int{
        return data?.id ?? -1
    }
    override func setup() {
        super.setup()
        separator.isHidden = true
        titleLabel.size = sizeMake(screen.width-200, 20)
        titleLabel.x = 75
        titleLabel.centerY = 20
        titleLabel.font = Font.Roboto.font(15,style: .normal)
        titleLabel.isUserInteractionEnabled = false
        
        subTitleLabel.textColor = .subText
        subTitleLabel.size = sizeMake(100, 12)
        subTitleLabel.font = Font.Roboto.font(12,style: .normal)
        subTitleLabel.origin = pointMake(75, 34)
        
        firstImageView.origin = pointMake(14, 5)
        firstImageView.size = sizeMake(50, 50)
        firstImageView.cornerRadius = 4
        firstImageView.clipsToBounds = true
        firstImageView.backgroundColor = .hex("bbbbbb")
        firstImageView.isUserInteractionEnabled = false
        
        if PixivSystem.isPrivate{
            titleLabel.textColor = .white
            subTitleLabel.textColor = .white
        }
        
        addSubview(firstImageView)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
    }
}
