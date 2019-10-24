import Foundation

enum RMDateFormatType: String{
    case ISO8601 = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
    case short = "yyyy/MM/dd"
    case long = "yyyy/MM/dd HH:mm:ss"
}

class RMDate{
    private var date = Date()
    var format = "yyyy/MM/dd HH:mm:ss"
    func set(_ dateStr:String,withFormat format:String = "yyyy/MM/dd HH:mm:ss"){
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = format
        self.date = formatter.date(from: dateStr)!
    }
    func set(_ dateStr:String,withType type:RMDateFormatType){
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = type.rawValue
        self.date = formatter.date(from: dateStr) ?? Date()
    }
    init(dateStr:String,withType type:RMDateFormatType) {
        self.set(dateStr, withType: type)
    }
    init(dateStr:String,withFormat format:String) {
        self.set(dateStr, withFormat: format)
    }
    func get(withFormat format:String = "yyyy/MM/dd HH:mm:ss")->String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    func get(withType type:RMDateFormatType)->String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = type.rawValue
        return formatter.string(from: date)
    }
}

extension RMDate: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    var description: String {
        return self.get(withFormat: format)
    }
    var debugDescription: String {
        return description
    }
}
