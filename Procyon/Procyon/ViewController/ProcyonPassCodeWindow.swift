import UIKit

class ProcyonPassCodeWindow: UIWindow {
    private var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let numberPad = ADNumberPad()
    private let backgroundView = UIView()
    private let passLabel = UILabel()
    private var passCode = ""
    
    init(){
        super.init(frame: CGRect.zero)
        self.alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func show(){
        self.backgroundColor = UIColor.clear
        self.frame.size = screen.size
        self.isHidden = false
        self.alpha = 1
        self.passCode = ""
        effectView.size = self.size
        numberPad.centerX = self.centerX
        numberPad.centerY = self.centerY+75
        numberPad.tapped = {[weak self] i in
            guard let me = self else {return}
            if i == 10{
                if me.passCode.characters.count != 0{
                    let endPoint = me.passCode.characters.count - 1
                    me.passCode = (me.passCode as NSString).substring(to: endPoint)
                }
            }else{
                me.passCode+="\(i)"
            }
            
            switch me.passCode.characters.count {
            case 0:
                me.passLabel.text = "○　　 ○　　 ○　　 ○"
            case 1:
                me.passLabel.text = "●　　 ○　　 ○　　 ○"
            case 2:
                me.passLabel.text = "●　　 ●　　 ○　　 ○"
            case 3:
                me.passLabel.text = "●　　 ●　　 ●　　 ○"
            case 4:
                me.passLabel.text = "●　　 ●　　 ●　　 ●"
                if me.passCode == info.string(forKey: "procyon-pass-code"){
                    UIView.animate(withDuration: 0.4, animations: {me.alpha = 0}, completion: {_ in me.isHidden = true})
                }else{
                    me.passLabel.vibrate{
                        me.passLabel.text = "○　　 ○　　 ○　　 ○"
                    }
                    me.passCode = ""
                }
            default:
                me.passLabel.text = "○　　 ○　　 ○　　 ○"
            }
        }
        
        passLabel.size = sizeMake(200, 30)
        passLabel.bottomY = numberPad.origin.y-20
        passLabel.centerX = centerX
        passLabel.textAlignment = .center
        self.passLabel.text = "○　　 ○　　 ○　　 ○"
        passLabel.font = Font.Roboto.font(14)
        passLabel.textColor = UIColor.white
        
        addSubview(effectView)
        addSubview(numberPad)
        addSubview(passLabel)
        
        self.makeKey()
        self.makeKeyAndVisible()

        UIView.animate(withDuration: 0.2, animations: {self.alpha = 1}, completion: {_ in })
    }
}
private class ADNumberPad:RMView{
    var tapped:intBlock = {_ in}
    var numButtons:[ADNumberPadButton] = []
    var margin:CGFloat = 10
    var topMargin:CGFloat = 5
    var buttonWidth:CGFloat = 70
    fileprivate override func setup() {
        super.setup()
        self.size = sizeMake(margin*6+buttonWidth*3, margin*8+buttonWidth*4)
        
        for i in 0...10{
            let button = ADNumberPadButton(num: "\(i)")
            if i == 10{
                button.isBack = true
            }
            button.addAction{[weak self] in
                guard let me = self else {return}
                me.tapped(i)
            }
            numButtons.append(button)
        }
        
        numButtons[1].origin.x = margin
        numButtons[2].origin.x = margin*3+buttonWidth
        numButtons[3].origin.x = margin*5+buttonWidth*2
        numButtons[4].origin.x = margin
        numButtons[5].origin.x = margin*3+buttonWidth
        numButtons[6].origin.x = margin*5+buttonWidth*2
        numButtons[7].origin.x = margin
        numButtons[8].origin.x = margin*3+buttonWidth
        numButtons[9].origin.x = margin*5+buttonWidth*2
        
        numButtons[10].origin.x = margin*5+buttonWidth*2
        numButtons[0].origin.x = margin*3+buttonWidth
        
        
        numButtons[1].origin.y = topMargin
        numButtons[2].origin.y = topMargin
        numButtons[3].origin.y = topMargin
        numButtons[4].origin.y = topMargin*3+buttonWidth
        numButtons[5].origin.y = topMargin*3+buttonWidth
        numButtons[6].origin.y = topMargin*3+buttonWidth
        numButtons[7].origin.y = topMargin*5+buttonWidth*2
        numButtons[8].origin.y = topMargin*5+buttonWidth*2
        numButtons[9].origin.y = topMargin*5+buttonWidth*2
        
        numButtons[10].origin.y = topMargin*7+buttonWidth*3
        numButtons[0].origin.y = topMargin*7+buttonWidth*3
        
        self.addSubviews(viewArr: numButtons)
    }
}
private class ADNumberPadButton:ADButton{
    let numLabel = RMLabel()
    var isBack = false{
        didSet{
            if isBack{
                numLabel.font = Font.MaterialIcons.font(30)
                numLabel.text = "arrow_back"
            }
        }
    }
    init(num:String){
        super.init(frame: CGRect.zero)
        self.size = sizeMake(70, 70)
        self.cornerRadius = 35
        
        numLabel.text = "\(num)"
        numLabel.size = self.size
        numLabel.textColor = UIColor.white
        numLabel.font = Font.Roboto.font(30)
        numLabel.textAlignment = .center
        
        addSubview(numLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



