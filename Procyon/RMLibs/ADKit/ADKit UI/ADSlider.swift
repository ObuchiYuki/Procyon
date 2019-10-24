import UIKit

class ADSlider: UIView {
    //==========================================================================
    //  variable
    private var rawValue:CGFloat = 0{
        willSet{
            if rawValue != newValue{
                isvalueChange = true
            }else{
                isvalueChange = false
            }
        }
    }
    var value:CGFloat{
        get{
            return rawValue
        }
        set{
            rawValue = newValue
            let locationX = valueToLocation(rawValue)
            
            handleView.center.x = locationX
            handleHelpView.center.x = locationX
            sliderView.width = locationX-15
        }
    }
    private var isvalueChange = false
    var min:CGFloat = 0
    var max:CGFloat = 1
    var handleColor = UIColor.white{
        didSet{
            handleView.backgroundColor = handleColor
        }
    }
    var sliderColor = UIColor.main{
        didSet{
            sliderView.backgroundColor = sliderColor
        }
    }
    var sliderUnselectColor = UIColor.white{
        didSet{
            sliderUnselectView.backgroundColor = sliderUnselectColor
        }
    }
    var showHandleShadow = false{
        didSet{
            if showHandleShadow {
                handleView.unsafeShadowLevel = 2
            }else{
                handleView.unsafeShadowLevel = 0
            }
        }
    }
    override var width:CGFloat{
        get{
            return super.width
        }
        set{
            super.width = newValue
            didFrameChange()
        }
    }
    override var y: CGFloat{
        get{
            return super.y
        }
        set{
            super.y = newValue
            handleView.y = newValue
            handleHelpView.y = newValue
            sliderView.y = newValue
            sliderUnselectView.y = newValue
        }
    }
    //==========================================================================
    //private variable
    private var ismoveing = false
    //======================================
    //views
    private var handleView = UIView()
    private var handleHelpView = UIView()
    private var sliderView = UIView()
    private var sliderUnselectView = UIView()
    //==========================================================================
    //init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    //==========================================================================
    //  method
    var valueChangeing:cgFloatBlock = {_ in}
    var valueDidChanged:cgFloatBlock = {_ in}
    //==========================================================================
    //override method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            if touch.view == handleView || touch.view == handleHelpView{
                ismoveing = true
                UIView.animate(withDuration: 0.2, animations: {
                    self.handleView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                })
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
            if ismoveing && handleView.center.x >= 15 && handleView.center.x <= self.frame.width-15{
                var tempLocationX = location.x
                if tempLocationX < 15{
                    tempLocationX = 15
                }
                if tempLocationX > self.frame.width-15{
                    tempLocationX = self.frame.width-15
                }
                let per = (tempLocationX-15)/(self.frame.width-30)
                rawValue = per*(max-min)+min
                
                let locationX = valueToLocation(rawValue)
                
                handleView.center.x = locationX
                handleHelpView.center.x = locationX
                sliderView.width = locationX-15
            }else{
                if handleView.center.x < 15{
                    handleView.center.x = 15
                }
                if handleView.center.x > self.frame.width-15{
                    handleView.center.x = self.frame.width-15
                }
            }
        }
        didValueChangeing()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        ismoveing = false
        UIView.animate(withDuration: 0.2, animations: {
            self.handleView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        didValueChanged()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        ismoveing = false
        UIView.animate(withDuration: 0.2, animations: {
            self.handleView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        didValueChanged()
    }
    //==========================================================================
    //private method
    private func setScreen(){
        sliderUnselectView.frame = CGRect(origin: CGPoint(x: 15,y: self.height/2), size: sizeMake(self.frame.width-30, 2))
        sliderView.frame.origin = CGPoint(x: 15,y: self.height/2)
        sliderView.frame.size.height = 2
        handleView.frame = CGRect(origin: .zero, size: sizeMake(15, 15))
        handleView.center.y = self.height/2
        handleHelpView.frame = CGRect(origin: .zero, size: sizeMake(50, 50))
        handleHelpView.center = handleView.center
    }
    private func setup(){
        self.isUserInteractionEnabled = true
        super.frame.size.height = 50
        
        setScreen()
        sliderUnselectView.backgroundColor = UIColor.white
        sliderUnselectView.layer.cornerRadius = 1
        
        sliderView.backgroundColor = sliderColor
        sliderView.layer.cornerRadius = 1
        
        
        handleView.backgroundColor = handleColor
        handleView.layer.cornerRadius = handleView.frame.height/2
        
        handleHelpView.backgroundColor = UIColor.clear
        
        self.addSubview(sliderUnselectView)
        self.addSubview(sliderView)
        self.addSubview(handleHelpView)
        self.addSubview(handleView)
    }
    private func didFrameChange(){
        setScreen()
    }
    private func didValueChangeing(){
        valueChangeing(self.value)
    }
    private func didValueChanged(){
        valueDidChanged(self.value)
    }
    private func valueToLocation(_ value:CGFloat)->CGFloat{
        return (rawValue-min)/(max-min)*(self.frame.width-30)+15
    }
}





