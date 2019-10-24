import UIKit

class ADMenu: UIWindow,UITableViewDelegate, UITableViewDataSource{
    //====================================================================
    //member
    var useActionArr = false
    var iconArr = [String]()
    var titles = [String]()
    var actionArr = [voidBlock]()
    var completed:voidBlock = {}
    var indexAction:intBlock = {_ in}
    var maxShowCellCount = 5
    static var isMenuShowed = false
    static var cellHeight = 50
    private var windowAnimated = false
    private var forSystemSuviveOnMemory = {}
    private var suviveOnMemory = ""
    private var defaultIsStatusBarHidden = false
    private var defaultStatusBarStyle:UIStatusBarStyle = .lightContent
    //======================================
    //Views
    private let BGview = RMControl()
    private let tableView = UITableView()
    //====================================================================
    //method
    //====================================================================
    //private method
    func insertItem(at index: Int,title:String,icon:String,action:@escaping voidBlock){
        self.titles.insert(title, at: index)
        self.iconArr.insert(icon, at: index)
        self.actionArr.insert(action, at: index)
        useActionArr = true
    }
    func addItem(title:String,icon:String,action:@escaping voidBlock){
        self.titles.append(title)
        self.iconArr.append(icon)
        self.actionArr.append(action)
        useActionArr = true
    }
    func close(){
        ADMenu.isMenuShowed = false
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                system.mainWindow.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.BGview.backgroundColor = .hex("0", alpha: 0)
                self.tableView.frame.origin.y = self.frame.height+self.tableView.frame.size.height
            },
            completion: {_ in
                self.indexAction = {_ in}
                self.actionArr = []
                self.completed = {}
                self.isHidden = true
                self.forSystemSuviveOnMemory = {}
                if self.windowAnimated{
                    application.isStatusBarHidden = self.defaultIsStatusBarHidden
                    application.statusBarStyle = self.defaultStatusBarStyle
                }
            }
        )
    }
    private func open(){
        if windowAnimated {
            defaultStatusBarStyle = application.statusBarStyle
            defaultIsStatusBarHidden = application.isStatusBarHidden
            application.statusBarStyle = .lightContent
            application.isStatusBarHidden = false
        }
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                if self.windowAnimated{
                    system.mainWindow.transform = CGAffineTransform(
                        scaleX: (system.mainWindow.height-40)/system.mainWindow.height,
                        y:      (system.mainWindow.height-40)/system.mainWindow.height
                    )
                }
                self.BGview.backgroundColor = .hex("0", alpha: 0.6)
                if self.iconArr.count<=self.maxShowCellCount{
                    self.tableView.frame.origin.y = self.frame.height-self.tableView.frame.size.height
                }else{
                    self.tableView.frame.origin.y = self.frame.height-CGFloat(ADMenu.cellHeight*self.maxShowCellCount+ADMenu.cellHeight/2)
                }
            },
            completion: {_ in}
        )
    }
    private func setCloseCell(){
        iconArr.append("close")
        titles.append("cancel".l())
        actionArr.append(close)
    }
    private func setupScreen(){
        setCloseCell()
        forSystemSuviveOnMemory = {self.suviveOnMemory = ""}
        frame.size = screen.size
        BGview.frame.size = frame.size
        tableView.width = frame.width
        if self.iconArr.count<=maxShowCellCount{
            self.tableView.height = CGFloat(iconArr.count*ADMenu.cellHeight)
        }else{
            self.tableView.height = CGFloat(ADMenu.cellHeight*maxShowCellCount+ADMenu.cellHeight/2)
        }
        tableView.y = frame.size.height-tableView.frame.size.height
    }
    private func setupSetting(){
        backgroundColor = .hex("0", alpha: 0)
        BGview.addGestureAction(.tap){[weak self] in
            self?.close()
        }
        BGview.backgroundColor = .hex("0", alpha: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = ADMenu.cellHeight.cgFloat
        tableView.frame.origin.y = self.frame.height+self.tableView.frame.size.height
        tableView.showsVerticalScrollIndicator = false
        addSubview(BGview)
        addSubview(tableView)
    }
    //====================================================================
    //delegate method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        close()
        if useActionArr{
            actionArr[indexPath.row]()
            completed()
        }else{
            if indexPath.row != iconArr.count-1{
                indexAction(indexPath.row)
                completed()
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return iconArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        let cell = ADMenuTableViewCell()
        cell.title = titles.index(indexPath.row) ?? ""
        cell.icon = iconArr.index(indexPath.row) ?? ""
        return cell
    }
    func show(windowAnimated: Bool = false){
        
        if ADMenu.isMenuShowed{
            debugPrint("ADMenu: menu is already showed.")
            return
        }
        ADMenu.isMenuShowed = true
        self.makeKey()
        self.makeKeyAndVisible()
        self.windowAnimated = windowAnimated
        setupScreen()
        setupSetting()
        open()
    }
}

extension ADMenu{
    class func show(animated:Bool=false,iconArr:[String],titles:[String],actionArr:[voidBlock],completed:@escaping voidBlock = {}) {
        let menu = ADMenu()
        menu.iconArr = iconArr
        menu.titles = titles
        menu.actionArr = actionArr
        menu.completed = completed
        menu.useActionArr = true
        menu.show(windowAnimated: animated)
    }
}


class ADMenuTableViewCell:ADTableViewCell{
    var title = "" {
        didSet{
            self.titleLabel.text = title
        }
    }
    var icon = "" {
        didSet{
            self.iconLabel.text = icon
        }
    }
    
    var iconLabel = UILabel()
    var titleLabel = UILabel()
    
    override func setup(){
        super.setup()
        rippleLayerColor = UIColor.lightGray
        self.separator.isHidden = true
        
        iconLabel.frame.size = sizeMake(24, 24)
        iconLabel.frame.origin.x = 20
        iconLabel.center.y = (ADMenu.cellHeight/2).cgFloat
        iconLabel.font = Font.MaterialIcons.font(24)
        iconLabel.textColor = .hex("555555")
        
        titleLabel.frame.origin.x = 80
        titleLabel.frame.size = sizeMake(self.frame.width-60, 30)
        titleLabel.center.y = (ADMenu.cellHeight/2).cgFloat
        titleLabel.textColor = .hex("555555")
        
        addSubview(iconLabel)
        addSubview(titleLabel)
    }
}
















