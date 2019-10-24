import UIKit
import WebKit

class PixivWebViewBaseController: ADWebViewController {
    override func shouldOpenUrl(url: URL) -> Bool {
        if let m = Re.search("http://(.*)&illust_id=(.*)", url.absoluteString){
            back({application.openURL("procyon://illust/\(m.group(2))".url!)})
            return false
        }
        if let m = Re.search("http://(.*)/member.php\\?id=(.*)", url.absoluteString){
            back({application.openURL("procyon://user/\(m.group(2))".url!)})
            return false
        }
        return true
    }
}
