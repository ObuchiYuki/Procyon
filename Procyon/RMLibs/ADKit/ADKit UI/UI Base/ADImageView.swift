import UIKit


class ADImageView: UIImageView{
    var maskEnabled: Bool = true {
        didSet {
            adLayer.maskEnabled = maskEnabled
        }
    }
    override var cornerRadius: CGFloat{
        set{
            super.cornerRadius = self.cornerRadius
            adLayer.superLayerDidResize()
        }
        get{
            return super.cornerRadius
        }
    }
    var elevation: CGFloat = 0 {
        didSet {
            adLayer.elevation = elevation
        }
    }
    var shadowOffset: CGSize = CGSize.zero {
        didSet {
            adLayer.shadowOffset = shadowOffset
        }
    }
    var roundingCorners: UIRectCorner = UIRectCorner.allCorners {
        didSet {
            adLayer.roundingCorners = roundingCorners
        }
    }
    var rippleEnabled: Bool = true {
        didSet {
            adLayer.rippleEnabled = rippleEnabled
        }
    }
    var rippleDuration: CFTimeInterval = 0.35 {
        didSet {
            adLayer.rippleDuration = rippleDuration
        }
    }
    var rippleScaleRatio: CGFloat = 1.0 {
        didSet {
            adLayer.rippleScaleRatio = rippleScaleRatio
        }
    }
    var rippleLayerColor: UIColor = UIColor(hex: 0xEEEEEE) {
        didSet {
            adLayer.setRippleColor(rippleLayerColor)
        }
    }
    var backgroundAnimationEnabled: Bool = true {
        didSet {
            adLayer.backgroundAnimationEnabled = backgroundAnimationEnabled
        }
    }
    
    override   var bounds: CGRect {
        didSet {
            adLayer.superLayerDidResize()
        }
    }
    private lazy var adLayer: ADLayer = ADLayer(withView: self)
    
    required   init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }
    
    override   init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    override   init(image: UIImage?) {
        super.init(image: image)
        setupLayer()
    }
    
    override   init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        setupLayer()
    }
    
    
    private func setupLayer() {
        adLayer.elevation = self.elevation
        self.layer.cornerRadius = self.cornerRadius
        adLayer.elevationOffset = self.shadowOffset
        adLayer.roundingCorners = self.roundingCorners
        adLayer.maskEnabled = self.maskEnabled
        adLayer.rippleScaleRatio = self.rippleScaleRatio
        adLayer.rippleDuration = self.rippleDuration
        adLayer.rippleEnabled = self.rippleEnabled
        adLayer.backgroundAnimationEnabled = self.backgroundAnimationEnabled
        adLayer.setRippleColor(self.rippleLayerColor)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        adLayer.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        adLayer.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        adLayer.touchesCancelled(touches, withEvent: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        adLayer.touchesMoved(touches, withEvent: event)
    } }
