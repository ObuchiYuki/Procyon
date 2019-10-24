import UIKit

class pixivContentsData: Storable{
    var works:[pixivWorkData]
    var nextUrl:String
    var count:Int{
        return works.count
    }
    weak var collectionViewController:PixivCollectionViewBaseController?
    
    func reset(){
        works = []
        nextUrl = ""
    }
    
    func append(_ json:JSON,completion:@escaping voidBlock) {
        asyncQ {
            let addingIllusts = json["illusts"].arrayValue.map{json in pixivWorkData(json: json)}
            var addIllusts:[pixivWorkData] = []
            for illust in addingIllusts{
                if self.canAdd(withData: illust){addIllusts.append(illust)}
            }
            self.works.append(contentsOf: addIllusts)
            self.nextUrl = json["next_url"].stringValue
            mainQ {completion()}
        }
    }
    
    private func canAdd(withData data:pixivWorkData)->Bool{
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
    
    init(json:JSON){
        works = json["illusts"].arrayValue.map{json in pixivWorkData(json: json)}
        nextUrl = json["next_url"].stringValue
    }
    init(vc:PixivCollectionViewBaseController? = nil){
        works = []
        nextUrl = ""
        self.collectionViewController = vc
    }
    var dict: [String : Any]{
        return ["works":works.map{$0.dict},"nextUrl":nextUrl]
    }
    required init(dict: [String : Any]) {
        let d = Decoder(dict: dict)
        self.works = d.structArray(pixivWorkData.self, "works")
        self.nextUrl = d.string("nextUrl")
    }
}

struct pixivWorkData {
    var pageCount:Int{
        return metaPages.count
    }
    var id:Int
    var title:String
    var caption:String
    var restrict:Int
    var sanityLevel:Int
    var totalView:Int
    var totalBookmarks:Int
    var isBookmarked:Bool
    
    var width:CGFloat
    var height:CGFloat
    var createDate:Date
    var tools:[String]
    var tags:[String]
    
    var user:pixivUserData!
    var metaPages:[pixivImageUrlsData]
    var type:pixivWorkType
    var imageUrls:pixivImageUrlsData!
    
    init(){
        self.id = 0
        self.title = ""
        self.caption = ""
        self.restrict = 0
        self.sanityLevel = 0
        self.totalView = 0
        self.totalBookmarks = 0
        self.isBookmarked = false
        
        self.width = 0
        self.height = 0
        self.createDate = Date(timeIntervalSince1970: 0)
        self.tools = []
        self.type = .illust
        
        self.user = nil
        self.tags = []
        
        self.imageUrls = nil
        self.metaPages = []
    }
    
    enum pixivWorkType:String {
        case illust
        case manga
        case ugoira
    }
    struct pixivImageUrlsData {
        var squareMedium:String
        var medium:String
        var large:String
        var original:String
        init(json:JSON){
            self.squareMedium = json["square_medium"].stringValue
            self.medium = json["medium"].stringValue
            self.large = json["large"].stringValue
            self.original = json["original"].stringValue
        }
        init(json:JSON,secondJson:JSON){
            self.squareMedium = json["square_medium"].stringValue
            self.medium = json["medium"].stringValue
            self.large = json["large"].stringValue
            self.original = secondJson["original_image_url"].stringValue
        }
    }
    
