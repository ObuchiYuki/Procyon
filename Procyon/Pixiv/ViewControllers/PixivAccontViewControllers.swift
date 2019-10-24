import UIKit

class PixivBookmarkViewController: PixivBaseViewController{
    private let inner = PixivBookmarkInner()
    override func setSetting() {
        inner.settingView.tip.addAction {[weak self] in
            let dialog = ADDialog()
            dialog.title = "ブックマークタグ"
            dialog.setTableView(titles: ["全て","未分類"]+(PixivSystem.tagBookmarkData()?.bookmarkTags ?? []),style: .select){i in
                self?.inner.tag = i == 1 ? "未分類" : PixivSystem.tagBookmarkData()?.bookmarkTags.index(i-2)
                self?.title = i == 1 ? "未分類" : PixivSystem.tagBookmarkData()?.bookmarkTags.index(i-2) ?? "ブックマーク"
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
class PixivHistoryViewController: PixivBaseViewController{
    private let inner = PixivHistoryInner()
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
