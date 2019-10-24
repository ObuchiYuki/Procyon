import UIKit

enum PixivMode:String {
    case novels
    case illusts
    case `private`
    case privateNovel
    case users
    case bookmarkUsers
}

struct pixivHiddenContentsData {
    struct TagData: Storable,Equatable{
        var tagName:String
        var includingContains:Bool
        var dict: [String : Any]{return ["tag_name":tagName,"including_contains":includingContains]}
        init(tagName:String,includingContains:Bool){
            self.tagName = tagName
            self.includingContains = includingContains
        }
        init(dict: [String : Any]) {
            self.tagName = stringValue(of: dict["tag_name"])
            self.includingContains = boolValue(of: dict["including_contains"])
        }
        static func ==(lhs: TagData, rhs: TagData) -> Bool{
            return lhs.tagName == rhs.tagName
        }
    }
    var hideTags:[TagData]
    var hideUsers:[pixivUserData]
    var showR18:Bool
    var showR18on3G:Bool
}
extension pixivHiddenContentsData:Storable{
    var dict: [String : Any]{
        return ["hide_tags":hideTags.map{$0.dict},"hide_users": hideUsers.map{$0.dict},"show_R18":showR18,"show_R18_on_3G":showR18on3G]
    }
    init(dict: [String : Any]) {
        self.hideTags = dictArrayValue(of: dict["hide_tags"]).map{TagData(dict: $0)}
        self.hideUsers = dictArrayValue(of: dict["hide_users"]).map{pixivUserData(dict: $0)}
        self.showR18 = boolValue(of: dict["show_R18"])
        self.showR18on3G = boolValue(of: dict["show_R18_on_3G"])
    }
}

