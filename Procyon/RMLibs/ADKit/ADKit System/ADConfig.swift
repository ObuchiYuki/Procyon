import UIKit


//=======================================================================//
//CONFIG
struct ADSystem{
    //===================================//
    //This method call when application begins
    //please set colors in this method
    static var colorTheme:RMcolorTheme = .custom{
        didSet{
            AppColor.colortheme = colorTheme
        }
    }
}
