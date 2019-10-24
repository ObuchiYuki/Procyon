import UIKit
import QuartzCore


class ADTextField : RMTextField {
    
    var padding: CGSize = CGSize(width: 5, height: 5)
    var floatingLabelBottomMargin: CGFloat = 2.0
    var floatingPlaceholderEnabled: Bool = false {
        didSet {
            self.updateFloatingLabelText()
        }
    }
    
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
    
    override var bounds: CGRect {
        didSet {
            adLayer.superLayerDidResize()
        }
    }
    
    // floating label
    var floatingLabelFont: UIFont = UIFont.boldSystemFont(ofSize: 10.0) {
        didSet {
            floatingLabel.font = floatingLabelFont
        }
    }
    var floatingLabelTextColor: UIColor = UIColor.lightGray {
        didSet {
            floatingLabel.textColor = floatingLabelTextColor
        }
    }
    
    var bottomBorderEnabled: Bool = true {
        didSet {
            bottomBorderLayer?.removeFromSuperlayer()
            bottomBorderLayer = nil
            if bottomBorderEnabled {
                bottomBorderLayer = CALayer()
                bottomBorderLayer?.frame = CGRect(x: 0, y: layer.bounds.height - 1, width: bounds.width, height: 1)
                bottomBorderLayer?.backgroundColor = ADColor.Grey.P500.cgColor
                layer.addSublayer(bottomBorderLayer!)
            }
        }
    }
    var bottomBorderWidth: CGFloat = 0.5
    var bottomBorderColor: UIColor = UIColor.lightGray {
        didSet {
            if bottomBorderEnabled {
                bottomBorderLayer?.backgroundColor = bottomBorderColor.cgColor
            }
        }
    }
    var bottomBorderHighlightWidth: CGFloat = 1.0
    override var attributedPlaceholder: NSAttributedString? {
        didSet {
            updateFloatingLabelText()
        }
    }
    
    weak var adLayer:ADLayer!
    
    fileprivate var floatingLabel: UILabel!
    fileprivate var bottomBorderLayer: CALayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }
    
    private func setupLayer() {
        adLayer = ADLayer(withView: self)
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
        adLayer.cornerRadius = 2
        
        layer.borderWidth = 0
        borderStyle = .none
        
        floatingLabel = UILabel()
        floatingLabel.font = floatingLabelFont
        floatingLabel.alpha = 0.0
        updateFloatingLabelText()
        
        addSubview(floatingLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bottomBorderLayer?.backgroundColor = isFirstResponder ? tintColor.cgColor : bottomBorderColor.cgColor
        let borderWidth = isFirstResponder ? bottomBorderHighlightWidth : bottomBorderWidth
        bottomBorderLayer?.frame = CGRect(x: 0, y: layer.bounds.height - borderWidth, width: layer.bounds.width, height: borderWidth)
        
        if !floatingPlaceholderEnabled {
            return
        }
        
        if let text = text, text.isEmpty == false {
            floatingLabel.textColor = isFirstResponder ? tintColor : floatingLabelTextColor
            if floatingLabel.alpha == 0 {
                showFloatingLabel()
            }
        } else {
            hideFloatingLabel()
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        var newRect = CGRect(x: rect.origin.x + padding.width, y: rect.origin.y,
                             width: rect.size.width - 2 * padding.width, height: rect.size.height)
        
        if !floatingPlaceholderEnabled {
            return newRect
        }
        
        if let text = text, text.isEmpty == false {
            let dTop = floatingLabel.font.lineHeight + floatingLabelBottomMargin
            newRect = UIEdgeInsetsInsetRect(newRect, UIEdgeInsets(top: dTop, left: 0.0, bottom: 0.0, right: 0.0))
        }
        
        return newRect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
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
    }
}

private extension ADTextField {
    func setFloatingLabelOverlapTextField() {
        let textRect = self.textRect(forBounds: bounds)
        var originX = textRect.origin.x
        switch textAlignment {
        case .center:
            originX += textRect.size.width / 2 - floatingLabel.bounds.width / 2
        case .right:
            originX += textRect.size.width - floatingLabel.bounds.width
        default:
            break
        }
        floatingLabel.frame = CGRect(x: originX, y: padding.height,
                                     width: floatingLabel.width, height: floatingLabel.frame.size.height)
    }
    
    func showFloatingLabel() {
        let curFrame = floatingLabel.frame
        floatingLabel.frame = CGRect(x: curFrame.origin.x, y: bounds.height / 2, width: curFrame.width, height: curFrame.height)
        UIView.animate(withDuration: 0.45, delay: 0.0, options: .curveEaseOut,
                                   animations: {
                                    self.floatingLabel.alpha = 1.0
                                    self.floatingLabel.frame = curFrame
            }, completion: nil)
    }
    
    func hideFloatingLabel() {
        floatingLabel.alpha = 0.0
    }
    
    func updateFloatingLabelText() {
        floatingLabel.attributedText = attributedPlaceholder
        floatingLabel.sizeToFit()
        setFloatingLabelOverlapTextField()
    }
}