struct PixivSystem {
    static func removeBlockUser(at index:Int){
        var hiddenContents = hiddenContentsData
        hiddenContents.hideUsers.remove(at: index)
        setHideContentsData(data: hiddenContents)
    }
    static func addBlockUser(data:pixivUserData){
        var hiddenContents = hiddenContentsData
        hiddenContents.hideUsers.insert(data, at: 0)
        setHideContentsData(data: hiddenContents)
    }
    static func showEditHideTagDialog(){
        let dialog1 = ADDialog()
        var isDelete = false
        dialog1.title = "hidden_tags".l()
        dialog1.addButton(title:"add".l()){
            let dialog2 = ADDialog()
            dialog2.title = "enter_hide_tag".l()
            dialog2.textFieldPlaceHolder = "tag".l()
            dialog2.setTableView(titles: ["contain_tag_name".l()], selectedIndexAxtion: {_ in})
            dialog2.addOKButton{
                let text = dialog2.textFieldText
                if text.isEmpty{
                    let dialog2 = ADDialog()
                    dialog2.title = "error".l()
                    dialog2.message = "you_can_not_add_blank_tag".l()
                    dialog2.addOKButton{showEditHideTagDialog()}
                    dialog2.show()
                }else{
                    guard let tableView = dialog2.customView as? ADDialog.TableView else {return}
                    addHideTag(tagName: text, includeContains: tableView.enableCheckBoxIndexes[0] ?? false)
                    showEditHideTagDialog()
                }
            }
            dialog2.addCancelButton {
                showEditHideTagDialog()
            }
            dialog2.show()
        }
        if !hiddenContentsData.hideTags.isEmpty{dialog1.addButton(title: "remove".l()){isDelete = true}}
        dialog1.setTableView(
            titles: hiddenContentsData.hideTags.map{$0.tagName.omit(6) + ($0.includingContains ? "   "+"and_contains".l() : "")}
        ){indexSet in
            if isDelete{
                if indexSet.isEmpty{
                    let dialog3 = ADDialog()
                    dialog3.title = "error".l()
                    dialog3.message = "nothing_is_selected".l()
                    dialog3.addOKButton {
                        showEditHideTagDialog()
                    }
                    dialog3.show()
                    return
                }
                let dialog2 = ADDialog()
                dialog2.title = "remove?".l()
                indexSet.map{i in dialog2.message += (hiddenContentsData.hideTags.map{$0.tagName}.index(i) ?? "") + "\n"}
                dialog2.addOKButton{
                    removeHideTag(indexSet: indexSet)
                    showEditHideTagDialog()
                }
                dialog2.addCancelButton{
                    showEditHideTagDialog()
                }
                dialog2.show()
            }
        }
        dialog1.addButton(title: "CLOSE")
        dialog1.show()
    }
    static func showHideTagDialog(tag:String){
        let dialog = ADDialog()
        dialog.title = "hidden_tags".l()
        dialog.textFieldText = tag
        dialog.textFieldPlaceHolder = "tag".l()
        dialog.setTableView(titles: ["contain_tag_name".l()], selectedIndexAxtion: {_ in})
        dialog.addOKButton {
            let text = dialog.textFieldText
            if text.isEmpty{
                let dialog2 = ADDialog()
                dialog2.title = "error".l()
                dialog2.message = "you_can_not_add_blank_tag".l()
                dialog2.addOKButton{showHideTagDialog(tag: tag)}
                dialog2.show()
            }else{
                guard let tableView = dialog.customView as? ADDialog.TableView else {return}
                addHideTag(tagName: text, includeContains: tableView.enableCheckBoxIndexes[0] ?? false)
                ADSnackbar.show("done".l())
            }
        }
        dialog.addButton(title:"edit".l()){
            showEditHideTagDialog()
        }
        dialog.addButton(title: "HELP"){
            let dialog2 = ADDialog()
            dialog2.title = "HELP"
            dialog2.message = "非表示タグには、「含むタグ」を設定できます。\n例えば「風景」を非表示にしても「風景画」は非表示にはなりませんが、含むタグを有効にすることでこれも非表示にすることができます。\nジャンルを丸ごと非表示にすることなどに有効です。\nただしあまりに短すぎると何も表示されなくなることがあるのでお気をつけください。"
            dialog2.addOKButton {
                showHideTagDialog(tag: tag)
            }
            dialog2.show()
        }
        dialog.addCancelButton()
        dialog.show()
    }
    static func removeHideTag(indexSet:[Int]){
        var hideContentsDatas = hiddenContentsData
        var hiddenTags:[pixivHiddenContentsData.TagData] = []
        for (i,tag) in hideContentsDatas.hideTags.enumerated(){
            if !indexSet.contains(i){hiddenTags.append(tag)}
        }
        hideContentsDatas.hideTags = hiddenTags
        setHideContentsData(data: hideContentsDatas)
    }
    static func addHideTag(tagName:String,includeContains:Bool){
        var hideContentsData = hiddenContentsData
        hideContentsData.hideTags.insert(pixivHiddenContentsData.TagData(tagName: tagName, includingContains: includeContains), at: 0)
        setHideContentsData(data: hideContentsData)
    }
    static func setHideContentsData(data: pixivHiddenContentsData){
        info.set(data, forKey: "hiddent_contents_data")
    }
    static func updataHiddenContentsData(){
        var data = hiddenContentsData
        data.showR18 = !info.boolValue(forKey: "Nshow_r18")
        data.showR18on3G = !info.boolValue(forKey: "NshowR18on3G")
        info.set(data, forKey: "hiddent_contents_data")
    }
    static var hiddenContentsData:pixivHiddenContentsData{
        if let data = info.struct(type: pixivHiddenContentsData.self, forKey: "hiddent_contents_data"){
            return data
        }else{
            let data = createHiddenContentsData()
            info.setStruct(data, forKey: "hiddent_contents_data")
            return data
        }
    }
    private static func createHiddenContentsData()->pixivHiddenContentsData{
        var hideTags:[pixivHiddenContentsData.TagData] = []
        _=info.stringArrayValue(forKey: "NtagNew").enumerated().map{i,tag in
            hideTags.append(pixivHiddenContentsData.TagData(
                tagName: tag, includingContains: info.boolArrayValue(forKey: "NtagContain").index(i) ?? false
            ))
        }
        return pixivHiddenContentsData(
            hideTags: hideTags, hideUsers: [], showR18: !info.boolValue(forKey: "Nshow_r18"), showR18on3G:  !info.boolValue(forKey: "NshowR18on3G")
        )
    }
    static func novelTagBookmark(tags:[String],id:Int){
        var restrict = PixivRestrict.public
        var isCalceled = false
        let dialog = ADDialog()
        dialog.title = "tag_bookmark".l()
        dialog.setTableView(titles: tags+(PixivSystem.novelTagBookmarkData()?.bookmarkTags ?? [])){indexes in
            guard !isCalceled else {return}
            novel.addBookMark(id: id, restrict: restrict, tags: indexes.map{tags.index($0) ?? ""}){json in
                ADSnackbar.show(json["error"].isEmpty ? "tag_bookmarked".l() : "error".l())
            }
        }
        dialog.addButton(title: "bookmark_this".l()){restrict = .public}
        dialog.addButton(title: "private_bookmark_this".l()){restrict = .private}
        dialog.addButton(title: "add_tag".l()){
            isCalceled=true
            let dialog = ADDialog()
            dialog.title = "tag_bookmark".l()
            dialog.textFieldPlaceHolder = "tag".l()
            dialog.addOKButton {
                if dialog.textFieldText.isEmpty{ADDialog.show(title: "tag_cannot_be_blank".l()){PixivSystem.novelTagBookmark(tags: tags, id: id)}}
                else{PixivSystem.novelTagBookmark(tags: [dialog.textFieldText]+tags, id: id)}
            }
            dialog.addCancelButton()
            dialog.show()
        }
        dialog.addCancelButton{isCalceled=true}
        dialog.show()
    }
    static func tagBookmark(tags:[String],id:Int){
        var restrict = PixivRestrict.public
        var isCalceled = false
        let dialog = ADDialog()
        dialog.title = "tag_bookmark".l()
        dialog.setTableView(titles: tags+(PixivSystem.tagBookmarkData()?.bookmarkTags ?? [])){indexes in
            guard !isCalceled else {return}
            pixiv.addBookMark(id: id, restrict: restrict, tags: indexes.map{tags.index($0) ?? ""}){json in
                ADSnackbar.show(json["error"].isEmpty ? "tag_bookmarked".l() : "error".l())
            }
        }
        dialog.addButton(title: "bookmark_this".l()){restrict = .public}
        dialog.addButton(title: "private_bookmark_this".l()){restrict = .private}
        dialog.addButton(title: "add_tag".l()){
            isCalceled=true
            let dialog = ADDialog()
            dialog.title = "tag_bookmark".l()
            dialog.textFieldPlaceHolder = "tag".l()
            dialog.addOKButton {
                if dialog.textFieldText.isEmpty{ADDialog.show(title: "tag_cannot_be_blank".l()){PixivSystem.tagBookmark(tags: tags, id: id)}}
                else{PixivSystem.tagBookmark(tags: [dialog.textFieldText]+tags, id: id)}
            }
            dialog.addCancelButton()
            dialog.show()
        }
        dialog.addCancelButton{isCalceled=true}
        dialog.show()
    }
    static func tagBookmarkData()->pixivTagBookmarkData?{
        return PixivSystem.restrict == .public ? PixivSystem.publicTagBookmarkData : PixivSystem.privateTagBookmarkData
    }
    static func novelTagBookmarkData()->pixivTagBookmarkData?{
        return PixivSystem.restrict == .public ? PixivSystem.publicNovelTagBookmarkData : PixivSystem.privateNovelTagBookmarkData
    }
    static func reloadTagBookmark(){
        novel.getTagBookmark(restrict: .public){PixivSystem.publicNovelTagBookmarkData = pixivTagBookmarkData(json: $0)}
        novel.getTagBookmark(restrict: .private){PixivSystem.privateNovelTagBookmarkData = pixivTagBookmarkData(json: $0)}
        pixiv.getTagBookmark(restrict: .public){PixivSystem.publicTagBookmarkData = pixivTagBookmarkData(json: $0)}
        pixiv.getTagBookmark(restrict: .private){PixivSystem.privateTagBookmarkData = pixivTagBookmarkData(json: $0)}
    }
    private static var publicTagBookmarkData:pixivTagBookmarkData? = nil
    private static var privateTagBookmarkData:pixivTagBookmarkData? = nil
    private static var publicNovelTagBookmarkData:pixivTagBookmarkData? = nil
    private static var privateNovelTagBookmarkData:pixivTagBookmarkData? = nil
    
