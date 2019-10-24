import UIKit

class PixivNovelImageViewController: PixivPageBaseViewController{
    var datas = pixivNovelContentsData()
    var index = 0
    var id:Int? = nil
    
    override func setSetting() {
        pageSpace=0
        if datas.count == 0{
            guard let id = id else {return}
            novel.getData(id: id, completion: {json in
                self.datas.novels.append(pixivNovelData(json: json["novel"]))
                self.startPageing()
            })
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
        return datas.novels
    }
    override func viewController(at index: Int) -> ADPageCellViewController {
        return PixivNovelImageCellViewController()
    }
}
