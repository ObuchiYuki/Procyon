import UIKit

class ADSearchEstimatedView: UIView,UITableViewDelegate,UITableViewDataSource{
    //====================================================================
    //member
    var titles = [String](){
        didSet{
            self.frame.size.height = CGFloat(titles.count*53)
            tableView.frame.size.height = self.frame.size.height
            tableView.reloadData()
        }
    }
    var cellTapped:intBlock = {_ in}
    //======================================
    //Views
    private let tableView = UITableView()
    //====================================================================
    //method
    func open(){
        self.isHidden = false
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.frame.origin.y = 77
            },
            completion: {_ in}
        )
    }
    func close(){
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.frame.origin.y = 72-self.frame.height
            },
            completion: {_ in
                self.isHidden = true
            }
        )
    }
    //====================================================================
    //private method
    private func setupScreen(){
        self.width = screen.width-10
        self.safeCornerRadius = 2
        self.unsafeShadowLevel = 2
        self.backgroundColor = UIColor.white
        tableView.frame.origin.y = 0
    }
    private func setupSetting(){
        self.isHidden = true
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.width = width
        tableView.rowHeight = 53
        tableView.safeCornerRadius = 2
        addSubview(tableView)
    }
    //====================================================================
    //delegate method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellTapped(indexPath.row)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        let cell = ADSearchEstimatedViewTableViewCell()
        cell.title = titles[indexPath.row]
        if indexPath.row == 3{
            cell.iconLabel.text = "history"
        }
        return cell
    }
    private func setup(){
        setupScreen()
        setupSetting()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    init(){
        super.init(frame: CGRect.zero)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class ADSearchEstimatedViewTableViewCell:ADTableViewCell{
    var title = "" {
        didSet{
            self.titleLabel.text = title
        }
    }
    fileprivate var iconLabel = UILabel()
    fileprivate var titleLabel = UILabel()
    
    override func setup(){
        super.setup()
        separator.isHidden = true
        rippleLayerColor = UIColor.lightGray
        
        iconLabel.frame.size = sizeMake(24, 24)
        iconLabel.frame.origin.x = 20
        iconLabel.center.y = self.center.y+4
        iconLabel.font = Font.MaterialIcons.font(24)
        iconLabel.textColor = .hex("555555")
        iconLabel.text = "search"
        
        titleLabel.frame.origin.x = 80
        titleLabel.frame.size = sizeMake(self.frame.width-130, 30)
        titleLabel.center.y = self.center.y+4
        titleLabel.textColor = .hex("555555")
        
        addSubview(iconLabel)
        addSubview(titleLabel)
    }
}
















