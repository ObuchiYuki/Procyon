import UIKit

extension UIView{
    func runAction(_ action:RMAction){
        action.animate(with: self.layer)
    }
}
typealias RMActionEaseMode = CAMediaTimingFunction
extension CAMediaTimingFunction{
    static var linear:CAMediaTimingFunction{return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)}
    static var easeIn:CAMediaTimingFunction{return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)}
    static var easeOut:CAMediaTimingFunction{return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)}
    static var easeInEaseOut:CAMediaTimingFunction{return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)}
    static var spring:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.5, 1.1+Float(1/3), 1, 1)}
    static var easeInSine:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.47, 0, 0.745, 0.715)}
    static var easeOutSine:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.39, 0.575, 0.565, 1)}
    static var easeInOutSine:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.445, 0.05, 0.55, 0.95)}
    static var easeInQuad:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.55, 0.085, 0.68, 0.53)}
    static var easeOutQuad:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.25, 0.46, 0.45, 0.94)}
    static var easeInOutQuad:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.455, 0.03, 0.515, 0.955)}
    static var easeInCubic:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.55, 0.055, 0.675, 0.19)}
    static var easeOutCubic:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.215, 0.61, 0.355, 1)}
    static var easeInOutCubic:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.895, 0.03, 0.685, 0.22)}
    static var easeInQuart:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.645, 0.045, 0.355, 1)}
    static var easeOutQuart:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.77, 0, 0.175, 1)}
    static var easeInQuint:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.755, 0.05, 0.855, 0.06)}
    static var easeOutQuint:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)}
    static var easeInOutQuint:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.86, 0, 0.07, 1)}
    static var easeInExpo:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.95, 0.05, 0.795, 0.035)}
    static var easeOutExpo:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.19, 1, 0.22, 1)}
    static var easeInOutExpo:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 1, 0, 0, 1)}
    static var easeInCirc:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.6, 0.04, 0.98, 0.335)}
    static var easeOutCirc:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.075, 0.82, 0.165, 1)}
    static var easeInOutCirc:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.785, 0.135, 0.15, 0.86)}
    static var easeInBack:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.6, -0.28, 0.735, 0.045)}
    static var easeOutBack:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.175, 0.885, 0.32, 1.275)}
    static var easeInOutBack:CAMediaTimingFunction{return CAMediaTimingFunction(controlPoints: 0.68, -0.55, 0.265, 1.55)}
}

struct RMAction {
    
    fileprivate var type:AnimationType
    fileprivate var value:Any
    fileprivate var keyPath:String
    fileprivate var duration:Double
    fileprivate var timingMode:CAMediaTimingFunction? = .easeInEaseOut
    fileprivate enum AnimationType: Int{
        case to,by
    }
    func setEase(_ mode:CAMediaTimingFunction?)->RMAction{
        var action = RMAction(keyPath: self.keyPath, type: self.type, value: self.value, duration: self.duration)
        action.timingMode = mode
        return action
    }
    
