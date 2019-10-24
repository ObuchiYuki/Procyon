import UIKit

class PixivCommentViewCell:PixivCardCellBase{
    
    class func height(withComment comment:String)->CGFloat{
        let commentTextView = UITextView()
        commentTextView.text = comment
        commentTextView.size = sizeMake(screen.width-100, 10)
        commentTextView.noPadding()
        commentTextView.font = Font.Roboto.font(13,style: .normal)
        return commentTextView.height+52
    }
    var commentData:pixivCommentsData.pixivCommentData?{
        set{
            if let commentData = newValue{
                _commentData = commentData
                userNameLabel.text = commentData.user.name.omit(10) + "・" + commentData.date.get(withType: .short)
                commentTextView.text = commentData.comment
                commentTextView.size =  commentTextView.sizeThatFits(sizeMake(screen.width-100, 10000))
            }
        }
        get{
            return _commentData
        }
    }
    private var _commentData:pixivCommentsData.pixivCommentData? = nil
    var userImage:UIImage? = nil{
        didSet{
            asyncQ {
                let image = self.userImage?.resize(to: sizeMake(40, 40)*2)
                mainQ {self.userImageView.image = image}
            }
        }
    }
    var id:Int{
        return _commentData?.id ?? -1
    }
    private let userImageView = UIImageView()
    private let userNameLabel = UILabel()
    private let dateLabel = UILabel()
    private let commentTextView = UITextView()
    
    func reset(){
        commentTextView.text = nil
        userNameLabel.text = nil
        dateLabel.text = nil
        userImageView.image = nil
    }
    
    override func setup() {
        super.setup()
        cardView.height = 1000
        cardView.setAsCardView(with: .bordered)
        userImageView.size = sizeMake(40, 40)
        userImageView.origin = Point(15, 15)
        userImageView.noCorner()
        userImageView.clipsToBounds = true
        userImageView.backgroundColor = .hex("bbbbbb")
        
        userNameLabel.size = sizeMake(screen.width-100, 14)
        userNameLabel.origin = Point(70, 20)
        userNameLabel.textColor = .subText
        userNameLabel.font = Font.Roboto.font(13,style: .normal)
        
        commentTextView.width = screen.width-100
        commentTextView.origin = Point(70, 42)
        commentTextView.noPadding()
        commentTextView.dissableFunctions()
        commentTextView.backgroundColor = .clear
        commentTextView.font = Font.Roboto.font(13,style: .normal)
        commentTextView.textColor = .text
        commentTextView.isUserInteractionEnabled = false
        
        addSubview(userImageView)
        addSubview(userNameLabel)
        addSubview(commentTextView)
    }
}
