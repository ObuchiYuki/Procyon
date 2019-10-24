import UIKit

class PixivAccountInner: ADViewController{
    var accountView = PixivAccountView()
    var extraView = PixivExtraView()
    
    override func setUISetting() {
        view.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        PixivSystem.getLoginData{data in pixiv.getUserData(userID: data.user.id, completion: {json in
                let userData = pixivFullUserData(json: json)
                self.accountView.userData = userData
        })}
        
        extraView.titles = ["view_history".l(),"bookmark".l(),"submitted_work".l(),"album".l()]
        extraView.iconArr = ["history","bookmark","person","list"]
        extraView.itemCount = 4
        extraView.y = accountView.bottomY
    }
    override func addUIs() {
        addSubview(accountView)
        addSubview(extraView)
    }
}





