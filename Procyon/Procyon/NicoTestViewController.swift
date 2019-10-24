/*import UIKit

class NicoTestViewController: ADNavigationController,NicoSeigaCollectionViewDelegate{
    let inner = TestInner()
    override func setSetting() {
        title = "Nico静画テスト"
        ADDialog.alert(message: "よくこんなところにたどり着いたねw\n\nしばらくしたらニコニコ静画も対応するよ。")
        themeColor = ADColor.DeepOrange.P500
        inner.delegate = self
        inner.size = contentSize
        
        showSearchButton = true
        
        searchEndAction = {[weak self] in
            self?.inner.word = $0
            self?.inner.reload()
            self?.title = $0
        }
        
        addSubview(inner.view)
    }
    func cellTapped(datas: NicoContentsData, at index: Int) {
        ADDialog.alert(message: "\(datas.works.index(index)!)")
    }
}
*/
