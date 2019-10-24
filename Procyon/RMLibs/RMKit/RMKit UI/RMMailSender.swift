import UIKit
import MessageUI

class RMMailSender: MFMailComposeViewController ,MFMailComposeViewControllerDelegate{
    class func send(_ vc:RMViewController,to:String,title:String,message:String = ""){
        let mailViewController = RMMailSender()
        
        let toRecipients = [to]
        
        mailViewController.mailComposeDelegate = mailViewController
        mailViewController.setSubject(title)
        mailViewController.setToRecipients(toRecipients)
        mailViewController.setMessageBody(message, isHTML: false)
        
        vc.go(to: mailViewController,usePush: false)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}
