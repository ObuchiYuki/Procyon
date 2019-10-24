import UIKit

class ADNoProfile {
    private static let colorType = [
        ADColor.Amber.P500,
        ADColor.Blue.P500,
        ADColor.BlueGrey.P500,
        ADColor.Brown.P500,
        ADColor.Cyan.P500,
        ADColor.DeepOrange.P500,
        ADColor.DeepPurple.P500,
        ADColor.Green.P500,
        ADColor.Grey.P500,
        ADColor.Indigo.P500,
        ADColor.Lime.P500,
        ADColor.Orange.P500,
        ADColor.Pink.P500,
        ADColor.Purple.P500,
        ADColor.Red.P500,
        ADColor.Teal.P500,
    ]
    
    static func createImage(withName name:String, completion:@escaping imageBlock){
        asyncQ {
            usleep(10)
            mainQ {
                let nameLabel = UILabel()
                let bgView = UIView()
            
                var color = UIColor()
            
                if let index = info.int(forKey: name){
                    color = ADNoProfile.colorType[index]
                }else{
                    let randomIndex = Int(arc4random_uniform(15))
                    color = ADNoProfile.colorType[randomIndex]
                    info.set(randomIndex, forKey: name)
                }
                bgView.size = sizeMake(100, 100)
                bgView.backgroundColor = color
                bgView.noCorner()
                nameLabel.size = sizeMake(60, 60)
                nameLabel.center = Point(50, 50)
                nameLabel.textAlignment = .center
                nameLabel.font = Font.Roboto.font(60, style: .normal)
                nameLabel.textColor = .white
                nameLabel.text = name.first
                bgView.addSubview(nameLabel)
                let image = bgView.imageContext
                completion(image)
            }
        }
    }
}

































