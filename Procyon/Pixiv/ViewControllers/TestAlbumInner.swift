import UIKit

class PixivAlbumInner: PixivCollectionViewBaseController{
    var data:pixivAlbumData! = nil
    let settingView = PixivHeaderButtonsView(icon: "settings")
    let playButton = ADMainButton(icon: "play_arrow")
    
    private var page = 0
    override func setSetting() {
        headerView = settingView
        mainButton = playButton
    }
    override func reset() {
        super.reset()
        page = 0
    }
    override func cellLongTapped(index: Int) {
        if let item = self.data.items.index(index){
            let title = datas.works.index(index)?.title ?? ""
            let dialog = ADDialog()
            dialog.title = "delete_[work_name]".l(title)
            dialog.addOKButton {[weak self] in
                albumApi.deleteItem(albumId: self?.data.id ?? -1, data: item, completion: {
                    self?.remove(at: index)
                    ADSnackbar.show("removed".l())
                })
            }
            dialog.addCancelButton()
            dialog.show()
        }
    }
    override func callNextData(handler: @escaping jsonBlock) {
        runApi(handler: handler)
    }
    override func runApi(handler: @escaping jsonBlock) {
        albumApi.getItems(albumId: data.id, page: page, completion: {json in
            self.page+=1
            handler(json)
        })
    }
}
