import UIKit
import WebKit

class ADDialog: UIWindow {
    enum AnimationStyle {
        case pop
        case fade
    }
    var title = ""{didSet{titleLabel.text = title}}
    var message = ""{didSet{messageView.text = message}}
    var textFieldText:String{get{return textField.text ?? ""}set{textField.text = newValue}}
    var textFieldPlaceHolder = ""{didSet{textField.placeholder = textFieldPlaceHolder}}
    
    //views
    var customView:UIView? = nil
    let textField = ADTextField()
    let messageView = UITextView()

    fileprivate let dialogView = UIView()
    fileprivate let titleLabel = UILabel()
    fileprivate let buttonsView = ButtonsView(frame: CGRect(origin: CGPoint.zero, size: sizeMake(260, 52)))
    fileprivate var contentsHight:CGFloat = 0
    fileprivate var customViewHeight:CGFloat?
    fileprivate var completion:voidBlock = {}
    
    //static
    static var current:ADDialog? = nil
    static var animationStyle = AnimationStyle.pop
    
    //func
    func addButton(title:String,tapToClose:Bool = true,with action:@escaping voidBlock = {}){
        buttonsView.addButton(title, block: tapToClose ? {[weak self] in self?.close();action()} : action)
    }
    func setCustomView(_ customView:UIView,for height:CGFloat? = nil){
        self.customViewHeight = height
        self.customView = customView
    }
    func setCompletion(_ completion:@escaping voidBlock){self.completion = completion}
    func close(){
        ADDialog.current = nil
        textField.resignFirstResponder()
        switch ADDialog.animationStyle {
        case .pop: popToEnd()
        case .fade: fadeToEnd()
        }
    }
    func show(){
        guard ADDialog.current == nil else {debugPrint("dialog is alredy showed");return}
        ADDialog.current = self
        setAlertBase()
        if !title.isEmpty{createTitleLabel()}
        if !message.isEmpty{createMessageView()}
        if !textFieldPlaceHolder.isEmpty || !textFieldText.isEmpty {createTextField()}
        if customView != nil {createCustomView()}
        if !buttonsView.buttons.isEmpty {addContent(buttonsView)}
        
        dialogView.center = self.center
        self.makeKey()
        self.makeKeyAndVisible()
        openAlert()
    }
    
