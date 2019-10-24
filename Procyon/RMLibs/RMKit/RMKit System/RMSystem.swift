import UIKit

@objc protocol RMAppDelegate {
    @objc optional func appLuanch()
    @objc optional func appEnd()
    @objc optional func appOpen()
    @objc optional func appClose()
    @objc optional func appOpenURL(url:URL)
}

class RMSystem{
    var mainWindow:UIWindow! = nil
    var delegate:RMAppDelegate? = nil
    func appLuanch(){
        guard let appLuanch = delegate?.appLuanch else {return}
        appLuanch()
    }
    func appOpenURL(url:URL){
        guard let appOpenURL = delegate?.appOpenURL else {return}
        appOpenURL(url)
    }
    func appEnd(){
        guard let appEnd = delegate?.appEnd else {return}
        appEnd()
    }
    func appOpen(){
        guard let appOpen = delegate?.appOpen else {return}
        appOpen()
    }
    func appClose(){
        guard let appClose = delegate?.appClose else {return}
        appClose()
    }
}


    
