import UIKit

class PixivButtonCell : PixivCardCellBase {
    var title = ""{
        didSet{
            titleLabel.text = title
        }
    }
    var showDisclosure = false{
        didSet{
            if showDisclosure {
                disclosureIndicator.size = sizeMake(20, 20)
                disclosureIndicator.centerY = self.height/2
                disclosureIndicator.rightX = self.width-10
                disclosureIndicator.textColor = .hex("bbb")
                disclosureIndicator.font = Font.MaterialIcons.font(20)
                disclosureIndicator.text = "chevron_right"
                addSubview(disclosureIndicator)
            }else{
                disclosureIndicator.removeFromSuperview()
            }
        }
    }
    var titleColor:UIColor? = nil{
        didSet{titleLabel.textColor = titleColor}
    }
    var textAlign:NSTextAlignment = .center{
        didSet{
            if textAlign == .left{
                titleLabel.size = sizeMake(screen.width-45, 20)
                titleLabel.x = 15
                titleLabel.textAlignment = textAlign
            }
        }
    }
    var fontSize:CGFloat = 0{
        didSet{self.titleLabel.font = Font.Roboto.font(fontSize)}
    }
    private let titleLabel = RMLabel()
    private let disclosureIndicator = UILabel()
    
    
    func reset(){
        titleLabel.size = sizeMake(screen.width-50, 20)
        titleLabel.x = 25
        titleLabel.textAlignment = .center
        titleLabel.font = Font.Roboto.font(17)
        titleLabel.textColor = .subText
        titleLabel.text = nil
        disclosureIndicator.removeFromSuperview()
        textLabel?.text = ""
    }
    
    override func didFrameChange() {
        super.didFrameChange()
        titleLabel.centerY = self.height/2
    }
    override func setup() {
        super.setup()
        selectionStyle = .none
        
        titleLabel.size = sizeMake(screen.width-45, 20)
        titleLabel.x = 15
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .subText
        titleLabel.textAlignment = .center
        
        addSubview(titleLabel)
    }
}




