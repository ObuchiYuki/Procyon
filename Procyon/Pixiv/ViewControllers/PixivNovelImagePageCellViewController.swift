import UIKit

class PixivNovelPageCellViewController: ADPageCellViewController{
    //====================================================================
    //var
    private var backgroundTextView = UITextView()

    func checkNovelTheme(){
        backgroundTextView.backgroundColor = PixivSystem.novelTheme.color.backgroundColor
        backgroundTextView.textColor = PixivSystem.novelTheme.color.textColor
        backgroundTextView.font = PixivSystem.novelTheme.font.font
    }
    private func tap(){
        sendToRoot(identifier: "cellViewTapped", info: nil)
    }
    //====================================================================
    //override func
    override func set(data: Any?) {
        guard let text = data as? String else {return}
        backgroundTextView.text = text
    }
    //====================================================================
    //delegateMethod
    override func setUISetting() {
        contentView.addGestureAction(.tap, action: tap)
        
        backgroundTextView.isSelectable = false
        backgroundTextView.isScrollEnabled = true
        checkNovelTheme()
        
        isStatusBarHidden = true
    }
    override func setUIScreen() {
        backgroundTextView.size = fullScreenSize
    }
    override func setLoadControl() {
        checkNovelTheme()
    }
    override func addUIs() {
        addSubview(backgroundTextView)
    }
}


