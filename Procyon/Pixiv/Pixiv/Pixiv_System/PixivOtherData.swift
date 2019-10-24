import UIKit

struct pixiVisionContentsData {
    var count: Int{
        return spotlightArticles.count
    }
    var spotlightArticles:[pixiVisionData]
    var nextUrl:String
    
    mutating func appendJson(_ json:JSON){
        self.spotlightArticles.append(
            contentsOf: json["spotlight_articles"].arrayValue.map{json in pixiVisionData(json: json)}
        )
        self.nextUrl = json["next_url"].stringValue
    }
    
    init(json: JSON) {
        self.spotlightArticles = json["spotlight_articles"].arrayValue.map{json in pixiVisionData(json: json)}
        self.nextUrl = json["next_url"].stringValue
    }
}
struct pixivWorkSearchSettingData {
    var sort:PixivSearchSort{
        set{info.set(newValue.rawValue, forKey: "pixiv_search_sort")}
        get{return PixivSearchSort(rawValue: info.stringValue(forKey: "pixiv_search_sort")) ?? .date_desc}
    }
    var target:PixivSearchTarget{
        set{info.set(newValue.rawValue, forKey: "pixiv_search_target")}
        get{return PixivSearchTarget(rawValue: info.stringValue(forKey: "pixiv_search_target")) ?? .partial_match_for_tags}
    }
    var duration:PixivSearchDuration{
        set{info.set(newValue.rawValue, forKey: "pixiv_search_duration")}
        get{return PixivSearchDuration(rawValue: info.stringValue(forKey: "pixiv_search_target")) ?? .all}
    }
}
struct pixivNovelSearchSettingData {
    var sort:PixivSearchSort{
        set{info.set(newValue.rawValue, forKey: "novel_search_sort")}
        get{return PixivSearchSort(rawValue: info.stringValue(forKey: "novel_search_sort")) ?? .date_desc}
    }
    var target:NovelSearchTarget{
        set{info.set(newValue.rawValue, forKey: "novel_search_target")}
        get{return NovelSearchTarget(rawValue: info.stringValue(forKey: "novel_search_target")) ?? .partial_match_for_tags}
    }
    var duration:PixivSearchDuration{
        set{info.set(newValue.rawValue, forKey: "novel_search_target")}
        get{return PixivSearchDuration(rawValue: info.stringValue(forKey: "novel_search_target")) ?? .all}
    }
}

struct pixiVisionData {
    var id:Int
    var title:String
    var thumbnail:String
    var articleUrl:String
    var publishDate:RMDate
    var category:categoryType
    var subcategoryLabel:String
    var pureTitle:String//謎
    
    enum categoryType: String{
        case spotlight//イラスト,Web漫画 ...
        case inspiration//インタビュー,おすすめ ...
        case tutorial//描き方,素材 ...
    }
    
    init(json:JSON) {
        self.id = json["id"].intValue
        self.title = json["title"].stringValue
        self.thumbnail = json["thumbnail"].stringValue
        self.articleUrl = json["article_url"].stringValue
        self.publishDate = RMDate(dateStr: json["publish_date"].stringValue, withType: .ISO8601)
        self.category = categoryType(rawValue: json["category"].stringValue) ?? .spotlight
        self.subcategoryLabel = json["subcategory_label"].stringValue
        self.pureTitle = json["pure_title"].stringValue
    }
}

struct pixivNovelThemeData {
    var font:pixivNovelFontData
    var color:pixivNovelColorData
    
    struct pixivNovelFontData {
        var font:UIFont{
            switch textFont {
            case .gothic:
                return Font.Roboto.font(textSize)
            case .mincho:
                return Font.HiraginoMincho.font(textSize)
            }
        }
        
        var textSize:CGFloat{
            didSet{
                info.set(textSize, forKey: "pixiv_novel_font_data_text_size")
            }
        }
        var textFont:pixivNovelThemeTextType{
            didSet{
                info.set(textFont.rawValue, forKey: "pixiv_novel_font_data_text_font")
            }
        }
        
        static var `default`:pixivNovelFontData{
            return pixivNovelFontData(textSize: 14, textFont: .mincho)
        }
        
        enum pixivNovelThemeTextType:Int {
            case mincho = 0
            case gothic
        }
        
        init(textSize: CGFloat,textFont: pixivNovelThemeTextType) {
            self.textSize = textSize
            self.textFont = textFont
        }
        init() {
            self.textSize = info.cgFloat(forKey: "pixiv_novel_font_data_text_size") ?? 14
            
            self.textFont = (pixivNovelThemeTextType(
                rawValue: info.intValue(forKey: "pixiv_novel_font_data_text_font")
            )) ?? .mincho
        }
    }
    
    struct pixivNovelColorData {
        var backgroundColor:UIColor
        var textColor:UIColor
        var index:Int{
            didSet{
                info.set(index, forKey: "pixiv_novel_color_data_index")
            }
        }
        
        static var white:pixivNovelColorData{
            return pixivNovelColorData(
                backgroundColor: .hex("fbfbfb"),
                textColor: .hex("1b1b1b"),
                index:0
            )
        }
        static var worm:pixivNovelColorData{
            return pixivNovelColorData(
                backgroundColor: .hex("F8F0E3"),
                textColor: .hex("4F311C"),
                index: 1
            )
        }
        static var gray:pixivNovelColorData{
            return pixivNovelColorData(
                backgroundColor: .hex("5a5a5c"),
                textColor: .hex("cccccc"),
                index: 2
            )
        }
        static var black:pixivNovelColorData{
            return pixivNovelColorData(
                backgroundColor: .hex("121212"),
                textColor: .hex("B0B0B0"),
                index: 3
            )
        }
        init(){
            self.init(index: info.intValue(forKey: "pixiv_novel_color_data_index"))
        }
        
        init(backgroundColor: UIColor,textColor: UIColor,index: Int){
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.index = index
        }
        init(index: Int){
            self.index = index
            switch index {
            case 0:
                self.backgroundColor = pixivNovelColorData.white.backgroundColor
                self.textColor = pixivNovelColorData.white.textColor
            case 1:
                self.backgroundColor = pixivNovelColorData.worm.backgroundColor
                self.textColor = pixivNovelColorData.worm.textColor
            case 2:
                self.backgroundColor = pixivNovelColorData.gray.backgroundColor
                self.textColor = pixivNovelColorData.gray.textColor
            case 3:
                self.backgroundColor = pixivNovelColorData.black.backgroundColor
                self.textColor = pixivNovelColorData.black.textColor
            default:
                self.backgroundColor = pixivNovelColorData.white.backgroundColor
                self.textColor = pixivNovelColorData.white.textColor
            }
        }
    }
    
    init() {
        font = pixivNovelFontData()
        color = pixivNovelColorData()
    }
}


