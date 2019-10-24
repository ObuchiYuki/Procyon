import UIKit

class RMShare {
    var text = ""
    var image:UIImage? = nil
    var url:URL? = nil
    private var excludedTypes = [UIActivityType]()
    
    enum ShareType {
        case share
        case `default`
    }
    
    func show(){
        let window = UIWindow()
        var activityItems:[Any] = [text]
        if let image = image{activityItems.append(image)}
        if let url = url{activityItems.append(url)}
        let controller =  UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.excludedActivityTypes = excludedTypes
        window.backgroundColor = .clear
        window.size = screen.size
        window.makeKey()
        window.makeKeyAndVisible()
        window.rootViewController = UIViewController()
        window.rootViewController?.present(controller, animated: true, completion: {})
        controller.view.size = screen.size
    }
    class func show(text:String,image:UIImage? = nil,url:URL? = nil,type:ShareType = .default){
        let share = RMShare()
        share.text = text
        share.image = image
        share.url = url
        switch type {
        case .share:
            share.excludedTypes = [
                .airDrop,.addToReadingList,.assignToContact,.message,.copyToPasteboard,.openInIBooks,.print,.saveToCameraRoll,
                UIActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
                UIActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"),
                UIActivityType(rawValue: "com.google.Drive.FileProviderExtension"),
                UIActivityType(rawValue: "com.google.Drive.ShareExtension"),
                UIActivityType(rawValue: "jp.naver.line.KeepAction"),
            ]
        default: break
        }
        share.show()
    }
}
