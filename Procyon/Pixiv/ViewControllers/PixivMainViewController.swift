import UIKit

class PixivMainViewController: PixivBaseViewController{
    //====================================================================
    //property
    private var rankingTitle = "ranking_of_[type]".l("ranking_daily".l())
    
    private let recommendInner = PixivRecommendInner()
    private let rankingInner = PixivRankingInner()
    private let followerLatestInner = PixivFollowerLatestInner()
    private let accountInner = PixivAccountInner()
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
        
        recommendInner.pixivVisionView.cellTapped = {[weak self] data in
            let vc = PixiVisionViewController()
            vc.data = data
            self?.go(to: vc, usePush: false)
        }
        rankingInner.settingView.tip.addAction {[weak self] in
            guard let me = self else {return}
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
                    dialog.title = "select_ranking_search_type".l()
                    dialog.setCustomView(innerView)
                    dialog.addButton(title: "search".l()){
                        me.rankingInner.date = innerView.date
                        me.rankingInner.rankingType = innerView.type
                        me.rankingInner.reload()
                    }
                    dialog.addCancelButton()
                    dialog.show()
                }else{
                    me.rankingInner.rankingType = PixivRankingType(rawValue: index) ?? .day
                    me.rankingInner.reload()
                }
                me.rankingTitle = "ranking_of_[type]".l(menu.titles[index])
                me.title = "ranking_of_[type]".l(menu.titles[index])
            }
            menu.show()
        }
        followerLatestInner.followUserView.cellTapped = {[weak self] userData in
            let viewController = PixivUserViewController()
            viewController.userData = userData
            self?.go(to: viewController)
        }
        followerLatestInner.followUserView.loadMoreButton.addAction {[weak self] in
            self?.go(to: PixivUserFollowViewController())
        }
        accountInner.extraView.indexAction = {[weak self] index in
            switch index {
            case 0: self?.go(to: PixivHistoryViewController())
            case 1: self?.go(to: PixivBookmarkViewController())
            case 2: self?.go(to: PixivMyWorksViewController())
            case 3:
                if PixivSystem.tmpAlbumEnable || ProcyonSystem.isPremium{self?.go(to: PixivAlbumsViewController())}
                else{ProcyonSystem.buyPremiun{}}
            default: break
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
        horizontalMenu?.move(at: info.intValue(forKey: "pixiv_main_page_default_tab_index"), animated: false)
    }
    private func setTitle(at index:Int){
        title = ["recommended".l(),rankingTitle,"follower_latest".l(),"account".l()].index(index) ?? "Pixiv"
    }
    func horizontalMenuDidMove(at index: Int) {
        setTitle(at: index)
        info.set(index, forKey: "pixiv_main_page_default_tab_index")
    }
    class func instance()->UIViewController{
        let drawerController = ADDrawerController(drawerDirection: .left, drawerWidth: 260)
        let drawerViewController = PixivDrawerViewController()
        drawerController.mainViewController = UINavigationController(rootViewController: PixivMainViewController())
        drawerController.drawerViewController = drawerViewController
        return drawerController
    }
}




















