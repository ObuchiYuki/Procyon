import UIKit

class PixivNovelHistoryInner: PixivNovelCollectionViewBaseController{
    private let deleteButton = ADMainButton(icon: "delete")
    override func setSetting() {
        deleteButton.addAction {
            let dialog = ADDialog()
            dialog.title = "remove_all_history?".l()
            dialog.message = "long_press_to_remove_each".l()
            dialog.addOKButton{
                novelInternalApi.deleteAllHistory(restrict: PixivSystem.restrict)
                self.reset()
            }
            dialog.addCancelButton()
            dialog.show()
        }
        mainButton = deleteButton
        setDatas(datas: novelInternalApi.getHistory(restrict: PixivSystem.restrict))
    }
    override func onShowCellMenu(menu: ADMenu, at index: Int) {
        menu.insertItem(at: 0,title: "remove_from_view_history?".l(), icon: "delete"){
            novelInternalApi.deleteHistory(restrict: PixivSystem.restrict, at: index)
            self.remove(at: index)
        }
        menu.show(windowAnimated: true)
    }
}
