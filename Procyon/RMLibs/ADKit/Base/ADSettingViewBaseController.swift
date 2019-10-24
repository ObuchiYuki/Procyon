import UIKit

class ADSettingViewBaseController: ADNavigationController,UITableViewDelegate,UITableViewDataSource{
    var tableData:[SectionData] = []{
        didSet{
            tableView.reloadData()
        }
    }
    
    struct SectionData {
        var title:String
        var cells:[CellData]
        var count:Int{
            return cells.count
        }
    }
    struct CellData {
        var title:String
        var icon:String
        var identifier:String
        init(title: String,icon: String, identifier: String) {
            self.title = title
            self.icon = icon
            self.identifier = identifier
        }
        init() {
            self.title = ""
            self.icon = ""
            self.identifier = ""
        }
    }
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    func setCell(data:CellData,cell:ADSettingViewTableViewCell)->UITableViewCell{return cell}
    func cellTapped(cell:ADSettingViewTableViewCell,identifier:String){}
    
    override func setupSetting_P() {
        super.setupSetting_P()
        title = "setting".l()
        tableView.register(ADSettingViewTableViewCell.self, forCellReuseIdentifier: "settingCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
    }
    override func setupScreen_P() {
        super.setupScreen_P()
        tableView.frame = fullContentsFrame
        addSubview(tableView)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.index(section)?.count ?? 0
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableData.index(section)?.title ?? ""
    }
    func tableView(_ tabeView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! ADSettingViewTableViewCell
        let data = tableData.index(indexPath.section)?.cells.index(indexPath.row)
        cell.reset()
        cell.title = data?.title ?? ""
        cell.icon = data?.icon ?? ""
        cell.identifier = data?.identifier ?? ""
        return setCell(data: data ?? CellData(), cell: cell)
    }
    //===============================================================================================
    //Tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ADSettingViewTableViewCell
        let data =  tableData.index(indexPath.section)?.cells.index(indexPath.row)
        cell.SettingSwitch.on<-!
        cellTapped(cell: cell, identifier: data?.identifier ?? "")
    }
}
class ADSettingViewTableViewCell: ADTableViewCell{
    let titleLabel = UILabel()
    let iconLabel = UILabel()
    let subTitleLabel = UILabel()
    let SettingSwitch = ADSwitch()
    let accessory = UILabel()
    
    var switchOn:Bool{
        return SettingSwitch.on
    }
    
    func reset(){
        titleLabel.centerY = height/2
        title = ""
        icon = ""
        showSwitch = false
        showAccessory = false
        identifier = ""
    }
    
    var title:String? = ""{
        didSet{
            self.titleLabel.text = title
        }
    }
    var subTitle:String? = ""{
        didSet{
            subTitleLabel.text = subTitle
        }
    }
    
    var icon:String? = ""{
        didSet{
            self.iconLabel.text = icon
        }
    }
    
    var showSwitch = false{
        didSet{
            SettingSwitch.isHidden = !showSwitch
        }
    }
    var showAccessory = false{
        didSet{
            accessory.isHidden = !showAccessory
        }
    }
    var identifier = ""{
        didSet{
            SettingSwitch.saveIdentifier = identifier
        }
    }
    override func didFrameChange(){
        accessory.frame.origin.x = width-30
        SettingSwitch.rightX = width
        if !(subTitle ?? "").isEmpty{
            titleLabel.centerY = height/2-5
        }else{
            titleLabel.centerY = height/2
        }
        
    }
    
    override func setup(){
        super.setup()
        self.contentView.backgroundColor = .white
        separator.isHidden = true
        iconLabel.frame.size = sizeMake(24, 24)
        iconLabel.font = UIFont(name: "MaterialIcons-Regular", size: 24)!
        iconLabel.textColor = .hex("555555")
        iconLabel.frame.origin = Point(15, 14)
        addSubview(iconLabel)
        
        titleLabel.size = sizeMake(screen.width-120, 30)
        titleLabel.x = 70
        titleLabel.textColor = .text
        addSubview(titleLabel)
    
        subTitleLabel.size = sizeMake(200, 10)
        subTitleLabel.font = Font.Roboto.font(10,style: .normal)
        subTitleLabel.centerY = height-5
        subTitleLabel.x = 70
        subTitleLabel.textColor = .subText
        addSubview(subTitleLabel)
        
        SettingSwitch.y = 0
        SettingSwitch.isHidden = true
        
        addSubview(SettingSwitch)
        
        accessory.layer.position.y = 10
        accessory.text = "chevron_right"
        accessory.font = Font.MaterialIcons.font(30)
        accessory.sizeToFit()
        accessory.textColor = .hex("999999", alpha: 0.5)
        accessory.isHidden = true
        addSubview(accessory)
    }
}


