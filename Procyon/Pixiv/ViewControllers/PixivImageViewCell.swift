import UIKit

class PixivImageViewCell: RMTableViewCell {
    var illustImage:UIImage? = nil{
        didSet{
            cellImageView.image = illustImage
            indicator.stop()
        }
    }
    private let indicator = ADActivityIndicator()
    let cellImageView = UIImageView()
    
    override func setup() {
        super.setup()
        cellImageView.contentMode = .scaleAspectFit
        cellImageView.origin = pointMake(3, 3)
        
        if UIAppearance.useShadowLevel{
            cellImageView.layer.shadowRadius = 1
            cellImageView.layer.shadowColor = UIColor.black.cgColor
            cellImageView.layer.shadowOffset = .zero
            cellImageView.layer.shadowOpacity = 0.4
        }
        
        
        addSubview(indicator)
        addSubview(cellImageView)
    }
    override func didFrameChange() {
        indicator.center = center
        indicator.y -= 35
        cellImageView.size = sizeMake(self.width-6, self.height-6)
    }
}
