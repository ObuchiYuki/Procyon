import UIKit

class RMCache{
    private let cache = NSCache<AnyObject, AnyObject>()
    
    func removeAll(completion:@escaping voidBlock) {
        asyncQ {
            self.cache.removeAllObjects()
            mainQ(completion)
        }
    }
    func remove(forKey defaultName:String){
        cache.removeObject(forKey: defaultName as AnyObject)
    }
    
    func set(_ value: Any?, forKey defaultName: String){
        cache.setObject(value as AnyObject, forKey: defaultName as AnyObject)
    }
    
    func set(_ value: Int, forKey defaultName: String){
        cache.setObject(value as AnyObject, forKey: defaultName as AnyObject)
    }
    
    func set(_ value: Float, forKey defaultName: String){
        cache.setObject(value as AnyObject, forKey: defaultName as AnyObject)
    }
    
    func set(_ value: Double, forKey defaultName: String){
        cache.setObject(value as AnyObject, forKey: defaultName as AnyObject)
    }
    
    func set(_ value: Bool, forKey defaultName: String){
        cache.setObject(value as AnyObject, forKey: defaultName as AnyObject)
    }
    
    func set(_ url: URL?, forKey defaultName: String){
        cache.setObject(url as AnyObject, forKey: defaultName as AnyObject)
    }
    func set(_ image: UIImage?, forKey defaultName: String){
        cache.setObject(image as AnyObject, forKey: defaultName as AnyObject)
    }
    
    
    
    func string(forKey defaultName: String) -> String?{
        return cache.object(forKey: defaultName as AnyObject) as? String
    }
    func stringValue(forKey defaultName:String)->String{
        return self.string(forKey: defaultName) ?? ""
    }
    
    func array(forKey defaultName: String) -> [Any]?{
        return cache.object(forKey: defaultName as AnyObject) as? [Any]
    }
    func arrayValue(forKey defaultName:String)->[Any]{
        return self.array(forKey: defaultName) ?? []
    }
    
    
    func dictionary(forKey defaultName: String) -> [String : Any]?{
        return cache.object(forKey: defaultName as AnyObject) as? [String : Any]
    }
    func dictionaryValue(forKey defaultName:String)->[String:Any]{
        return self.dictionary(forKey: defaultName) ?? [:]
    }
    
    func data(forKey defaultName: String) -> Data?{
        return cache.object(forKey: defaultName as AnyObject) as? Data
    }
    
    func stringArray(forKey defaultName: String) -> [String]?{
        return cache.object(forKey: defaultName as AnyObject) as? [String]
    }
    func stringArrayValue(forKey defaultName:String)->[String]{
        return self.stringArray(forKey: defaultName) ?? []
    }
    
    func int(forKey defaultName: String) -> Int?{
        return cache.object(forKey: defaultName as AnyObject) as? Int
    }
    func intValue(forKey defaultName: String) -> Int{
        return self.int(forKey: defaultName) ?? 0
    }
    
    func float(forKey defaultName: String) -> Float?{
        return cache.object(forKey: defaultName as AnyObject) as? Float
    }
    func floatValue(forKey defaultName:String)->Float{
        return self.float(forKey: defaultName) ?? 0
    }
    
    func double(forKey defaultName: String) -> Double?{
        return cache.object(forKey: defaultName as AnyObject) as? Double
    }
    func doubleValue(forKey defaultName:String)->Double{
        return self.double(forKey: defaultName) ?? 0
    }
    
    func bool(forKey defaultName: String) -> Bool?{
        return cache.object(forKey: defaultName as AnyObject) as? Bool
    }
    func boolValue(forKey defalutName:String)->Bool{
        return self.bool(forKey: defalutName) ?? false
    }
    
    func url(forKey defaultName: String) -> URL?{
        return cache.object(forKey: defaultName as AnyObject) as? URL
    }
    func image(forKey defaultName: String) -> UIImage?{
        guard let image = cache.object(forKey: defaultName as AnyObject) as? UIImage else {
            return nil
        }
        return image
    }
}

extension RMCache:AnyObject{}
