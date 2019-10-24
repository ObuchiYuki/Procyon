import UIKit

class PixivExtraView: UIView,UITableViewDelegate,UITableViewDataSource {
    var titles = [String](){didSet{checkItems()}}
    var iconArr = [String](){didSet{checkItems()}}
    var indexAction:intBlock = {_ in}
    var itemCount = 0{
        didSet{
            self.tableView.height = 53*itemCount.cgFloat
            self.height = tableView.height
        }
    }
    private let tableView = UITableView()
    
    func checkItems(){
        if titles.count == iconArr.count{
            self.tableView.reloadData()
        }
    }
    
    init() {
        super.init(frame:.zero)
        self.backgroundColor = .clear
        self.width = screen.width
        tableView.width = screen.width
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 53
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.backgroundView?.backgroundColor = .clear
        
        addSubview(tableView)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexAction(indexPath.row)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        let cell = ADMenuTableViewCell()
        cell.title = titles[indexPath.row]
        cell.icon = iconArr[indexPath.row]
        cell.backgroundColor = .back
        if PixivSystem.isPrivate{
            cell.backgroundColor = .hex("303030")
            cell.iconLabel.textColor = .white
            cell.titleLabel.textColor = .white
        }
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
