import UIKit

let pixivInternalApi = PixivInternalAPI()

class PixivInternalAPI{
    func getHistory(restrict: PixivRestrict)->pixivContentsData{
        return info.structValue(type: pixivContentsData.self, forKey: self.getHistoryKey(restrict: restrict))
    }
    func addHistory(restrict: PixivRestrict,work:pixivWorkData){
        let datas = info.structValue(type: pixivContentsData.self, forKey: self.getHistoryKey(restrict: restrict))
        datas.works=datas.works.filter{$0 != work}
        datas.works.insert(work, at: 0)
        info.set(datas, forKey: self.getHistoryKey(restrict: restrict))
    }
    func deleteAllHistory(restrict: PixivRestrict){
        info.set(pixivContentsData(), forKey: self.getHistoryKey(restrict: restrict))
    }
    func deleteHistory(restrict: PixivRestrict,at index:Int){
        let datas = info.structValue(type: pixivContentsData.self, forKey: self.getHistoryKey(restrict: restrict))
        datas.works.remove(index)
        info.set(datas, forKey: self.getHistoryKey(restrict: restrict))
    }
    func getSearchHistory(restrict:PixivRestrict)->[String]{
        return info.stringArrayValue(forKey: self.getSearchHistoryKey(restrict: restrict))
    }
    func addSearchHistory(word:String,restrict:PixivRestrict){
        asyncQ{
            let defaultName = self.getSearchHistoryKey(restrict: restrict)
            let oldHistories = info.stringArrayValue(forKey: defaultName)
            var newHistories = [String]()
            for history in oldHistories{
                if history != word{
                    newHistories.append(history)
                }
            }
            newHistories.insert(word, at: 0)
            info.set(newHistories, forKey: defaultName)
        }
    }
    func deleteAllSearchHistory(restrict: PixivRestrict){
        let defaultName = self.getSearchHistoryKey(restrict: restrict)
        info.set([], forKey: defaultName)
    }
    func deleteSearchHistory(restrict: PixivRestrict,element:String){
        let defaultName = self.getSearchHistoryKey(restrict: restrict)
        asyncQ {
            var histories = info.stringArrayValue(forKey: defaultName)
            histories.remove(element)
            info.set(histories, forKey: defaultName)
        }
    }
    
    func getWorkDatas(withIDs ids:[Int], completion:@escaping jsonBlock){
        asyncQ {
            var jsonArray = [JSON]()
            if !ids.isEmpty{
                for id in ids{
                    let request = "https://app-api.pixiv.net/v1/illust/detail?illust_id=\(id)".request
                    request.headers = pixiv.headers
                    request.sync = true
                    request.getJson{json in
                        jsonArray.append(json["illust"])
                    }
                }
                var json = JSON(dictionaryLiteral: [])
                json["illusts"] = JSON(jsonArray)
                mainQ {
                    completion(json)
                }
            }else{
                var json = JSON(dictionaryLiteral: [])
                json["illusts"] = []
                mainQ {
                    completion(json)
                }
            }
        }
    }
    private func getHistoryKey(restrict: PixivRestrict)->String{
        var defaultName = "pixiv_history_datas_"
        
        if restrict == .private{
            defaultName+="private"
        }else{
            defaultName+="public"
        }
        
        return defaultName
    }
    private func getSearchHistoryKey(restrict: PixivRestrict)->String{
        var defaultName = "search_histories"
        
        if restrict == .private{
            defaultName+="private"
        }else{
            defaultName+="public"
        }
        
        return defaultName
    }
}
