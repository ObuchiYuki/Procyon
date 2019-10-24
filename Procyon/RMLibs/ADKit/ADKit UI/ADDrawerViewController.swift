import  UIKit

class ADDrawerViewController: RMViewController {
    let headerView = HeaderView()
    let tableView = TableView()
    var drawerController:ADDrawerController?{return self.parent as? ADDrawerController}
    
    typealias CellData = TableView.SectionData.CellData
    
    private let width:CGFloat = 260
    
    func go(_ vc:UIViewController,animated:Bool = false){
        if animated{run(after: 0.25){self.drawerController?.present(vc, animated: true)}}
        else{run(after: 0.25){system.mainWindow.rootViewController = vc}}
        self.drawerController?.close()        
    }
    override func setupSetting_P() {
        super.setupSetting_P()
        self.contentView.removeFromSuperview()
        
        view.backgroundColor = UIColor.white
        
        headerView.width = width
        headerView.height = 160
        
        tableView.y = 160
        
        view.addSubview(headerView)
        view.addSubviews(tableView)
    }
    
    class TableView: RMView,UITableViewDataSource,UITableViewDelegate{
        var data = [SectionData](){didSet{tableView.reloadData()}}
        
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        override func setup() {
            super.setup()
            self.size = sizeMake(260, screen.height-160)
            
            tableView.size = self.size
            tableView.register(Cell.self, forCellReuseIdentifier: "cell")
            tableView.dataSource = self
            tableView.delegate = self
            tableView.backgroundColor = .white
            
            addSubview(tableView)
        }
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let view = UIView()
            let separator = UIView()
            separator.height = 0.5
            separator.width = 260
            separator.backgroundColor = .hex("bb")
            view.addSubview(separator)
            return view
        }
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {return 5}
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {return 5}
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            data.index(indexPath.section)?.cells.index(indexPath.row)?.action()
        }
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return 47}
        func numberOfSections(in tableView: UITableView) -> Int {return self.data.count}
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.data.index(section)?.cells.count ?? 0
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
            let data = self.data.index(indexPath.section)?.cells.index(indexPath.row)
            cell.iconLabel.text = data?.icon ?? ""
            cell.titleLable.text = data?.title ?? ""
            return cell
        }
        class Cell: ADTableViewCell {
            let iconLabel = UILabel()
            let titleLable = UILabel()
            
            override func setup() {
                super.setup()
                separator.isHidden = true
                
                iconLabel.font = Font.MaterialIcons.font(22)
                iconLabel.textColor = .subText
                iconLabel.size = sizeMake(22, 22)
                iconLabel.origin = pointMake(15, 12)
                
                titleLable.size = sizeMake(260-32, 20)
                titleLable.origin = pointMake(70, 16)
                titleLable.font = Font.Roboto.font(14,style: .normal)
                titleLable.textColor = .text
                
                addSubviews(iconLabel,titleLable)
            }
        }
        struct SectionData {
            var cells: [CellData]
            struct CellData {
                var title:String
                var icon:String
                var action:voidBlock
            }
        }
    }
    class HeaderView: RMView {
        var fullUserData:pixivFullUserData? = nil
        
        let imageView = UIImageView()
        let coverView = UIView()
        let userImageView = UIImageView()
        let userNameLabel = UILabel()
        let userIDLabel = UILabel()
        let actionButton = ADButton()
        
        override func setup() {
            self.size = sizeMake(260, 160)
            imageView.size = self.size
            imageView.image = #imageLiteral(resourceName: "DrawerBackgroundImage1")
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            
            coverView.size = self.size
            coverView.backgroundColor = .hex("0",alpha: 0.3)
            
            userImageView.size = sizeMake(65, 65)
            userImageView.origin = pointMake(15, 15)
            userImageView.noCorner()
            userImageView.clipsToBounds = true
            
            userNameLabel.size = sizeMake(170, 13)
            userNameLabel.origin = pointMake(15, 110)
            userNameLabel.font = Font.Roboto.font(13,style: .bold)
            userNameLabel.textColor = .hex("fafafa")
            
            
            userIDLabel.size = sizeMake(170, 13)
            userIDLabel.origin = pointMake(15, 130)
            userIDLabel.font = Font.Roboto.font(13,style: .normal)
            userIDLabel.textColor = .hex("fafafa")
            
            actionButton.title = "arrow_drop_down"
            actionButton.titleLabel?.font = Font.MaterialIcons.font(21)
            actionButton.titleColor = .white
            actionButton.size = sizeMake(45, 45)
            actionButton.origin = pointMake(260-45, 160-45)
            actionButton.noCorner()
            actionButton.shadowLevel = 1
            
            addSubviews(imageView,coverView,userNameLabel,userIDLabel,userImageView,actionButton)
        }
    }
}









