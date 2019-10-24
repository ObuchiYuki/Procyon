import Foundation

class pixivNovelContentsData: Storable{
    var novels:[pixivNovelData]
    var nextUrl:String
    var count:Int{
        return novels.count
    }
    weak var collectionViewController:PixivNovelCollectionViewBaseController?
    
    func reset(){
        self.novels = []
        self.nextUrl = ""
    }
    func append(_ json:JSON,completion:@escaping voidBlock){
        asyncQ {
            let addingNovels = json["novels"].arrayValue.map{json in pixivNovelData(json: json)}
            var addNovels:[pixivNovelData] = []
            for novel in addingNovels{
                if self.canAdd(withData: novel){addNovels.append(novel)}
            }
            self.novels.append(contentsOf: addNovels)
            self.nextUrl = json["next_url"].stringValue
            mainQ {
                completion()
            }
        }
    }
    private func canAdd(withData data:pixivNovelData)->Bool{
        let hideData = PixivSystem.hiddenContentsData
        
        for tag in data.tags{
            for hideTagData in hideData.hideTags{
                if hideTagData.includingContains{
                    if tag.contains(hideTagData.tagName){return false}
                }else{
                    if tag == hideTagData.tagName{return false}
                }
            }
            if !hideData.showR18{
                if tag.contains("R-18"){return false}
            }
            if !hideData.showR18on3G{
                if net.status == .cellular && tag.contains("R-18"){return false}
            }
        }
        for hideUser in hideData.hideUsers {
            if data.user.id == hideUser.id{return false}
        }
        return true
    }
    
    init(json:JSON) {
        self.novels = json["novels"].arrayValue.map{json in pixivNovelData(json: json)}
        self.nextUrl = json["next_url"].stringValue
    }
    init(){
        self.novels = []
        self.nextUrl = ""
    }
    var dict: [String : Any]{
        return ["novels":novels.map{$0.dict},"nextUrl":nextUrl]
    }
    required init(dict: [String : Any]) {
        let d = Decoder(dict: dict)
        self.novels = d.structArray(pixivNovelData.self, "novels")
        self.nextUrl = d.string("nextUrl")
    }
}

struct pixivNovelData {
    var title:String
    var id:Int
    var caption:String
    var restrict:Int
    var imageUrls:pixivWorkData.pixivImageUrlsData
    var createDate:Date
    var tags:[String]
    var pageCount:Int
    var textLength:Int
    var user:pixivUserData
    var series:pixivNovelSeriesData
    var isBookmarked:Bool
    var totalBookmarks:Int
    var totalView:Int
    var totalComments:Int
    
    struct pixivNovelSeriesData {
        var id:Int
        var title:String
        
        init(json:JSON) {
            self.id = json["id"].intValue
            self.title = json["title"].stringValue
        }
    }
    init(json:JSON) {
        self.title = json["title"].stringValue
        self.id = json["id"].intValue
        self.caption = json["caption"].stringValue.replace(of: "pixiv://", with: "procyon://")
        self.restrict = json["restrict"].intValue
        self.imageUrls = pixivWorkData.pixivImageUrlsData(json: json["image_urls"])
        self.createDate = Date(string: json["create_date"].stringValue, for: "yyyy-MM-dd'T'HH:mm:ssZZZZ")
        self.tags = json["tags"].arrayValue.map{json in json["name"].stringValue}
        self.pageCount = json["page_count"].intValue
        self.textLength = json["text_length"].intValue
        self.user = pixivUserData(json: json["user"])
        self.series = pixivNovelSeriesData(json: json["series"])
        self.isBookmarked = json["is_bookmarked"].boolValue
        self.totalBookmarks = json["total_bookmarks"].intValue
        self.totalView = json["total_view"].intValue
        self.totalComments = json["total_comments"].intValue
    }
}

extension pixivNovelData.pixivNovelSeriesData: Storable {
    var dict: [String : Any]{
        return ["id":id,"title":title]
    }
    init(dict: [String : Any]) {
        let d = Decoder(dict: dict)
        self.id = d.int("id")
        self.title = d.string("title")
    }
}
extension pixivNovelData: Storable{
    var dict: [String : Any]{
        return [
            "title":title,
            "id":id,
            "caption":caption,
            "restrict":restrict,
            "imageUrls":imageUrls.dict,
            "createDate":createDate,
            "tags":tags,
            "pageCount":pageCount,
            "textLength":textLength,
            "user":user.dict,
            "series":series.dict,
            "isBookmarked":isBookmarked,
            "totalBookmarks":totalBookmarks,
            "totalView":totalView,
            "totalComments":totalComments,
        ]
    }
    init(dict: [String : Any]) {
        let d = Decoder(dict: dict)
        
        self.title = d.string("title")
        self.id = d.int("id")
        self.caption = d.string("caption")
        self.restrict = d.int("restrict")
        self.imageUrls = d.struct(pixivWorkData.pixivImageUrlsData.self, "imageUrls")
        self.createDate = d.date("createDate")
        self.tags = d.stringArray("tags")
        self.pageCount = d.int("pageCount")
        self.textLength = d.int("textLength")
        self.user = d.struct(pixivUserData.self, "user")
        self.series = d.struct(pixivNovelSeriesData.self, "series")
        self.isBookmarked = d.bool("isBookmarked")
        self.totalBookmarks = d.int("totalBookmarks")
        self.totalView = d.int("totalView")
        self.totalComments = d.int("totalComments")
    }
}
extension pixivNovelData: Equatable{
    static func == (right:pixivNovelData,left:pixivNovelData)->Bool{
        return right.id == left.id
    }
}

struct pixivNovelTextData{
    var rawText:String{
        return novelText.joined(separator: "\n")
    }
    var novelMarker:[String]//?
    var novelText:[String]
    var seriesPrev:pixivNovelData.pixivNovelSeriesData
    var seriesNext:pixivNovelData.pixivNovelSeriesData
    
    init(json:JSON) {
        self.novelMarker = json["novel_marker"].arrayValue.map{json in json.stringValue}
        self.novelText = json["novel_text"].stringValue.split("[newpage]")
        self.seriesPrev = pixivNovelData.pixivNovelSeriesData(json: json["series_prev"])
        self.seriesNext = pixivNovelData.pixivNovelSeriesData(json: json["series_next"])
    }
}
