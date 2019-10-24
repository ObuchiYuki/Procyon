//==========================================================================
//Global Functions
//結構 Usefull
import UIKit

//==========================================================================
//you can run an async block
func asyncQ(_ block:@escaping voidBlock){
    DispatchQueue.global(qos: .default).async(execute: block)
}
//==========================================================================
//you can run a sync block
//call when you have to change UI from async block
func mainQ(_ block:@escaping voidBlock){
    DispatchQueue.mainSyncSafe(execute: block)
}
//==========================================================================
//you can run a block with dely
func runInNextLoop(_ block:@escaping voidBlock){
    run(after: 0.001, block: block)
}
func analyze(_ block:voidBlock){
    let start = Date()
    
    block()
    
    let elapsed = Date().timeIntervalSince(start)
    debugPrint("run block end. time: \(elapsed)")
}
func runAfter(_ delay:Double,block: @escaping voidBlock){
    run(after: delay, block: block)
}
func run(after delay:Double,block: @escaping voidBlock){
    if delay == 0{
        block()
    }else{
        RMTimer().startStopWatch(delay, endAction: block)
    }
}
func random(_ range:CountableClosedRange<Int>)->Int{
    return Int(arc4random_uniform(UInt32(range.upperBound-range.lowerBound+1)))+range.lowerBound
}

func reachable()->Bool{
    return net.isReachable
}
func print(after delay: Double ,_ block: @escaping ()->(Any?)){
    run(after: delay, block: {
        debugPrint(block() ?? "nil")
    })
}
//==========================================================================
//this function show class name and all propaties of object.
//use to check error.
func ERROR(_ fromClass:NSObject){
    debugPrint("className: \(fromClass.className) \n \(fromClass.propaties)")
}

func dateMake(string: String,format: String)->Date?{
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.dateFormat = format
    return dateFormatter.date(from: string)
}

func pointMake(_ x:CGFloat,_ y:CGFloat)->CGPoint{
    return CGPoint(x: x, y: y)
}
func pointMake(_ x:Int,_ y:Int)->CGPoint{
    return CGPoint(x: x, y: y)
}
func pointMake(_ x:Double,_ y:Double)->CGPoint{
    return CGPoint(x: x, y: y)
}
func pointMake(_ x:Float,_ y:Float)->CGPoint{
    return CGPoint(x: CGFloat(x), y: CGFloat(y))
}

func sizeMake(_ width:CGFloat,_ height:CGFloat)->CGSize{
    return CGSize(width: width, height: height)
}
func sizeMake(_ width:Int,_ height:Int)->CGSize{
    return CGSize(width: width, height: height)
}
func sizeMake(_ width:Double,_ height:Double)->CGSize{
    return CGSize(width: width, height: height)
}
func sizeMake(_ width:Float,_ height:Float)->CGSize{
    return CGSize(width: CGFloat(width), height: CGFloat(height))
}

func boolValue(of item: Any?)->Bool{
    return item as? Bool ?? false
}
func intValue(of item: Any?)->Int{
    return item as? Int ?? 0
}
func floatValue(of item: Any?)->Float{
    return item as? Float ?? 0
}
func doubleValue(of item: Any?)->Double{
    return item as? Double ?? 0.0
}
func stringValue(of item: Any?)->String{
    return item as? String ?? ""
}
func arrayValue(of item: Any?)->[Any]{
    return item as? [Any] ?? []
}
func boolArrayVlue(of item:Any?)->[Bool]{
    return item as? [Bool] ?? []
}
func intArrayValue(of item:Any?)->[Int]{
    return item as? [Int] ?? []
}
func stringArrayValue(of item:Any?)->[String]{
    return item as? [String] ?? []
}
func dictValue(of item:Any?)->[String:Any]{
    return item as? [String:Any] ?? [:]
}
func dictArrayValue(of item:Any?)->[[String:Any]]{
    return item as? [[String:Any]] ?? []
}




























