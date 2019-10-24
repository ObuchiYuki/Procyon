import UIKit

class ADRefreshControl: UIControl {
    
    private var parentScrollView: UIScrollView?
    private var animationView: UIView?
    private var circleView: UIView?
    private var progressPath: UIBezierPath?
    private var progressLayer: CAShapeLayer?
    private var refreshBlock: (() -> Void)?
    private var radius: CGFloat = 0
    private var rotation: CGFloat = 0
    private var rotationIncrement: CGFloat = 0
    
    private(set) var refreshing: Bool = false
    var controllerHeight: CGFloat = 60
    var color: UIColor = .accent {
        didSet {
            if let progressLayer = self.progressLayer {
                progressLayer.strokeColor = self.color.cgColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRefreshControl()
        setup()
    }
    
    required   init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupRefreshControl()
        setup()
    }
    
    
    
    func add(toScrollView scrollView: UIScrollView, withRefreshBlock block: @escaping voidBlock ){
        self.parentScrollView = scrollView
        self.refreshBlock = block
        if let parentScrollView = self.parentScrollView {
            parentScrollView.addSubview(self)
            parentScrollView.sendSubview(toBack: self)
            parentScrollView.panGestureRecognizer.addTarget(self, action: #selector(ADRefreshControl.handlePanGestureRecognizer))
            parentScrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        }
    }
    
    func beginRefreshing() {
        self.refreshing = true
        self.startRefreshing()
    }
    
    func endRefreshing() {
        self.resetAnimation()
    }
    
    private func setupRefreshControl() {
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.controllerHeight)
        self.animationView = UIView(frame: self.bounds)
        if let animationView = self.animationView {
            animationView.backgroundColor = UIColor.clear
            self.layer.masksToBounds = true
            self.addSubview(animationView)
        }
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
        
        self.rotation = 0
        self.rotationIncrement = CGFloat(14 * M_PI / 8.0)
        self.radius = 15.0
        let center = Point(UIScreen.main.bounds.width / 2, self.controllerHeight / 2)
        
        self.circleView = UIView(frame: CGRect(x: 0, y: 0, width: self.radius * 2, height: self.radius * 2))
        if let circleView = self.circleView, let animationView = self.animationView {
            circleView.center = center
            circleView.backgroundColor = UIColor.clear
            animationView.addSubview(circleView)
            
            let circleViewCenter = Point(self.radius, self.radius)
            self.progressPath = UIBezierPath(arcCenter: circleViewCenter, radius: self.radius, startAngle: CGFloat(-M_PI), endAngle: CGFloat(M_PI), clockwise: true)
            self.progressLayer = CAShapeLayer()
            if let progressLayer = self.progressLayer, let progressPath = self.progressPath {
                progressLayer.path = progressPath.cgPath
                progressLayer.strokeColor = self.color.cgColor
                progressLayer.fillColor = UIColor.clear.cgColor
                progressLayer.lineWidth = 0.1 * radius * 2
                progressLayer.strokeStart = 0
                progressLayer.strokeEnd = 0
                progressLayer.frame = circleView.bounds
                circleView.layer.insertSublayer(progressLayer, at: 0)
            }
        }
        
        self.refreshing = false
    }
    
    private func setScrollViewTopInsets(withOffset offset: CGFloat) {
        if let parentScrollView = self.parentScrollView {
            var insets: UIEdgeInsets = parentScrollView.contentInset
            insets.top += offset
            parentScrollView.contentInset = insets
        }
    }
    
    private func refresh() {
        self.refreshing = true
        self.sendActions(for: .valueChanged)
        if let refreshBlock = self.refreshBlock {
            refreshBlock()
        }
        self.startRefreshing()
    }
    
    private func startRefreshing() {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.setScrollViewTopInsets(withOffset: self.controllerHeight)
        }) 
        self.animateRefreshView()
    }
    
    private func handleScrollingOnAnimationView(_ animationView: UIView, withPullDistance pullDistance: CGFloat, withPullRatio pullRatio: CGFloat, withPullVelocity pullVelocity: CGFloat) {
        if let circleView = self.circleView, let progressLayer = self.progressLayer {
            if pullDistance < self.controllerHeight {
                circleView.alpha = pullDistance / self.controllerHeight
                progressLayer.strokeEnd = pullDistance / self.controllerHeight * 0.9
            }
            self.rotation = CGFloat(M_PI) * pullDistance / self.controllerHeight * 0.5
            circleView.transform = CGAffineTransform(rotationAngle: self.rotation)
        }
    }
    
    private func resetAnimation() {
        self.refreshing = false
        if let animationView = self.animationView {
            self.exitAnimation(forRefreshView: animationView) { () -> Void in
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.setScrollViewTopInsets(withOffset: -self.controllerHeight)
                    }, completion: { _ -> Void in
                        if let parentScrollView = self.parentScrollView {
                            parentScrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
                        }
                })
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(350 * NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                    if let animationView = self.animationView {
                        self.resetAnimationView(animationView)
                    }
                })
            }
        }
    }
    
    private func resetAnimationView(_ animationView: UIView) {
        self.rotation = 0
        if let circleView = self.circleView {
            circleView.alpha = 1
            circleView.transform = CGAffineTransform(rotationAngle: self.rotation)
        }
        if let progressLayer = self.progressLayer {
            progressLayer.strokeStart = 0
            progressLayer.strokeEnd = 0
            progressLayer.removeAllAnimations()
        }
    }
    
    private func setupRefreshControl(forAnimationView animationView: UIView) {
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.animationSecondPhase()
        }
        
        if let progressLayer = self.progressLayer {
            progressLayer.strokeStart = 0.99
            progressLayer.strokeEnd = 1
        }
        if let circleView = self.circleView {
            circleView.alpha = 1
        }
        
        CATransaction.commit()
    }
    
    private func animationSecondPhase() {
        CATransaction.begin()
        
        let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnim.fromValue = 0
        rotationAnim.duration = 4
        rotationAnim.toValue = 2 * M_PI
        rotationAnim.repeatCount = Float.infinity
        rotationAnim.isRemovedOnCompletion = false
        
        let startHeadAnim = CABasicAnimation(keyPath: "strokeStart")
        startHeadAnim.beginTime = 0.1
        startHeadAnim.fromValue = 0
        startHeadAnim.toValue = 0.25
        startHeadAnim.duration = 1
        startHeadAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let startTailAnim = CABasicAnimation(keyPath: "strokeEnd")
        startTailAnim.beginTime = 0.1
        startTailAnim.fromValue = 0
        startTailAnim.toValue = 1
        startTailAnim.duration = 1
        startTailAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let endHeadAnim = CABasicAnimation(keyPath: "strokeStart")
        endHeadAnim.beginTime = 1
        endHeadAnim.fromValue = 0.25
        endHeadAnim.toValue = 0.99
        endHeadAnim.duration = 0.5
        endHeadAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let endTailAnim = CABasicAnimation(keyPath: "strokeEnd")
        endTailAnim.beginTime = 1
        endTailAnim.fromValue = 1
        endTailAnim.toValue = 1
        endTailAnim.duration = 0.5
        endTailAnim.toValue = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let strokeAnimGroup = CAAnimationGroup()
        strokeAnimGroup.duration = 1.5
        strokeAnimGroup.animations = [startHeadAnim, startTailAnim, endHeadAnim, endTailAnim]
        strokeAnimGroup.repeatCount = Float.infinity
        strokeAnimGroup.isRemovedOnCompletion = false
        
        if let progressLayer = self.progressLayer {
            progressLayer.add(rotationAnim, forKey: "rotation")
            progressLayer.add(strokeAnimGroup, forKey: "stroke")
        }
        
        CATransaction.commit()
    }
    
    private func animateRefreshView() {
        if let animationView = self.animationView {
            self.setupRefreshControl(forAnimationView: animationView)
        }
    }
    
    private func exitAnimation(forRefreshView view: UIView, withCompletionBlock block: @escaping (() -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            if let circleView = self.circleView, let progressLayer = self.progressLayer {
                circleView.alpha = 0
                progressLayer.removeAllAnimations()
            }
            block()
        }
        
        let opacityAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.duration = 0.25
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.fillMode = kCAFillModeForwards
        
        if let progressLayer = self.progressLayer {
            progressLayer.add(opacityAnimation, forKey: "opacity")
        }
        
        CATransaction.commit()
    }
    
    
    override   func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath {
            if keyPath == "contentOffset" {
                if let object = object as? UIScrollView, let parentScrollView = self.parentScrollView {
                    if object == parentScrollView {
                        self.containingScrollViewDidScroll(parentScrollView)
                    }
                }
            }
        }
    }
    
    func handlePanGestureRecognizer() {
        if let parentScrollView = self.parentScrollView {
            if parentScrollView.panGestureRecognizer.state == .ended {
                self.containingScrollViewDidEndDragging(parentScrollView)
            }
        }
    }
    
    private func containingScrollViewDidScroll(_ scrollView: UIScrollView) {
        let actualOffset: CGFloat = scrollView.contentOffset.y
        self.setFrameForScrolling(withOffset: actualOffset)
        if !self.refreshing {
            let pullDistance: CGFloat = max(0, -actualOffset)
            let pullRatio: CGFloat = min(max(0, pullDistance), self.controllerHeight) / self.controllerHeight
            let velocity: CGFloat = scrollView.panGestureRecognizer.velocity(in: scrollView).y
            if pullRatio != 0 {
                if let animationView = self.animationView {
                    self.handleScrollingOnAnimationView(
                        animationView,
                        withPullDistance: pullDistance,
                        withPullRatio: pullRatio,
                        withPullVelocity: velocity)
                }
            }
        }
    }
    
    private func containingScrollViewDidEndDragging(_ scrollView: UIScrollView) {
        let actualOffset: CGFloat = scrollView.contentOffset.y
        if !self.refreshing && -actualOffset > self.controllerHeight {
            self.refresh()
        }
    }
    
    
    private func setFrameForScrolling(withOffset offset: CGFloat) {
        if -offset > self.controllerHeight {
            let newFrame: CGRect = CGRect(x: 0, y: offset, width: UIScreen.main.bounds.width, height: abs(offset))
            self.frame = newFrame
            self.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: abs(offset))
        } else {
            let newY: CGFloat = offset
            self.frame = CGRect(x: 0, y: newY, width: UIScreen.main.bounds.width, height: self.controllerHeight)
            self.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.controllerHeight)
        }
    }
}
