import UIKit

class PixivPageViewBaseController: ADPageViewController{
    //====================================================================
    //properties
    var pageIndex = 0{didSet{setupPageLabel()}}
    var pageCount = 0{didSet{setupPageLabel()}}
    
    private var isBarClosed = true
    //======================================
    //Views
    private let moreButton = ADTip(icon: "more_vert")
    private let bottomView = UIView()
    private let pageLabel = UILabel()
    //====================================================================
    //method
    //======================================
    //moreButtonTapped
    func moreButtonTapped(){}
    private func setupPageLabel(){
        pageLabel.text = "\(pageIndex+1)/\(pageCount)"
    }
    private func closeBar(){
        self.isBarClosed = true
        UIView.animateKeyframes(withDuration: 0.5,delay: 0,options: .calculationModeCubic,
            animations: {
                self.navigationBar.frame = CGRect(
                    origin: Point(0, -72),
                    size: CGSize(width: self.view.frame.width, height: 52)
                )
                self.bottomView.frame = CGRect(
                    origin: Point(0, self.view.frame.height),
                    size: sizeMake(self.view.frame.width, 52)
                )
            },
            completion: {_ in}
        )
    }
    private func openBar(){
        self.isBarClosed = false
        UIView.animateKeyframes(withDuration: 0.5,delay: 0,options: .calculationModeCubic,
            animations: {
                self.navigationBar.frame = CGRect(
                    origin: Point(0, 0),
                    size: CGSize(width: self.view.frame.width, height: 52)
                )
                self.bottomView.frame = CGRect(
                    origin: Point(0, self.view.frame.height - 52),
                    size: sizeMake(self.view.frame.width, 52)
                )
            },
            completion: {_ in
                run(after: 3, block: {
                    self.closeBar()
                })
            }
        )
    }
    override func setupSetting_P() {
        super.setupSetting_P()
        
        themeColor = .hex("0", alpha: 0.6)
        bottomView.backgroundColor = .hex("0", alpha: 0.6)
        
        pageLabel.frame.size = sizeMake(100, 30)
        pageLabel.textColor = .white
        pageLabel.textAlignment = .center
        
        statusBarBackgroundColor = .clear
        
        navigationBar.origin = .zero
        
        moreButton.addAction{ [weak self] in
            self?.moreButtonTapped()
        }
        
        addButtonRight(moreButton)
        bottomView.addSubview(pageLabel)
        view.addSubview(bottomView)
    }
    override func setupScreen_P() {
        super.setupScreen_P()
        useTranslucentNavigationBar = true
        useFullScreen = true
        
        contentView.size = fullScreenSize
        bottomView.frame = CGRect(origin: Point(0, view.frame.height - 52), size: sizeMake(view.frame.width, 52))
        pageLabel.centerX = bottomView.centerX
        pageLabel.y = 6
    }
    override func setLoadControl_P() {
        super.setLoadControl_P()
        closeBar()
    }
    override func receiveMessage(identifier: String, info: Any?) {
        switch identifier {
        case "cellViewTapped":
            if isBarClosed {openBar()}else{closeBar()};
        default:
            break
        }
    }
}














