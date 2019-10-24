import UIKit

class PixivImagePageViewController: PixivPageViewBaseController {
    //============================================================================
    //propertiess
    var data:pixivWorkData! = nil
    var isAuto = false
    private var isAppeared = true

    //============================================================================
    //method
    override func setSetting() {
        title = data.title
        contentView.backgroundColor = .hex("222")
        view.backgroundColor = .hex("222")
        trasitionStyle = .scroll
        navigationOrientation = .horizontal
        if isAuto{
            asyncQ {
                while(self.isAppeared){
                    sleep(PixivSystem.slideTime)
                    if self.data.pageCount <= self.currentIndex+1{
                        mainQ {self.currentIndex=0}
                        sleep(PixivSystem.slideTime)
                    }
                    mainQ {self.currentIndex+=1}
                }
            }
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        isAppeared = false
    }
    override func moreButtonTapped() {
        let menu = ADMenu()
        menu.iconArr = ["save"]
        menu.titles = ["save_image".l()]
        menu.indexAction = {[weak self] index in
            if let image = (self?.currentViewController as? PixivImagePageCellViewController)?.image{
                image.saveToPhotoAlbum()
                ADSnackbar.show("image_saved".l())
            }else{
                ADSnackbar.show("error".l())
            }
        }
        menu.show(windowAnimated: true)
    }
    override func setUISetting() {
        pageCount = data.pageCount
        self.startPageing()
    }
    //============================================================================
    //delegateMethod
    override func didAfterPaging(from: Int, to: Int) {
        pageIndex = to
    }
    override func pageData() -> [Any] {
        return data.metaPages
    }
    override func viewController(at index: Int) -> ADPageCellViewController {
        return PixivImagePageCellViewController()
    }
}














