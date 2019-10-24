import UIKit

class PixivUserViewController: PixivBaseViewController{
    //====================================================================
    //properties
    var id = 0
    var userData:pixivUserData! = nil
    
    private let userWorksInner = PixivUserWorksInner()
    private let userBookmarkInner = PixivUserBookmarkInner()
    private let userNovelsInner = PixivNovelUserNovelsInner()
    private let userDataInner = PixivUserDataInner()
    //====================================================================
    //method
    private func createViews(){
        guard let userData = userData else {return}
        setTitle(at: 0)
        
        userWorksInner.userID = userData.id
        userBookmarkInner.userID = userData.id
        userNovelsInner.userID = userData.id
        userDataInner.userID = userData.id
        
        userDataInner.socialView.twitterButton.addAction {[weak self] in
            guard let me = self else {return}
            if let data =  me.userDataInner.socialView.data{
                let vc = PixivWebViewBaseController()
                vc.defaultUrl = data.twitterUrl
                me.go(to: vc,usePush: false)
            }
        }
        userDataInner.socialView.webpageButton.addAction {[weak self] in
            guard let me = self else {return}
            if let data =  me.userDataInner.socialView.data{
                let vc = PixivWebViewBaseController()
                vc.defaultUrl = data.webpage
                me.go(to: vc,usePush: false)
            }
        }
    }
    private func setTitle(at index:Int){
        switch index {
        case 0:
            title = "illusts_of_[user_name]".l(userData!.name)
        case 1:
            title = "bookmark_by_[user_name]".l(userData!.name)
        case 2:
            title = "novels_of_[user_name]".l(userData!.name)
        case 3:
            title = "details_of_[user_name]".l(userData!.name)
        default:
            title = "Pixiv"
        }
    }
    override func setSetting() {
        let menuTip = ADTip(icon: "more_vert")
        menuTip.addAction {[weak self] in
            guard let this = self else {return}
            let menu = ADMenu()
            menu.addItem(title: "share".l(), icon: "share")
            {RMShare.show(text: this.userData.name, url: "http://www.pixiv.net/member.php?id=\(this.userData.id)".url)}
            menu.addItem(title: "make_this_user_block".l(), icon: "pan_tool"){
                let dialog = ADDialog()
                dialog.title = this.userData.name
                dialog.message = "make_this_user_hide?".l()
                dialog.addOKButton{
                    PixivSystem.addBlockUser(data: this.userData)
                    ADSnackbar.show("done".l())
                }
                dialog.addCancelButton()
                dialog.show()
            }
            if this.userData.isFollowed{
                menu.addItem(title: "remove_follow_[user_name]".l(this.userData.name.omit(6)), icon: "person"){
                    pixiv.deleteFollowUser(id: this.userData.id){
                        if $0["error"].isEmpty{ADSnackbar.show("unfollowed".l());this.userData.isFollowed=true}
                        else{ADSnackbar.show("error".l())}
                    }
                }
            }else{
                menu.addItem(title: "follow_[user_name]".l(this.userData.name.omit(6)), icon: "person_add"){
                    pixiv.addFollowUser(id: this.userData.id, restrict: .public) {
                        if $0["error"].isEmpty{ADSnackbar.show("followed".l());this.userData.isFollowed=true}
                        else{ADSnackbar.show("error".l())}
                    }
                }
                menu.addItem(title: "follow_private_[user_name]".l(this.userData.name.omit(6)), icon: "vpn_lock"){
                    pixiv.addFollowUser(id: this.userData.id, restrict: .private) {
                        if $0["error"].isEmpty{ADSnackbar.show("private_followed".l());this.userData.isFollowed=true}
                        else{ADSnackbar.show("error".l())}
                    }
                }
            }
            menu.show(windowAnimated: true)
        }
        addButtonRight(menuTip)
        if userData != nil{
            createViews()
        }else{
            pixiv.getUserData(userID: id, completion: {json in
                self.userData = pixivUserData(json: json["user"])
                
                self.createViews()
                
                self.userWorksInner.reload()
                self.userBookmarkInner.reload()
                self.userNovelsInner.reload()
            })
        }
    }
    override func setUISetting() {
        userWorksInner.title = "photo"
        userBookmarkInner.title = "bookmark"
        userNovelsInner.title = "book"
        userDataInner.title = "person"
        
        userWorksInner.delegate = self
        userBookmarkInner.delegate = self
        userNovelsInner.delegate = self
        
        if PixivSystem.isPrivate{
            horizontalMenu = ADHorizontalMenu(
                viewControllers: [userWorksInner,userBookmarkInner,userNovelsInner,userDataInner],
                defaultOption: .black
            )
        }else{
            horizontalMenu = ADHorizontalMenu(
                viewControllers: [userWorksInner,userBookmarkInner,userNovelsInner,userDataInner],
                defaultOption: .default
            )
        }
        
        horizontalMenu?.delegate = self
    }
    func horizontalMenuDidMove(at index: Int) {
        setTitle(at: index)
    }
}






