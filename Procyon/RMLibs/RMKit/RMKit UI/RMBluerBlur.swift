import UIKit

class RMBlurView: UIVisualEffectView {
    var style:UIBlurEffectStyle = .light{
        didSet{
            self.effect = UIBlurEffect(style: style)
        }
    }
    
    func setup(){}
    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}