    init(json:JSON) {
        self.id = json["id"].intValue
        self.title = json["title"].stringValue
        self.caption = json["caption"].stringValue.replace(of: "pixiv://", with: "procyon://")
        self.restrict = json["restrict"].intValue
        self.sanityLevel = json["sanity_level"].intValue
        self.totalView = json["total_view"].intValue
        self.totalBookmarks = json["total_bookmarks"].intValue
        self.isBookmarked = json["is_bookmarked"].boolValue
        
        self.width = CGFloat(json["width"].intValue)
        self.height = CGFloat(json["height"].intValue)
        self.createDate = Date(string: json["create_date"].stringValue, for: "yyyy-MM-dd'T'HH:mm:ssZZZZ")
        self.tools = json["tools"].arrayValue.map{json in json.stringValue}
        self.type = pixivWorkType(rawValue: json["type"].stringValue) ?? .illust
        
        self.user = pixivUserData(json: json["user"])
        self.tags = json["tags"].arrayValue.map{json in json["name"].stringValue}
        
        self.imageUrls = pixivImageUrlsData(json: json["image_urls"], secondJson: json["meta_single_page"])
        self.metaPages = json["meta_pages"].arrayValue.map{pjson in pixivImageUrlsData(json: pjson["image_urls"])}
        if metaPages.isEmpty{metaPages.append(imageUrls)}
    }
}
extension pixivWorkData.pixivImageUrlsData: Storable{
    var dict: [String : Any]{
        return [
            "squareMedium":squareMedium,
            "medium":medium,
            "large":large,
            "original":original
        ]
    }
    init(dict: [String : Any]) {
        self.squareMedium = stringValue(of: dict["squareMedium"])
        self.medium = stringValue(of: dict["medium"])
        self.large = stringValue(of: dict["large"])
        self.original = stringValue(of: dict["original"])
    }
}
extension pixivWorkData: Equatable{
    static func ==(lhs: pixivWorkData, rhs: pixivWorkData) -> Bool{
        return lhs.id == rhs.id
    }
}
extension pixivWorkData: Storable{
    var dict: [String : Any]{
        return [
            "id":id,
            "title":title,
            "caption":caption,
            "restrict":restrict,
            "sanityLevel":sanityLevel,
            "totalView":totalView,
            "totalBookmarks":totalBookmarks,
            "isBookmarked":isBookmarked,
            "width":width,
            "height":height,
            "createDate":createDate,
            "tools":tools,
            "tags":tags,
            "user":user.dict,
            "metaPages":metaPages.map{$0.dict},
            "type":type.rawValue,
            "imageUrls":imageUrls.dict
        ]
    }
    init(dict: [String : Any]) {
        let d = Decoder(dict: dict)
        self.id = d.int("id")
        self.title = d.string("title")
        self.caption = d.string("caption")
        self.restrict = d.int("restrict")
        self.sanityLevel = d.int("sanityLevel")
        self.totalView = d.int("totalView")
        self.totalBookmarks = d.int("totalBookmarks")
        self.isBookmarked = d.bool("isBookmarked")
        self.width = d.cgFloat("width")
        self.height = d.cgFloat("height")
        self.createDate = d.date("createDate")
        self.tools = d.stringArray("tools")
        self.tags = d.stringArray("tags")
        self.user = d.struct(pixivUserData.self, "user")
        self.metaPages = d.structArray(pixivWorkData.pixivImageUrlsData.self,"metaPages")
        self.type = pixivWorkType(rawValue: d.string("type")) ?? .illust
        self.imageUrls = d.struct(pixivWorkData.pixivImageUrlsData.self, "imageUrls")
    }
}
struct Decoder {
    private var _dict:[String : Any] = [:]
    func int(_ key:String)->Int{return self._dict[key] as? Int ?? 0}
    func string(_ key:String)->String{return self._dict[key] as? String ?? ""}
    func bool(_ key:String)->Bool{return self._dict[key] as? Bool ?? false}
    func cgFloat(_ key:String)->CGFloat{return self._dict[key] as? CGFloat ?? 0}
    func array(_ key:String)->Array<Any>{return self._dict[key] as? Array<Any> ?? []}
    func stringArray(_ key:String)->[String]{return self._dict[key] as? [String] ?? []}
    func intArray(_ key:String)->[Int]{return self._dict[key] as? [Int] ?? []}
    func dictionary(_ key:String)->[String:Any]{return self._dict[key] as? [String:Any] ?? [:]}
    func dictArray(_ key:String)->[[String:Any]]{return self.array(key) as? [[String:Any]] ?? []}
    func date(_ key:String)->Date{return self._dict[key] as? Date ?? Date()}
    func `struct`<T:Storable>(_ type:T.Type ,_ key:String)->T{return T(dict: self._dict[key] as? [String:Any] ?? [:])}
    func structArray<T:Storable>(_ type:T.Type,_ key: String)->[T]{
        return dictArray(key).map{d in T(dict: d)}
    }
    
    init(dict: [String : Any]) {
        self._dict = dict
    }
}
class pixivUserContentsData {
    var userPreviews:[pixivUserPreviewData]
    var nextUrl:String
    var count:Int{
        return userPreviews.count
    }
    
    func append(_ json: JSON,completion:@escaping voidBlock){
        asyncQ {
            self.userPreviews.append(contentsOf: json["user_previews"].arrayValue.map{json in pixivUserPreviewData(json: json)})
            self.nextUrl = json["next_url"].stringValue
            mainQ (completion)
        }
    }
    func reset(){
        userPreviews = []
        nextUrl = ""
    }
    
