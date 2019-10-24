import UIKit
//import HTML

class RMRequest {
    //====================================================================
    //public properties
    var url:URL? = nil
    var headers:[String:String] = [:]
    var referer:String? = nil
    var userAgent:UserAgentType? = nil
    var bodyParam:[String:Any] = [:]
    var bodyData:Data? = nil
    var bodyStr:String? = nil
    var sync = false
    var rawRequest:URLRequest?{
        return createRequest() as URLRequest?
    }
    var imageCacheKey:String{
        return url?.absoluteString ?? ""
    }
    var method = HTTPMethod.get
    static var simultaneouslyRunMaxCount = 10
    //====================================================================
    //private properties
    private let connection = RMConnection()
    
    enum HTTPMethod {
        case post
        case get
        case delete
        case put
        case head
    }
    enum UserAgentType:String{
        case iPhone = "Mozilla/5.0 (iPhone; CPU iPhone OS 9_3_2 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13F69"
        case iPad = "Mozilla/5.0 (iPad; CPU iPad OS 9_3_2 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13F69"
        case mac = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0.2 Safari/602.3.12"
        case windowns = "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; NP06; rv:11.0) like Gecko"
        case android = "Mozilla/5.0 (Linux; U; Android 2.2.1; en-us; Nexus One Build/FRG83) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533."
    }
    //====================================================================
    //public func
    //==================================
    //getJson
    func getJson(_ progress: @escaping floatBlock,_ completion:@escaping jsonBlock){
        self.get(progress,{data in completion(data.json)})
    }
    func getJson(_ completion:@escaping jsonBlock){
        self.get{data in completion(data.json)}
    }
    //==================================
    //postJson
    func postJson(_ progress:@escaping floatBlock ,_ completion:@escaping jsonBlock){
        self.post(progress,{data in completion(data.json)})
    }
    func postJson(_ completion:@escaping jsonBlock){
        self.post{data in completion(data.json)}
    }
    //==================================
    //getHTML
    /*func getHTML(_ progress:@escaping floatBlock,_ completion:@escaping (HTML)->()){
        self.post(progress,{data in completion(data.html)})
    }
    func getHTML(_ completion:@escaping (HTML)->()){
        self.post{data in completion(data.html)}
    }*/
    //==================================
    //getImage
    func getImage(_ progress: @escaping floatBlock,_ completion:@escaping imageBlock){
        guard let url = url else {return}
        if let image = cache.image(forKey: url.absoluteString) {
            completion(image)
        }else{
            self.get(progress,{data in
                if let image = UIImage(data: data){
                    cache.set(image, forKey: url.absoluteString)
                    completion(image)
                }
            })
        }
    }
    func getImage(_ completion:@escaping imageBlock){
        guard let url = url else {return}
        if let image = cache.image(forKey: url.absoluteString) {
            completion(image)
        }else{
            self.get({data in
                if let image = UIImage(data: data){
                    cache.set(image, forKey: url.absoluteString)
                    completion(image)
                }
            })
        }
    }
    //==================================
    //getHeader
    func getHeader(_ completion:@escaping ([String:Any])->()){
        self.method = .get
        self.send(nil, {_ in}, headerBlock: completion)
    }
    //==================================
    //postHeader
    func postHeader(_ completion:@escaping ([String:Any])->()){
        self.method = .post
        self.send(nil, {_ in}, headerBlock: completion)
    }
    //==================================
    //get
    func get(_ progress:@escaping floatBlock,_ completion:@escaping dataBlock){
        self.method = .get
        self.send(progress, completion)
    }
    func get(_ completion:@escaping dataBlock){
        self.method = .get
        self.send(nil, completion)
    }
    //==================================
    //post
    func post(_ progress: floatBlock? = nil,_ completion:@escaping dataBlock = {_ in}){
        self.method = .post
        self.send(progress, completion)
    }
    func post(_ completion:@escaping dataBlock = {_ in}){
        self.method = .post
        self.send(nil, completion)
    }
    //====================================================================
    //init
    init(_ url:URL?){
        self.url = url
    }
    //====================================================================
    //private func
    private func send(_ progress: floatBlock? = nil,_ completion: @escaping dataBlock,headerBlock:@escaping ([String:Any])->() = {_ in}){
        guard let request = createRequest() else {return}
        if sync{
            completion(connection.sendSync(withRequest: request))
        }else{
            connection.send(withRequest: request, completion: completion, progress: progress,headerBlock: headerBlock)
        }
    }
    private func createRequest()->NSMutableURLRequest?{
        guard let url = url else {debugPrint("RMRequest ERROR: url is void or nil");return nil}
        var body = Data()
        if bodyParam.count != 0{
            body.append(makeData())
        }
        if let data = bodyData{
            body.append(data)
        }
        if let data = bodyStr{
            body.append(data.data_utf8)
        }
        if let referer = referer{
            headers["Referer"] = referer
        }
        if let userAgent = userAgent{
            headers["User-Agent"] = userAgent.rawValue
        }
        headers["Content-Length"] = "\([UInt8](body).count)"
        let request = NSMutableURLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        switch method {
        case .get:
            request.httpMethod = "GET"
        case .delete:
            request.httpMethod = "DELETE"
        case .post:
            request.httpMethod = "POST"
        case .put:
            request.httpMethod = "PUT"
        case .head:
            request.httpMethod = "HEAD"
        }
        return request
    }
    private func makeData()->Data{
        var dataString = ""
        for (key ,value) in bodyParam{
            dataString += "\(key)=\(value)&"
        }
        return dataString.removeLast().data_utf8
    }
}

