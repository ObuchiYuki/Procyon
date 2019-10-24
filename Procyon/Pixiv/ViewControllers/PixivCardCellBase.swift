import UIKit

class PixivCardCellBase: RMTableViewCell {
    let cardView = UIView()
    var indexPath:IndexPath = .zero{didSet{separator.isHidden = indexPath.row==0}}
    private weak var adLayer: ADLayer!
    
    override func didFrameChange() {}
    override func setup() {
        selectionStyle = .none
        adLayer = ADLayer(withView: self.cardView)
        adLayer.setRippleColor(.hex("ccc"))
        self.clipsToBounds = true
        self.backgroundColor = .clear
        
        cardView.backgroundColor = .white
        cardView.size = sizeMake(screen.width-10, 100)
        cardView.origin = pointMake(5, -10)
        cardView.setAsCardView(with: .bordered)
        
        addSubviews(cardView)
        super.setup()
        separator.backgroundColor = .hex("e1e1e1")
        separator.width = screen.width-10
        separator.x = 5
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
