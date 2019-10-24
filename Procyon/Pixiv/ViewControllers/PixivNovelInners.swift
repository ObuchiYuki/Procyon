import UIKit

class PixivNovelRecommendInner: PixivNovelCollectionViewBaseController {
    override func runApi(handler: @escaping jsonBlock) {
        novel.getRecommend(handler)
    }
}
class PixivNovelFollowerLatestInner: PixivNovelCollectionViewBaseController{
    override func runApi(handler: @escaping jsonBlock) {
        novel.getFollowLatest(restrict: PixivSystem.restrict, completion: handler)
    }
}
class PixivNovelMyNovelsInner: PixivNovelCollectionViewBaseController{
    override func runApi(handler: @escaping jsonBlock) {
        novel.getMyNovel(handler)
    }
}
class PixivNovelUserNovelsInner: PixivNovelCollectionViewBaseController{
    var userID = 0
    override func runApi(handler: @escaping jsonBlock) {
        novel.getUserNovels(id: userID, completion: handler)
    }
}
class PixivNovelSeriesInner: PixivNovelCollectionViewBaseController{
    var id = 0
    override func runApi(handler: @escaping jsonBlock) {
        novel.getSeries(id: id, completion: handler)
    }
}
class PixivNovelRankingInner: PixivNovelCollectionViewBaseController{
    let settingView = PixivHeaderButtonsView(icon: "tune")
    var rankingType = PixivRankingType.day{didSet{reload()}}
    var date:String? = nil
    
    override func setSetting() {
        self.headerView = settingView
    }
    
    override func runApi(handler: @escaping jsonBlock) {
        novel.getRanking(type: rankingType,date: date, completion: handler)
    }
}
class PixivNovelBookmarkInner: PixivNovelCollectionViewBaseController{
    let settingView = PixivHeaderButtonsView(icon: "tune")
    var tag:String? = nil
    
    override func setSetting() {
        self.headerView = settingView
    }
    override func runApi(handler: @escaping jsonBlock) {
        novel.getBookMark(PixivSystem.restrict,tag: tag, completion: handler)
    }
}
