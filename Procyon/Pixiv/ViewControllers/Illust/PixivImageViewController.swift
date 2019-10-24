import UIKit

class PixivImageViewController: PixivPageBaseViewController{
    var datas = pixivContentsData()
    var index = 0
    var id:Int? = nil
    override func setSetting() {
        pageSpace=0
        addKeyCommand(input: "o", modifierFlags: .command){[unowned self] in
            let data = self.datas.works[self.currentIndex]
            if data.type == .ugoira{
                let imagePageViewController = PixivUgoiraViewController()
                imagePageViewController.data = data
                self.go(to: imagePageViewController)
            }else{
                let imagePageViewController = PixivImagePageViewController()
                imagePageViewController.data = data
                self.go(to: imagePageViewController)
            }
        }
        addKeyCommand(input: "u", modifierFlags: .command){[unowned self] in
            let data = self.datas.works[self.currentIndex]
            let userViewController = PixivUserViewController()
            userViewController.userData = data.user
            self.go(to: userViewController)
        }
        addKeyCommand(input: UIKeyInputDownArrow, modifierFlags: .none){[unowned self] in
            if let vc =  self.currentViewController as? PixivImageCellViewController{
                vc.mainTableView.contentOffset.y += 100
            }
        }
        addKeyCommand(input: UIKeyInputUpArrow, modifierFlags: .none){[unowned self] in
            if let vc =  self.currentViewController as? PixivImageCellViewController{
                vc.mainTableView.contentOffset.y -= 100
            }
        }
        if datas.count == 0{
            guard let id = id else {return}
            pixiv.getWorkData(id: id){json in
                self.datas.works.append(pixivWorkData(json: json["illust"]))
                self.startPageing()
            }
        }else{
            self.firstPageIndex = index
            self.startPageing()
        }
    }
    override func didBeforePaging(from: Int, to: Int) {
        if to == datas.count-2{
            pixiv.get(datas.nextUrl.request, {json in self.datas.append(json){}})
        }
    }
    override func pageData() -> [Any] {
        return datas.works
    }
    override func viewController(at index: Int) -> ADPageCellViewController {
        return PixivImageCellViewController()
    }
}



