    static func addAlbum(data:pixivWorkData){
        if !PixivSystem.tmpAlbumEnable && !ProcyonSystem.isPremium{ProcyonSystem.buyPremiun {} ;return}
        let menu = ADMenu()
        let albums = albumApi.getAlbums()
        menu.iconArr = Array(repeating: "library_books", count: albums.count)
        menu.iconArr.insert("add", at: 0)
        menu.titles = albums.map{album in return album.title}
        menu.titles.insert("create_new_album".l(), at: 0)
        menu.indexAction = {index in
            if index != 0{
                let album = albums[index-1]
                albumApi.addItem(albumId: album.id,data:pixivAlbumData.ItemData(data: data),completion: {
                    ADSnackbar.show("added_to_[album_title]".l(album.title))
                })
            }else{
                menu.close()
                let dialog = ADDialog()
                dialog.title = "create_new_album".l()
                dialog.textFieldPlaceHolder = "album_name".l()
                dialog.addOKButton{
                    albumApi.addAlbum(title: dialog.textFieldText, completion: {album in
                        albumApi.addItem(
                            albumId: album.id,
                            data: pixivAlbumData.ItemData(data: data),
                            completion: {ADSnackbar.show("added_to_[album_title]".l(album.title))}
                        )
                    })
                }
                dialog.addCancelButton()
                dialog.show()
            }
        }
        menu.show(windowAnimated: true)
    }
    static var isPremium:Bool{
        if let isPremium = logInData?.user.isPremium{
            return isPremium
        }else{
            return false
        }
    }
    
