import UIKit

class RMDocumentController {
    class func show(url:URL){
        let window = UIWindow()
        let helper = RMDocumentControllerViewController()
        window.backgroundColor = .clear
        window.size = screen.size
        window.makeKey()
        window.makeKeyAndVisible()
        window.rootViewController = helper
        helper.view.size = screen.size
        helper.show(url: url)
    }
    fileprivate class RMDocumentControllerViewController:UIViewController,UIDocumentInteractionControllerDelegate{
        fileprivate var docController:UIDocumentInteractionController! = nil
        fileprivate func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
            docController = nil
        }
        func show(url:URL){
            docController = UIDocumentInteractionController(url: url)
            docController.delegate = self
            docController.presentOpenInMenu(from: view.frame, in: view, animated: true)
        }
    }
}
