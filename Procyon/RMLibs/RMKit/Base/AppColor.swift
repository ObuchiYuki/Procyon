//==========================================================================
//this struct holds base information and function of application color

import UIKit

enum RMcolorTheme {
    case black
    case white
    case custom
}

extension UIColor{
    static var text:UIColor{return UIColor.hex("212121")}
    static var subText:UIColor{return UIColor.hex("767676")}
    static var main:UIColor{return UIColor.hex("2196F3")}
    static var accent:UIColor{return UIColor.hex("E91E63")}
    static var back:UIColor{return UIColor.hex("fafafa")}
}

struct AppColor {
    //==============================================
    //you can choose application color theme from RMcolorTheme
    static var colortheme = RMcolorTheme.custom
    //==============================================
    //mainColor is used in navigationBar ,tintColor...
    static var mainColor:UIColor{
        get{
            switch colortheme {
            case .white:
                return .hex("f5f5f5")
            case .black:
                return .hex("212121")
            case .custom:
                return rawMainColor
            }
        }
        set(value){
            rawMainColor = value
        }
    }
    private static var rawMainColor = UIColor.white
    //==============================================
    //accentColor is used in mainButton, checkBox, RadioButton...
    static var accentColor:UIColor{
        get{
            switch colortheme {
            case .white:
                return .hex("ffffff")
            case .black:
                return .hex("424242")
            case .custom:
                return rawAccentColor
            }
        }
        set(value){
            rawAccentColor = value
        }
    }
    private static var rawAccentColor = UIColor.white
    //==============================================
    //backColor is used in background color of ADViewController...
    static var backColor:UIColor{
        get{
            switch colortheme {
            case .white:
                return .hex("fafafa")
            case .black:
                return .hex("303030")
            case .custom:
                return rawBackColor
            }
        }
        set(value){
            rawBackColor = value
        }
    }
    private static var rawBackColor = UIColor.white
    //==============================================
    //backColor is used for text
    static var textColor:UIColor{
        get{
            switch colortheme {
            case .white:
                return .hex("212121")
            case .black:
                return .hex("ffffff")
            case .custom:
                return rawTextColor
            }
        }
        set(value){
            rawTextColor = value
        }
    }
    private static var rawTextColor = UIColor.white
    //==============================================
    //backColor is used for sub text
    static var subTextColor:UIColor{
        get{
            switch colortheme {
            case .white:
                return .hex("767676")
            case .black:
                return .hex("e0e0e0")
            case .custom:
                return rawSubTextColor
            }
        }
        set(value){
            rawSubTextColor = value
        }
    }
    private static var rawSubTextColor = UIColor.white
    //==============================================
    //you can get recommended navigation item color
    static var navigationItemColor:UIColor{
        var color = UIColor.white
        if !UIColor.main.isDark {
            color = .hex("0", alpha: 0.8)
        }
        return color
    }
    //==============================================
    //you can get recommended main button icon color
    static var mainButtonColor:UIColor{
        var color = UIColor.white
        if !UIColor.accent.isDark {
            color = .hex("0", alpha: 0.8)
        }
        return color
    }
    //==============================================
    //you can get recommended status bar style
    static var statusBarColor:UIStatusBarStyle{
        var style = UIStatusBarStyle.lightContent
        if !UIColor.main.isDark {
            style = .default
        }
        return style
    }
}