    static func getLoginData(_ completion:@escaping (pixivLoginData)->()){
        if logInData == nil{
            if isLogingIn{
                getLoginDataCompletions.append(completion)
            }else{
                isLogingIn = true
                getLoginDataCompletions.append(completion)
                pixiv.logIn(username: accountData.id, password: accountData.password){data in
                    if data.hasError{
                        ADSnackbar.show("login_error".l())
                    }else{
                        logInData = data
                        isLogingIn = false
                        getLoginDataCompletions.map{$0(data)}
                        getLoginDataCompletions.removeAll()
                        info.setStruct(accountData, forKey: "last_login_account")
                        PixivSystem.reloadTagBookmark()
                        pixiv.getAccountImage(userData: data.user){image in
                            let newAccount =  ProcyonAccountData(
                                type: .pixiv, name: data.user.name, id: accountData.id, password: accountData.password, image: image
                            )
                            accountData = newAccount
                            var tmp = [ProcyonAccountData]()
                            for account in ProcyonSystem.accounts{tmp.append(account == newAccount ? newAccount : account)}
                            ProcyonSystem.accounts = tmp
                        }
                    }
                }
            }
        }
        else {completion(logInData!)}
    }
    private static var getLoginDataCompletions = [(pixivLoginData)->()]()
    private static var isLogingIn = false
    private static var logInData:pixivLoginData? = nil
    
    static func resetAccountData(_ data: ProcyonAccountData){
        logInData = nil
        accountData = data
        pixiv.headers["Authorization"] = ""
        getLoginData{data in ADSnackbar.show("login_with_[account_name]".l(data.user.name))}
    }
    static var accountData:ProcyonAccountData! = nil
    
    
    static var tmpAlbumEnable:Bool{
        set{
            let dialog = ADDialog()
            dialog.title = "警告: 開発用メニュー"
            dialog.message = "アルバム機能を変更します。\nアプリを一時的に終了します。\nError: \(info.dict)"
            dialog.addButton(title: "オン", with: {
                info.set(true, forKey: "tmp_album_enable")
                application.end()
            })
            dialog.addButton(title: "オフ", with: {
                info.set(false, forKey: "tmp_album_enable")
                application.end()
            })
            dialog.show()
        }
        get{
            return info.boolValue(forKey: "tmp_album_enable")
        }
    }
    static var inReview = false
    static var mode = PixivMode.illusts{
        didSet{info.set(mode.rawValue, forKey: "pixiv_last_mdoe")}
    }
    static var novelTheme = pixivNovelThemeData()
    static var restrict:PixivRestrict{
        if PixivSystem.isPrivate{
            return .private
        }else{
            return .public
        }
    }
    static var isPrivate:Bool{
        return PixivSystem.mode == .private || PixivSystem.mode == .privateNovel
    }
    
