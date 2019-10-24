import UIKit

class PixivMyWorksInner: PixivCollectionViewBaseController{
    override func runApi(handler: @escaping jsonBlock) {
        pixiv.getMyWorks(handler)
    }
}

class PixivUserWorksInner: PixivCollectionViewBaseController{
    var userID = 0
    override func runApi(handler: @escaping jsonBlock) {
        pixiv.getUserWorks(userID: userID, completion: handler)
    }
}
class PixivUserBookmarkInner: PixivCollectionViewBaseController{
    var userID = 0
    override func runApi(handler: @escaping jsonBlock) {
        pixiv.getUserBookmark(userID: userID, completion: handler)
    }
}

class PixivRelatedWorksInner: PixivCollectionViewBaseController{
    var id = 0
    override func runApi(handler: @escaping jsonBlock) {
        pixiv.getRelated(id: id, completion: handler)
    }
}
class PixivRecommendInner: PixivCollectionViewBaseController {
    let pixivVisionView = PixiVisionView()
    
    override func setSetting() {
        self.headerView = pixivVisionView
    }
    override func runApi(handler: @escaping jsonBlock) {
        pixiv.getRecommend(handler)
    }
}
class PixivRankingInner: PixivCollectionViewBaseController {
    let settingView = PixivHeaderButtonsView(icon: "tune")
    var rankingType = PixivRankingType.day
    var date:String? = nil
    
    override func setSetting() {
        self.headerView = settingView
    }
    override func runApi(handler: @escaping jsonBlock) {
        pixiv.getRanking(mode: rankingType,date: date, completion: handler)
    }
}
class PixivBookmarkInner: PixivCollectionViewBaseController {
    let settingView = PixivHeaderButtonsView(icon: "tune")
    var tag:String? = nil
    
    override func setSetting() {
        self.headerView = settingView
    }
    override func runApi(handler: @escaping jsonBlock) {
        pixiv.getBookMark(restrict: PixivSystem.restrict,tag:tag, completion: handler)
    }
}
class PixivFollowerLatestInner: PixivCollectionViewBaseController {
    let followUserView = PixivFollowUserView()

    override func setSetting() {
        self.headerView = followUserView
        self.isHeaderViewScrollable = false
    }
    override func runApi(handler: @escaping jsonBlock) {
        pixiv.getFollowingLatest(restrict: PixivSystem.restrict, completion: handler)
    }
}


