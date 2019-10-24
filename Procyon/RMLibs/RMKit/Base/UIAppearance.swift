import UIKit

struct UIAppearance {
    static var useShadowLevel = false
    static func setup() {
        application.statusBarStyle = AppColor.statusBarColor
        UIView.appearance().tintColor = .main
        UITableView.appearance().separatorStyle = .none
    }
}


















