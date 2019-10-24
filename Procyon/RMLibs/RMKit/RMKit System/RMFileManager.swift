import Foundation
import Zip

class RMFile: NSObject {
    enum Dir {
        case document
        case tmp
        case cache
        func raw()->String{
            switch self {
            case .document:
                return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).index(0) ?? ""
            case .tmp:
                return NSTemporaryDirectory()
            case .cache:
                return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).index(0) ?? ""
            }
        }
    }
    
    private let fileManager = FileManager.default
    var unZipToRemove = true
    
    func rm(_ url:URL){
        do{
            try fileManager.removeItem(atPath: url.absoluteString)
        }catch{
            return
        }
    }
    func rm(_ name:String="",atPath path:Dir = .document){
        do{
            try fileManager.removeItem(atPath: "\(path.raw())/\(name)")
        }catch{
            return
        }
    }
    func mkdir(_ name:String,atPath path:Dir = .document)->URL?{
        do{
            let path = "\(path.raw())/\(name)"
            try fileManager.createDirectory(at: path.url! as URL, withIntermediateDirectories: true, attributes: nil)
            return path.url! as URL
        }catch{
            debugPrint(error)
            return nil
        }
    }
    func mkFile(_ name:String,contents:Data ,atPath path:Dir = .document)->URL{
        let path = "\(path.raw())/\(name)"
        fileManager.createFile(atPath: path, contents: contents, attributes: nil)
        return path.url! as URL
    }
    func ls(atPath path:Dir = .document)->[String]{
        return try! fileManager.contentsOfDirectory(atPath: path.raw())
    }
    func unZip(_ identifier:String,contents:Data,completion:@escaping (String?)->()){
        asyncQ{
            /*do{
                let destinationURL = try Zip.quickUnzipFile(self.mkFile("\(identifier)Data.zip", contents: contents))
                if self.unZipToRemove{_=self.rm("\(identifier)Data.zip")}
                mainQ{completion(destinationURL.path+"/")}
            }catch{
                debugPrint(error)
                completion(nil)
            }*/
        }
    }
}
