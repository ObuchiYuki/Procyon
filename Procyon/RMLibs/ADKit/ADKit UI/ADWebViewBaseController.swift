import UIKit
import WebKit

class ADWebViewController: ADNavigationController ,WKNavigationDelegate,WKUIDelegate{
    var defaultUrl:String? = nil{didSet{if let request = defaultUrl?.request{webView.load(rmRequest: request)}}}
    var defaultRequest:RMRequest? = nil{didSet{if let request = defaultRequest{webView.load(rmRequest: request)}}}
    var useContentsBlocker = true
    let historyManager = ADWebHistoryManager.shared
    let webView = WKWebView()
    private let progressBar = UIProgressView()
    
    typealias HistoryData = ADWebHistoryManager.HistoryData
    
    func willLoadPage(webView: WKWebView){}
    func didLoadPage(webView: WKWebView){}
    func shouldOpenUrl(url: URL)->Bool{return true}
    func willTitleChange(title: String)->String{return title}
    func shouldAddHistory(history:HistoryData)->Bool{return true}
    func willAddHistory(history:HistoryData)->HistoryData{return history}
    
    fileprivate func open(history: HistoryData){
        webView.load(rmRequest: history.url.request)
    }

    override func menuButtonTapped() {
        let menu = ADMenu()
        menu.iconArr = ["explore","history"]
        menu.titles = ["open_in_safari".l(),"view_history".l()]
        menu.indexAction = {[weak self] index in
            guard let me = self else {return}
            switch index {
            case 0:
                if let url = me.webView.url{application.openURL(url)}
            case 1:
                let vc = ADWebHistoryViewController()
                vc.fromViewController = self
                self?.go(to: vc,usePush: false)
            default:
                break
            }
        }
        menu.show(windowAnimated: true)
    }
    override func setupScreen_P() {
        super.setupScreen_P()
        innerNavigationViewEnable = true
        showMenuButton = true
        
        progressBar.size = sizeMake(screen.width, 2)
        progressBar.y = navigationBar.height-2
        progressBar.tintColor = .main
        
        webView.size = contentSize
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.addObserver(self, forKeyPath:"estimatedProgress", options:.new, context:nil)
        webView.addObserver(self, forKeyPath:"title", options: .new, context:nil)
        showCloseButton = true
        
        addSubview(webView)
        navigationBar.addSubview(progressBar)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard  let keyPath = keyPath else {return}
        switch keyPath {
        case "estimatedProgress":
            if let progress = change?[.newKey] as? Float {
                if progress == 1 {
                    UIView.animate(withDuration: 0.5) {
                        self.progressBar.alpha = 0
                    }
                }else if progressBar.alpha != 1{
                    progressBar.setProgress(progress, animated: progressBar.progress != 1)
                    UIView.animate(withDuration: 0.2) {
                        self.progressBar.alpha = 1
                    }
                }
            }
        case "title":
            if
                let title = webView.title,
                let url = webView.url?.absoluteString
            {
                if !title.isEmpty{
                    let history = HistoryData(title: title, url: url)
                    if shouldAddHistory(history: history){
                        self.historyManager.add(willAddHistory(history: history))
                    }
                }
            }
            self.title = willTitleChange(title: webView.title ?? "")
        default:
            break
        }
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.willLoadPage(webView: webView)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if useContentsBlocker{
            let javaScript = JavaScriptDOM()
            javaScript.hideBy(
                ids: [
                    "top_touch",
                    "global-sidemenu-close_touch",
                    "breadcrumbs_touch",
                    "illust_touch",
                    "bottom_pixivcomic_touch",
                    "related_contents_touch",
                    "view_comments_touch",
                    "share_article_touch",
                    "related_articles_touch",
                    "bottom_spotlight_touch",
                    "back-to-top_touch",
                    "page-footer_touch",
                    "bottom_infobar_touch",
                    "inner_pixivcomic_touch",
                    "inner_pixivnovel_touch"
                ]
            )
            javaScript.hideBy(
                classNames: [
                    "pixivcomic_body_ad",
                    "subscript",
                    "subscript2",
                    "share_touch",
                    "checklist_add_button",
                    "article_section_allopen_link",
                    "article_section_close_link"
                ]
            )
            javaScript.hideBy(tags: [
                "dt",
                "dd",
                "iframe"
            ])
            javaScript.hideByAutomatic()
            webView.evaluateJavaScript(javaScript.string, completionHandler: {_ in})
        }
        didLoadPage(webView: webView)
    }
    func webView(_ webView: WKWebView,decidePolicyFor navigationAction: WKNavigationAction,decisionHandler: @escaping(WKNavigationActionPolicy) -> Void){
        decisionHandler(shouldOpenUrl(url: navigationAction.request.url!) ? .allow : .cancel)
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil{if let url = navigationAction.request.url{application.openURL(url)}}
        return nil
    }
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "title")
    }
}

