import UIKit

var pixivOther = PixivOtherAPI()

struct PixivOtherAPI {
    func getPixiVision(completion: @escaping jsonBlock){
        let request = "https://app-api.pixiv.net/v1/spotlight/articles?category=all&filter=for_ios".request
        pixiv.get(request, completion)
    }
}
