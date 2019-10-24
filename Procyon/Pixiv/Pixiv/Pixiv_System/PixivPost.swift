import UIKit

let pixivPost = PixivPost()

class PixivPost: NSObject {
    func postImage(_ postData:PixivPostImageData,completion:@escaping jsonBlock){
        let request = "https://-api.secure.pixiv.net/v1/upload/works".request
        
        
        let boundary = "--boundary-D1E591B2-9B00-4A83-B8EB-3E79F50F8C04-pixiv"
        
        func makeData(_ name:String,data:String)->String{
            var innerData = ""
            innerData += "--\(boundary)\r\n"
            innerData += "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n"
            innerData += data
            innerData += "\r\n"
            
            return innerData
        }
        
        var data = ""
        let body = NSMutableData()
        var headers = pixiv.headers
        
        headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        
        for tag in postData.tags{
            data += makeData("tags[]", data: tag)
        }
        data += makeData("title", data: postData.title)
        data += makeData("comment", data: postData.comment)
        data += makeData("age_limit", data: postData.ageLimit.rawValue)
        data += makeData("sexual", data: "\(postData.sexual.rawValue)")
        data += makeData("type", data: postData.type.rawValue)
        data += makeData("publicity", data: postData.publicity.rawValue)
        data += "--\(boundary)\r\n"
        data += "Content-Disposition: form-data; name=\"files[]\"; filename=\"image.jpeg\"\r\n"
        data += "Content-Type: Optional(\"image/jpeg\")\r\n\r\n"
        body.append(data.data_utf8 as Data)
        body.append(NSData(data:UIImageJPEGRepresentation(postData.image, 1.0)!) as Data)
        data = ""
        data += "\r\n"
        data += "--\(boundary)--"
        body.append(data.data_utf8 as Data)
        
        request.headers = headers
        request.bodyData = body as Data
        request.postJson(completion)
    }
}


struct PixivPostImageData {
    var title = ""
    var comment = ""
    var tags = [String]()
    var ageLimit:PixivPostAgeLimit = .allAge
    var sexual:PixivPostSexual = .no
    var type:PixivPostType = .illust
    var publicity:PixivPostPublicity = .public
    var image:UIImage
}

enum PixivPostAgeLimit:String {
    case allAge = "all-age"
    case r18 = "r18"
    case r18g = "r18g"
}
enum PixivPostSexual:Int {
    case yes = 0
    case no = 1
}
enum PixivPostType:String {
    case illust
    case manga
}
enum PixivPostPublicity:String {
    case `public`
    case `private`
}

class HTMLForm: NSObject {
    var data = Data()
}
