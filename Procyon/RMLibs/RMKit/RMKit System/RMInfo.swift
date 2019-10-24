import UIKit


class RMInfo{
    var dict = [String:Any]()
    var `default`:[String:Any] = [:]{
        didSet{
            if !defaults.bool(forKey: "RMInfoDefaultInfoSaved"){
                for key in `default`.keys{
                    defaults.set(`default`[key]!, forKey: key)
                    defaults.set(true, forKey: "RMInfoDefaultInfoSaved")
                }
            }
        }
    }
    let defaults = UserDefaults()

    func setup() {
        for (key,value) in defaults.dictionaryRepresentation(){
            dict[key] = value
        }
    }
    func removeAll() {
        for key in self.dict.keys{
            defaults.removeObject(forKey: key)
        }
        dict = [:]
    }
    func remove(withKey key:String){
        defaults.removeObject(forKey: key)
    }
    func remove(withContainString containString:String){
        for key in self.dict.keys{
            if key == containString{
                defaults.removeObject(forKey: key)
            }
        }
    }
    func remove(withClassName className:String){
        for (key ,value) in self.dict{
            if let value = value as? NSObject{
                if value.className == className{
                    defaults.removeObject(forKey: key)
                }
            }
        }
    }
    //====================================================================================
    //setter
    func set(_ value:Any,forKey defaultName:String){
        dict[defaultName] = value
        asyncQ {self.defaults.set(value, forKey: defaultName)}
    }
    func setStorableArray(_ value:[Storable],forKey defaultName:String){
        dict[defaultName] = value.map{s in s.dict}
        asyncQ {self.defaults.set(value.map{s in s.dict}, forKey: defaultName)}
    }
    func setStruct(_ value:Storable,forKey defaultName:String) {
        dict[defaultName] = value.dict
        asyncQ {self.defaults.set(value.dict, forKey: defaultName)}
    }
    func set(_ value:Storable,forKey defaultName:String) {
        dict[defaultName] = value.dict
        asyncQ {self.defaults.set(value.dict, forKey: defaultName)}
    }
    //====================================================================================
    //getter
    func first(forKey defaultName:String)->Bool{
        if !boolValue(forKey: defaultName){info.set(true, forKey: defaultName)}
        return !boolValue(forKey: defaultName)
    }
    func count(count:Int,forKey defaultName:String)->Bool{
        let tmp = intValue(forKey: defaultName)
        info.set(tmp+1, forKey: defaultName)
        return tmp==count-1
    }
    func `struct`<T:Storable>(type:T.Type,forKey defaultName: String)->T?{
        let tmp = dict[defaultName] as? [String:Any]
        return  tmp == nil ? nil : T(dict: tmp!)
    }
    func structValue<T:Storable>(type:T.Type,forKey defaultName: String)->T{
        return T(dict: dict[defaultName] as? [String:Any] ?? [:])
    }
    func structArray<T:Storable>(type:T.Type,forKey defaultName: String)->[T]{
        return dictArrayValue(forKey: defaultName).map{d in T(dict: d)}
    }
    func object(forKey defaultName: String) -> Any?{
        return dict[defaultName]
    }
    
    func string(forKey defaultName: String) -> String?{
        return dict[defaultName] as? String
    }
    func stringValue(forKey defaultName: String) -> String{
        return dict[defaultName] as? String ?? ""
    }
    
    func array(forKey defaultName: String) -> [Any]?{
        return dict[defaultName] as? [Any]
    }
    func arrayValue(forKey defaultName: String) -> [Any]{
        return dict[defaultName] as? [Any] ?? []
    }
    
    func boolArray(forKey defaultName: String) -> [Bool]?{
        return array(forKey: defaultName) as? [Bool]
    }
    func boolArrayValue(forKey defaultName:String) -> [Bool]{
        return boolArray(forKey: defaultName) ?? []
    }
    
    func dictionary(forKey defaultName: String) -> [String : Any]?{
        return dict[defaultName] as? [String:Any]
    }
    func dictionaryValue(forKey defaultName: String) -> [String : Any]{
        return dictionary(forKey: defaultName) ?? [:]
    }
    
    func dictArray(forKey defaultName: String)->[[String:Any]]?{
        return self.array(forKey: defaultName) as? [[String:Any]]
    }
    func dictArrayValue(forKey defaultName: String)->[[String:Any]]{
        return self.dictArray(forKey: defaultName) ?? []
    }
    
    func data(forKey defaultName: String) -> Data?{
        return dict[defaultName] as? Data
    }

    func stringArray(forKey defaultName: String) -> [String]?{
        return dict[defaultName] as? [String]
    }
    func stringArrayValue(forKey defaultName: String) -> [String]{
        return stringArray(forKey: defaultName) ?? []
    }
    
    func int(forKey defaultName: String) -> Int?{
        return dict[defaultName] as? Int
    }
    func intValue(forKey defaultName:String)->Int{
        return int(forKey: defaultName) ?? 0
    }
    
    func float(forKey defaultName: String) -> Float?{
        return dict[defaultName] as? Float
    }
    func floatValue(forKey defaultName:String)->Float{
        return float(forKey: defaultName) ?? 0
    }
    
    func double(forKey defaultName: String) -> Double?{
        return dict[defaultName] as? Double
    }
    func doubleVlue(forKey defaultName:String)->Double{
        return double(forKey: defaultName) ?? 0
    }
    
    func bool(forKey defaultName: String) -> Bool?{
        return dict[defaultName] as? Bool
    }
    func boolValue(forKey defaultName:String)->Bool{
        return bool(forKey: defaultName) ?? false
    }
    
    func intArray(forKey defaultName:String) -> [Int]?{
        return self.array(forKey: defaultName) as? [Int]
    }
    func intArrayValue(forKey defaultName:String) -> [Int]{
        return intArray(forKey: defaultName) ?? []
    }
    
    func url(forKey defaultName: String) -> URL?{
        return dict[defaultName] as? URL
    }

    func cgFloat(forKey defaultName:String)->CGFloat?{
        return dict[defaultName] as? CGFloat
    }
    func cgFloatValue(forKey defaultName:String)->CGFloat{
        return cgFloat(forKey: defaultName) ?? 0
    }
    
    func contains(_ key:String)->Bool{
        return dict.keys.contains(key)
    }
}

protocol Storable {
    var dict:[String:Any]{get}
    init(dict: [String:Any])
}





