import UIKit

let kADControlWidth: CGFloat = 40
let kADControlHeight: CGFloat = 20
let kADTrackWidth: CGFloat = 34
let kADTrackHeight: CGFloat = 12
let kADTrackCornerRadius: CGFloat = 6
let kADThumbRadius: CGFloat = 10


class ADSwitch: RMControl {
    private var block = {}
    
    override func addAction(_ block: @escaping voidBlock) {
        self.block = block
    }
    
    var saveIdentifier:String? = nil{
        didSet{
            guard let identifier = saveIdentifier else {return}
            self.on =  info.boolValue(forKey: identifier)
        }
    }
    override var isEnabled: Bool {
        didSet {
            if let switchLayer = self.switchLayer {
                switchLayer.enabled = self.isEnabled
            }
        }
    }
    var thumbOnColor: UIColor = ADColor.Blue.P500 {
        didSet {
            if let switchLayer = self.switchLayer {
                if let onColorPallete = switchLayer.onColorPallete {
                    onColorPallete.thumbColor = self.thumbOnColor
                    switchLayer.updateColors()
                }
            }
        }
    }
    var thumbOffColor: UIColor = UIColor(hex: 0xFAFAFA) {
        didSet {
            if let switchLayer = self.switchLayer {
                if let offColorPallete = switchLayer.offColorPallete {
                    offColorPallete.thumbColor = self.thumbOffColor
                    switchLayer.updateColors()
                }
            }
        }
    }
    var thumbDisabledColor: UIColor = UIColor(hex: 0xBDBDBD) {
        didSet {
            if let switchLayer = self.switchLayer {
                if let disabledColorPallete = switchLayer.disabledColorPallete {
                    disabledColorPallete.thumbColor = self.thumbDisabledColor
                    switchLayer.updateColors()
                }
            }
        }
    }
    var trackOnColor: UIColor = ADColor.Blue.P300 {
        didSet {
            if let switchLayer = self.switchLayer {
                if let onColorPallete = switchLayer.onColorPallete {
                    onColorPallete.trackColor = self.trackOnColor
                    switchLayer.updateColors()
                }
            }
        }
    }
    var trackOffColor: UIColor = .hex("cccccc") {
        didSet {
            if let switchLayer = self.switchLayer {
                if let offColorPallete = switchLayer.offColorPallete {
                    offColorPallete.trackColor = self.trackOffColor
                    switchLayer.updateColors()
                }
            }
        }
    }
    var trackDisabledColor: UIColor = UIColor(hex: 0xBDBDBD) {
        didSet {
            if let switchLayer = self.switchLayer {
                if let disabledColorPallete = switchLayer.disabledColorPallete {
                    disabledColorPallete.trackColor = self.trackDisabledColor
                    switchLayer.updateColors()
                }
            }
        }
    }
    var on: Bool = false {
        didSet {
            if let switchLayer = self.switchLayer {
                switchLayer.switchState(self.on)
                sendActions(for: .valueChanged)
                didChangeOn()
                block()
            }
        }
    }
    
