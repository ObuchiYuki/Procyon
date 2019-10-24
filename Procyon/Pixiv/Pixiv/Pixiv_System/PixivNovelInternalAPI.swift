import Foundation

let novelInternalApi = PixivNovelInternalAPI()

class PixivNovelInternalAPI{
    func getHistory(restrict: PixivRestrict)->pixivNovelContentsData{
        return info.structValue(type: pixivNovelContentsData.self, forKey: self.getHistoryKey(restrict: restrict))
    }
    func addHistory(restrict: PixivRestrict,novel:pixivNovelData){
        let datas = info.structValue(type: pixivNovelContentsData.self, forKey: self.getHistoryKey(restrict: restrict))
        datas.novels=datas.novels.filter{$0 != novel}
        datas.novels.insert(novel, at: 0)
        info.set(datas, forKey: self.getHistoryKey(restrict: restrict))
    }
    func deleteAllHistory(restrict: PixivRestrict){
        info.set(pixivNovelContentsData(), forKey: self.getHistoryKey(restrict: restrict))
    }
    func deleteHistory(restrict: PixivRestrict,at index:Int){
        let datas = info.structValue(type: pixivNovelContentsData.self, forKey: self.getHistoryKey(restrict: restrict))
        datas.novels.remove(index)
        info.set(datas, forKey: self.getHistoryKey(restrict: restrict))
    }
    private func getNovelDatas(withIDs ids:[Int], completion:@escaping jsonBlock){
        asyncQ {
            var jsonArray = [JSON]()
            if !ids.isEmpty{
                for id in ids{
                    let request = "https://app-api.pixiv.net/v2/novel/detail?novel_id=\(id)".request
                    request.headers = pixiv.headers
                    request.sync = true
                    request.getJson{json in
                        jsonArray.append(json["novel"])
                    }
                }
                var json = JSON(dictionaryLiteral: [])
                json["novels"] = JSON(jsonArray)
                mainQ {
                    completion(json)
                }
            }
        }
    }
    private func getHistoryKey(restrict: PixivRestrict)->String{
        var defaultName = "pixiv_novel_history_datas_"
        
        if restrict == .private{
            defaultName+="private"
        }else{
            defaultName+="public"
        }
        
        return defaultName
    }
}
