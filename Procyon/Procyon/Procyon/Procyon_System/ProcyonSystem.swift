import UIKit

struct ProcyonAccountData {
    var type:AccountType
    var name:String
    var id:String
    var password:String
    var image:UIImage?
    
    var isTemporary = false
    
    init(type:AccountType,name:String,id:String,password:String,image:UIImage?) {
        self.type = type
        self.name = name
        self.id = id
        self.password = password
        self.image = image
    }
    
    enum AccountType:String {case pixiv}
}
extension ProcyonAccountData: Storable{
    init(dict: [String : Any]) {
        self.type = AccountType(rawValue: stringValue(of: dict["type"])) ?? .pixiv
        self.name = stringValue(of: dict["name"])
        self.id = stringValue(of: dict["id"])
        self.password = stringValue(of: dict["password"])
        self.image = UIImage(data: dict["image"] as? Data ?? Data())
    }
    var dict: [String : Any]{
        return ["type":type.rawValue,"name":name,"id":id,"password":password,"image": image?.pngData as Any]
    }
}
extension ProcyonAccountData: Equatable{
    static func ==(lhs: ProcyonAccountData, rhs: ProcyonAccountData) -> Bool{
        return lhs.id == rhs.id
    }
}


class ProcyonSystem {
    static var shareEnd:Bool{
        set{info.set(shareEnd,forKey: "share_end")}
        get{return info.boolValue(forKey: "share_end")}
    }
    static let version = "1.2.8"
    static let mainColor:UIColor = .hex("3A49AA")
    static var procyonJson:JSON? = nil
    static var mode = ProcyonMode.procyon
    static var isURLPathFin = true
    static var isURLLoginFin = true
    static var loadIndex = 0
    static var accounts = [ProcyonAccountData](){
        didSet{info.setStorableArray(accounts, forKey: "procyon_account_datas")}
    }
    
    static var isPremium:Bool{
        return store.isBought(id: "procyon_premium")
    }
    static var localNotificationCount = 0
    static func buyPremiun(completion:@escaping voidBlock){
        let dialog = ADDialog()
        dialog.title = "purchase_album?".l()
        dialog.message = "album_description".l()
        dialog.addButton(title: "purchase".l(), with: {
            store.buy(id: "procyon_premium", completion: {success in
                if success{
                    ADDialog.show(title: "done".l(),message: "purchase_was_succeeded".l())
                    completion()
                }else{
                    ADDialog.show(title: "error".l(),message: "purchase_was_failed".l())
                }
            })
        })
        dialog.addCancelButton()
        dialog.show()
    }
}
enum ProcyonMode {
    case procyon
    case pixiv
}
struct ProcyonData {
    static var procyonStoreUrl = "http://appstore.com/Procyonイラストビュアーforpixiv".encodedForURL.url!
}
