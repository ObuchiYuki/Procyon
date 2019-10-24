import UIKit

class PixivRelatedWorksViewController: PixivBaseViewController{
    var id = 0
    let inner = PixivRelatedWorksInner()
    override func setSetting() {
        inner.id = id
        inner.size = contentSize
        inner.delegate = self
        addSubview(inner.view)
    }
}