extension RMRequest: CustomStringConvertible{
    var description: String{
        var string = ""
        if let url = url{
            string+="Url: \(url)\n"
        }
        string+="headers: [\n"
        headers.map{(key,value) in string+="    \(key): \(value)\n"}
        string+="]\n"
        string+="bodyParamators: [\n"
        bodyParam.map{(key,value) in string+="    \(key): \(value)\n"}
        string+="]\n"
        if let bodyData = bodyData{
            string+="bodyData\(bodyData)\n"
        }
        return string.removeLast()
    }
}

fileprivate class RMConnection: NSObject{
    func send(withRequest request:NSMutableURLRequest,completion:@escaping dataBlock,progress: floatBlock? = nil,headerBlock:@escaping ([String:Any])->() = {_ in}){
        if progress != nil{
            let helper = RMConnectionHelper(request: request, completion: completion, progress: progress!)
            helper.sendRequest()
        }else{
            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: .main, completionHandler: {res,data,error in
                if let response = res as? HTTPURLResponse{
                    var headers = [String:Any]()
                    response.allHeaderFields.map{(k,v) in headers["\(k)"]=v}
                    headerBlock(headers)
                }
                if let data = data{completion(data)}else{debugPrint("RMRequest ERROR: data is nil")}
            })
        }
    }
    func sendSync(withRequest request:NSMutableURLRequest)->Data{
        do{
            return try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: nil)
        }catch{
            return Data()
        }
    }
}


fileprivate class RMConnectionHelper:NSObject,URLSessionDownloadDelegate{
    
    private var completion:dataBlock
    private var progress:floatBlock
    private var request:NSMutableURLRequest!
    private var tryCount = 0
    
    init(request:NSMutableURLRequest,completion:@escaping dataBlock,progress:@escaping floatBlock) {
        
        self.request = request
        self.completion = completion
        self.progress = progress
        
        super.init()
    }
    fileprivate func sendRequest(){
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        let task = session.downloadTask(with: request as URLRequest)
        
        task.resume()
    }
    
    @objc func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let data = try? Data(contentsOf: location)
        if data != nil{
            self.completion(data!)
            completion = {_ in}
            progress = {_ in}
            request = nil
        }else{
            
            if tryCount < 10 {
                debugPrint("RMRequest ERROR: data is nil call next data")
                self.sendRequest()
            }else{
                debugPrint("RMRequest ERROR: you send a request for 10 time. but not data could dowonload.")
            }
            tryCount+=1
        }
    }
    
    @objc func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
        ){
        progress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite))
    }
}





