    private var switchLayer: ADSwitchLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let switchLayer = switchLayer {
            switchLayer.updateSuperBounds(self.bounds)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            let point = touch.location(in: self)
            if let switchLayer = switchLayer {
                switchLayer.onTouchDown(self.layer.convert(point, to: switchLayer))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let touch = touches.first {
            let point = touch.location(in: self)
            if let switchLayer = switchLayer {
                switchLayer.onTouchUp(self.layer.convert(point, to: switchLayer))
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if let touch = touches.first {
            let point = touch.location(in: self)
            if let switchLayer = switchLayer {
                switchLayer.onTouchUp(self.layer.convert(point, to: switchLayer))
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let touch = touches.first {
            let point = touch.location(in: self)
            if let switchLayer = switchLayer {
                switchLayer.onTouchMoved(self.layer.convert(point, to: switchLayer))
            }
        }
    }
    
    override func setup() {
        super.setup()
        size = sizeMake(70, 50)
        switchLayer = ADSwitchLayer(withParent: self)
        self.isEnabled = true
        
        switchLayer!.onColorPallete = ADSwitchColorPallete(
            thumbColor: thumbOnColor, trackColor: trackOnColor)
        switchLayer!.offColorPallete = ADSwitchColorPallete(
            thumbColor: thumbOffColor, trackColor: trackOffColor)
        switchLayer!.disabledColorPallete = ADSwitchColorPallete(
            thumbColor: thumbDisabledColor, trackColor: trackDisabledColor)
        self.layer.addSublayer(switchLayer!)
    }
    private func didChangeOn(){
        guard let identifier = saveIdentifier else {
            return
        }
        info.set(on, forKey: identifier)
    }
}

class ADSwitchLayer: CALayer {
    
    var enabled: Bool = true {
        didSet {
            updateColors()
        }
    }
    var parent: ADSwitch?
    var rippleAnimationDuration: CFTimeInterval = 0.35
    
    private var trackLayer: CAShapeLayer?
    private var thumbHolder: CALayer?
    private var thumbLayer: CAShapeLayer?
    private var thumbBackground: CALayer?
    private var rippleLayer: ADLayer?
    private var shadowLayer: ADLayer?
    private var touchInside: Bool = false
    private var touchDownLocation: CGPoint?
    private var thumbFrame: CGRect?
    fileprivate var onColorPallete: ADSwitchColorPallete? {
        didSet {
            updateColors()
        }
    }
    fileprivate var offColorPallete: ADSwitchColorPallete? {
        didSet {
            updateColors()
        }
    }
    fileprivate var disabledColorPallete: ADSwitchColorPallete? {
        didSet {
            updateColors()
        }
    }
    
    init(withParent parent: ADSwitch) {
        super.init()
        self.parent = parent
        setup()
    }
    
    required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        trackLayer = CAShapeLayer()
        thumbLayer = CAShapeLayer()
        thumbHolder = CALayer()
        thumbBackground = CALayer()
        shadowLayer = ADLayer(superLayer: thumbLayer!)
        shadowLayer!.rippleScaleRatio = 0
        rippleLayer = ADLayer(superLayer: thumbBackground!)
        rippleLayer!.rippleScaleRatio = 1.7
        rippleLayer!.maskEnabled = false
        rippleLayer!.elevation = 0
        thumbHolder!.addSublayer(thumbBackground!)
        thumbHolder!.addSublayer(thumbLayer!)
        self.addSublayer(trackLayer!)
        self.addSublayer(thumbHolder!)
    }
    
    fileprivate func updateSuperBounds(_ bounds: CGRect) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let subX = center.x - kADControlWidth / 2
        let subY = center.y - kADControlHeight / 2
        self.frame = CGRect(x: subX, y: subY, width: kADControlWidth, height: kADControlHeight)
        updateTrackLayer()
        updateThumbLayer()
    }
    
    fileprivate func updateTrackLayer() {
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let subX = center.x - kADTrackWidth / 2
        let subY = center.y - kADTrackHeight / 2
        
        if let trackLayer = trackLayer {
            trackLayer.frame = CGRect(x: subX, y: subY, width: kADTrackWidth, height: kADTrackHeight)
            trackLayer.path = UIBezierPath(
                roundedRect: trackLayer.bounds,
                byRoundingCorners: UIRectCorner.allCorners,
                cornerRadii: CGSize(
                    width: kADTrackCornerRadius,
                    height: kADTrackCornerRadius)).cgPath
        }
    }
    
    fileprivate func updateThumbLayer() {
        var subX: CGFloat = 0
        if let parent = parent {
            if parent.on {
                subX = kADControlWidth - kADThumbRadius * 2
            }
        }
        
        thumbFrame = CGRect(x: subX, y: 0, width: kADThumbRadius * 2, height: kADThumbRadius * 2)
        if
            let thumbHolder = thumbHolder,
            let thumbBackground = thumbBackground,
            let thumbLayer = thumbLayer {
            thumbHolder.frame = thumbFrame!
            thumbBackground.frame = thumbHolder.bounds
            thumbLayer.frame = thumbHolder.bounds
            thumbLayer.path = UIBezierPath(ovalIn: thumbLayer.bounds).cgPath
        }
    }
    
    fileprivate func updateColors() {
        if
            let trackLayer = trackLayer,
            let thumbLayer = thumbLayer,
            let rippleLayer = rippleLayer,
            let parent = parent
        {
            if !enabled {
                if let disabledColorPallete = disabledColorPallete {
                    trackLayer.fillColor = disabledColorPallete.trackColor.cgColor
                    thumbLayer.fillColor = disabledColorPallete.thumbColor.cgColor
                }
            } else if parent.on {
                if let
                    onColorPallete = onColorPallete {
                    trackLayer.fillColor = onColorPallete.trackColor.cgColor
                    thumbLayer.fillColor = onColorPallete.thumbColor.cgColor
                    rippleLayer.setRippleColor(
                        onColorPallete.thumbColor,
                        withRippleAlpha: 0.1,
                        withBackgroundAlpha: 0.1
                    )
                }
            } else {
                if let
                    offColorPallete = offColorPallete {
                    trackLayer.fillColor = offColorPallete.trackColor.cgColor
                    thumbLayer.fillColor = offColorPallete.thumbColor.cgColor
                    rippleLayer.setRippleColor(
                        offColorPallete.thumbColor,
                        withRippleAlpha: 0.1,
                        withBackgroundAlpha: 0.1
                    )
                }
            }
        }
    }
    
    fileprivate func switchState(_ on: Bool) {
        if on {
            thumbFrame = CGRect(
                x: kADControlWidth - kADThumbRadius * 2,
                y: 0,
                width: kADThumbRadius * 2,
                height: kADThumbRadius * 2
            )
        } else {
            thumbFrame = CGRect(
                x: 0, y: 0, width: kADThumbRadius * 2, height: kADThumbRadius * 2)
        }
        if let thumbHolder = thumbHolder {
            thumbHolder.frame = thumbFrame!
        }
        self.updateColors()
    }
    
    func onTouchDown(_ touchLocation: CGPoint) {
        if enabled {
            if
                let rippleLayer = rippleLayer,
                let shadowLayer = shadowLayer,
                let thumbBackground = thumbBackground,
                let thumbLayer = thumbLayer
            {
                rippleLayer.startEffects(atLocation: self.convert(touchLocation, to: thumbBackground))
                shadowLayer.startEffects(atLocation: self.convert(touchLocation, to: thumbLayer))
                
                self.touchInside = self.contains(touchLocation)
                self.touchDownLocation = touchLocation
            }
        }
    }
    
    func onTouchMoved(_ moveLocation: CGPoint) {
        if enabled {
            if touchInside {
                if
                    let thumbFrame = thumbFrame,
                    let thumbHolder = thumbHolder,
                    let touchDownLocation = touchDownLocation
                {
                    var x = thumbFrame.origin.x + moveLocation.x - touchDownLocation.x
                    if x < 0 {
                        x = 0
                    } else if x > self.bounds.size.width - thumbFrame.size.width {
                        x = self.bounds.size.width - thumbFrame.size.width
                    }
                    thumbHolder.frame = CGRect(
                        x: x,
                        y: thumbFrame.origin.y,
                        width: thumbFrame.size.width,
                        height: thumbFrame.size.height
                    )
                }
            }
        }
    }
    
    func onTouchUp(_ touchLocation: CGPoint) {
        if enabled {
            if let rippleLayer = rippleLayer, let shadowLayer = shadowLayer {
                rippleLayer.stopEffects()
                shadowLayer.stopEffects()
            }
            
            if let touchDownLocation = touchDownLocation, let parent = parent {
                if !touchInside || self.checkPoint(touchLocation, equalTo: touchDownLocation) {
                    parent.on = !parent.on
                } else {
                    if parent.on && touchLocation.x < touchDownLocation.x {
                        parent.on = false
                    } else if !parent.on && touchLocation.x > touchDownLocation.x {
                        parent.on = true
                    }
                }
            }
            touchInside = false
        }
    }
    
    private func checkPoint(_ point: CGPoint, equalTo other: CGPoint) -> Bool {
        return fabs(point.x - other.x) <= 5 && fabs(point.y - other.y) <= 5
    }
}

class ADSwitchColorPallete {
    var thumbColor: UIColor
    var trackColor: UIColor
    
    init(thumbColor: UIColor, trackColor: UIColor) {
        self.thumbColor = thumbColor
        self.trackColor = trackColor
    }
}
