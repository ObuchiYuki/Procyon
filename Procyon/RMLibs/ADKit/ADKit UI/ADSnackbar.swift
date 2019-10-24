import UIKit

class ADSnackbar: UIWindow {
    //==========================================================================
    //Public proparties
    //======================================
    //text is a text of Snackbar
    var title = "" {
        didSet {
            tieleLabel.text = title
        }
    }
    //======================================
    //block Title is a title of block button
    var actionTitle = "" {
        didSet {
            actionButtonEnable = true
            actionButton.title = actionTitle
            actionButton.sizeToFit()
            actionButton.width += 20
            actionButton.frame.origin.x = screen.width-actionButton.width-10
        }
    }
    //======================================
    //set text color
    var textColor = UIColor.white {
        didSet {
            tieleLabel.textColor = textColor
        }
    }
    //======================================
    //set text color
    var actionTitleColor = UIColor.accent {
        didSet {
            tieleLabel.textColor = textColor
        }
    }
    var duration: TimeInterval = 2.5
    var completion = {}
    var progessPer:Float = 0{
        didSet{
            self.progressBar.setProgress(progessPer, animated: true)
        }
    }
    //==========================================================================
    //private proparties
    private static var isShowing = false
    private var actionButtonEnable = false
    private var contentView = UIView()
    private var tieleLabel = RMLabel()
    private var actionButton = ADButton()
    private var progressBar = UIProgressView()

    private weak var fromViewController:ADViewController? = nil
    //==========================================================================
    //Public methods
    func show(_ fromViewController:ADViewController? = nil){
        self.makeKey()
        self.makeKeyAndVisible()
        self.fromViewController = fromViewController
        open()
        if duration > 0{
            run(after: duration){
                if !self.actionButtonEnable{
                    self.close()
                }
            }
        }
    }
    func setProgress(){
        progressBar.isHidden = false
        progressBar.setProgress(0, animated: true)
    }
    func close() {
        ADSnackbar.isShowing = false
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: UIViewAnimationOptions(),
            animations: {
                self.tieleLabel.alpha = 0
                self.actionButton.alpha = 0
                self.contentView.frame.origin.y = 60
                if self.fromViewController?.mainButton != nil {
                    self.fromViewController?.mainButton?.transform = CGAffineTransform(translationX: 0, y: 0)
                }
            },
            completion: {_ in
                self.completion = {}
                self.actionButton.removeAllActions()
                self.isHidden = true
                self.removeFromSuperview()
                self.contentView.removeFromSuperview()
                self.tieleLabel.removeFromSuperview()
                self.actionButton.removeFromSuperview()
            }
        )
    }
    //==========================================================================
    //init
    init(){
        super.init(frame: CGRect.zero)
        setup()
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    private func setup() {
        self.frame.size = sizeMake(screen.width, 60)
        self.frame.origin.y = screen.height - 60
        
        contentView.frame.size = sizeMake(screen.width, 60)
        contentView.backgroundColor = .hex("444444")
        contentView.frame.origin.y = 60
        
        tieleLabel.font = Font.Roboto.font(14)
        tieleLabel.frame.origin.x = 20
        tieleLabel.frame.size = sizeMake(self.contentView.frame.width - 20, 30)
        tieleLabel.center.y = 30
        tieleLabel.textColor = textColor
        tieleLabel.alpha = 0

        actionButton.titleLabel?.font = Font.Roboto.font(16, style: .bold)
        actionButton.titleColor = actionTitleColor
        actionButton.frame.size = sizeMake(0, 30)
        actionButton.center.y = 30
        actionButton.safeCornerRadius = 2
        actionButton.tintColor = ADColor.Blue.P500
        actionButton.alpha = 0
        actionButton.addAction{[weak self] in
            guard let me = self else {return}
            me.close()
        }
        
        progressBar.width = self.contentView.width
        progressBar.height = 10
        progressBar.backgroundColor = UIColor.white
        progressBar.isHidden = true
        
        self.addSubview(contentView)
        contentView.addSubview(tieleLabel)
        contentView.addSubview(actionButton)
        contentView.addSubview(progressBar)
    }
    private func open(){
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: UIViewAnimationOptions(),
            animations: {
                self.tieleLabel.alpha = 1
                self.actionButton.alpha = 1
                self.contentView.frame.origin.y = 0
                if self.fromViewController?.mainButton != nil {
                    self.fromViewController?.mainButton?.transform = CGAffineTransform(translationX: 0, y: -60)
                }
            },
            completion: {_ in}
        )
    }
}

extension ADSnackbar{
    class func show(_ title:String){
        let snack = ADSnackbar()
        snack.title = title
        snack.show()
    }
}




