 import UIKit

class RMViewController:UIViewController{
    //====================================================================
    //variables
    private var commands = [UIKeyCommand:voidBlock]()
    @objc private func keyCommandHandler(_ keyCommand:UIKeyCommand){
        commands.map{if $0.key == keyCommand{$0.value()}}
    }
    func addKeyCommand(input: String, modifierFlags: UIKeyModifierFlags, action:@escaping voidBlock) {
        let command = UIKeyCommand(input: input, modifierFlags: modifierFlags, action: #selector(RMViewController.keyCommandHandler(_:)))
        self.commands[command] = action
        self.addKeyCommand(command)
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    //==================================
    // useWithStoryBoard
    //you have to make this property true when you use StoryBorad
    final var useWithStoryBoard = false{
        didSet{
            if useWithStoryBoard {
                contentView.removeFromSuperview()
            }
        }
    }
    final var useAsInnerView = false{
        didSet{
            useWithStoryBoard = useAsInnerView
        }
    }
    //==================================
    //you can hide status bar
    final var isStatusBarHidden = false{
        didSet{
            checkStatusBar()
        }
    }
    //==================================
    //you can set status bar color
    final var statusBarColor:UIStatusBarStyle{
        set{
            _statusBarColor = newValue
            checkStatusBar()
        }
        get{
            if let statusBarColor = _statusBarColor{
                return statusBarColor
            }else{
                return AppColor.statusBarColor
            }
        }
    }
    private var _statusBarColor:UIStatusBarStyle? = nil
    //==================================
    // contentView
    //all view have to be added to this view
    //you have to addSubView not to view but to contentView
    final let contentView = RMControl()
    var contentSize:CGSize{
        return contentView.size
    }
    var backgroundColor:UIColor? = nil{
        didSet{
            self.contentView.backgroundColor = backgroundColor
        }
    }
    
    final var isFirstLoad = true
    final var isCurrentViewController:Bool{
        if  screen.currentViewController == nil ||
            screen.currentViewController == self.navigationController ||
            screen.currentViewController == self
        {
            return true
        }else{
            return false
        }
    }
    var fullScreenSize:CGSize{
        return view.size
    }
    //====================================================================
    //  methods
    //==================================
    // addSubview
    //this method add view to contentView
    final func addSubview(_ subView:UIView){
        if useWithStoryBoard {
            view.addSubview(subView)
        }else{
            contentView.addSubview(subView)
        }
    }
    final func addSubviews(_ subViews:UIView...){
        if useWithStoryBoard {
            view.addSubviews(viewArr: subViews)
        }else{
            view.addSubviews(viewArr: subViews)
        }
    }
    //==================================
    // addSubviews
    //this method add overlay view as FullScreen view
    //like dialog, waitView as so on.
    final func addFullScreenView(_ subView:UIView){
        subView.size = contentSize
        self.view.addSubview(subView)
    }
    //==================================
    //back
    final func back(animated:Bool=true,_ block:@escaping voidBlock={}){
        if self.navigationController == nil || self.navigationController?.viewControllers.count == 1{
            self.dismiss(animated: animated, completion: block)
        }else{
            _ = navigationController?.popViewController(animated: animated)
        }
    }
    //==================================
    //go
    final func go(to vc:UIViewController,usePush:Bool = true,animated:Bool = true){
        if self.navigationController == nil{
            self.present(vc, animated: animated, completion: {})
        }else if usePush{
            navigationController?.pushViewController(vc, animated: animated)
        }else{
            navigationController?.present(vc, animated: animated, completion: {})
        }
    }
    //====================================================================
    //override methods
    //==================================
    // setSetting
    //write view setting in this method
    //this method call only one time when view did load
    func setSetting(){}
    //==================================
    // setUISetting
    //write Setting of UI in this method
    //this method call only one time when view did load
    func setUISetting(){}
    //==================================
    // setUIScreen
    //write UI Position in this method
    //this method call when view did load or when device was rotate
    func setUIScreen(){}
    //==================================
    // addUIs
    //write all add View method in this method
    //this method call only one time when view did load
    func addUIs(){}
    //==================================
    // setLoadControl
    //write starting animation in this method
    //this method call only one time when view did apper
    func setLoadControl(){}
    //==================================
    //if you override this methods
    //write root setting of viewController
    //you have to call super.METHOD() again in your method
    func setupScreen_P(){
        contentView.frame = view.frame
    }
    func setupSetting_P(){
        self.view.backgroundColor = .back
        self.contentView.backgroundColor = .clear
        self.automaticallyAdjustsScrollViewInsets = false
        addKeyCommand(input: "[", modifierFlags: .command, action: {[weak self] in self?.back()})
        addKeyCommand(input: "w", modifierFlags: .command, action: {[weak self] in self?.back()})
        
        view.addSubview(contentView)
    }
    func setupEndSetting_P(){}
    func setLoadControl_P(){}
    //====================================================================
    //viewDidLoad
    override func viewDidLoad() {
        isFirstLoad = false
        app.rotateEnable = app.rotateDefaultEnable
        super.viewDidLoad()
        setupSetting_P()
        setupScreen_P()
        setSetting()
        setUISetting()
        setUIScreen()
        addUIs()
        setupEndSetting_P()
    }
    //====================================================================
    //viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        checkStatusBar()
        setLoadControl_P()
        setLoadControl()
    }
    //====================================================================
    //private methods
    private func checkStatusBar(){
        application.statusBarStyle = statusBarColor
        application.isStatusBarHidden = isStatusBarHidden
    }
    //====================================================================
    //delegate methods
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return statusBarColor
    }
}