class ADWebHistoryManager{
    var defaultName = "ADKit_web_view_controller_histories"
    
    static var shared = ADWebHistoryManager()
    struct HistoryData: Storable,Equatable{
        var title:String
        var url:String
        
        var dict: [String : Any]{
            return ["title": title,"url": url]
        }
        static func ==(lhs: HistoryData, rhs: HistoryData) -> Bool{
            return lhs.title == rhs.title
        }
        
        init(dict: [String : Any]) {
            self.title = stringValue(of: dict["title"])
            self.url = stringValue(of: dict["url"])
        }
        init(title:String,url:String) {
            self.title = title
            self.url = url
        }
    }
    
    func add(_ newHistory:HistoryData){
        var histories = info.structArray(type: HistoryData.self, forKey: self.defaultName).filter{h in h.title != newHistory.title}
        histories.insert(newHistory, at: 0)
        
        info.setStorableArray(histories, forKey: self.defaultName)
    }
    func histories()->[ADWebViewController.HistoryData]{
        return info.structArray(type: HistoryData.self, forKey: self.defaultName)
    }
    func remove(at index:Int){
        var histories = info.structArray(type: HistoryData.self, forKey: self.defaultName)
        histories.remove(at: index)
        info.setStorableArray(histories, forKey: self.defaultName)
    }
    func removeAll(){
        info.set([], forKey: self.defaultName)
    }
}
fileprivate class ADWebHistoryViewController: ADNavigationController,UITableViewDataSource,UITableViewDelegate {
    weak var fromViewController:ADWebViewController? = nil
    private var historyDatas = ADWebHistoryManager.shared.histories()
    private let deleteButton = ADMainButton(icon: "delete")
    private let tableView = UITableView()
    
    func onLongTap(sender: UILongPressGestureRecognizer){
        let point = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
            ADDialog.show(title: historyDatas[indexPath.row].title, message: "remove?".l()){[weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                ADWebHistoryManager.shared.remove(at: indexPath.row)
                self?.historyDatas.remove(at: indexPath.row)
                self?.tableView.endUpdates()
            }
        }
    }
    
    fileprivate override func setSetting() {
        title = "view_history".l()
        showCloseButton = true
    }
    fileprivate override func setUISetting() {
        tableView.register(ADSettingViewTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 52
        tableView.delegate = self
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(ADWebHistoryViewController.onLongTap)))
        tableView.dataSource = self
        
        deleteButton.addAction {[weak self] in
            ADDialog.show(title: "remove_all_history?".l(),message: "long_press_to_remove_each".l()){
                self?.historyDatas = []
                ADWebHistoryManager.shared.removeAll()
                self?.tableView.reloadData()
            }
        }
        mainButton = deleteButton
    }
    fileprivate override func setUIScreen() {
        tableView.size = contentSize
    }
    fileprivate override func addUIs() {
        addSubview(tableView)
    }
    fileprivate func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = fromViewController{
            vc.open(history: historyDatas[indexPath.row])
            self.back()
        }
    }
    fileprivate func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyDatas.count
    }
    fileprivate func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    fileprivate func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ADSettingViewTableViewCell
        cell.reset()
        cell.title = historyDatas.index(indexPath.row)?.title ?? ""
        cell.subTitle = historyDatas.index(indexPath.row)?.url.decodedFromURL ?? ""
        cell.icon = "history"
        
        return cell
    }
}


class JavaScriptDOM {
    var string = ""
    func hideByAutomatic(){
        string+="var yads = document.getElementsByClassName(\"yadsOverlay\");"
        string+="for (var i=0;i<yads.length;i+=1) {"
        string+="   yads[i].style.zIndex = -1;"
        string+="}"
    }
    func hideBy(id:String){
        string+="document.getElementById(\"\(id)\").style.display=\"none\";"
    }
    func hideBy(className:String){
        string+="var \(className)s = document.getElementsByClassName(\"\(className)\");"
        string+="for (var i=0;i<\(className)s.length;i+=1) {"
        string+="   \(className)s[i].style.display = \"none\";"
        string+="}"
    }
    func hideBy(ids:[String]){
        for id in ids{
            string+="document.getElementById(\"\(id)\").style.display=\"none\";"
        }
    }
    func hideBy(tags:[String]){
        for type in tags{
            string+="var \(type)s = document.getElementsByTagName(\"\(type)\");"
            string+="for (var i=0;i<\(type)s.length;i+=1) {"
            string+="   \(type)s[i].style.display = \"none\";"
            string+="}"
        }
    }
    func hideBy(classNames:[String]){
        for className in classNames{
            string+="var \(className)s = document.getElementsByClassName(\"\(className)\");"
            string+="for (var i=0;i<\(className)s.length;i+=1) {"
            string+="   \(className)s[i].style.display = \"none\";"
            string+="}"
        }
    }
}







