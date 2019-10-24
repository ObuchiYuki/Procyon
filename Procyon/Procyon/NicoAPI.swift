/*import UIKit
import HTML

let nico = NicoAPI()

class NicoAPI{
    private var headers = [
        "Accept": "*++++*",
        "Connection": "keep-alive",
        "Cookie": "image_search_sort=comment_created; target=illust; user_session=user_session_31109455_02fd4e6d3ff4c1b7b20b51f274ce025f47b813a5134b3432474e12333c38940b; nicosid=1486308888.1105273219",
        "User-Agent": "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_3; ja-jp) AppleWebKit/533.16 (KHTML, like Gecko) Version/5.0 Safari/533.16",
        "Accept-Language": "ja-jp",
        "Referer": "http://seiga.nicovideo.jp/",
        "Accept-Encoding": "gzip, deflate",
    ]
    private let loginHeaders = [
        "Content-Type": "application/x-www-form-urlencoded",
        "Connection": "keep-alive",
        "Accept": "*++++*",
        "Cookie": "user_session=user_session_31109455_7fdb636aa408918080d2bb9e599691d29293249abdb42ca37769bb5144d95a0e; user_session_secure=MzExMDk0NTU6TGhmRGxQTm1GRkpyNUJjY1ZTVXguZGNjSFBYbHlXU3cyaEZHS3pheElHRw; nicosid=1486308888.1105273219",


        "User-Agent": "Illustail/2.9.9.2 CFNetwork/808.2.16 Darwin/16.3.0",
        "Accept-Language": "ja-jp",
        "Accept-Encoding": "gzip, deflate"
    ]
    private var cookies = [String:String]()
    enum SearchSorType:String {//_aは逆
        case image_created
        case image_created_a
        case comment_created
        case comment_created_a
        case clip_created
        case clip_created_a
        case image_view
        case image_view_a
        case comment_count
        case comment_count_a
        case clip_count
        case clip_count_a
    }
    func login(mail:String,pass:String,completion:@escaping voidBlock){
        let request =  "http://secure.nicovideo.jp/secure/login?site=seiga".request
        request.headers = loginHeaders
        request.bodyParam = ["mail":mail.encodedForURL,"password":pass.encodedForURL,"next_url":"/".encodedForURL]
        request.postHeader{headers in
            print(headers)
        }
    }
    func search(word:String,sort:SearchSorType,page:Int,completion:@escaping htmlBlock){
        "http://seiga.nicovideo.jp/tag/\(word)?sort=\(sort.rawValue)&page=\(page)".encodedForURL.request.getHTML(completion)
    }
}
*/
