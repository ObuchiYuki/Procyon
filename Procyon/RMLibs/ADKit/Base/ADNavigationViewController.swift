import UIKit

class ADNavigationController: ADViewController,ADHorizontalMenuDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate,UINavigationControllerDelegate{
    //====================================================================
    //  properties
    //======================================
    //when this property is true a menu button will be added on navigation bar
    //you can get tap event by overrideing the method menuButtonTapped()
    final var showBackButton:Bool = true{
        didSet{
            if !showBackButton {
                backButton.removeFromSuperview()
                navigationBarButtonsLeft.remove(backButton)
            }else{
                addButtonRight(backButton)
            }
        }
    }
    //======================================
    //back buttton is automatically added to navigationbar when it is needed
    //so if you want to force to remove backButton . please use this property
    final var showMenuButton:Bool = false{
        willSet(value){
            if value != showMenuButton && value{
                addButtonRight(menuButton)
            }
        }
        didSet{
            if !showMenuButton {
                menuButton.removeFromSuperview()
            }
        }
    }
    //======================================
    //when you make true this property
    //serchButton and some function will prepare
    //you can make app search mode by tapped Title label
    final var showSearchButton:Bool = false{
        didSet{
            if showSearchButton {
                searchButton.addAction{[weak self] in self?.searchBegan()}
                addButtonRight(searchButton)
                run(after: 0.1, block: {
                    self.defaultSearchButtonPosition = self.searchButton.frame.origin
                })
            }else{
                searchButton.removeFromSuperview()
            }
        }
    }
    final var showCloseButton = false{
        didSet{
            if showCloseButton{
                guard self.navigationController?.viewControllers.count == 1 || self.navigationController == nil else {return}
                let closeButton = ADTip(icon: "close")
                closeButton.addAction{[weak self] in self?.back()}
                addButtonLeft(closeButton)
                var newNavigationBarButtonsLeft = [ADTip]()
                navigationBarButtonsLeft.map{i in if i.title != "arrow_back"{newNavigationBarButtonsLeft.append(i)}else{i.removeFromSuperview()}}
                navigationBarButtonsLeft = newNavigationBarButtonsLeft
                checkButtonsFromRight(false)
            }
        }
    }
    //======================================
    //when you make this property true
    //User can call search view by tapped titleLabel
    //I rcommended you to make titleLabel text search word
    //so that user can understand "I am on serch".
    final var tapTitleLabelToBeganSearch = false{
        didSet{
            if tapTitleLabelToBeganSearch && showSearchButton{
                titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ADNavigationController.searchBegan)))
            }
        }
    }
    //======================================
    //when you change this property value
    //if view is loaded navigation bar will close with animation
    final var showNavigationBer:Bool = true{
        willSet(value){
            if value != showNavigationBer {
                if showNavigationBer {
                    UIView.animate(
                        withDuration: 0.2,
                        delay: 0,
                        options: UIViewAnimationOptions.curveEaseOut,
                        animations: {
                            self.navigationBar.frame.origin.y = 20
                            self.contentView.frame.size.height -= 52
                            self.contentView.frame.origin.y += 52
                        },
                        completion: {_ in}
                    )
                }else{
                    UIView.animate(
                        withDuration: 0.2,
                        delay: 0,
                        options: UIViewAnimationOptions.curveEaseOut,
                        animations: {
                            self.navigationBar.frame.origin.y = -(self.navigationBar.frame.size.height)+20
                            self.contentView.frame.size.height += 52
                            self.contentView.frame.origin.y -= 52
                        },
                        completion: {_ in}
                    )
                }
            }
        }
    }
    //======================================
    //when this proparty is true navigationbar shadow will be removed
    //I recommended not to do
    //I make this for horizontalMenu
    final var showShadow = true{
        didSet{
            if showShadow {
                navigationBar.layer.shadowOpacity = 0.5
            }else{
                navigationBar.layer.shadowOpacity = 0
            }
        }
    }
    //======================================
    //when you make this property true
    //status bar will be hide and all navigation items set to fit automatically
    final var useFullScreen = false{
        didSet{
            if useFullScreen {
                isStatusBarHidden = true
            }
            checkStatusBar()
        }
    }
    //======================================
    //when you make this property true
    //
    final var useTranslucentNavigationBar = false{
        didSet{
            if useTranslucentNavigationBar{
                fullContentsFrame = view.frame
                contentView.frame.origin.y -= 72
                showShadow = false
            }
        }
    }
    //======================================
    //そのまま　Literally
    final var statusBarBackgroundColor = UIColor.main{
        didSet{
            statusBarBackground.backgroundColor = statusBarBackgroundColor
        }
    }
    //======================================
    //if you want to change colors used in navigation Controller
    //when you change this property
    //statusBarBackgroundColor, navigationBarBackGroundColor and icons colors will change.
    //to the best color for user interface
    final var themeColor = UIColor.main{
        didSet{
            statusBarBackground.backgroundColor = themeColor
            navigationBar.backgroundColor = themeColor
            searchNavigationOverLayView.backgroundColor = themeColor
            if forceNavigationItemColor == nil{
                if themeColor.isDark {
                    navigationItemColor = UIColor.white
                }else{
                    navigationItemColor = UIColor.black.alpha(0.75)
                }
            }else{
                navigationItemColor = forceNavigationItemColor!
            }
            for item in navigationBarButtonsLeft{
                item.setTitleColor(navigationItemColor, for: UIControlState())
            }
            for item in navigationBarButtonsRight{
                item.setTitleColor(navigationItemColor, for: UIControlState())
            }
            titleLabel.textColor = navigationItemColor
            searchTextField.tintColor = navigationItemColor
            searchTextField.textColor = navigationItemColor
        }
    }
    final var forceNavigationItemColor:UIColor? = nil{
        didSet{
            navigationItemColor = forceNavigationItemColor!
            for item in navigationBarButtonsLeft{
                item.setTitleColor(forceNavigationItemColor!, for: UIControlState())
            }
            for item in navigationBarButtonsRight{
                item.setTitleColor(forceNavigationItemColor!, for: UIControlState())
            }
            titleLabel.textColor = forceNavigationItemColor!
            searchTextField.tintColor = forceNavigationItemColor!
            searchTextField.textColor = forceNavigationItemColor!
        }
    }
    //======================================
    //this is title text of navigation bar
    //please set title of a viewController
    override var title: String?{
        set{
            super.title = newValue
            self.titleLabel.text = newValue
        }
        get{
            return super.title
        }
    }
    //======================================
    //please set ADHorizontalMenu instance
    //when you set horizontalMenu navigationBar showdow remove automatically
    final var horizontalMenu:ADHorizontalMenu? = nil{
        didSet{
            addSubview((horizontalMenu?.view)!)
            self.showShadow = false
        }
    }
    final var innerNavigationViewEnable = false{
        didSet{
            if innerNavigationViewEnable{
                helpGestureView.removeFromSuperview()
            }
        }
    }
    //======================================
    //please set what to do when search text field's keyBoard's return key tapped
    //you can get a text putted in text field by closure
    var searchEndAction:stringBlock = {_ in}
    var searchTextChangeAction:stringBlock = {_ in}
    var searchEstimatedObjects = [String](){
        didSet{
            searchEstimatedView.titles = searchEstimatedObjects
        }
    }
    var searchEstimatedItemSelected:intBlock = {_ in}{
        didSet{
            searchEstimatedView.cellTapped = searchEstimatedItemSelected
        }
    }
    //======================================
    //this property has CGRect of full contents
    final var fullContentsFrame = CGRect()
    final var navigationItemColor = UIColor.white
    //======================================
    //Views
    //======================================
    //あんまり使わんでね。
    final let navigationBar = RMView()
    final let searchTextField = UITextField()
    final var searchButton = ADTip(icon: "search")
    final let searchEstimatedView = ADSearchEstimatedView()
    final let backButton = ADTip(icon: "arrow_back")
    final let menuButton = ADTip(icon: "more_vert")
    //====================================================================
    //private properties
    private var navigationBarButtonsLeft:[ADTip] = []
    private var navigationBarButtonsRight:[ADTip] = []
    private var defaultSearchButtonPosition = CGPoint()
    private var searchTitleLabelGestureEnable = false
    private let helpGestureView = UIView()
    private let statusBarBackground = UIView()
    private let titleLabel = RMLabel()
    private let searchNavigationOverLayView = UIView()
    private let searchOverLayView = UIView()
    //====================================================================
    //  method
    //======================================
    //not recommended
    //you can add button to navigationbar from left
    //but I don't recommend to use it because there are already menu button and back button
    final func addButtonLeft(_ button:ADTip){
        button.setTitleColor(navigationItemColor, for: UIControlState())
        self.navigationBarButtonsLeft.insert(button, at: 0)
        self.checkButtonsFromRight(false)
        self.navigationBar.addSubview(button)
    }
    //======================================
    //you can add button to navigationbar from right
    final func addButtonRight(_ button:ADTip){
        button.setTitleColor(navigationItemColor, for: UIControlState())
        self.navigationBarButtonsRight.insert(button, at: 0)
        self.checkButtonsFromRight(true)
        self.navigationBar.addSubview(button)
    }
    //======================================
    //you can remove all navigationbar items without backbutton if you want to
    //remove buck button make showBuckButton false
    final func removeAllNavigationItems(){
        for button in navigationBarButtonsLeft {
            if button != backButton {
                button.removeFromSuperview()
            }
        }
        for button in navigationBarButtonsLeft {
            if button != backButton {
                button.removeFromSuperview()
            }
        }
        navigationBarButtonsLeft = []
        navigationBarButtonsRight = []
        if navigationController?.viewControllers.count != 1 && navigationController != nil{
            addButtonLeft(backButton)
        }
    }
    //====================================================================
    //for override method
    //======================================
    //menuButtonTapped (optional override)
    func menuButtonTapped(){}
    //====================================================================
    //private method
    private func checkStatusBar(){
        if isStatusBarHidden {
            statusBarBackground.removeFromSuperview()
            isStatusBarHidden = true
            navigationBar.frame.origin.y-=20
        }
    }
    @objc private func searchBegan(){
        searchOverLayView.isHidden = false
        searchTextField.becomeFirstResponder()
        searchTextField.isHidden = false
        navigationBar.bringSubview(toFront: searchNavigationOverLayView)
        navigationBar.bringSubview(toFront: searchButton)
        navigationBar.bringSubview(toFront: searchTextField)
        searchNavigationOverLayView.isHidden = false
        searchEstimatedView.open()
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.searchTextField.alpha = 1
                self.searchNavigationOverLayView.alpha = 1
                self.searchButton.frame.origin.x = 0
                self.searchOverLayView.alpha = 1
            },
            completion: { _ in}
        )
    }
    func searchEndActionAnimation(){
        searchTextField.resignFirstResponder()
        searchEstimatedView.close()
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.searchNavigationOverLayView.alpha = 0
                self.searchTextField.alpha = 0
                self.searchButton.frame.origin = self.defaultSearchButtonPosition
                self.searchOverLayView.alpha = 0
            },
            completion: { _ in
                self.searchNavigationOverLayView.isHidden = true
                self.searchOverLayView.isHidden = true
                self.searchTextField.isHidden = true
            }
        )
    }
    func searchEndActioned(_ word:String){
        searchEndActionAnimation()
        searchEndAction(word)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchEndActioned(searchTextField.text!)
        return true
    }
    override func setupScreen_P(){
        super.setupScreen_P()
        helpGestureView.frame = CGRect(
            origin: Point(0, 0),
            size: CGSize(width: 10, height: view.frame.height)
        )
        statusBarBackground.frame = CGRect(
            origin: Point(0, 0),
            size: CGSize(width: view.frame.width, height: 20.5)
        )
        navigationBar.frame = CGRect(
            origin: Point(0, 20),
            size: CGSize(width: view.frame.width, height: 52.5)
        )
        navigationBar.shadowLevel = 2
        navigationBar.layer.shadowRadius = 1
        contentView.frame = CGRect(
            origin: Point(0, 72),
            size: CGSize(width: view.frame.width, height: view.frame.height-72)
        )
        searchNavigationOverLayView.frame = CGRect(
            origin: Point(0, -20),
            size: CGSize(width: view.frame.width, height: 72)
        )
        searchTextField.frame = CGRect(
            origin: Point(48, 10),
            size: CGSize(width: 250, height: 30)
        )
        searchEstimatedView.frame.origin = Point(5, 77)
        titleLabel.frame.origin.y = 14
        titleLabel.frame.size.height = 20
        searchOverLayView.frame = view.frame
        searchOverLayView.backgroundColor = .hex("0", alpha: 0.75)
        fullContentsFrame = CGRect(x: 0, y: 0, width: contentView.width, height: contentView.frame.size.height)
        checkStatusBar()
    }
    override func setLoadControl_P() {
        super.setLoadControl_P()
        //orgDelegate = navigationController?.interactivePopGestureRecognizer!.delegate
        navigationController?.interactivePopGestureRecognizer!.delegate = self
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //navigationController?.interactivePopGestureRecognizer!.delegate = orgDelegate
    }
    override func setupSetting_P(){
        super.setupSetting_P()
        
        navigationController?.delegate = self
        navigationController?.isNavigationBarHidden = true
        
        addKeyCommand(input: "f", modifierFlags: .command){[weak self] in self?.searchBegan()}
        addKeyCommand(input: UIKeyInputEscape, modifierFlags: .none){[weak self] in self?.searchEndActionAnimation()}
        addKeyCommand(input: UIKeyInputRightArrow, modifierFlags: .none){[weak self] in
            self?.horizontalMenu?.move(at: (self?.horizontalMenu?.currentIndex ?? 0)+1)
        }
        addKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: .none){[weak self] in
            self?.horizontalMenu?.move(at: (self?.horizontalMenu?.currentIndex ?? 0)-1)
        }
        //======================================
        //setting
        helpGestureView.backgroundColor = UIColor.clear
        statusBarBackground.backgroundColor = .main
        navigationBar.backgroundColor = .main
        titleLabel.textColor = AppColor.navigationItemColor
        titleLabel.font = Font.Roboto.font(19)
        if showSearchButton {
            titleLabel.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(ADNavigationController.searchBegan))
            )
            searchTitleLabelGestureEnable = true
        }
        menuButton.addAction{[weak self] in
            self?.menuButtonTapped()
        }
        backButton.addAction{[weak self] in
            self?.back()
        }
        searchNavigationOverLayView.backgroundColor = .main
        searchNavigationOverLayView.unsafeShadowLevel = 4
        searchNavigationOverLayView.isHidden = true
        searchNavigationOverLayView.alpha = 0
        searchTextField.delegate = self
        searchTextField.isHidden = true
        searchTextField.placeholder = "search".l()
        searchTextField.font = Font.Roboto.font(19)
        searchTextField.tintColor = AppColor.navigationItemColor
        searchTextField.textColor = AppColor.navigationItemColor
        searchTextField.addTarget(self, action: #selector(ADNavigationController.didSearchTextChange), for: .editingChanged)
        searchTextField.keyboardType = .webSearch
        searchOverLayView.alpha = 0
        searchOverLayView.isHidden = true
        searchOverLayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ADNavigationController.searchEndActionAnimation)))
        //======================================
        //add
        if showMenuButton {
            addButtonRight(menuButton)
        }
        if navigationController?.viewControllers.count != 1 && navigationController != nil{
            addButtonLeft(backButton)
        }
        navigationBar.addSubview(titleLabel)
        navigationBar.addSubview(searchNavigationOverLayView)
        navigationBar.addSubview(searchTextField)
        view.addSubview(searchOverLayView)
        view.addSubview(searchEstimatedView)
        view.addSubview(navigationBar)
        view.addSubview(statusBarBackground)
        view.addSubview(helpGestureView)
    }
    @objc private func didSearchTextChange(){
        self.searchTextChangeAction(self.searchTextField.text!)
    }
    func checkButtonsFromRight(_ right:Bool){
        if right {
            for i in 0...navigationBarButtonsRight.count-1{
                let button = navigationBarButtonsRight[navigationBarButtonsRight.count-i-1]
                button.frame.origin.x = view.frame.width-CGFloat((i+1)*48)
            }
        }else{
            for i in 0...navigationBarButtonsLeft.count-1{
                let button = navigationBarButtonsLeft[i]
                button.frame.origin.x = CGFloat(i*48)
            }
        }
        titleLabel.width = screen.width - CGFloat(navigationBarButtonsLeft.count+navigationBarButtonsRight.count)*48
        if navigationBarButtonsLeft.count>0{
            titleLabel.frame.origin.x = CGFloat(navigationBarButtonsLeft.count)*48
        }else{
            titleLabel.frame.origin.x = 18
        }
    }
}





















