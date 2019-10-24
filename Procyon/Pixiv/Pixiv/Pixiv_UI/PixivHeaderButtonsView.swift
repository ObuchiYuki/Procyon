import UIKit

class PixivHeaderButtonsView: RMView {
    let tip = ADTip(icon: "tune")
    override func setup() {
        super.setup()
        self.size = sizeMake(screen.width, 25)
        
        tip.size = sizeMake(35, 35)
        tip.origin = pointMake(screen.width-35, -2)
        tip.titleLabel?.font = Font.MaterialIcons.font(20)
        tip.titleColor = .subText
        
        addSubview(tip)
    }
    init(icon:String) {
        super.init(frame: .zero)
        tip.title = icon
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
