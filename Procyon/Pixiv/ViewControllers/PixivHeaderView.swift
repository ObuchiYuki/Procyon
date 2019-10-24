import UIKit

class PixivHeaderView: RMView {
    var title = ""{
        didSet{
            titleLabel.text = title
            titleLabel.isHidden = false
            lowerCardView.y = 15
            lowerCardView.height = 55
        }
    }
    var buttonTitle = ""{
        didSet{
            actionButton.title = buttonTitle
            actionButton.isHidden = false
            actionButton.sizeToFit()
            actionButton.width+=10
            actionButton.y = 22
            actionButton.rightX = screen.width-20
            lowerCardView.y = 15
            lowerCardView.height = 55
        }
    }
    let upperCardView = UIView()
    let lowerCardView = UIView()
    let actionButton = ADButton()
    private let titleLabel = UILabel()
    var type:SectionType = .default{
        didSet{
            switch type {
            case .default:
                break
            case .endSection:
                lowerCardView.removeFromSuperview()
            case .startSection:
                upperCardView.removeFromSuperview()
                lowerCardView.y = 5
            }
        }
    }
    enum SectionType {
        case endSection
        case startSection
        case `default`
    }
    
    static let defaultCardMargin:CGFloat = 10
    static let defaultHeight:CGFloat = 20
    static let edgeHeight:CGFloat = 10
    static let withTitleHeight:CGFloat = 50
    
    override func setup() {
        self.clipsToBounds = true
        
        titleLabel.size = sizeMake(screen.width-100, 20)
        titleLabel.isHidden = true
        titleLabel.origin = pointMake(20, 25)
        titleLabel.textColor = .subText
        titleLabel.font = Font.Roboto.font(13,style: .normal)
        
        actionButton.isHidden = true
        actionButton.titleColor = .main
        actionButton.titleLabel?.font = Font.Roboto.font(12,style: .normal)
        actionButton.cornerRadius = 2
        
        upperCardView.size = sizeMake(screen.width-10, 10)
        upperCardView.origin = pointMake(5, -5)
        upperCardView.backgroundColor = .white
        upperCardView.setAsCardView(with: .bordered,.shadowed,.cornerd)
        
        lowerCardView.size = sizeMake(screen.width-10, 10)
        lowerCardView.origin = pointMake(5, PixivHeaderView.defaultHeight+5-PixivHeaderView.defaultCardMargin)
        lowerCardView.backgroundColor = .white
        lowerCardView.setAsCardView(with: .bordered,.shadowed,.cornerd)
        
        addSubviews(upperCardView,lowerCardView,titleLabel,actionButton)
    }
}
