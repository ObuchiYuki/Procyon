import UIKit

class PixivPageCountView: UIView {
    
    fileprivate let mangaLabel = UILabel()
    fileprivate let numLabel = UILabel(
        frame: CGRect(
            origin: CGPoint.zero,
            size: CGSize(width: 30, height: 20)
        )
    )
    var count = 0{
        didSet{
            numLabel.text = "\(count)"
            isHidden = count == 1
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(origin: .zero,size: CGSize(width: 40, height: 20)))
        self.cornerRadius = 2
        backgroundColor = UIColor(white: 0, alpha: 0.6)
        isHidden = true
        
        mangaLabel.size = sizeMake(13, 13)
        mangaLabel.center = CGPoint(x: 10, y: 10)
        mangaLabel.font = Font.MaterialIcons.font(13)
        mangaLabel.textColor = UIColor.white
        mangaLabel.text = "library_books"
        
        numLabel.center = CGPoint(x: 22, y: 10)
        numLabel.textAlignment = .right
        numLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        numLabel.textColor = UIColor.white
        
        addSubview(numLabel)
        addSubview(mangaLabel)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
