import UIKit

class PixivBaseViewController: ADNavigationController {
    func goToImageViewByCallingURL(){
        if !PixivSystem.UrlCallFin{
            switch PixivSystem.UrlType {
            case .illusts:
                let viewCon = PixivImageViewController()
                viewCon.id = PixivSystem.UrlID
                go(to: viewCon)
            case .novels:
                let viewCon = PixivNovelImageViewController()
                viewCon.id = PixivSystem.UrlID
                go(to: viewCon)
            case .users:
                let viewCon = PixivUserViewController()
                viewCon.id = PixivSystem.UrlID
                go(to: viewCon)
            default:
                break
            }
            PixivSystem.UrlCallFin = true
        }
    }
    private func setSearchHistories(){
        let searchHistories = pixivInternalApi.getSearchHistory(restrict: PixivSystem.restrict)
        var searchHistoriesArray = [String]()
        if searchHistories.count > 3{
            for i in 0...2{searchHistoriesArray.append(searchHistories[i])}
            searchHistoriesArray.append("more_search_history".l())
        }else{
            searchHistoriesArray = searchHistories
        }
        self.searchEstimatedObjects = searchHistoriesArray
    }
    
    override func setupSetting_P() {
        super.setupSetting_P()
        
        addKeyCommand(input: ",", modifierFlags: .command){[weak self] in
            self?.present(ProcyonSettingViewController(), animated: true)
        }
        
        showSearchButton = true
        showBackButton = false
        
        let tip = ADTip(icon: "menu")
        tip.addAction {[weak self] in self?.drawerController?.setDrawerState(.opened, animated: true)}
        addButtonLeft(tip)
        
        if self.navigationController?.viewControllers.count != 1{
            let backTip = ADTip(icon: "arrow_back")
            backTip.addAction {[weak self] in self?.back()}
            backTip.longTapAction = {[weak self] in
                guard let me = self else {return}
                let dialog = ADDialog()
                dialog.title = "confirm".l()
                dialog.message = "back_to_pixiv_home?".l()
                dialog.addOKButton{
                    _=me.navigationController?.popToRootViewController(animated: true)
                }
                dialog.addCancelButton()
                dialog.show()
            }
            addButtonLeft(backTip)
        }
        checkButtonsFromRight(false)
        
        themeColor = .hex("2196F3")
        
        if PixivSystem.isPrivate{
            themeColor = .hex("212121")
            contentView.backgroundColor = .hex("303030")
        }
        
        notificationCenter.addObserver(
            self,
            selector: #selector(PixivBaseViewController.goToImageViewByCallingURL),
            name: NSNotification.Name(rawValue: "notificationImageURL"),
            object: nil
        )
        
        searchButton.addAction{[weak self] in
            self?.setSearchHistories()
        }
        
        searchEstimatedItemSelected = {[weak self] index in
            guard let me = self else {return}
            if index == 3{
                me.searchEndActionAnimation()
                me.go(to: PixivSearchHistoryViewController())
            }else{
                me.searchEndActioned(me.searchEstimatedObjects[index])
            }
        }
        
        searchTextChangeAction = {[weak self] word in
            guard let me = self else {return}
            if word.isEmpty{
                me.setSearchHistories()
            }else{
                pixiv.getSearchEstimated(word: word, completion: {json in
                    let estimatedWords = json["search_auto_complete_keywords"].arrayValue.map{json in json.stringValue}
                    var showedEstimatedWords = [String]()
                    
                    if estimatedWords.count >= 3{
                        for i in 0...2{showedEstimatedWords.insert(estimatedWords[i], at: 0)}
                    }else{
                        for item in estimatedWords{showedEstimatedWords.insert(item, at: 0)}
                    }
                    me.searchEstimatedObjects = showedEstimatedWords
                })
            }
        }
        searchEndAction = {[weak self] word in
            guard let me = self else {return}
            pixivInternalApi.addSearchHistory(word: word, restrict: PixivSystem.restrict)
            let searchViewController = PixivSearchViewController()
            searchViewController.word = word
            if PixivSystem.mode == .novels || PixivSystem.mode == .privateNovel{
                searchViewController.state = .novel
            }
            me.go(to: searchViewController)
        }
    }
}
extension PixivBaseViewController: PixivWorkCollectionViewDelegate{
    func cellTapped(datas: pixivContentsData,at index: Int) {
        let imageController = PixivImageViewController()
        imageController.datas = datas
        imageController.index = index
        go(to: imageController)
    }
}
extension PixivBaseViewController: PixivNovelCollectionViewDelegate{
    func cellTapped(datas:pixivNovelContentsData,at index: Int) {
        let imageController = PixivNovelImageViewController()
        imageController.datas = datas
        imageController.index = index
        go(to: imageController)
    }
}
extension PixivBaseViewController: PixivUserCollectionViewDelegate{
    func cellTapped(data: pixivUserData) {
        let viewController = PixivUserViewController()
        viewController.userData = data
        go(to: viewController)
    }
    func innerCellTapped(data: pixivWorkData) {
        let imageController = PixivImageViewController()
        let datas = pixivContentsData()
        datas.works = [data]
        imageController.datas = datas
        go(to: imageController)
    }
}




