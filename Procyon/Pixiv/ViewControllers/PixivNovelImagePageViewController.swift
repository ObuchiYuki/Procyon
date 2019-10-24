import UIKit

class PixivNovelPageViewController: PixivPageViewBaseController {
    //============================================================================
    //propertiess
    var data:pixivNovelData! = nil
    
    private var textData:pixivNovelTextData? = nil
    private let indicator = ADActivityIndicator()
    //============================================================================
    //method
    override func setSetting() {
        title = data.title
        pageCount = data.pageCount
        novel.getText(id: data.id, completion: {json in
            let textData = pixivNovelTextData(json: json)
            self.textData = textData
            self.startPageing()
            self.indicator.stop()
        })
        let tip = ADTip(icon: "format_size")
        tip.addAction{[weak self] in
            let dialog = ADDialog()
            let settingView = PixivNovelSettingView()
            settingView.themeChangeAction = {
                for cell in self?.viewControllers ?? []{
                    (cell as! PixivNovelPageCellViewController).checkNovelTheme()
                }
            }
            dialog.hideBackgroundView()
            dialog.title = "disply_setting".l()
            dialog.setCustomView(settingView)
            dialog.addOKButton()
            dialog.show()
        }
        addButtonRight(tip)
    }
    override func moreButtonTapped() {
        ADMenu.show(animated: true,iconArr: ["content_copy"],titles: ["copy_novel".l()],
            actionArr: [
                {
                    clipBoard.text = self.textData?.novelText.joined(separator: "\n") ?? ""
                    ADSnackbar.show("copied".l())
                },
            ]
        )
    }
    override func setUISetting() {
        view.backgroundColor = PixivSystem.novelTheme.color.backgroundColor
        contentView.backgroundColor = .clear
        
        indicator.center = center
        
        trasitionStyle = .pageCurl
        navigationOrientation = .horizontal
    }
    override func addUIs() {
        addSubview(indicator)
    }
    //============================================================================
    //delegateMethod
    override func didAfterPaging(from: Int, to: Int) {
        pageIndex = to
    }
    override func pageData() -> [Any] {
        return self.textData?.novelText ?? []
    }
    override func viewController(at index: Int) -> ADPageCellViewController {
        return PixivNovelPageCellViewController()
    }
}