    //private
    private func addContent(_ content:UIView,for height:CGFloat? = nil,top: CGFloat = 0){
        content.y = contentsHight+top
        dialogView.addSubview(content)
        if let height = height {contentsHight += height+top}
        else{contentsHight += content.frame.height+top}
        dialogView.height = contentsHight
    }
    private func setAlertBase(){
        windowLevel = UIWindowLevelAlert
        self.backgroundColor = .hex("0",alpha: 0.4)
        self.size = screen.size
        
        dialogView.width = 260
        dialogView.backgroundColor = .back
        dialogView.shadowLevel = 12
        dialogView.cornerRadius = 2
        
        self.addSubview(dialogView)
    }
    private func createTitleLabel(){
        let titleView = UIView()
        
        titleLabel.frame.size = sizeMake(dialogView.frame.width-48, 17)
        titleLabel.origin = pointMake(24, 20)
        titleLabel.text = title
        titleLabel.font = Font.Roboto.font(17)
        titleView.addSubview(titleLabel)
        titleView.height = 55
        
        addContent(titleView)
    }
    private func createMessageView(){
        let baseView = UIView()
        messageView.frame.size = sizeMake(dialogView.frame.width-48, 100)
        messageView.x = 24
        messageView.textColor = .subText
        messageView.noPadding()
        messageView.backgroundColor = UIColor.clear
        messageView.font = Font.Roboto.font(16)
        messageView.textAlignment = .left
        messageView.dissableFunctions()
        messageView.text = message
        messageView.sizeToFit()
        if messageView.frame.height>345 {
            let upperSeparater = UIView()
            upperSeparater.height = 0.5
            upperSeparater.width = 260
            upperSeparater.backgroundColor = .hex("aaa")
            
            let lowerSeparater = UIView()
            lowerSeparater.height = 0.5
            lowerSeparater.width = 260
            lowerSeparater.backgroundColor = .hex("aaa")
            
            messageView.frame.size.height = 345
            messageView.frame.size.height+=24
            messageView.isScrollEnabled = true
            upperSeparater.y = 0
            lowerSeparater.y = messageView.height
            baseView.addSubview(upperSeparater)
            baseView.addSubview(lowerSeparater)
            buttonsView.frame.origin.y = messageView.bottomY
        }else{
            buttonsView.frame.origin.y = messageView.bottomY+24
        }
        baseView.addSubview(messageView)
        baseView.height = messageView.height
        baseView.width = 260
        addContent(baseView,for: baseView.height+20)
    }
    private func createTextField(){
        textField.frame.size = sizeMake(dialogView.frame.width-48, 30)
        textField.bottomBorderColor = .main
        textField.bottomBorderWidth = 1.5
        textField.bottomBorderEnabled = true
        textField.placeholder = self.textFieldPlaceHolder
        textField.bottomBorderHighlightWidth = 2
        textField.textColor = .subText
        textField.safeCornerRadius = 2
        textField.x = 24
        addContent(textField,top: 7)
        textField.becomeFirstResponder()
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveEaseOut,animations: {self.dialogView.y -= 65})
    }
    private func createCustomView(){
        guard let customView = customView else {return}
        customView.width = 260
        customView.height = customViewHeight ?? customView.height
        addContent(customView)
    }
    private func freeMemory(){
        self.completion = {}
        self.buttonsView.buttons.map{button in button.removeAllActions()}
    }
    
    //animations
    private func openAlert(){
        if !textFieldPlaceHolder.isEmpty || !textFieldText.isEmpty {
            textField.becomeFirstResponder()
            if screen.height-device.keyBoardHight-self.dialogView.frame.height-20<self.center.y{
                forTextFieldBegin()
            }
        }
        switch ADDialog.animationStyle {
        case .pop: popToBegin()
        case .fade: fadeToBegin()
        }
    }
    private func popToBegin(){
        dialogView.transform =  CGAffineTransform(scaleX: 1.2, y: 1.2)
        dialogView.alpha = 0
        UIView.animate(withDuration: 0.15,delay: 0,options: .curveEaseOut,animations: {
            self.alpha = 0.66
            self.dialogView.alpha = 0.66
            self.dialogView.transform =  CGAffineTransform(scaleX: 0.98, y: 0.98)
        })
        UIView.animate(withDuration: 0.13,delay: 0.15,options: .curveEaseOut,animations: {
            self.alpha = 1
            self.dialogView.alpha = 1
            self.dialogView.transform =  CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    private func fadeToBegin(){
        dialogView.transform =  CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveEaseOut,animations: {
            self.alpha = 1
            self.dialogView.transform =  CGAffineTransform(scaleX: 1,y: 1)
        })
    }
    private func fadeToEnd(){
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveEaseOut,animations: {
            self.alpha = 0
            self.dialogView.transform =  CGAffineTransform(scaleX: 0.9,y: 0.9)
            self.dialogView.center = self.center
        },completion: {_ in
            self.isHidden = true
            self.completion()
            self.freeMemory()
        })
    }
    private func popToEnd(){
        UIView.animate(withDuration: 0.2,delay: 0,options: .curveEaseOut,animations: {
            self.alpha = 0
            self.dialogView.transform =  CGAffineTransform(scaleX: 0.9,y: 0.9)
            self.dialogView.center = self.center
        },completion: {_ in
            self.isHidden = true
            self.completion()
            self.freeMemory()
        })
    }
    private func forTextFieldBegin(){
        let toY = screen.height-device.keyBoardHight-self.dialogView.frame.height-20
        if self.dialogView.frame.origin.y > toY{
            UIView.animate(withDuration: 0.3,delay: 0,options: .curveEaseOut,animations:{
                self.dialogView.frame.origin.y = toY
            })
        }
    }
    
    //class
    class ButtonsView: UIScrollView{
        fileprivate var buttons:[ADButton] = []
        
        func addButton(_ title:String,color:UIColor = .main,block:@escaping voidBlock){
            self.clipsToBounds = true
            let button = ADButton()
            button.title = title
            button.titleColor = color
            button.addAction(block)
            buttons.append(button)
            button.titleLabel?.font = Font.Roboto.font(15,style: .normal)
            button.sizeToFit()
            button.safeCornerRadius = 2
            button.height=36
            button.width+=16
            button.y = 8
            if button.frame.width < 64 {button.width = 64}
            addSubview(button)
            self.contentSize.width = buttons.map{$0.width+8}.sum+8 > 260 ? buttons.map{$0.width+8}.sum+8 : 260
            _=buttons.enumerated().map{$1.rightX = contentSize.width-buttons.subArray(to: $0).map{$0.width+8}.sum-8}
            
            self.contentOffset.x = 100000
        }
    }
}

