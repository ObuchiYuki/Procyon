import UIKit

class PixivUserFollowViewController: PixivBaseViewController{
    let inner = PixivUserMyFollowInner()
    override func setSetting() {
        title = "follow_users".l()
        
        inner.size = contentSize
        inner.delegate = self
        addSubview(inner.view)
    }
}