    struct pixivUserPreviewData {
        var workCount:Int{
            return illusts.count+novels.count
        }
        var user:pixivUserData
        var illusts:[pixivWorkData]
        var novels:[pixivNovelData]
        
        init(json: JSON) {
            user = pixivUserData(json: json["user"])
            illusts = json["illusts"].arrayValue.map{json in pixivWorkData(json: json)}
            novels = json["novels"].arrayValue.map{json in pixivNovelData(json: json)}
        }
    }
    
    init(json: JSON) {
        self.userPreviews = json["user_previews"].arrayValue.map{json in pixivUserPreviewData(json: json)}
        self.nextUrl = json["next_url"].stringValue
    }
    init(){
        userPreviews = []
        nextUrl = ""
    }
}
struct pixivUserData {
    var name:String
    var id:Int
    var account:String
    var profileImageUrl:String
    var comment:String
    var isFollowed:Bool
    var isPremium:Bool?
    
    init(json:JSON){
        self.name = json["name"].stringValue
        self.id = json["id"].intValue
        self.account = json["account"].stringValue
        self.profileImageUrl = json["profile_image_urls"]["medium"].stringValue
        self.comment = json["comment"].stringValue
        self.isFollowed = json["is_followed"].boolValue
        self.isPremium = json["is_premium"].bool
        if profileImageUrl.isEmpty{
            self.profileImageUrl = json["profile_image_urls"]["px_170x170"].stringValue
        }
    }
}
extension pixivUserData: Storable{
    var dict: [String : Any]{
        return ["name":name,"id":id,"account":account,"profile_image_url":profileImageUrl,"comment":comment,"is_followed":isFollowed]
    }
    init(dict: [String : Any]) {
        self.name = stringValue(of: dict["name"])
        self.id = intValue(of: dict["id"])
        self.account = stringValue(of: dict["account"])
        self.profileImageUrl = stringValue(of: dict["profile_image_url"])
        self.comment = stringValue(of: dict["comment"])
        self.isFollowed = boolValue(of: dict["is_followed"])
        self.isPremium = false
    }
}
struct pixivFullUserData {
    var user:pixivUserData
    var profile:pixivUserProfileData
    var workspace:pixivUserWorkspaceData
    
    struct pixivUserProfileData {
        var webpage:String
        var gender:pixivUserGender
        var birth:Date?
        var region:String
        var job:String
        var totalFollowUsers:Int
        var totalFollower:Int
        var totalMyPixivUsers:Int
        var totalIllusts:Int
        var totalManga:Int
        var totalNovels:Int
        var totalIllustBookmarksPublic:Int
        var backgroundImageUrl:String
        var twitterAccount:String
        var twitterUrl:String
        var isPremium:Bool
        
        enum pixivUserGender :String{
            case female
            case male
            case other
            func jpValue()->String{
                if self == .female{return "女性"}
                if self == .male{return "男性"}
                return ""
            }
        }
        
        init(json:JSON) {
            self.webpage = json["webpage"].stringValue
            self.gender = pixivUserGender(rawValue: json["gender"].stringValue) ?? .other
            self.birth = dateMake(string: json["birth"].stringValue, format: "yyyy-mm-dd") 
            self.region = json["region"].stringValue
            self.job = json["job"].stringValue
            self.totalFollowUsers = json["total_follow_users"].intValue
            self.totalFollower = json["total_follower"].intValue
            self.totalMyPixivUsers = json["total_mypixiv_users"].intValue
            self.totalIllusts = json["total_illusts"].intValue
            self.totalManga = json["total_manga"].intValue
            self.totalNovels = json["total_novels"].intValue
            self.totalIllustBookmarksPublic = json["total_illust_bookmarks_public"].intValue
            self.backgroundImageUrl = json["background_image_url"].stringValue
            self.twitterAccount = json["twitter_account"].stringValue
            self.twitterUrl = json["twitter_url"].stringValue
            self.isPremium = json["is_premium"].boolValue
        }
    }
    
    struct pixivUserWorkspaceData {
        var pc:String
        var monitor:String
        var tool:String
        var scanner:String
        var tablet:String
        var mouse:String
        var printer:String
        var desktop:String
        var music:String
        var desk:String
        var chair:String
        var comment:String
        var workspaceImageUrl:String
        
