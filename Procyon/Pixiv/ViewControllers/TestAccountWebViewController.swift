import UIKit
import WebKit

class PixivAccountWebViewController: PixivWebViewBaseController {
    override func setSetting() {
        showMenuButton = false
        defaultUrl = "http://touch.pixiv.net/setting_user.php?ref=ios-app"
    }
    override func willTitleChange(title: String) -> String {return title.split("-").index(1) ?? ""}
    override func shouldAddHistory(history: HistoryData) -> Bool {return false}
}
