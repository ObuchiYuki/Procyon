import UIKit

class PixivMyWorksViewController: PixivBaseViewController{
    private let workInner = PixivMyWorksInner()
    private let novelsInner = PixivNovelMyNovelsInner()
    private let followerInner = PixivUserMyFollowerInner()
    
    override func setSetting() {
        setTitle(at: 0)
        
        workInner.title = "photo"
        novelsInner.title = "book"
        followerInner.title = "person"
        
        workInner.delegate = self
        novelsInner.delegate = self
        followerInner.delegate = self
        
        if PixivSystem.isPrivate{
            horizontalMenu = ADHorizontalMenu(
                viewControllers: [workInner,novelsInner,followerInner],
                defaultOption: .black
            )
        }else{
            horizontalMenu = ADHorizontalMenu(
                viewControllers: [workInner,novelsInner,followerInner],
                defaultOption: .default
            )
        }
        horizontalMenu?.delegate = self
    }
    func horizontalMenuDidMove(at index: Int) {
        setTitle(at: index)
    }
    private func setTitle(at index:Int){
        title = ["submitted_illust".l(),"submitted_novel".l(),"my_follower".l()].index(index) ?? "Pixiv"
    }
}
