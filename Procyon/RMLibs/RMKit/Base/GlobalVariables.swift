import UIKit
import HTML

//==========================================================================
//Global Variables
let audioManager = RMAudioManager()
let device = RMDevice()
let screen = UIScreen()
let application = UIApplication.shared
let notificationCenter = NotificationCenter.default
let cache =  RMCache()
let info = RMInfo()
let net = RMNet(hostname: "RMNet")!
let clipBoard = RMClipBoard()
let file = RMFile()
let runCounter = RMRunCounter()
let store = RMStoreManager()
let system = RMSystem()

//==========================================================================
//Global Typealias

typealias Size = CGSize
typealias Color = UIColor
typealias Point = CGPoint
typealias UIAlert = UIAlertController
typealias voidBlock = ()->()
typealias boolBlock = (Bool)->()
typealias intBlock = (Int)->()
typealias stringBlock = (String)->()
typealias floatBlock = (Float)->()
typealias cgFloatBlock = (CGFloat)->()
typealias dataBlock = (Data)->()
typealias imageBlock = (UIImage)->()
typealias jsonBlock = (JSON)->()
//typealias htmlBlock = (HTML)->()
