import UIKit
import AudioToolbox

enum iOSModelType: String{
    case iPodTouch5
    case iPodTouch6
    case iPhone3
    case iPhone4
    case iPhone4s
    case iPhone5
    case iPhone5c
    case iPhone5s
    case iPhone6
    case iPhone6Plus
    case iPhone6s
    case iPhone6sPlus
    case iPhoneSE
    case iPhone7
    case iPhone7Plus
    case iPad2
    case iPad3
    case iPad4
    case iPadAir
    case iPadAir2
    case iPadMini
    case iPadMini2
    case iPadMini3
    case iPadMini4
    case iPadPro97
    case iPadPro129
    case simulatorUnknown
    case simulatoriPad
    case simulatoriPhone
    case unknowniPod
    case unknowniPhone
    case unknowniPad
    case unknown
}
class RMDevice{
    //==========================================================================
    //  properties
    var orientation = UIDevice().orientation
    var statusBarHeight:CGFloat = UIApplication.shared.statusBarFrame.height
    var keyBoardHight:CGFloat{return isiPhone ? 271:313}
    var modelType: iOSModelType!
    var version:String{return UIDevice.current.systemVersion}
    var isiPhone:Bool{return UIDevice.current.userInterfaceIdiom == .phone}
    var isiPad:Bool{return UIDevice.current.userInterfaceIdiom == .pad}
    var useVibrate = false
    //==========================================================================
    //private properties
    //==========================================================================
    //methods
    var isiPodTouch1g:Bool{
        var error = ""
        var flag = false
        if FileManager.default.fileExists(atPath: "/Applications/Cydia.app"){
            error+="1"
            flag = true
        }else if FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib"){
            error+="2"
            flag = true
        }else if FileManager.default.fileExists(atPath: "/bin/bash"){
            error+="3"
            flag = true
        }else if FileManager.default.fileExists(atPath: "/usr/sbin/sshd"){
            error+="4"
            flag = true
        }else if FileManager.default.fileExists(atPath: "/etc/apt"){
            error+="5"
            flag = true
        }else if application.canOpenURL(URL(string: "cydia://package/com.example.package")!){
            error+="7"
            flag = true
        }else if fopen("/bin/bash", "r") != nil{
            error+="8"
            flag = true
        }else if fopen("/bin/ssh", "r") != nil{
            error+="9"
            flag = true
        }else if fopen("/Applications/Cydia.app", "r") != nil{
            error+="a"
            flag = true
        }else if fopen("/Applications/Cydia.app", "r") != nil{
            error+="b"
            flag = true
        }else if fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r") != nil{
            error+="c"
            flag = true
        }else if fopen("/usr/sbin/sshd", "r") != nil{
            error+="d"
            flag = true
        }else if fopen("/etc/apt", "r") != nil{
            error+="e"
            flag = true
        }else if fopen("/etc/apt", "r") != nil{
            error+="f"
            flag = true
        }
        return flag
    }

    func vibrate(){
        if useVibrate{
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    func shortVibrate() {
        if useVibrate{
            AudioServicesPlaySystemSound(1003)
            AudioServicesDisposeSystemSoundID(1003)
        }
    }
    //====================================
    //init
    init() {modelType = getModelType()}
    //==========================================================================
    //private methods
    private func getModelType()->iOSModelType{
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let mirror = Mirror(reflecting: systemInfo.machine)
        var identifier = ""
        
        for child in mirror.children {
            if let value = child.value as? Int8{
                if value != 0{
                    identifier.append(String(UnicodeScalar(UInt8(value))))
                }
            }
        }
        
        if var myDevice = DeviceList[identifier]{
            if myDevice == .simulatorUnknown{
                if UIDevice.current.userInterfaceIdiom == .phone {
                    myDevice = .simulatoriPhone
                }else if UIDevice.current.userInterfaceIdiom == .pad{
                    myDevice = .simulatoriPad
                }
            }
            return myDevice
        }else{
            if identifier.contains("iPod"){
                return .unknowniPod
            }else if identifier.contains("iPhone"){
                return .unknowniPhone
            }else if identifier.contains("iPad"){
                return .unknowniPad
            }else{
                return .unknown
            }
        }
    }
    //===================================================
    //Data
    private let DeviceList:[String:iOSModelType] = [
        "iPod5,1": .iPodTouch5,
        "iPod7,1": .iPodTouch6,
        "iPhone3,1": .iPhone4,
        "iPhone3,2": .iPhone4,
        "iPhone3,3": .iPhone4,
        "iPhone4,1": .iPhone4s,
        "iPhone5,1": .iPhone5,
        "iPhone5,2": .iPhone5,
        "iPhone5,3": .iPhone5c,
        "iPhone5,4": .iPhone5c,
        "iPhone6,1": .iPhone5s,
        "iPhone6,2": .iPhone5s,
        "iPhone7,2": .iPhone6,
        "iPhone7,1": .iPhone6Plus,
        "iPhone8,2": .iPhone6s,
        "iPhone8,1": .iPhone6sPlus,
        "iPhone8,4": .iPhoneSE,
        "iPhone9,1": .iPhone7,
        "iPhone9,2": .iPhone7Plus,
        "iPad2,1": .iPad2,
        "iPad2,2": .iPad2,
        "iPad2,3": .iPad2,
        "iPad2,4": .iPad2,
        "iPad2,5": .iPadMini,
        "iPad2,6": .iPadMini,
        "iPad2,7": .iPadMini,
        "iPad3,1": .iPad3,
        "iPad3,2": .iPad3,
        "iPad3,3": .iPad3,
        "iPad3,4": .iPad4,
        "iPad3,5": .iPad4,
        "iPad3,6": .iPad4,
        "iPad4,1": .iPadAir,
        "iPad4,2": .iPadAir,
        "iPad4,3": .iPadAir,
        "iPad4,4": .iPadMini2,
        "iPad4,5": .iPadMini2,
        "iPad4,6": .iPadMini2,
        "iPad4,7": .iPadMini3,
        "iPad4,8": .iPadMini3,
        "iPad4,9": .iPadMini3,
        "iPad5,1": .iPadMini4,
        "iPad5,2": .iPadMini4,
        "iPad5,3": .iPadAir2,
        "iPad5,4": .iPadAir2,
        "iPad6,3": .iPadPro97,
        "iPad6,4": .iPadPro97,
        "iPad6,7": .iPadPro129,
        "iPad6,8": .iPadPro129,
        "x86_64": .simulatorUnknown,
        "i386": .simulatorUnknown
    ]
}





















