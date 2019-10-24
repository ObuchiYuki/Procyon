import Foundation

enum RMURLProtocolType: String{
    case https
    case http
    case ftp
}

class RMURL{
    var rawUrl:URL?{
        return createURL()
    }
    
    var string:String{
        return createString()
    }
    
    var `protocol`:RMURLProtocolType = .http
    var domain = ""
    var directory = ""
    var params = [String:Any]()
    
    private func createURL()->URL?{
        return URL(string: createString())
    }
    private func createString()->String{
        var rawString = ""
        rawString+=self.protocol.rawValue+"://"
        rawString+=domain
        rawString+=directory
        if !params.isEmpty{
            rawString+="?"
            for (key,value) in params{
                rawString+="\(key)=\(value)&"
            }
            rawString = rawString.removeLast()
        }
        return rawString
    }
    
    init(string:String){
        let first = string.split("://")
        self.protocol = RMURLProtocolType(rawValue: (first.index(0) ?? "")) ?? .http
        let splitedUrl = (first.index(1) ?? "").split("?")
        domain = splitedUrl[0].split("/").index(0) ?? ""
        directory = splitedUrl[0].remove(domain)
        if let paramsStr = splitedUrl.index(1){
            let paramsStrs = paramsStr.split("&")
            for param in paramsStrs{
                let key = param.split("=").index(0) ?? ""
                let value = param.split("=").index(1) ?? ""
                self.params[key] = value
            }
        }
    }
    init(){}
}
