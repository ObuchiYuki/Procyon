import UIKit

class RMTextView: UIView {
    /*var lineSpaceing = 28.0
    var font = Font.Roboto.font(14)
    var text = [
        "任天堂の君島達己社長は、日本経済新聞の取材でNintendo",
        "Switchのオンラインサービスを強化する方針を",
        "示しました。Wii Uではゲームのオンライン機能は無料で",
        "提供されていましたが、Nintendo Switchでは年間料金2000円～3000円で",
        "有料化されるとのこと。",
        "この方針について君島社長は「有料の方がきちんとお客さんにコミットできる」と発言しています。",
    ].joined(separator: "\n")
    override func draw(_ rect: CGRect) {
        let attributed = NSMutableAttributedString(string: self.text)
        var lineSpaceing = self.lineSpaceing
        let settings = [
            CTParagraphStyleSetting(
                spec: .minimumLineHeight,
                valueSize: Int(MemoryLayout.size(ofValue: lineSpaceing)),
                value: &lineSpaceing
            )
        ]
        let style = CTParagraphStyleCreate(settings, 1)
        attributed.addAttributes(
            [
                NSFontAttributeName: font,
                NSVerticalGlyphFormAttributeName: true,
                kCTParagraphStyleAttributeName as String: style,
            ],
            range: NSMakeRange(0, attributed.length)
        )
        guard let context = UIGraphicsGetCurrentContext() else {return}
        
        context.setFillColor(self.backgroundColor?.cgColor ?? UIColor.white.cgColor)
        context.addRect(rect)
        context.fillPath()
        context.rotate(by: CGFloat(M_PI_2))
        context.translateBy(x: 5, y: 5)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let framesetter = CTFramesetterCreateWithAttributedString(attributed)
        let path = sizeMake(rect.height, rect.width).rect.path
        let frame = CTFramesetterCreateFrame(framesetter, .zero, path, nil)
        CTFrameDraw(frame, context)
    }*/
}











