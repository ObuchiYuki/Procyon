import UIKit

class ADHomeButton:RMButton{
    var goHomeAction = {}
    private var homeButtonRised = false
    private var homeButtonAnimated = false
    private var nowShowed = true
    
    weak var fromView:UIView!
    
    func hide(){
        if nowShowed{
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.frame.origin.y += 30
                },
                completion: {_ in
                    self.nowShowed = false
                }
            )
        }
    }
    func open(){
        if !nowShowed{
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.frame.origin.y -= 30
                },
                completion: {_ in
                    self.nowShowed = true
                }
            )
        }
    }
    private func goHome(){
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.shadowLevel = 0
                self.titleLabel?.alpha = 0
                self.frame.size = self.fromView.frame.size
                self.center = self.fromView.center
                self.safeCornerRadius = 0
                self.layer.shadowOpacity = 0
            },
            completion: {_ in
                self.goHomeAction()
            }
        )
    }
    private func riseToBackHome(){
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.shadowLevel = 10
                self.frame.size = sizeMake(80, 80)
                self.center.x = self.fromView.frame.center.x
                self.frame.origin.y -= 30
                self.noCorner()
            },
            completion: {_ in}
        )
    }
    private func cancelBackingHome(){
        if !homeButtonAnimated{
            homeButtonRised = false
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.shadowLevel = 4
                    self.frame.size = sizeMake(60, 60)
                    self.center.x = self.fromView.frame.center.x
                    self.frame.origin.y += 30
                    self.noCorner()
                },
                completion: {_ in}
            )
        }
    }
    override func setup(){
        super.setup()
        backgroundColor = UIColor.white
        self.frame.size = sizeMake(60, 60)
        self.noCorner()
        self.shadowLevel = 4
        self.titleLabel?.font = Font.MaterialIcons.font(30)
        self.title = "home"
        self.titleColor = .subText
        self.addAction{[weak self] in
            guard let me = self else {return}
            if !me.homeButtonRised{
                me.homeButtonRised = true
                run(after: 0.75){
                    me.cancelBackingHome()
                }
                me.riseToBackHome()
            }else{
                me.homeButtonAnimated = true
                me.goHome()
            }
        }
    }
}












