import UIKit

class PixivSearchViewController: PixivBaseViewController{
    var word = ""
    var state:SearchState = .work
    var isTag = false{didSet{workSearchSetting.target = .partial_match_for_tags;novelSearchSetting.target = .partial_match_for_tags}}
    private var workSearchSetting = pixivWorkSearchSettingData(){
        didSet{
            workInner.set(word: word, setting: workSearchSetting)
            workInner.reload()
        }
    }
    private var novelSearchSetting = pixivNovelSearchSettingData(){
        didSet{
            novelInner.set(word: word, setting: novelSearchSetting)
            novelInner.reload()
        }
    }
    
    private let tuneButton = ADTip(icon: "tune")
    private let workInner = PixivSearchInner()
    private let novelInner = PixivNovelSearchInner()
    private let userInner = PixivUserSearchInner()
    
    enum SearchState:Int {
        case work = 0
        case novel
        case user
    }
    
    override func setSetting() {
        title = word
        searchTextField.text = word
        themeColor = .hex("f0f0f0")
        statusBarColor = .default
        
        workInner.set(word: word, setting: workSearchSetting)
        workInner.delegate = self
        workInner.title = "photo"
        workInner.statusBarColor = .default
        
        novelInner.set(word: word, setting: novelSearchSetting)
        novelInner.delegate = self
        novelInner.title = "book"
        novelInner.statusBarColor = .default
        
        userInner.word = word
        userInner.delegate = self
        userInner.title = "person"
        userInner.statusBarColor = .default
        
        tuneButton.addAction {[weak self] in
            guard let me = self else {return}
            switch me.state{
            case .work:
                let viewController = PixivSearchSettingViewController()
                viewController.settingData = self?.workSearchSetting
                viewController.endBlock = {setting in self?.workSearchSetting=setting}
                me.go(to: viewController)
            case .novel:
                let viewController = PixivNovelSearchSettingViewController()
                viewController.settingData = self?.novelSearchSetting
                viewController.endBlock = {setting in self?.novelSearchSetting=setting}
                me.go(to: viewController)
            case .user:
                break
            }
        }
        
        horizontalMenu = ADHorizontalMenu(
            viewControllers: [workInner,novelInner,userInner],
            defaultOption: .white
        )
        horizontalMenu?.delegate = self
        horizontalMenu?.move(at: state.rawValue,animated: false)
        
        addButtonRight(tuneButton)
    }
    func horizontalMenuDidMove(at index: Int){
        state = SearchState(rawValue: index) ?? .work
        tuneButton.titleColor = state == .user ? .hex("bbb") : navigationItemColor
    }
}




