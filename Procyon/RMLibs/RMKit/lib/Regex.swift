import Foundation

class Re {
    static func compile(_ pattern: String, flags: RegexObject.Flag = []) -> RegexObject  {
        return RegexObject(pattern: pattern, flags: flags)
    }
    static func search(_ pattern: String, _ string: String, flags: RegexObject.Flag = []) -> MatchObject? {
        return Re.compile(pattern, flags: flags).search(string)
    }
    static func match(_ pattern: String, _ string: String, flags: RegexObject.Flag = []) -> MatchObject? {
        return Re.compile(pattern, flags: flags).match(string)
    }
    static func split(_ pattern: String, _ string: String, _ maxsplit: Int = 0, flags: RegexObject.Flag = []) -> [String] {
        return Re.compile(pattern, flags: flags).split(string, maxsplit).map{v in
            return v ?? ""
        }
    }
    static func findall(_ pattern: String, _ string: String, flags: RegexObject.Flag = []) -> [String] {
        return Re.compile(pattern, flags: flags).findall(string)
    }
    static func finditer(_ pattern: String, _ string: String, flags: RegexObject.Flag = []) -> [MatchObject] {
        return Re.compile(pattern, flags: flags).finditer(string)
    }
    static func sub(_ pattern: String, _ repl: String, _ string: String, _ count: Int = 0, flags: RegexObject.Flag = []) -> String {
        return Re.compile(pattern, flags: flags).sub(repl, string, count)
    }
    static func subn(_ pattern: String, _ repl: String, _ string: String, _ count: Int = 0, flags: RegexObject.Flag = []) -> (String, Int) {
        return Re.compile(pattern, flags: flags).subn(repl, string, count)
    }
    class RegexObject {
        typealias Flag = NSRegularExpression.Options
        var isValid: Bool {
            return regex != nil
        }
        
        let pattern: String
        
        private let regex: NSRegularExpression?
        var nsRegex: NSRegularExpression? {
            return regex
        }
        var flags: Flag {
            return regex?.options ?? []
        }
        var groups: Int {
            return regex?.numberOfCaptureGroups ?? 0
        }
        required init(pattern: String, flags: Flag = [])  {
            self.pattern = pattern
            do {
                self.regex = try NSRegularExpression(pattern: pattern, options: flags)
            } catch let error as NSError {
                self.regex = nil
                debugPrint(error)
            }
        }
        func search(_ string: String, _ pos: Int = 0, _ endpos: Int? = nil, options: NSRegularExpression.MatchingOptions = []) -> MatchObject? {
            guard let regex = regex else {
                return nil
            }
            let start = pos > 0 ?pos :0
            let end = endpos ?? string.utf16.count
            let length = max(0, end - start)
            let range = NSRange(location: start, length: length)
            if let match = regex.firstMatch(in: string, options: options, range: range) {
                return MatchObject(string: string, match: match)
            }
            return nil
        }
        func match(_ string: String, _ pos: Int = 0, _ endpos: Int? = nil) -> MatchObject? {
            return search(string, pos, endpos, options: [.anchored])
        }
        func split(_ string: String, _ maxsplit: Int = 0) -> [String?] {
            guard let regex = regex else {
                return []
            }
            var splitsLeft = maxsplit == 0 ? Int.max : (maxsplit < 0 ? 0 : maxsplit)
            let range = NSRange(location: 0, length: string.utf16.count)
            var results = [String?]()
            var start = string.startIndex
            var end = string.startIndex
            regex.enumerateMatches(in: string, options: [], range: range) { result, _, stop in
                if splitsLeft <= 0 {
                    stop.pointee = true
                    return
                }
                
                guard let result = result, result.range.length > 0 else {
                    return
                }
                
                end = string.characters.index(string.startIndex, offsetBy: result.range.location)
                results.append(string[start..<end])
                if regex.numberOfCaptureGroups > 0 {
                    results += MatchObject(string: string, match: result).groups()
                }
                splitsLeft -= 1
                start = string.index(end, offsetBy: result.range.length)
            }
            if start <= string.endIndex {
                results.append(string[start..<string.endIndex])
            }
            return results
        }
        func findall(_ string: String, _ pos: Int = 0, _ endpos: Int? = nil) -> [String] {
            return finditer(string, pos, endpos).map { $0.group() }
        }
        func finditer(_ string: String, _ pos: Int = 0, _ endpos: Int? = nil) -> [MatchObject] {
            guard let regex = regex else {
                return []
            }
            let start = pos > 0 ?pos :0
            let end = endpos ?? string.utf16.count
            let length = max(0, end - start)
            let range = NSRange(location: start, length: length)
            return regex.matches(in: string, options: [], range: range).map { MatchObject(string: string, match: $0) }
        }
        func sub(_ repl: String, _ string: String, _ count: Int = 0) -> String {
            return subn(repl, string, count).0
        }
        func subn(_ repl: String, _ string: String, _ count: Int = 0) -> (String, Int) {
            guard let regex = regex else {
                return (string, 0)
            }
            let range = NSRange(location: 0, length: string.utf16.count)
            let mutable = NSMutableString(string: string)
            let maxCount = count == 0 ? Int.max : (count > 0 ? count : 0)
            var n = 0
            var offset = 0
            regex.enumerateMatches(in: string, options: [], range: range) { result, _, stop in
                if maxCount <= n {
                    stop.pointee = true
                    return
                }
                if let result = result {
                    n += 1
                    let resultRange = NSRange(location: result.range.location + offset, length: result.range.length)
                    let lengthBeforeReplace = mutable.length
                    regex.replaceMatches(in: mutable, options: [], range: resultRange, withTemplate: repl)
                    offset += mutable.length - lengthBeforeReplace
                }
            }
            return (mutable as String, n)
        }
    }
    final class MatchObject {
        let string: String
        let match: NSTextCheckingResult
        
        init(string: String, match: NSTextCheckingResult) {
            self.string = string
            self.match = match
        }
        func expand(_ template: String) -> String {
            guard let regex = match.regularExpression else {
                return ""
            }
            return regex.replacementString(for: match, in: string, offset: 0, template: template)
        }
        func group(_ index: Int = 0) -> String {
            guard let range = span(index), range.lowerBound < string.endIndex else {
                return ""
            }
            return string[range]
        }
        func group(_ indexes: [Int]) -> [String?] {
            return indexes.map { group($0) }
        }
        func groups(_ defaultValue: String) -> [String] {
            return (1..<match.numberOfRanges).map { group($0)}
        }
        func groups() -> [String?] {
            return (1..<match.numberOfRanges).map { group($0) }
        }
        func span(_ index: Int = 0) -> Range<String.Index>? {
            if index >= match.numberOfRanges {
                return nil
            }
            let nsrange = match.rangeAt(index)
            
            if nsrange.location == NSNotFound {
                return string.endIndex..<string.endIndex
            }
            let startIndex16 = string.utf16.startIndex.advanced(by: nsrange.location)
            let endIndex16 = startIndex16.advanced(by: nsrange.length)
            return (String.Index(startIndex16, within: string) ?? string.endIndex)..<(String.Index(endIndex16, within: string) ?? string.endIndex)
        }
    }
}
