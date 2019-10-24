import UIKit
//===============================================================================
//grobal properties
let π = CGFloat(M_PI)
//===============================================================================
//precedencegroup
precedencegroup Base {
    associativity: left
    lowerThan: AdditionPrecedence
}

postfix operator <-!

postfix func <-! (lhs: inout Bool){
    lhs = !lhs
}


//======================================
//String * Int -> String
func * (lhs: String, rhs: Int)->String{
    var tmp = ""
    for _ in 0..<rhs {
        tmp += lhs
    }
    return tmp
}
//======================================
//CGSize + CGSize -> CGSize
func + (lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width+rhs.width, height: lhs.height+rhs.height)
}

//======================================
//CGSize - CGSize -> CGSize
func - (lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width-rhs.width, height: lhs.height-rhs.height)
}

//======================================
//CGSize * ... -> CGSize

func * (lhs: CGSize, rhs: Double) -> CGSize {
    return CGSize(width: lhs.width*CGFloat(rhs), height: lhs.height*CGFloat(rhs))
}
func * (lhs: CGSize, rhs: Int) -> CGSize {
    return CGSize(width: lhs.width*CGFloat(rhs), height: lhs.height*CGFloat(rhs))
}
func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width*rhs, height: lhs.height*rhs)
}
func *= (lhs: inout CGSize, rhs: Double){
    lhs = CGSize(width: lhs.width*CGFloat(rhs), height: lhs.height*CGFloat(rhs))
}
func *= (lhs: inout CGSize, rhs: CGFloat){
    lhs = CGSize(width: lhs.width*rhs, height: lhs.height*rhs)
}


func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    if lhs != nil && rhs != nil{
        return lhs! < rhs!
    }
    return false
}

func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    if lhs != nil && rhs != nil{
        return lhs! > rhs!
    }
    return false
}






















