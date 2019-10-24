import UIKit

class PixivImageMenuView: RMView {
    let albumTip = ADTip(icon: "library_add")
    let shareTip = ADTip(icon: "share")
    let menuTip = ADTip(icon: "more_vert")
    
    private let gradientLayer = CAGradientLayer()
    
    override func setup() {
        super.setup()
        self.size = sizeMake(screen.width, 48)
        
        albumTip.x = screen.width-48*3
        shareTip.x = screen.width-48*2
        menuTip.x = screen.width-48*1
        
        albumTip.rippleLayerColor = UIColor.white
        shareTip.rippleLayerColor = UIColor.white
        menuTip.rippleLayerColor = UIColor.white
        
        let topColor = UIColor.black.alpha(0.2).cgColor
        let bottomColor = UIColor.clear.cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.frame.size = self.size
        
        layer.insertSublayer(gradientLayer, at: 0)
        
        addSubview(albumTip)
        addSubview(shareTip)
        addSubview(menuTip)
    }
}
