//============================================================================
//PixivAPI
import Foundation

let pixiv = PixivAPI()

enum PixivRestrict:String{
    case `public`
    case `private`
}
enum PixivSearchSort:String{
    case popular_desc
    case date_asc
    case date_desc
}
enum PixivSearchTarget:String {
    case partial_match_for_tags
    case exact_match_for_tags
    case title_and_caption
}
enum PixivSearchDuration:String {
    case all
    case within_last_day
    case within_last_week
    case within_last_month
}
enum PixivReportType:String {
    case infringes_on_copyrights
    case contains_excessive_sexual_content
    case contains_excessive_grotesque_content
    case violated_other_rules
}
enum PixivRankingType:Int {//順番が大切
    case day = 0
    case week
    case month
    case day_male
    case day_female
    case week_original
    case week_rookie
    case day_r18
    case week_r18
    case day_male_r18
    case day_female_r18
}
/*[
 //date=2017-01-25
 "デイリー",
 "ウィークリー",
 "マンスリー",
 "男子向け",
 "女子向け",
 "オリジナル",
 "ルーキー",
 "R-18デイリー",day_r18
 "R18ウィークリー",week_r18
 "R18男性向け",day_male_r18
 "R18女性向け"day_female_r18
]*/
class PixivAPI{
    //============================================================================
    //properties
    var selfID:Int{
        return loginData?.user.id ?? -1
    }
    var loginData:pixivLoginData? = nil
    var referer = "http://www.pixiv.net/"
    var headers = [
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate",
        "Connection": "keep-alive",
        "Proxy-Connection": "keep-alive",
        "App-OS-Version": "10.0.0",
        "App-OS": "ios",
        "User-Agent": "PixivIOSApp/6.4.4 (iOS 10.0.0; iPhone6,2)",
        "App-Version": "6.4.4",
        "Accept-Language": "ja-jp",
    ]
    //============================================================================
    //method
    //======================================
    //logIn
    func logIn(username:String,password:String,completion:@escaping (pixivLoginData)->()){
        let request = "https://oauth.secure.pixiv.net/auth/token".request
        request.bodyParam = [
            "client_id":"bYGKuGVw91e0NMfPGp44euvGt59s",
            "client_secret":"HP3RmkgAmEGro0gn1x9ioawQE8WMfvLXDz3ZqxpK",
            "get_secure_url":"1",
            "grant_type":"password",
            "password":"\(password)",
            "username":"\(username)"
        ]
        request.headers = headers
        request.postJson {json in
            let data = pixivLoginData(json: json)
            self.loginData = data
            self.headers["Authorization"] = "Bearer \(data.accessToken)"
            completion(data)
        }
    }
    //======================================
    //getWorkData
    func addComment(id:Int,comment:String,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/illust/comment/add".request
        request.bodyParam = ["illust_id": id,"comment": comment.encodedForURL]
        self.post(request, completion)
    }
    //======================================
    //getAppInfo
    func getAppInfo(_ completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/application-info/ios".request
        self.get(request, completion)
    }
    //======================================
    //getUgoiraMatadata
    func getUgoiraMatadata(id:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/ugoira/metadata?illust_id=\(id)".request
        self.get(request, completion)
    }
    //======================================
    //getWorkData
    func getWorkData(id:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/illust/detail?illust_id=\(id)".request
        self.get(request, completion)
    }
    //======================================
    //getComments
    func getComments(id:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/illust/comments?illust_id=\(id)".request
        self.get(request, completion)
    }
    //======================================
    //getRecommend
    func getRecommend(_ completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/illust/recommended?content_type=illust&filter=for_ios&include_ranking_label=true".request
        self.get(request, completion)
    }
    //======================================
    //getFollowingLatest
    func getFollowingLatest(restrict: PixivRestrict,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v2/illust/follow?restrict=\(restrict.rawValue)".request
        self.get(request, completion)
    }
    //======================================
    //getUserData
    func getUserData(userID:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/user/detail?user_id=\(userID)&filter=for_ios".request
        self.get(request, completion)
    }
    //======================================
    //getRanking
    func getRanking(mode:PixivRankingType,date: String?=nil, completion:@escaping jsonBlock){
        var url = "https://app-api.pixiv.net/v1/illust/ranking?"
        if let date = date{
            url+="date=\(date)&mode=\(mode)"
        }else{
            url+="mode=\(mode)"
        }
        let request = url.request
        self.get(request, completion)
    }
    //======================================
    //getUserBookmark
    func getUserBookmark(userID:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/user/bookmarks/illust?user_id=\(userID)&restrict=public&filter=for_ios".request
        self.get(request, completion)
    }
    //======================================
    //getUserWorks
    func getUserWorks(userID:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/user/illusts?user_id=\(userID)&filter=for_ios".request
        self.get(request, completion)
    }
    //======================================
    //getUserWorks
    func getMyWorks(_ completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/user/illusts?user_id=\(pixiv.selfID)&filter=for_ios".request
        self.get(request, completion)
    }
    //======================================
    //getUserWorks
    func getUserFollowUser(userID:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/user/following?user_id=\(userID)&restrict=".request
        self.get(request, completion)
    }
    //======================================
    //getMyFollowUser
    func getMyFollowUser(restrict: PixivRestrict,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/user/following?user_id=\(pixiv.selfID)&restrict=\(restrict.rawValue)".request
        self.get(request, completion)
    }
    //======================================
    //getMyFollowUser
    func getUserFollow(id: Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/user/following?user_id=\(id)".request
        self.get(request, completion)
    }
    //======================================
    //addBookMark
    func addBookMark(id:Int,restrict: PixivRestrict,tags:[String] = [],completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v2/illust/bookmark/add".request
        request.bodyStr = "illust_id=\(id)&restrict=\(restrict.rawValue)"
        _=tags.map{t in request.bodyStr?.append("&tags[]=\(t.encodedForURL)")}
        self.post(request, completion)
    }
    //======================================
    //deleteBookMark
    func deleteBookMark(id:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/illust/bookmark/delete".request
        request.bodyParam = ["illust_id":id]
        self.post(request, completion)
    }
    //======================================
    //getBookMark
    func getBookMark(restrict: PixivRestrict,tag:String? = nil,completion:@escaping jsonBlock){
        var url = "https://app-api.pixiv.net/v1/user/bookmarks/illust?user_id=\(pixiv.selfID)&restrict=\(restrict.rawValue)"
        if let tag = tag{url+="&tag=\(tag.encodedForURL)"}
        self.get(url.request, completion)
    }
    //======================================
    //search
    func search(word:String,sort:PixivSearchSort,target:PixivSearchTarget,duration:PixivSearchDuration,completion:@escaping jsonBlock){
        var url = "https://app-api.pixiv.net/v1/search/illust?search_target=\(target.rawValue)&sort=\(sort.rawValue)&word=\(word.encodedForURL)"
        if duration != .all{
            url += "&duration=\(duration.rawValue)"
        }
        let request = url.request
        self.get(request, completion)
    }
    //======================================
    //getPopularWorks
    func getPopularWorks(word:String,target:PixivSearchTarget,duration:PixivSearchDuration,completion:@escaping jsonBlock){
        var url = "https://app-api.pixiv.net/v1/search/popular-preview/illust?search_target=\(target.rawValue)&filter=for_ios&word=\(word.encodedForURL)"
        if duration != .all{url += "&duration=\(duration.rawValue)"}
        let request = url.request
        self.get(request, completion)
    }
    //======================================
    //getSearchEstimated
    func getSearchEstimated(word:String,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/search/autocomplete?word=\(word.encodedForURL)".request
        self.get(request, completion)
    }
    //======================================
    //getLatest
    func getLatest(_ completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/illust/new?content_type=illust&filter=for_ios".request
        self.get(request, completion)
    }
    //======================================
    //getTagBookmark
    func getTagBookmark(restrict: PixivRestrict,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/user/bookmark-tags/illust?restrict=\(restrict.rawValue)".request
        self.get(request, completion)
    }
    //======================================
    //postReport
    func postReport(id:Int,type:PixivReportType,message:String,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/illust/report".request
        request.bodyParam = ["illust_id":id,"type_of_problem":"type.rawValue","message":message]
        self.get(request, completion)
    }
    //======================================
    //getRelated
    func getRelated(id:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v2/illust/related?illust_id=\(id)&filter=for_ios".request
        self.get(request, completion)
    }
    //======================================
    //addFollowUser
    func addFollowUser(id:Int,restrict: PixivRestrict,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/user/follow/add".request
        request.bodyParam = ["restrict":restrict.rawValue,"user_id":id]
        self.post(request, completion)
    }
    //======================================
    //deleteFollowUser
    func deleteFollowUser(id:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/user/follow/delete".request
        request.bodyParam = ["user_id":id]
        self.post(request, completion)
    }
    //======================================
    //searchUser
    func searchUser(word: String,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/search/user?filter=for_ios&word=\(word.encodedForURL)".request
        self.get(request, completion)
    }
    //======================================
    //getBookmarked
    func getBookmarked(id: Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/illust/bookmark/users?illust_id=\(id)".request
        self.get(request, completion)
    }
    //======================================
    //getMyFollower
    func getMyFollower(completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/user/follower?filter=for_ios&user_id=\(pixiv.selfID)".request
        self.get(request, completion)
    }
    //======================================
    //getUserFollower
    func getUserFollower(id:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/user/follower?filter=for_ios&user_id=\(id)".request
        self.get(request, completion)
    }
    //======================================
    //getMyAccountImage
    func getMyAccountImage(completion:@escaping imageBlock){
        PixivSystem.getLoginData{data in
            if data.user.profileImageUrl.contains("no_profile"){
                ADNoProfile.createImage(withName: data.user.name, completion: completion)
            }else{
                let request = data.user.profileImageUrl.request
                request.referer = self.referer
                request.getImage(completion)
            }
        }
    }
    //======================================
    //getAccountImage
    func getAccountImage(userData:pixivUserData,completion:@escaping imageBlock){
        if userData.profileImageUrl.contains("no_profile"){
            ADNoProfile.createImage(withName: userData.name, completion: completion)
        }else{
            let request = userData.profileImageUrl.request
            request.referer = referer
            request.getImage(completion)
        }
    }
    func getImage(url:String,_ completion:@escaping imageBlock){
        let request = url.request
        request.referer = pixiv.referer
        request.getImage(completion)
    }
    func createNewAccount(name:String,completion:@escaping jsonBlock){
        let request = "https://accounts.pixiv.net/api/provisional-accounts/create".request
        request.bodyStr = "ref=pixiv_ios_app_provisional_account&user_name=\(name.encodedForURL)"
        request.headers = [
            "Host": "accounts.pixiv.net",
            "Accept": "*/*",
            "Authorization": "Bearer WHDWCGnwWA2C8PRfQSdXJxjXp0G6ULRaRkkd6t5B6h8",
            "App-Version": "6.7.0",
            "App-OS": "ios",
            "Accept-Language": "ja-jp",
            "Accept-Encoding": "gzip, deflate",
            "Content-Type": "application/x-www-form-urlencoded",
            "User-Agent": "PixivIOSApp/6.7.0 (iOS 10.2; iPhone6,2)",
            "Connection": "keep-alive",
            "Cookie": "PHPSESSID=3ec97901ce751d3b19bd5b77dc6a124f",
            "App-OS-Version": "10.2",
        ]
        request.postJson(completion)
    }
    func get(_ reqest: RMRequest,_ completion:@escaping jsonBlock){
        reqest.headers = pixiv.headers
        reqest.getJson {json in
            if json["error"]["message"].stringValue.contains("Error occurred at the OAuth process."){
                guard let accountData = PixivSystem.accountData else {return}
                self.logIn(username: accountData.id, password: accountData.password, completion: {_ in
                    reqest.headers = pixiv.headers
                    reqest.getJson(completion)
                })
            }else{
                completion(json)
            }
        }
    }
    func post(_ reqest: RMRequest,_ completion:@escaping jsonBlock){
        reqest.headers = pixiv.headers
        reqest.postJson {json in
            PixivSystem.reloadTagBookmark() 
            if json["error"]["message"].stringValue.contains("Error occurred at the OAuth process."){
                guard let accountData = PixivSystem.accountData else {return}
                self.logIn(username: accountData.id, password: accountData.password, completion: {_ in
                    reqest.headers = pixiv.headers
                    reqest.postJson(completion)
                })
            }else{
                completion(json)
            }
        }
    }
}





