import UIKit

class PixivNovelSearchInner: PixivNovelCollectionViewBaseController {
    private var word = ""
    private var sort = PixivSearchSort.date_desc
    private var target = NovelSearchTarget.partial_match_for_tags
    private var duration = PixivSearchDuration.all
    
    func set(word:String,setting:pixivNovelSearchSettingData){
        self.word = word
        self.sort = setting.sort
        self.target = setting.target
        self.duration = setting.duration
    }
    
    override func runApi(handler: @escaping jsonBlock) {
        novel.search(word: word, target: target, sort: sort, duration: duration, completion: handler)
    }
}
