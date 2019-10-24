import UIKit

enum ADSetPassEndType {
    case cancel
    case end(pass:String)
}

class ADSetPassViewController: ADNavigationController {
    var endSettingPass:(ADSetPassEndType)->() = {_ in}
    var useForCancel = true{
        didSet{
            if useForCancel{
                titleLabel.text = "パスコードを確認"
            }else{
                titleLabel.text = "パスコードを入力"
            }
        }
    }
    var chackText = "1111"
    fileprivate var isChack = false
    fileprivate let titleLabel = RMLabel()
    fileprivate let closeButton = ADTip(icon: "close")
    fileprivate let passHiddenTextField = RMTextField()
    fileprivate let passTypeButton = ADButton()
    fileprivate let passLabel = RMLabel()
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        run(after: 0.1){
            switch textField.text!.characters.count{
            case 0:
                self.passLabel.text = "ー　ー　ー　ー"
            case 1:
                self.passLabel.text = "●　ー　ー　ー"
            case 2:
                self.passLabel.text = "●　●　ー　ー"
            case 3:
                self.passLabel.text = "●　●　●　ー"
            case 4:
                self.passLabel.text = "●　●　●　●"
                self.passHiddenTextField.resignFirstResponder()
                run(after: 0.2, block: {
                    self.didEnd()
                    self.passHiddenTextField.text = ""
                    self.passLabel.text = "ー　ー　ー　ー"
                })
                
            default:
                break
            }
        }
        return true
    }
    fileprivate func didEnd(){
        if useForCancel{
            if chackText == passHiddenTextField.text!{
                self.navigationController?.dismiss(animated: true, completion: {})
                self.endSettingPass(.end(pass: ""))
                ADSnackbar.show("done".l())
            }else{
                let dialog = ADDialog()
                dialog.title = "パスコードが違います。"
                dialog.setCloseTime(to: 1.5)
                dialog.show()
                self.passHiddenTextField.becomeFirstResponder()
            }
        }else{
            let viewCon = ADSetPassChackViewController()
            viewCon.chackText = passHiddenTextField.text!
            viewCon.endSettingPass = endSettingPass
            viewCon.useForCancel = self.useForCancel
            self.go(to: viewCon)
        }
        
    }
    override func setSetting() {
        title = "パスコード"
    }
    override func setUISetting() {
        closeButton.addAction{[weak self] in
            guard let me = self else {return}
            me.endSettingPass(.cancel)
            me.navigationController?.dismiss(animated: true, completion: {})
        }
        
        titleLabel.textColor = .text
        titleLabel.textAlignment = .center
        
        passHiddenTextField.alpha = 0
        passHiddenTextField.delegate = self
        passHiddenTextField.keyboardType = .numberPad
        
        passLabel.text = "ー　ー　ー　ー"
        passLabel.font = Font.Roboto.font(20)
        passLabel.textAlignment = .center
    }
    override func setUIScreen() {
        titleLabel.size = sizeMake(200, 15)
        titleLabel.centerX = center.x
        titleLabel.y = 50
        
        passLabel.size = sizeMake(200, 30)
        passLabel.centerX = center.x
        passLabel.y = 100
        
    }
    override func addUIs() {
        addSubview(titleLabel)
        addSubview(passHiddenTextField)
        addSubview(passTypeButton)
        addSubview(passLabel)
        if !isChack {
            addButtonLeft(closeButton)
        }
    }
    override func setLoadControl() {
        passHiddenTextField.becomeFirstResponder()
    }
    class var instance:ADSetPassViewController{
        return (UIStoryboard(
            name: "ADSetPassMain",
            bundle: nil
        )
        .instantiateInitialViewController()?.childViewControllers.index(0)!)! as! ADSetPassViewController
    }
    class func show(_ vc:RMViewController,useForCancel:Bool = false,action:@escaping (ADSetPassEndType)->()){
        let nvc = UIStoryboard(name: "ADSetPassMain", bundle: nil).instantiateInitialViewController()!
        run(after: 0.2, block: {
            let vc = nvc.childViewControllers.index(0) as! ADSetPassViewController
            vc.useForCancel = useForCancel
            vc.endSettingPass = action
        })
        vc.go(to: nvc,usePush: false)
    }
}

private class ADSetPassChackViewController:ADSetPassViewController{
    
    fileprivate override func didEnd() {
        if passHiddenTextField.text == chackText{
            self.navigationController?.dismiss(animated: true, completion: {})
            endSettingPass(.end(pass: chackText))
            ADSnackbar.show("done".l())
        }else{
            back()
            let dialog = ADDialog()
            dialog.title = "パスコードが違います。"
            dialog.setCloseTime(to: 1.5)
            dialog.show()
        }
    }
    fileprivate override func setSetting() {
        super.setSetting()
        isChack = true
        titleLabel.text = "パスコードを確認"
    }
}