    fileprivate func makeAnimation(with layor:CALayer)->RMAnimation{
        switch keyPath {
        case "groupe":
            let animations = RMAnimationGroupe(superLayor: layor)
            animations.animations = (self.value as! [RMAction])
                .map{$0.timingMode==nil ? $0.setEase(self.timingMode) : $0}
                .map{$0.makeAnimation(with: layor)}
            return animations
        case "sequence":
            let animations = RMAnimationSequence(superLayor: layor)
            animations.animations = (value as! [RMAction]).map{$0.makeAnimation(with: layor)}
            return animations
        case "origin":
            return RMAction.groupe([
                RMAction.anchorPoint(to: .zero, duration: duration).setEase(self.timingMode),
                RMAction.position(to: value as! CGPoint, duration: duration).setEase(self.timingMode)
            ]).makeAnimation(with: layor)
        case "center":
            return RMAction.groupe([
                RMAction.anchorPoint(to: pointMake(0.5, 0.5), duration: duration).setEase(self.timingMode),
                RMAction.position(to: value as! CGPoint, duration: duration).setEase(self.timingMode)
            ]).makeAnimation(with: layor)
        case "run":
            let animation = RMAnimation(superLayor: layor)
            animation.animationDidStart = (value as! voidBlock)
            return animation
        default:
            let animation = RMAnimation(superLayor: layor,keyPath: keyPath)
            animation.baseAni.fromValue = layor.propaties[keyPath]
            animation.baseAni.toValue = value
            animation.baseAni.duration = duration
            animation.baseAni.timingFunction = self.timingMode
            return animation
        }
    }
    fileprivate func animate(with layor:CALayer){
        layor.add(self.makeAnimation(with: layor).baseAni, forKey: nil)
    }
    fileprivate init(keyPath:String,type:AnimationType,value: Any,duration:Double){
        self.keyPath = keyPath
        self.type = type
        self.value = value
        self.duration = duration
    }
    fileprivate class RMAnimation: NSObject,CAAnimationDelegate{
        let baseAni = CABasicAnimation()
        var animationDidStart = {}
        var animationDidStop = {}
        weak var superLayor:CALayer!
        func setup(){}
        
        init(superLayor:CALayer,keyPath:String? = nil) {
            super.init()
            baseAni.keyPath = keyPath
            baseAni.delegate = self
    
            baseAni.isRemovedOnCompletion = false
            baseAni.fillMode = kCAFillModeForwards
            self.superLayor = superLayor
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        fileprivate func animationDidStart(_ anim: CAAnimation) {self.animationDidStart()}
        fileprivate func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {self.animationDidStop()}
    }
    fileprivate class RMAnimationGroupe:RMAnimation{
        var animations = [RMAnimation](){
            didSet{
                baseAni.duration = baseAni.duration == 0 ? animations.map{$0.baseAni.duration}.max() ?? 0 : 0
                animationDidStart = {self.animations.map{self.superLayor.add($0.baseAni, forKey: nil)}}
            }
        }
    }
    fileprivate class RMAnimationSequence: RMAnimation{
        var animations = [RMAnimation](){
            didSet{
                guard !animations.isEmpty else {return}
                _=animations.enumerated().map{i,a in
                    a.animationDidStop = {[weak self] in
                        guard let action = self?.animations.index(i+1) else {return}
                        self?.superLayor.add(action.baseAni, forKey: nil)
                    }
                }
                superLayor.add(animations[0].baseAni, forKey: nil)
            }
        }
    }

}
extension RMAction{
    static func wait(duration:Double)->RMAction{
        return RMAction(keyPath: "",type: .to, value: 0, duration: duration)
    }
    static func run(_ action:voidBlock)->RMAction{
        return RMAction(keyPath: "run",type: .to, value: action,duration: 0)
    }
    static func opacity(to value: CGFloat,duration:Double)->RMAction{
        return RMAction(keyPath: "opacity",type: .to, value: value,duration: duration)
    }
    static func cornerRadius(to value: CGFloat,duration:Double)->RMAction{
        return RMAction(keyPath: "cornerRadius",type: .to, value: value,duration: duration)
    }
    static func shadowOpacity(to opacity:CGFloat,duration:Double)->RMAction{
        return RMAction(keyPath: "shadowOpacity",type: .to, value: opacity,duration: duration)
    }
    static func shadowColor(to color:UIColor,duration:Double)->RMAction{
        return RMAction(keyPath: "shadowColor",type: .to, value: color.cgColor,duration: duration)
    }
    static func backgroundColor(to color:UIColor,duration:Double)->RMAction{
        return RMAction(keyPath: "backgroundColor",type: .to, value: color.cgColor,duration: duration)
    }
    static func shadowRadius(to radius:CGFloat,duration:Double)->RMAction{
        return RMAction(keyPath: "shadowRadius",type: .to, value: radius,duration: duration)
    }
    static func shadowOffset(to offset:CGSize,duration:Double)->RMAction{
        return RMAction(keyPath: "shadowOffset",type: .to, value: offset,duration: duration)
    }
    static func anchorPoint(to point: CGPoint,duration:Double)->RMAction{
        return RMAction(keyPath: "anchorPoint",type: .to, value: point,duration: duration)
    }
    static func position(to point: CGPoint,duration:Double)->RMAction{
        return RMAction(keyPath: "position",type: .to, value: point,duration: duration)
    }
    static func center(to point: CGPoint,duration:Double)->RMAction{
        return RMAction(keyPath: "center",type: .to, value: point,duration: duration)
    }
    static func origin(to point: CGPoint,duration:Double)->RMAction{
        return RMAction(keyPath: "origin",type: .to, value: point,duration: duration)
    }
    static func rotate(to radius: CGFloat,duration:Double)->RMAction{
        return RMAction(keyPath: "bounds.origin",type: .to, value: radius,duration: duration)
    }
    static func resize(to size: CGSize,duration:Double)->RMAction{
        return RMAction(keyPath: "bounds.size",type: .to, value: size,duration: duration)
    }
    static func groupe(_ actions:[RMAction])->RMAction{
        return RMAction(keyPath: "groupe",type: .to, value: actions,duration: 0)
    }
    static func seqence(_ actions:[RMAction])->RMAction{
        return RMAction(keyPath: "sequence",type: .to, value: actions,duration: 0)
    }
}
