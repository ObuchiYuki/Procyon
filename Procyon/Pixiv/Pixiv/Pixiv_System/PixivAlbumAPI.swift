import Foundation

let albumApi = PixivAlbumAPI()

class PixivAlbumAPI {
    func getAlbums()->[pixivAlbumData] {
        return (info.array(forKey: getAlbumKey()) as? [[String:Any]] ?? []).map{dict in
            return pixivAlbumData(dict: dict)
        }
    }
    func getAlbum(id: Int,completion: @escaping (pixivAlbumData)->()){
        asyncQ {
            var albumData:pixivAlbumData! = nil
            for album in self.getAlbums(){
                if album.id == id{albumData=album}
            }
            mainQ{completion(albumData)}
        }
    }
    func addAlbum(title: String,completion: @escaping (pixivAlbumData)->()){
        asyncQ {
            let album = pixivAlbumData(id: self.newAlbumId(), title: title)
            var albums = self.getAlbums()
            albums.insert(album, at: 0)

            self.saveAlbums(datas: albums, completion: {
                completion(album)
            })
        }
    }
    func deleteAlbum(id: Int,completion: @escaping voidBlock){
        asyncQ {
            let oldAlbums = self.getAlbums()
            var newAlbums = [pixivAlbumData]()
            for album in oldAlbums{
                if album.id != id {
                    newAlbums.append(album)
                }
            }
            self.saveAlbums(datas: newAlbums, completion: completion)
        }
    }
    func renameAlbum(id:Int,title: String,completion: @escaping voidBlock){
        asyncQ {
            
            let oldAlbums = self.getAlbums()
            var newAlbums = [pixivAlbumData]()
            for album in oldAlbums{
                if album.id == id {
                    var newAlbum = album
                    newAlbum.title = title
                    newAlbums.append(newAlbum)
                }else{
                    newAlbums.append(album)
                }
            }
            self.saveAlbums(datas: newAlbums, completion: completion)
        }
    }
    private func saveAlbums(datas:[pixivAlbumData],completion: @escaping voidBlock){
        info.set(datas.map{data in return data.dict}, forKey: self.getAlbumKey())
        mainQ (completion)
    }
    private func saveAlbum(data: pixivAlbumData,completion: @escaping voidBlock){
        asyncQ {
            let oldAlbums = self.getAlbums()
            var newAlbums = [pixivAlbumData]()
            for album in oldAlbums{
                if album.id == data.id{
                    newAlbums.append(data)
                }else{
                    newAlbums.append(album)
                }
            }
            self.saveAlbums(datas: newAlbums, completion: completion)
        }
    }
    func getItems(albumId: Int,page: Int,completion: @escaping jsonBlock) {
        self.getAlbum(id: albumId, completion: {album in
            let perPage = 30
            var loadArray:[pixivAlbumData.ItemData] = []
            for i in perPage*page...perPage*(page+1){
                if album.items.count <= i {break}
                loadArray.append(album.items[i])
            }
            pixivInternalApi.getWorkDatas(withIDs: loadArray.map{item in return item.id}, completion: completion)
        })
    }
    func addItem(albumId: Int, data: pixivAlbumData.ItemData,completion: @escaping voidBlock) {
        self.getAlbum(id: albumId, completion: {album in
            var album = album
            album.items.insert(data, at: 0)
            self.saveAlbum(data: album, completion: completion)
        })
    }
    func deleteItem(albumId: Int, data: pixivAlbumData.ItemData,completion: @escaping voidBlock) {
        self.getAlbum(id: albumId, completion: {album in
            var album = album
            album.items.remove(data)
            self.saveAlbum(data: album, completion: completion)
        })
    }
    func deleteAllItems(albumId: Int,completion: @escaping voidBlock) {
        self.getAlbum(id: albumId, completion: {album in
            var album = album
            album.items = []
            self.saveAlbum(data: album, completion: completion)
        })
    }
    private func newAlbumId()->Int{
        let biggestId = info.intValue(forKey: "pixiv_albums_biggest_id")
        info.set(biggestId+1, forKey: "pixiv_albums_biggest_id")
        return biggestId+1
    }
    private func getAlbumKey()->String {
        return "pixiv_albums"
    }
}
