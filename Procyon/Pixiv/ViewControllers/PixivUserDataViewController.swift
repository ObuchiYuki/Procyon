import UIKit

class PixivUserDataInner: RMViewController{
    var userID = 0
    
    let socialView = PixivUserDataSocialView()
    private let mainScrollView = UIScrollView()
    private let accountView = PixivAccountView()
    private let textView = UITextView()
    
    private func createText(data: pixivFullUserData)->String{
        var text = ""
        var containsProfile = false
        if data.profile.gender != .other{text+="\(data.profile.gender.jpValue())/";containsProfile=true}
        if !data.profile.region.isEmpty{text+="\(data.profile.region)/";containsProfile=true}
        if !data.profile.job.isEmpty{text+="\(data.profile.job)/";containsProfile=true}
        if let birth = data.profile.birth{
            containsProfile=true
            text+="\(birth.string(for: "birth_format".l()))/"
            text+="age_[age]".l(birth.age)
        }
        if containsProfile{text+="\n\n\n"}
        text += data.user.comment
        return text
    }
    
    override func setSetting() {
        pixiv.getUserData(userID: userID, completion: {json in
            let data = pixivFullUserData(json: json)
            self.accountView.userData = data
            self.socialView.data = data.profile
            self.textView.text = self.createText(data: data)
            self.textView.sizeToFit()
            self.textView.width = screen.width-20
            self.mainScrollView.contentSize.height=self.textView.height+245
        })
    }
    override func setUISetting() {
        view.backgroundColor = .clear
        contentView.backgroundColor = .clear
        socialView.size = sizeMake(screen.width, 20)
        socialView.y = accountView.bottomY+5
        
        textView.size = sizeMake(screen.width-20, screen.height-accountView.height-72-85)
        textView.x = 10
        textView.y = socialView.bottomY+9
        textView.backgroundColor = .white
        textView.textColor = .subText
        textView.textAlignment = .center
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.dataDetectorTypes = .link
        textView.isScrollEnabled=false
        textView.setAsCardView(with: .auto)
        
        mainScrollView.size = contentSize
        mainScrollView.backgroundColor = .clear
    }
    override func setUIScreen() {
        
    }
    override func addUIs() {
        addSubview(mainScrollView)
        mainScrollView.addSubviews(accountView,socialView,textView)
    }
}

class PixivUserDataSocialView: RMView {
    var data:pixivFullUserData.pixivUserProfileData? = nil{
        didSet{
            guard let data = data else {return}
            if !data.webpage.isEmpty{
                webpageButton.title = "\u{f38f} \(data.webpage)"
                webpageButton.size = sizeMake(125, 24)
                webpageButton.x = 10
                webpageButton.titleEdgeInsets.left = 2
                webpageButton.titleEdgeInsets.right = 2
                webpageButton.titleLabel?.textAlignment = .left
                
                addSubview(webpageButton)
            }
            
            if !data.twitterUrl.isEmpty{
                twitterButton.title = "\u{f243} \(data.twitterAccount)"
                twitterButton.size = sizeMake(125, 24)
                twitterButton.x = webpageButton.rightX+10
                twitterButton.titleEdgeInsets.left = 2
                twitterButton.titleEdgeInsets.right = 2
                twitterButton.titleLabel?.textAlignment = .left
                
                addSubview(twitterButton)
            }
        }
    }
    let webpageButton = ADButton()
    let twitterButton = ADButton()
    
    override func setup() {
        webpageButton.titleLabel?.font = Font.IonIcons.font(14)
        webpageButton.cornerRadius = 2
        webpageButton.titleColor = .subText
        
        twitterButton.titleLabel?.font = Font.IonIcons.font(14)
        twitterButton.cornerRadius = 2
        twitterButton.titleColor = .subText
    }
}











