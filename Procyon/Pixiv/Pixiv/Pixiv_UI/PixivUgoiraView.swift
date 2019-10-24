import UIKit

class PixivUgoiraView: RMView {
    let label = RMLabel()
    override func setup(){
        super.setup()
        self.backgroundColor = UIColor(white: 0, alpha: 0.6)
        self.size = Size(20, 20)
        self.noCorner()
        
        label.textColor = UIColor.white
        label.size = self.size
        label.center = self.center
        label.text = "play_arrow"
        label.textAlignment = .center
        label.font = Font.MaterialIcons.font(13)
        
        addSubview(label)
    }
}
