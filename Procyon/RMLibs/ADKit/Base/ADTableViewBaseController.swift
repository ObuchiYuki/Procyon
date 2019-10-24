import UIKit

class ADTableViewBaseController: ADNavigationController ,UITableViewDelegate,UITableViewDataSource{
    //==========================================================================
    //proparties
    //======================================
    //addButton is default main Button if needed please change.
    let addButton = ADMainButton(icon: "add", position: .lowerRight, animationStyle: .pop)
    //======================================
    //if you set this proparty the value of tableObjects will
    //save and load automatically
    var tableObjectsDefaultName:String? = nil{
        didSet{
            guard let identifier = tableObjectsDefaultName else {
                return
            }
            tableObjects = info.stringArray(forKey: identifier) ?? []
        }
    }
    var useDelete = true
    var rowCount = 0
    //======================================
    //tableObjects if 2dim Array 
    //set first dim for per cell
    var tableObjects = [String]()
    let tableView = UITableView()
    func cellTapped(_ indexPath:IndexPath){}
    //==========================================================================
    //private proparties
    override func setupSetting_P() {
        super.setupSetting_P()
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 63
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .back
        
        mainButton = addButton
        addSubview(tableView)
    }
    override func setupScreen_P() {
        super.setupScreen_P()
        
        tableView.frame = fullContentsFrame
    }
    func saveCustomObject(){}
    func setCell(_ indexPath:IndexPath)->UITableViewCell{
        return UITableViewCell()
    }
    func insertNewObject(_ sender: String) {
        tableObjects.insert(sender, at: 0)
        if let defaultName = tableObjectsDefaultName {
            info.set(tableObjects, forKey: defaultName)
        }
        self.tableView.insertRows(
            at: [IndexPath(row: 0, section: 0)],
            with: .automatic
        )
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableObjectsDefaultName == nil{
            return rowCount
        }else{
            return tableObjects.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return setCell(indexPath)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellTapped(indexPath)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if useDelete{
            if editingStyle == .delete {
                tableObjects.remove(at: indexPath.row)
                if let defaultName = tableObjectsDefaultName {
                    info.set(tableObjects, forKey: defaultName)
                }
                saveCustomObject()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}

class ADTableViewCardCell: RMTableViewCell {
    var id = 0
    let cardView = ADCardView()
    let titleLabel = UILabel()
    let subTitleLable = UILabel()
    var title = ""{
        didSet{
            titleLabel.text = title
            titleLabel.sizeToFit()
        }
    }
    
    var subTitle = ""{
        didSet{
            subTitleLable.text = subTitle
            subTitleLable.sizeToFit()
        }
    }
    
    var cellImageView = RMImageView()
    var cellImage:UIImage? = UIImage(){
        didSet{
            asyncQ {
                let image = self.cellImage?.resize(to: sizeMake(self.height-40, self.height-40)*2)
                mainQ {
                    self.imageEnable = true
                    self.didFrameChange()
                    self.cellImageView.image = image
                }
            }
        }
    }
    private var imageEnable = false
    
    var accessoryTip = ADTip()
    var accessory = ""{
        didSet{
            accessoryTip.title = accessory
            accessoryTip.isHidden = false
        }
    }
    var margin = UIEdgeInsetsMake(5, 5, 5, 5){didSet{didFrameChange()}}
    func reset(){
        self.title = ""
        self.accessory = ""
        self.cellImage = nil
        self.subTitle = ""
    }
    
    override func setup(){
        super.setup()
        self.backgroundColor = UIColor.clear
        selectionStyle = .none
        separator.isHidden = true
        cardView.backgroundColor = UIColor.white
        cardView.safeCornerRadius = 2
        
        titleLabel.font = Font.Roboto.font(14)
        titleLabel.textColor = .text
        
        subTitleLable.font = Font.Roboto.font(12)
        subTitleLable.textColor = .subText
        
        accessoryTip.titleColor = .subText
        accessoryTip.title = accessory
        accessoryTip.isHidden = true
        
        self.addSubview(cardView)
        self.addSubview(titleLabel)
        self.addSubview(subTitleLable)
        self.addSubview(cellImageView)
        self.addSubview(accessoryTip)
    }
    override func didFrameChange() {
        cardView.width = self.width - (margin.left+margin.right)
        cardView.height = self.frame.size.height - (margin.top+margin.bottom)
        cardView.y = margin.top
        cardView.x = margin.left
        cardView.setAsCardView(with: .bordered,.shadowed)
        
        accessoryTip.center.y = cardView.center.y
        accessoryTip.frame.origin.x = width-60
        
        titleLabel.frame.size = sizeMake(self.width-150, 30)
        titleLabel.textColor = .text
        titleLabel.center.y = self.height/2
        
        subTitleLable.frame.size = sizeMake(self.width-150, 20)
        subTitleLable.bottomY = self.height-15
        
        cellImageView.frame.origin = Point(20, 20)
        cellImageView.frame.size = sizeMake(frame.height-40, frame.height-40)
        
        if imageEnable {
            titleLabel.frame.origin.x = 90
            subTitleLable.frame.origin.x = 90
        }else{
            titleLabel.frame.origin.x = 25
            subTitleLable.frame.origin.x = 25
        }
    }
}

















