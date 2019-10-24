import UIKit

class ADTip: ADButton {
    private var isIndicatorShown = false
    var longTapAction = {}
    lazy var indicator = UIActivityIndicatorView()
    override func setup(){
        super.setup()
        frame.size = sizeMake(48, 48)
        layer.cornerRadius = 24
        titleLabel?.font = Font.MaterialIcons.font(24)
        indicator.center = self.center
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(ADTip.longTapped)))
    }
    init(icon:String){
        super.init(frame: .zero)
        self.title = icon
    }
    override init(){
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func longTapped(){
        self.longTapAction()
    }
    func turnIntoIndicator(){
        if !isIndicatorShown{
            indicator.transform = CGAffineTransform(scaleX: 0, y: 0)
            indicator.startAnimating()
            addSubview(indicator)
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                },
                completion: {_ in}
            )
            UIView.animate(
                withDuration: 0.1,
                delay: 0.2,
                options: .curveEaseOut,
                animations: {
                    self.transform = CGAffineTransform(scaleX: 1, y: 1)
                },
                completion: {_ in}
            )
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.indicator.alpha = 1
                    self.titleLabel?.alpha = 0
                    self.indicator.transform = CGAffineTransform(scaleX: 1, y: 1)
                },
                completion: {_ in}
            )
            isIndicatorShown = true
        }
    }
    func returnToButtonFromIndicator(){
        if isIndicatorShown{
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.titleLabel?.alpha = 1
                    self.indicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    self.indicator.alpha = 0
                },
                completion: {_ in
                    self.indicator.stopAnimating()
                }
            )
            isIndicatorShown = false
        }
    }
}
