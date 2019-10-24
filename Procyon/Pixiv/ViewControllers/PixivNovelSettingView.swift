import UIKit

class PixivNovelSettingView: RMView{
    var themeChangeAction:voidBlock = {}
    
    private var themeData = PixivSystem.novelTheme
    
    private let colorThemeButtonsView = PixivColorThemeButtonsView()
    private let slider = ADSlider()
    private let siderLeftLabel = UILabel()
    private let minchoButton = ADButton()
    private let gothicButton = ADButton()
    
    override func setup() {
        super.setup()
        self.height = 145
        
        minchoButton.height = 50
        minchoButton.backgroundColor = .clear
        minchoButton.titleLabel?.font = Font.HiraginoMincho.font(20)
        minchoButton.titleColor = .text
        minchoButton.title = "mincho".l()
        minchoButton.addAction{[weak self] in
            PixivSystem.novelTheme.font.textFont = .mincho
            self?.themeChangeAction()
        }
        
        gothicButton.height = 50
        gothicButton.backgroundColor = .clear
        gothicButton.titleLabel?.font = Font.Roboto.font(20)
        gothicButton.titleColor = .text
        gothicButton.title = "gothic".l()
        gothicButton.addAction{[weak self] in
            PixivSystem.novelTheme.font.textFont = .gothic
            self?.themeChangeAction()
        }
        
        colorThemeButtonsView.height = 55
        colorThemeButtonsView.y = 50
        colorThemeButtonsView.select(at: themeData.color.index)
        colorThemeButtonsView.indexSelectedAction = {[weak self] index in
            PixivSystem.novelTheme.color.index = index
            PixivSystem.novelTheme.color = pixivNovelThemeData.pixivNovelColorData(index: index)
            self?.themeChangeAction()
        }
        
        slider.min = 8
        slider.max = 35
        slider.y = 105
        slider.sliderUnselectColor = .subText
        slider.handleColor = .main
        slider.valueDidChanged = {[weak self] per in
            PixivSystem.novelTheme.font.textSize = CGFloat(per.int)
            self?.themeChangeAction()
        }
        
        siderLeftLabel.text = "format_size"
        siderLeftLabel.font = Font.MaterialIcons.font(20)
        siderLeftLabel.size = sizeMake(20, 20)
        siderLeftLabel.textColor = .subText
        siderLeftLabel.centerY = 130
        siderLeftLabel.x = 20
        
        addSubviews(colorThemeButtonsView,minchoButton,gothicButton,siderLeftLabel,slider)
    }
    override func didChangeFrame() {
        minchoButton.width = self.width/2
        minchoButton.x = 0
        
        gothicButton.width = self.width/2
        gothicButton.x = self.width/2
        
        colorThemeButtonsView.x = 0
        colorThemeButtonsView.width = self.width
        
        slider.width = self.width-60
        slider.value = themeData.font.textSize
        slider.x = 50
    }
}

private class PixivColorThemeButtonsView: RMView{
    var indexSelectedAction:intBlock = {_ in}
    
    private let buttons = [ThemeButton(),ThemeButton(),ThemeButton(),ThemeButton()]
    
    func select(at index: Int) {
        for i in 0..<buttons.count{
            buttons[i].isSelected = (i == index)
        }
    }
    
    override func setup() {
        super.setup()
        for i in 0..<buttons.count{
            buttons[i].x = i.cgFloat*60+15
            buttons[i].y = 7.5
            buttons[i].theme = [.white,.worm,.gray,.black][i]
            buttons[i].title = ["white_theme".l(),"worm_theme".l(),"gray_theme".l(),"black_theme".l()][i]
            buttons[i].addAction {[weak self] in
                guard let me = self else {return}
                me.select(at: i)
                me.indexSelectedAction(i)
            }
            addSubview(buttons[i])
        }
    }
    
    private class ThemeButton: ADButton{
        var theme:pixivNovelThemeData.pixivNovelColorData = .white{
            didSet{
                self.backgroundColor = theme.backgroundColor
                self.rippleLayerColor = theme.textColor
                self.titleColor = theme.textColor
            }
        }
        override var isSelected: Bool{
            set{
                _isSelected = newValue
                if newValue{
                    self.layer.borderColor = UIColor.main.cgColor
                }else{
                    self.layer.borderColor = UIColor.subText.cgColor
                }
            }
            get{
                return _isSelected
            }
        }
        private var _isSelected = false
        
        override func setup() {
            super.setup()
            self.size = sizeMake(50, 40)
            self.noCorner()
            self.layer.borderColor = UIColor.subText.cgColor
            self.layer.borderWidth = 1
        }
    }
}
