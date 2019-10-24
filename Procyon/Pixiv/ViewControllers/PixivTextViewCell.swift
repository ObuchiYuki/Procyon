import UIKit

class PixivTextViewCell: PixivCardCellBase {
    let textView = UITextView()
    var titleColor:UIColor?{
        set{textView.textColor = newValue}
        get{return textView.textColor}
    }
    var title:String = ""{
        didSet{
            textView.text = title
            textView.sizeToFit()
            self.height = textView.height
        }
    }
    var attributCaption:String? = nil{
        didSet{
            if let attributCaption = attributCaption{
                textView.attributedText = attributCaption.htmlAttributedString
                textView.sizeToFit()
                self.height = textView.height
                cardView.height = textView.height+100
                cardView.setAsCardView(with: .bordered) 
            }
        }
    }
    func reset(){
        textView.font = Font.Roboto.font(12)        
        textView.isUserInteractionEnabled = false
        textView.dissableFunctions()
    }
    override func setup() {
        super.setup()
        textView.backgroundColor = .clear
        textView.isUserInteractionEnabled = false
        textView.origin = CGPoint(x: 15, y: 5)
        textView.noPadding()
        addSubview(textView)
    }
    override func didFrameChange() {
        textView.width = self.width - 30
    }
    class func getHight(withText text:String)->CGFloat{
        let textView = UITextView()
        textView.text = text
        let size = textView.sizeThatFits(sizeMake(screen.width-30, 100000))
        return size.height
    }
    class func getHight(withAttributText attributText:NSAttributedString)->CGFloat{
        let textView = UITextView()
        textView.attributedText = attributText
        let size = textView.sizeThatFits(sizeMake(screen.width-30, 100000))
        return size.height
    }
}







