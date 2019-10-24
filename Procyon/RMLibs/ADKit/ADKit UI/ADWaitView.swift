import UIKit

class ADWaitView: UIView {
    
    private var indicator = ADRefreshControl()
    private var messageLabel = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        alpha = 0
        backgroundColor = .hex("0", alpha: 0.6)
        
        indicator.layer.position = layer.position
        indicator.beginRefreshing()
        indicator.backgroundColor = .hex("", alpha:0)
        
        messageLabel.frame.size = sizeMake(300, 30)
        messageLabel.layer.position.x = self.layer.position.x
        messageLabel.frame.origin.y = 150
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.textColor = .hex("1")
        messageLabel.textAlignment = .center
        messageLabel.font = Font.Roboto.font(15)
        
        addSubview(indicator)
        addSubview(messageLabel)
    }
    private func animateToStart(){
        indicator.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.alpha = 1
            },
            completion: {_ in}
        )
        UIView.animate(
            withDuration: 0.3,
            delay: 0.2,
            options: .curveEaseOut,
            animations: {
                self.indicator.transform = CGAffineTransform(scaleX: 1, y: 1)
            },
            completion: {_ in}
        )
    }
    private func animationToEnd(_ end:@escaping voidBlock){
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.indicator.transform = CGAffineTransform(scaleX: 0, y: 0)
            },
            completion: {_ in}
        )
        UIView.animate(
            withDuration: 0.2,
            delay: 0.3,
            options: .curveEaseOut,
            animations: {
                self.alpha = 0
            },
            completion: {_ in
                self.indicator.removeFromSuperview()
                self.removeFromSuperview()
                end()
            }
        )
    }
    func dissmiss(_ end:(voidBlock)? = {}){
        if end == nil{
            animationToEnd({})
        }else{
            animationToEnd(end!)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    class func show(addTo view:UIView)->ADWaitView{
        let waitView = ADWaitView(frame: view.frame)
        view.addSubview(waitView)
        waitView.animateToStart()
        
        return waitView
    }
    class func show(addTo view:UIView,withMessage message:String)->ADWaitView{
        let waitView = ADWaitView(frame: view.frame)
        waitView.messageLabel.text = message
        view.addSubview(waitView)
        waitView.animateToStart()
        
        return waitView
    }
}








