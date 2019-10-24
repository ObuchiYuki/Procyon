import UIKit

enum ADMainButtonPosition {
    case lowerRight
    case lowerLeft
    case lowerCenter
    case upperRight
    case upperLeft
    case upperCenter
}
enum ADMainButtonAnimationStyle{
    case none
    case pop
    case move
}
class ADMainButton: ADButton {
    var position = ADMainButtonPosition.lowerRight
    private var animationStyle = ADMainButtonAnimationStyle.none
    private var didAnimate = false
    override var titleColor:UIColor{
        get{return currentTitleColor}
        set{setTitleColor(newValue, for: UIControlState())}
    }
    var icon:String{
        get{
            return currentTitle!
        }
        set(value){
            setTitle(value, for: UIControlState())
        }
    }
    @objc private func PmainButtonTapped(){
        self.runAction(.groupe([
            .shadowOffset(to: sizeMake(0, 9), duration: 0.3),
            .shadowRadius(to: 6, duration: 0.3)
        ]))
    }
    @objc private func PmainButtonOn(){
        PmainButtonOffed()
    }
    @objc private func PmainButtonOffed(){
        self.runAction(.groupe([
            .shadowOffset(to: sizeMake(0, 5), duration: 0.3),
            .shadowRadius(to: 4, duration: 0.3)
        ]))
    }
    override func setup(){
        super.setup()
        switch animationStyle {
        case .pop:
            self.transform = CGAffineTransform(scaleX: 0, y: 0)
        default:
            break
        }
    }
    func close(){
        UIView.animate(withDuration: 0.2, animations: {self.transform = CGAffineTransform(scaleX: 0, y: 0)})
    }
    func animate(){
        if !didAnimate{
            let oldPosition = self.frame.origin
            switch animationStyle {
            case .pop:
                self.transform = CGAffineTransform(scaleX: 0, y: 0)
                isHidden = false
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: .curveEaseOut,
                    animations: {
                        self.transform = CGAffineTransform(scaleX: 1, y: 1)
                    },
                    completion: {_ in}
                )
            case .move:
                self.frame.size = CGSize(width: 55, height: 55)
                noCorner()
                self.frame.origin.y += 80
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0.2,
                    options: .curveEaseOut,
                    animations: {
                        self.frame.origin = oldPosition
                    },
                    completion: {_ in}
                )
            case .none:
                break
            }
        }
        didAnimate = true
    }
    init(icon:String,position:ADMainButtonPosition = .lowerRight,animationStyle:ADMainButtonAnimationStyle = .pop){
        super.init(frame: CGRect.zero)
        self.position = position
        self.animationStyle = animationStyle
        if animationStyle == .pop{
            isHidden = true
        }
        backgroundColor = .accent
        frame.size = CGSize(width: 55, height: 55)
        noCorner()
        layer.shadowColor = UIColor.hex("444").cgColor
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 5)
        addTarget(self, action: #selector(ADMainButton.PmainButtonTapped), for: .touchDown)
        addTarget(self, action: #selector(ADMainButton.PmainButtonOn), for: .touchUpInside)
        addTarget(self, action: #selector(ADMainButton.PmainButtonOffed), for: .touchUpOutside)
        addTarget(self, action: #selector(ADMainButton.PmainButtonOffed), for: .touchCancel)
        titleLabel?.font = Font.MaterialIcons.font(24)
        setTitleColor(AppColor.mainButtonColor, for: .normal)
        setTitle(icon, for: UIControlState())
    }
    
    required  init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}










