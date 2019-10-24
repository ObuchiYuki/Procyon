import UIKit

class PixivNovelHistoryViewController: PixivBaseViewController{
    private let inner = PixivNovelHistoryInner()
    override func setSetting() {
        title = "view_history".l()
        inner.size = contentSize
        inner.delegate = self
        addSubview(inner.view)
    }
    override func setLoadControl() {
        inner.viewDidAppear(true)
    }
}
class PixivNovelSeriesViewController: PixivBaseViewController{
    var data:pixivNovelData! = nil
    let inner = PixivNovelSeriesInner()
    override func setSetting() {
        title = data.series.title
        inner.id = data.series.id
        inner.size = contentSize
        inner.delegate = self
        addSubview(inner.view)
    }
}
class PixivNovelBookmarkViewController: PixivBaseViewController{
    private let inner = PixivNovelBookmarkInner()
    override func setSetting() {
        inner.settingView.tip.addAction {[weak self] in
            let dialog = ADDialog()
            dialog.title = "ブックマークタグ"
            dialog.setTableView(titles: ["全て"]+(PixivSystem.novelTagBookmarkData()?.bookmarkTags ?? []),style: .select){i in
                self?.inner.tag = PixivSystem.novelTagBookmarkData()?.bookmarkTags.index(i-1)
                self?.title = PixivSystem.novelTagBookmarkData()?.bookmarkTags.index(i-1) ?? "ブックマーク"
                self?.inner.reload()
            }
            dialog.addCancelButton()
            dialog.show()
        }
        
        title = "bookmark".l()
        inner.size = contentSize
        inner.delegate = self
        addSubview(inner.view)
    }
}
