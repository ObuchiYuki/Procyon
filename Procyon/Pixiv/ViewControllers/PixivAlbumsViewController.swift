import UIKit

class PixivAlbumsViewController: PixivBaseViewController,UITableViewDelegate,UITableViewDataSource{
    private var datas:[pixivAlbumData] = albumApi.getAlbums()
    
    private let tableView = UITableView()
    
    private func reload(){
        self.datas = albumApi.getAlbums()
        self.tableView.reloadData()
    }
    
    override func setSetting() {
        title = "アルバム"
    }
    override func setUISetting() {
        tableView.backgroundColor = .clear
        tableView.register(PixivAlbumCell.self, forCellReuseIdentifier: "albumCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
    }
    override func setUIScreen() {
        tableView.size = contentSize
    }
    override func addUIs() {
        addSubview(tableView)
    }
    override func setLoadControl() {
        self.reload()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PixivAlbumViewController()
        vc.data = self.datas[indexPath.row]
        self.go(to: vc)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell") as! PixivAlbumCell
        let data = datas[indexPath.row]
        cell.data = data
        
        pixiv.getImage(url: data.imageUrl){if cell.id == data.id{cell.firstImage=$0}}

        return cell
    }
}
