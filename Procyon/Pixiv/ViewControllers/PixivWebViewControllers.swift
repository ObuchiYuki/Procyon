import UIKit
import WebKit

class PixiVisionViewController: PixivWebViewBaseController {
    var data:pixiVisionData? = nil{
        didSet{
            guard let data = data else {return}
            self.defaultUrl = data.articleUrl
        }
    }
}
class PixivEncyclopediaViewController: PixivWebViewBaseController {
    var word = ""{
        didSet{
            let request = (openNico ? "http://dic.nicovideo.jp/a/\(word.encodedForURL)" : "http://dic.pixiv.net/a/\(word.encodedForURL)").request
            request.userAgent = .iPhone
            defaultRequest = request
            request.get {data in
                if
                    data.string.contains("このタイトルの記事は、まだ作成されていません") ||
                    data.string.contains("まだ記事が書かれていません")
                {
                    let dialog = ADDialog()
                    dialog.title = "error".l()
                    dialog.message = "dic_no_page_error".l()
                    dialog.setCloseTime(to: 1.4)
                    dialog.show()
                    self.back()
                }
            }
        }
    }
    var openNico = false
    
    override func setUIScreen() {
        themeColor  = ADColor.BlueGrey.P500
        showMenuButton = true
    }
    override func willTitleChange(title: String) -> String {
        if let m = Re.search("(.*)\\((.*)\\)(.*)", title) {
            return m.group(1)
        }
        return title
    }
}
