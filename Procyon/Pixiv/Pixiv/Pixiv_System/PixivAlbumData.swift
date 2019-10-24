
struct pixivAlbumData: Storable{
    var count:Int{
        return items.count
    }
    var imageUrl:String{
        return items.index(0)?.imageUrl ?? ""
    }
    var id:Int
    var title:String
    var items:[ItemData]
    
    var dict:[String:Any]{
        return ["id": id,"title": title,"items": items.map{item in return item.dict}]
    }
    struct ItemData: Storable, Equatable{
        var id:Int
        var imageUrl:String
        
        var dict: [String : Any]{
            return ["id": id,"image_url": imageUrl]
        }
        init(data: pixivWorkData){
            self.id = data.id
            self.imageUrl = data.imageUrls.squareMedium
        }
        init(dict: [String : Any]) {
            self.id = intValue(of: dict["id"])
            self.imageUrl = stringValue(of: dict["image_url"])
        }
        static func == (lhs: ItemData, rhs: ItemData) -> Bool{
            return lhs.id == rhs.id
        }
    }
    init(id:Int,title:String){
        self.id = id
        self.title = title
        self.items = []
    }
    init(id:Int,title:String,imageUrl:String,items: [ItemData]){
        self.id = id
        self.title = title
        self.items = items
    }
    init(dict: [String : Any]) {
        self.id = intValue(of: dict["id"])
        self.title =  stringValue(of: dict["title"])
        self.items = dictArrayValue(of: dict["items"]).map{dict in ItemData(dict: dict)}
    }
}
