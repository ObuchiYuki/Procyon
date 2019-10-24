import UIKit

class PixivNovelMainViewController: PixivBaseViewController{
    //====================================================================
    //property
    private var rankingTitle = "ranking_of_[type]".l("ranking_daily".l())
    
    private let recommendInner = PixivNovelRecommendInner()
    private let rankingInner = PixivNovelRankingInner()
    private let followerLatestInner = PixivNovelFollowerLatestInner()
    private let accountInner = PixivNovelAccountInner()
    //====================================================================
    //method
    //====================================================================
    //override
    override func setUISetting() {        
        recommendInner.delegate = self
        rankingInner.delegate = self
        followerLatestInner.delegate = self
        
        recommendInner.title = "home"
        rankingInner.title = "whatshot"
        followerLatestInner.title = "view_day"
        accountInner.title = "person"
        
        rankingInner.settingView.tip.addAction {[weak self] in
            guard let this = self else {return}
            let menu = ADMenu()
            menu.iconArr = Array(repeating: "sort", count: 8)
            menu.titles = [
                "ranking_daily".l(),"ranking_weekly".l(),"ranking_monthly".l(),"ranking_for_man".l(),
                "ranking_for_woman".l(),"ranking_original".l(),"ranking_rookie".l(),"ranking_old".l()
            ]
            menu.maxShowCellCount = 8
            menu.indexAction = {index in
                if index == 7{
                    let dialog = ADDialog()
                    let innerView = PixivRankingDialogInner()
                    innerView.itemType = .novel
                    dialog.title = "select_ranking_search_type".l()
                    dialog.setCustomView(innerView)
                    dialog.addButton(title: "search".l()){
                        this.rankingInner.date = innerView.date
                        this.rankingInner.rankingType = innerView.type
                        this.rankingInner.reload()
                    }
                    dialog.addCancelButton()
                    dialog.show()
                }else{
                    self?.rankingTitle = "ranking_of_[type]".l(menu.titles[index])
                    self?.title = "ranking_of_[type]".l(menu.titles[index])
                    self?.rankingInner.rankingType = PixivRankingType(rawValue: index) ?? .day
                }
            }
            menu.show()
        }
        accountInner.extraView.indexAction = {[weak self] index in
            switch index {
            case 0:
                self?.go(to: PixivNovelHistoryViewController())
            case 1:
                self?.go(to: PixivNovelBookmarkViewController())
            default:
                break
            }
        }
        if PixivSystem.isPrivate{
            horizontalMenu = ADHorizontalMenu(
                viewControllers: [recommendInner,rankingInner,followerLatestInner,accountInner],
                defaultOption: .black
            )
        }else{
            horizontalMenu = ADHorizontalMenu(
                viewControllers: [recommendInner,rankingInner,followerLatestInner,accountInner],
                defaultOption: .default
            )
        }
        horizontalMenu?.delegate = self
        horizontalMenu?.move(at: info.intValue(forKey: "novel_main_page_default_tab_index"), animated: false)
    }
    private func setTitle(at index:Int){
        title = ["recommended".l(),rankingTitle,"follower_latest".l(),"account".l()].index(index) ?? "Pixiv"
    }
    func horizontalMenuDidMove(at index: Int) {
        setTitle(at: index)
        info.set(index, forKey: "novel_main_page_default_tab_index")
    }
    class func instance()->UIViewController{
        let drawerController = ADDrawerController(drawerDirection: .left, drawerWidth: 260)
        let drawerViewController = PixivDrawerViewController()
        drawerController.mainViewController = UINavigationController(rootViewController: PixivNovelMainViewController())
        drawerController.drawerViewController = drawerViewController
        return drawerController
    }
}