extension ADDialog{
    class func show(title:String,message: String="",_ action:@escaping voidBlock={}){
        let dialog = ADDialog()
        dialog.title = title
        if !message.isEmpty{dialog.message = message}
        dialog.addOKButton(action)
        dialog.addCancelButton()
        dialog.show()
    }
    class func alert(message:String,_ action:@escaping voidBlock = {}){
        ADDialog.show(title: "Alert", message: message)
    }
    class func error(message:String,_ action:@escaping voidBlock = {}){
        ADDialog.show(title: "error".l(), message: message)
    }
    func addOKButton(_ action:@escaping voidBlock = {}){addButton(title: "OK", with: action)}
    func addCancelButton(_ action:@escaping voidBlock = {}){addButton(title: "CANCEL", with: action)}
    func setCloseTime(to delay:Double){run(after: delay){[weak self] in self?.close()}}
    func autoClose(){setCloseTime(to: 0.75)}
    func hideBackgroundView(){self.backgroundColor = .clear}
}
extension ADDialog{
    func setTableView(titles:[String],style:SelectType,actions:[voidBlock]){
        setTableView(titles: titles, style: style, actions: actions, indexAction: {_ in}, selectedIndexAxtion: {_ in})
    }
    func setTableView(titles:[String],style:SelectType,indexAction: @escaping intBlock){
        setTableView(titles: titles, style: style, actions: [], indexAction: indexAction, selectedIndexAxtion: {_ in})
    }
    func setTableView(titles:[String],selectedIndexAxtion:@escaping ([Int])->()){
        setTableView(titles: titles, style: .checkBox, actions: [], indexAction: {_ in}, selectedIndexAxtion: selectedIndexAxtion)
    }
    private func setTableView(titles:[String],style:SelectType,actions:[voidBlock],indexAction: @escaping intBlock,selectedIndexAxtion:@escaping ([Int])->()){
        let tableView = TableView()
        tableView.titles = titles
        tableView.style = style
        tableView.actionArr = actions
        tableView.indexAction = indexAction
        tableView.selectedIndexAxtion = selectedIndexAxtion
        self.setCustomView(tableView)
    }
    enum SelectType {
        case select
        case checkBox
    }
    class TableView: RMView, UITableViewDelegate, UITableViewDataSource {
        var titles = [String]()
        var actionArr = [voidBlock]()
        var style = SelectType.select
        var indexAction:intBlock = {_ in}
        var selectedIndexAxtion:([Int])->() = {_ in}
        var enableCheckBoxIndexes = [Int:Bool]()
        let tableView = UITableView()
        
        deinit {
            var tmp = [Int]()
            _=enableCheckBoxIndexes.map{(k,v) in if v{tmp.append(k)}}
            selectedIndexAxtion(tmp)
            indexAction = {_ in}
            selectedIndexAxtion = {_ in}
            actionArr = []
        }
        