    static var layout:UICollectionViewFlowLayout{
        let layout = UICollectionViewFlowLayout()
        if device.isiPad{
            layout.itemSize = sizeMake((screen.width/4)-12, (screen.width/4)-12)
        }else{
            layout.itemSize = sizeMake((screen.width/2)-12, (screen.width/2)-12)
        }
        layout.sectionInset = UIEdgeInsetsMake(7, 7, 7, 7)
        
        _layout = layout
        return layout
    }
    private static var _layout:UICollectionViewFlowLayout? = nil
    static var thumbnailSize:CGSize{
        if let layout = _layout{
            return layout.itemSize
        }else{
            return layout.itemSize
        }
    }
    
    static var novelLayout:UICollectionViewFlowLayout{
        let layout = UICollectionViewFlowLayout()
        
        if device.isiPad{
            layout.itemSize = sizeMake((screen.width/2)-12, (screen.width*1/5)-12)
        }else{
            layout.itemSize = sizeMake((screen.width)-12, (screen.width*2/5)-12)
        }
        layout.sectionInset = UIEdgeInsetsMake(6, 6, 6, 6)
        
        _novelLayout = layout
        return layout
    }
    private static var _novelLayout:UICollectionViewFlowLayout? = nil
    static var novelThumbnailSize:CGSize{
        if let novelLayout = _novelLayout{
            return novelLayout.itemSize
        }else{
            return novelLayout.itemSize
        }
    }
    
    static var userLayout:UICollectionViewFlowLayout{
        let layout = UICollectionViewFlowLayout()
        
        if device.isiPad{
            layout.itemSize = sizeMake((screen.width/2)-12, userThumbnailInnerSize.height+56)
        }else{
            layout.itemSize = sizeMake((screen.width)-12, userThumbnailInnerSize.height+56)
        }
        layout.sectionInset = UIEdgeInsetsMake(6, 6, 6, 6)
        
        _userLayout = layout
        return layout
    }
    private static var _userLayout:UICollectionViewFlowLayout? = nil
    static var userThumbnailInnerSize:Size{
        if device.isiPad{
            return sizeMake((((screen.width/2)-32)/3, ((screen.width/2)-32)/3))
        }else{
            return sizeMake(((screen.width)-32)/3, ((screen.width)-32)/3)
        }
    }
    static var userThumbnailSize:CGSize{
        if let userLayout = _userLayout{
            return userLayout.itemSize
        }else{
            return userLayout.itemSize
        }
    }
    
    static var UrlID = 0
    static var UrlCallFin = true
    static var UrlType = PixivMode.illusts
    
    static var slideTime:UInt32{
        get{
            if let slideTime = PixivSystem._slideTime{
                return slideTime
            }else if let slideTime = info.int(forKey: "pixiv_slide_timer"){
                return UInt32(slideTime)
            }else{
                PixivSystem._slideTime = 3
                return 3
            }
        }
        set{
            info.set(newValue, forKey: "pixiv_slide_timer")
            _slideTime = newValue
        }
    }
    private static var _slideTime:UInt32? = nil
    static func showPremiumAlert(){
        let dialog = ADDialog()
        dialog.title = "register_to_pixiv_premium?".l()
        dialog.message = "pixiv_premium_discription".l()
        dialog.addButton(title: "register".l()){application.openURL("http://touch.pixiv.net/premium_touch.php?ref=t_footer".url!)}
        dialog.addCancelButton()
        dialog.show()
    }
}
