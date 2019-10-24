import UIKit

class PixivNavigationController: ADNavigationController ,PixivBaesViewControllerDelegate {
    func cellTapped(_ json: JSON,isNovel: Bool) {
        
    }
    override func menuButtonTapped() {
        
    }
    override func setupSetting_P() {
        menuButton.title = "view_carousel"
        backButton.longTapAction = {
            let alert = ADAlert()
            alert.title = "確認"
            alert.message = "Pixivのメイン画面に戻りますか？"
            alert.addOKButton{
                _=self.navigationController?.popToRootViewController(animated: true)
            }
            alert.addCancelButton()
            alert.show()
        }
        
        
        super.setupSetting_P()
        
        if PixivSystem.mode == .private{
            themeColor = .hex("212121")
            contentView.backgroundColor = .hex("303030")
        }
        
        var searchObjects = [String]()
        
        searchButton.addAction{}
        
        searchEstimatedItemSelected = {index in
            if index == 3{
                self.searchEndActionAnimation()
                self.go(to: PixivSearchHistoryViewController())
            }else{
                self.searchEndActioned(searchObjects[index])
            }
        }

        
        //self.launchImage.image = UIImage(named: "PixivLaunchImage")
        themeColor = .hex("2196F3")
        showMenuButton = true
        showSearchButton = true
        searchEndAction = {(word:String)  in
            if PixivSystem.mode == .novel{
                let searchViewController = PixivNovelSerchViewController()
                searchViewController.word = word
                self.go(to: searchViewController)
            }else{
                let searchViewController = PixivSearchViewController()
                searchViewController.word = word
                self.go(to: searchViewController)
            }
        }
    }
    override func setLoadControl_P() {
        super.setLoadControl_P()
        if !info.boolValue(forKey: "hide-home-button"){
            //ProcyonSystem.homeButton.open()
        }
    }
}






