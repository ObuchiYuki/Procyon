import UIKit

class PixivNovelBaseController: PixivBaesViewController{
    var pixiv_novel = PixivNovel()
    override func IllustData(_ json: JSON, row: Int) -> JSON {
        let nest = json["novels"][row]
        return nest
    }
    override func IllustNum(_ json: JSON) -> Int {
        let num = json["novels"].count
        return num
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyNovelCell", for: indexPath) as! NovelThumbnailCell
        let illustData = jsons[indexPath.row]
        //======================================
        //check the cache
        let image = cache.image(forKey: illustData["id"].stringValue+"S")
        //======================================
        //make cell
        cell.imageView.image = nil
        cell.title = illustData["title"].stringValue
        cell.authorName = illustData["user"]["name"].stringValue
        cell.tags = illustData["tags"]
        cell.illustNum = illustData["page_count"].intValue
        cell.id = illustData["id"].stringValue
        cell.isbookmarked = illustData["isbookmarked"].boolValue
        cell.likeCount = illustData["total_bookmarks"].intValue
        //======================================
        //DL
        if image != nil {
            cell.imageView.image = image!
        }else{
            let request = illustData["image_urls"]["square_medium"].stringValue.request
            request.headers  = [
                "Referer":pixiv.referer
            ]
            request.getImage{image in
                cache.set(image, forKey: illustData["id"].stringValue+"S")
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
        //======================================
        //if last cell next
        if indexPath.row+1 == collectionView.numberOfItems(inSection: 0) {
            let request = nextURL.request
            request.headers = pixiv.headers
            request.getJson(getDataFin)
        }
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let illustData = jsons[indexPath.row]
        delegate?.cellTapped(illustData,isNovel: true)
    }
    override func setupSetting_P() {
        super.setupSetting_P()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = sizeMake((view.frame.width)-12, (view.frame.width*2/5)-12)
        
        if device.isiPad{
            layout.itemSize = sizeMake((view.frame.width/2)-12, (view.frame.width*1/5)-12)
        }
        layout.sectionInset = UIEdgeInsetsMake(6, 6, 6, 6)
        
        alertMessage = "小説がありません"
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.register(NovelThumbnailCell.self, forCellWithReuseIdentifier: "MyNovelCell")
    }
}












