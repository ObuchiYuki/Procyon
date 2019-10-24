import UIKit

class PixivUserSearchInner: PixivUserCollectionViewBaseController {
    var word = ""
    override func runApi(handler: @escaping jsonBlock) {
        pixiv.searchUser(word: word, completion: handler)
    }
}
class PixivUserFollowerInner: PixivUserCollectionViewBaseController{
    var userID = 0
    override func runApi(handler: @escaping jsonBlock) {
        pixiv.getUserFollower(id: userID, completion: handler)
    }
}
class PixivUserFollowInner: PixivUserCollectionViewBaseController{
    var userID = 0
    override func runApi(handler: @escaping jsonBlock) {
        pixiv.getUserFollow(id: userID, completion: handler)
    }
}
class PixivUserMyFollowInner: PixivUserCollectionViewBaseController {
    override func runApi(handler: @escaping jsonBlock) {
        pixiv.getMyFollowUser(restrict: PixivSystem.restrict, completion: handler)
    }
}
class PixivUserMyFollowerInner: PixivUserCollectionViewBaseController{
    override func runApi(handler: @escaping jsonBlock) {
        pixiv.getMyFollower(completion: handler)
    }
}