        init(json:JSON) {
            self.pc = json["pc"].stringValue
            self.monitor = json["monitor"].stringValue
            self.tool = json["tool"].stringValue
            self.scanner = json["scanner"].stringValue
            self.tablet = json["tabler"].stringValue
            self.mouse = json["mouse"].stringValue
            self.printer = json["printer"].stringValue
            self.desktop = json["desktop"].stringValue
            self.music = json["music"].stringValue
            self.desk = json["desk"].stringValue
            self.chair = json["chair"].stringValue
            self.comment = json["comment"].stringValue
            self.workspaceImageUrl = json["workspace_image_url"].stringValue
        }
    }
    
    init(json:JSON) {
        self.user = pixivUserData(json: json["user"])
        self.profile = pixivUserProfileData(json: json["profile"])
        self.workspace = pixivUserWorkspaceData(json: json["workspace"])
    }
}

struct pixivUgoiraData {
    var count:Int{
        return files.count
    }
    var zipUrl:String
    var files:[String]
    var deleys:[UInt32]
    
    init(json:JSON) {
        self.zipUrl = json["ugoira_metadata"]["zip_urls"]["medium"].stringValue
        self.files = json["ugoira_metadata"]["frames"].arrayValue.map{json in json["file"].stringValue}
        self.deleys = json["ugoira_metadata"]["frames"].arrayValue.map{json in json["delay"].uInt32Value}
    }
}

struct pixivCommentsData {
    var nextUrl:String
    var comments:[pixivCommentData]
    var count:Int{
        return comments.count
    }
    
    struct pixivCommentData {
        var id:Int
        var comment:String
        var date:RMDate
        var user:pixivUserData
        
        init(json:JSON) {
            id = json["id"].intValue
            comment = json["comment"].stringValue
            date = RMDate(dateStr: json["date"].stringValue, withType: .ISO8601)
            user = pixivUserData(json: json["user"])
        }
    }
    mutating func reset(){
        nextUrl = ""
        comments = []
    }
    mutating func insertCommentJson(json:JSON){
        comments.insert(pixivCommentData(json: json["comment"]),at: 0)
    }
    mutating func appendJson(json:JSON){
        let jsonComments = json["comments"].arrayValue
        nextUrl = json["next_url"].stringValue
        comments.append(contentsOf: jsonComments.map{json in pixivCommentData(json: json)})
    }
    
    init(json:JSON){
        let jsonComments = json["comments"].arrayValue
        nextUrl = json["next_url"].stringValue
        comments = jsonComments.map{json in pixivCommentData(json: json)}
    }
}
struct pixivLoginData {
    var hasError:Bool
    var error:pixivErrorData
    var accessToken:String
    var expiresIn:String
    var tokenType:String
    var scope:String
    var refreshToken:String
    var user:pixivUserData
    
    init(json:JSON){
        self.hasError = json["has_error"].boolValue
        self.error = pixivErrorData(json: json["errors"])
        let response = json["response"]
        self.accessToken = response["access_token"].stringValue
        self.expiresIn = response["expires_in"].stringValue
        self.refreshToken = response["refresh_token"].stringValue
        self.tokenType = response["token_type"].stringValue
        self.scope = response["scope"].stringValue
        self.user = pixivUserData(json: response["user"])
    }
}
struct pixivCreatedAccountData {
    var message:String
    var error:Bool
    var body:Body
    struct Body {
        var password:String
        var deviceToken:String
        var userAccount:String
        init(json: JSON) {
            self.password = json["password"].stringValue
            self.deviceToken = json["device_token"].stringValue
            self.userAccount = json["user_account"].stringValue
        }
    }
    init(json: JSON) {
        self.message = json["message"].stringValue
        self.error = json["error"].boolValue
        self.body = Body(json: json["body"])
    }
}

struct pixivErrorData {
    var system:pixivErrorSystemData
    var message:String
    struct pixivErrorSystemData {
        var code:Int
        init(json:JSON) {
            self.code = json["code"].intValue
        }
    }
    init(json:JSON) {
        self.message = json["message"].stringValue
        self.system = pixivErrorSystemData(json: json["system"])
    }
}


struct pixivTagBookmarkData {
    var bookmarkTags:[String]
    init(json:JSON) {
        bookmarkTags = json["bookmark_tags"].arrayValue.map{$0["name"].stringValue}
    }
}









