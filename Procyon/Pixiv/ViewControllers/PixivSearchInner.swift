import UIKit

class PixivSearchInner: PixivCollectionViewBaseController {
    private var word = ""
    private var sort = PixivSearchSort.date_desc
    private var target = PixivSearchTarget.exact_match_for_tags
    private var duration = PixivSearchDuration.all
    
    func set(word:String, setting: pixivWorkSearchSettingData){
        self.word = word
        self.sort = setting.sort
        self.target = setting.target
        self.duration = setting.duration
    }
    
    override func runApi(handler: @escaping jsonBlock) {
        /*pixiv.search(word: word, sort: sort, target: target, duration: duration, completion: handler)*/
        if !PixivSystem.isPremium && sort == .popular_desc{
            pixiv.getPopularWorks(word: word, target: target, duration: duration, completion: handler)
        }else{
            pixiv.search(word: word, sort: sort, target: target, duration: duration, completion: handler)
        }
    }
}
