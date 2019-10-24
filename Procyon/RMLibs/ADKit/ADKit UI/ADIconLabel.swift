import UIKit

class ADIconLalbel:RMView{
    var icon = ""{
        didSet{}
    }
    var iconSize = 15{
        didSet{}
    }
    var text = ""{
        didSet{}
    }
    var iconLabel = UILabel()
    var textLabel = UILabel()
    
    override func setup() {
        super.setup()
        iconLabel.font = Font.MaterialIcons.font(15)
        iconLabel.textColor = .subText
        iconLabel.size = sizeMake(15, 15)
        iconLabel.centerY = self.height/2
        iconLabel.x = 5
        
        textLabel.font = Font.Roboto.font(15)
        textLabel.textColor = .subText
        textLabel.size = sizeMake(self.width-25, self.height)
        textLabel.x = 25
        textLabel.backgroundColor = .blue
        
        addSubview(textLabel)
        addSubview(iconLabel)
    }

    override func didChangeFrame() {
        iconLabel.centerY = self.height/2
        textLabel.size = sizeMake(self.width-25, self.height)
    }
}
