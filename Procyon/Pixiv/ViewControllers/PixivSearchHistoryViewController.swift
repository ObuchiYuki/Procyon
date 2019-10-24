import UIKit

class PixivSearchHistoryViewController: ADNavigationController{
    private let tableView = UITableView()
    private let deleteButton = ADMainButton(icon: "delete")
    var tableDatas = [String]()
    
    override func setSetting() {
        title = "search_history".l()
        tableDatas = pixivInternalApi.getSearchHistory(restrict: PixivSystem.restrict)
        
        deleteButton.addAction {
            let dialog = ADDialog()
            dialog.title = "confirm".l()
            dialog.message = "remove_all_history?".l()
            dialog.addOKButton{[weak self] in
                pixivInternalApi.deleteAllSearchHistory(restrict: PixivSystem.restrict)
                self?.back()
            }
            dialog.addCancelButton()
            dialog.show()
        }
        tableView.size = contentSize
        tableView.register(ADTableViewCardCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 62
        addSubview(tableView)
        
        mainButton = deleteButton
    }
}
extension PixivSearchHistoryViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PixivSearchViewController()
        vc.word = self.tableDatas.index(indexPath.row) ?? ""
        self.go(to: vc)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDatas.count
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            pixivInternalApi.deleteSearchHistory(restrict: PixivSystem.restrict, element: tableDatas.index(indexPath.row) ?? "")
            tableDatas.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ADTableViewCardCell
        cell.title = tableDatas.index(indexPath.row) ?? ""
        cell.accessory = "chevron_right"
        cell.accessoryTip.isUserInteractionEnabled = false
        return cell
    }
}


