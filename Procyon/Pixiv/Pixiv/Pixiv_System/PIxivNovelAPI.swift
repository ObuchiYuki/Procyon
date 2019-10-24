import UIKit
//============================================================================
//enum
enum NovelSearchTarget:String{
    case partial_match_for_tags
    case text
    case keyword
}

let novel = PixivNovel()

class PixivNovel{
    //============================================================================
    //APImethod
    //======================================
    //getText
    func getText(id:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/novel/text?novel_id=\(id)".request
        pixiv.get(request, completion)
    }
    //======================================
    //getData
    func getData(id:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v2/novel/detail?novel_id=\(id)".request
        pixiv.get(request, completion)
    }
    //======================================
    //getAuthorNovel
    func getUserNovels(id:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/user/novels?user_id=\(id)".request
        pixiv.get(request, completion)
    }
    //======================================
    //getAuthorNovel
    func getMyNovel(_ completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/user/novels?user_id=\(pixiv.selfID)".request
        pixiv.get(request, completion)
    }
    //======================================
    //getNovelSeries
    func getSeries(id:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/novel/series?series_id=\(id)".request
        pixiv.get(request, completion)
    }
    //======================================
    //getRanking
    func getRanking(type:PixivRankingType,date:String? = nil,completion:@escaping jsonBlock){
        var url = "https://app-api.pixiv.net/v1/novel/ranking?mode=\(type)"
        if let date = date{url+="&date=\(date)"}
        pixiv.get(url.request, completion)
    }
    //======================================
    //getNovelRecommend
    func getRecommend(_ completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/novel/recommended?include_ranking_label=true".request
        pixiv.get(request, completion)
    }
    //======================================
    //getTagBookmark
    func getTagBookmark(restrict: PixivRestrict,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/user/bookmark-tags/novel?restrict=\(restrict.rawValue)".request
        pixiv.get(request, completion)
    }
    //======================================
    //getNovelBookMark
    func getBookMark(_ restrict:PixivRestrict,tag:String? = nil,completion:@escaping jsonBlock){
        var url = "https://app-api.pixiv.net/v1/user/bookmarks/novel?user_id=\(pixiv.selfID)&restrict=\(restrict.rawValue)"
        if let tag = tag{url+="&tag=\(tag.encodedForURL)"}
        pixiv.get(url.request, completion)
    }
    //======================================
    //addNovelBookMark
    func addBookMark(id:Int,restrict:PixivRestrict,tags:[String] = [],completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v2/novel/bookmark/add".request
        request.bodyStr = "novel_id=\(id)&restrict=\(restrict.rawValue)"
        _=tags.map{t in request.bodyStr?.append("&tags[]=\(t.encodedForURL)")}
        pixiv.post(request, completion)
    }
    //======================================
    //deleteNovelBookMark
    func deleteBookMark(id:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/novel/bookmark/delete".request
        request.bodyParam = ["novel_id":"\(id)"]
        pixiv.post(request, completion)
    }
    //======================================
    //getFollowLatest
    func getFollowLatest(restrict:PixivRestrict,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/novel/follow?restrict=\(restrict.rawValue)".request
        pixiv.get(request, completion)
    }
    //======================================
    //search
    func search(word:String,target:NovelSearchTarget,sort:PixivSearchSort,duration:PixivSearchDuration,completion:@escaping jsonBlock){
        var url = "https://app-api.pixiv.net/v1/search/novel?sort=\(sort.rawValue)&search_target=\(target.rawValue)&word=\(word.encodedForURL)"
        if duration != .all{url += "&duration=\(duration.rawValue)"}
        pixiv.get(url.request, completion)
    }
    //======================================
    //search
    func getPopular(word:String,target:NovelSearchTarget,sort:PixivSearchSort,duration:PixivSearchDuration,completion:@escaping jsonBlock){
        var url = "https://app-api.pixiv.net/v1/search/popular-preview/novel?search_target=\(target.rawValue)&filter=for_ios&word=\(word.encodedForURL)"
        if duration != .all{
            url += "&duration=\(duration.rawValue)"
        }
        pixiv.get(url.request, completion)
    }
    //======================================
    //getComments
    func getComments(id:Int,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/novel/comments?novel_id=\(id)".request
        pixiv.get(request, completion)
    }
    //======================================
    //addComment
    func addComment(id:Int,comment:String,completion:@escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/novel/comment/add".request
        request.bodyParam = ["novel_id": id,"comment": comment.encodedForURL]
        pixiv.post(request, completion)
    }
}













