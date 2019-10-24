/*import UIKit
import HTML

struct NicoWorkData {
    var title:String
    var id:Int
    var caption:String
    var tags:[String]
    var createdTime:Date
    var totalView:Int
    var totalComments:Int
    var totalClips:Int
    var user:NicoUserSmallData
    var comments:[NicoCommentData]
}
struct NicoCommentData {
    var postedTime:Date
    var userId:Int
    var comment:String
    var isSelf:Bool
}

struct NicoContentsData {
    var count:Int{
        return works.count
    }
    var works:[NicoThumbnailWorkData]
    init(html:HTML) {
        works = html.path("/html/body/div/div/div/div[@class='illust_list']/ul/li")
            .map{h in NicoThumbnailWorkData(html: h)}
    }
    mutating func append(html:HTML){
        works.append(contentsOf:
            html.path("/html/body/div/div/div/div[@class='illust_list']/ul/li")
            .map{h in NicoThumbnailWorkData(html: h)}
        )
    }
    init(){self.works = []}
}

struct NicoThumbnailWorkData {
    var title:String
    var id:String
    var userName:String
    var imageUrl:String
    init(html: HTMLNode){
        title = html.path("a/ul[@class='illust_info']/li[@class='title']").index(0)?.stringValue ?? ""
        id = html.path("a").index(0)?.attributes["href"] ?? ""
        userName = html.path("a/ul[@class='illust_info']/li[@class='user']").index(0)?.stringValue ?? ""
        imageUrl = html.path("a/span/img").index(0)?.attributes["src"] ?? ""
    }
}
struct NicoUserSmallData {
    var id:Int
    var name:String
}
*/