        override func setup() {
            super.setup()
            self.backgroundColor = .clear
            tableView.register(Cell.self, forCellReuseIdentifier: "cell")
            tableView.dataSource = self
            tableView.delegate = self
            tableView.rowHeight = 48
            tableView.width = 260
            tableView.backgroundColor = .clear
            
            addSubview(tableView)
        }
        func numberOfSections(in tableView: UITableView) -> Int {return 1}
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let cell = tableView.cellForRow(at: indexPath) as? Cell else {return}
            if style == .select{ADDialog.current?.close()}
            indexAction(indexPath.row)
            (actionArr.index(indexPath.row) ?? {})()
            cell.chackBox.on = !cell.chackBox.on
            enableCheckBoxIndexes[indexPath.row] = !(enableCheckBoxIndexes[indexPath.row] ?? false)
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            self.tableView.height = titles.count*48<360 ? CGFloat(titles.count*48) : 360
            self.height = self.tableView.height
            return titles.count
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
            cell.titleLabel.text = titles.index(indexPath.row) ?? ""
            cell.chackBox.isHidden = style == .select
            cell.titleLabel.x = style == .select ? 24 : 68
            cell.chackBox.on = enableCheckBoxIndexes[indexPath.row] ?? false
            cell.chackBox.removeAllActions()
            cell.chackBox.addAction {[weak self] in
                cell.chackBox.on = !cell.chackBox.on
                self?.enableCheckBoxIndexes[indexPath.row] = !(self?.enableCheckBoxIndexes[indexPath.row] ?? false)
            }
            return cell
        }
        
        class Cell: ADTableViewCell {
            class CheckBox: ADTip {
                var on = false{didSet{
                    title = on ? "check_box" : "check_box_outline_blank"
                    titleColor = on ? .main : .hex("999")
                }}
                override func setup() {
                    super.setup()
                    titleColor = .hex("999")
                    title = "check_box_outline_blank"
                }
            }
            let chackBox = CheckBox()
            let titleLabel = UILabel()
            override func setup() {
                super.setup()
                self.backgroundColor = .clear
                self.contentView.backgroundColor = .clear
                separator.isHidden = true
                chackBox.x = 10
                
                titleLabel.size = sizeMake(190, 20)
                titleLabel.origin = pointMake(58, 15)
                titleLabel.font = Font.Roboto.font(14)
                titleLabel.textColor = .text
                
                self.addSubview(chackBox)
                self.addSubview(titleLabel)
            }
        }
    }
}
extension ADDialog{
    func setIndicator(color:UIColor = .main,title:String){
        let waitIndicatorView = WaitIndicatorView()
        waitIndicatorView.titleLabel.text = title
        waitIndicatorView.indicator.color = color
        self.setCustomView(waitIndicatorView)
    }
    private class WaitIndicatorView: RMView{
        let indicator = ADActivityIndicator()
        let titleLabel = UILabel()
        override func setup() {
            super.setup()
            self.size = sizeMake(260, 75)
            indicator.size = sizeMake(45, 45)
            indicator.lineWidth = 3
            indicator.color = .main
            indicator.centerY = self.height/2
            indicator.x = 15
            
            titleLabel.size = sizeMake(170, 30)
            titleLabel.origin = pointMake(80, 22)
            titleLabel.font = Font.Roboto.font(13)
            titleLabel.textColor = .subText
            
            addSubview(indicator)
            addSubview(titleLabel)
        }
    }
}
extension ADDialog{
    func setWebView(with request:RMRequest,autoTitleChange:Bool = true){
        let webView = WebView()
        webView.request = request
        webView.autoTitleChange = autoTitleChange
        self.setCustomView(webView,for: 300)
        if autoTitleChange{self.title = " "}
    }
    class WebView: RMView {
        var request:RMRequest? = nil{didSet{
            guard let request = request else {return}
            webView.load(rmRequest: request)
        }}
        let progressBar = UIProgressView()
        var webView:RMWebView! = RMWebView()
        var autoTitleChange = true
        override func setup() {
            progressBar.size = sizeMake(260, 1)
            
            webView.size = sizeMake(260, 300)
            webView.y = 1
            webView.didProgressChange = {[weak self] per in
                self?.progressBar.progress = per
                self?.progressBar.isHidden = per == 1
            }
            webView.didTitleChange = {[weak self] title in
                if self?.autoTitleChange ?? false{ADDialog.current?.titleLabel.text = title}
            }
            addSubviews(webView,progressBar)
        }
    }
}
extension ADDialog{
    private class ProgressView: UIView{
        
    }
}


