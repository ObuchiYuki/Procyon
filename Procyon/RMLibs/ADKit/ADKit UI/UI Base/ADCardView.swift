import UIKit


class ADCardView: RMView {
    
    override var bounds: CGRect {
        didSet {
            adLayer.superLayerDidResize()
        }
    }
    
    private weak var adLayer: ADLayer!
    
    override func setup() {
        super.setup()
        adLayer = ADLayer(withView: self)
        adLayer.setRippleColor(.hex("ccc"))
        self.setAsCardView(with: .auto)
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
