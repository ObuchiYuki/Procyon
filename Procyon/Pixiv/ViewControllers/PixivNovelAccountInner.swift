import UIKit

class PixivNovelAccountInner: ADViewController{
    var accountView = PixivAccountView()
    var extraView = PixivExtraView()
    
    override func setUISetting() {
        view.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        PixivSystem.getLoginData{data in pixiv.getUserData(userID: data.user.id, completion: {json in
            let userData = pixivFullUserData(json: json)
            self.accountView.userData = userData
        })}
        
        extraView.titles = ["view_history".l(),"bookmark".l(),"bookshelf".l()]
        extraView.iconArr = ["history","bookmark","library_books"]
        extraView.itemCount = 2
        extraView.y = accountView.bottomY
    }
    override func addUIs() {
        addSubview(accountView)
        addSubview(extraView)
    }
}
