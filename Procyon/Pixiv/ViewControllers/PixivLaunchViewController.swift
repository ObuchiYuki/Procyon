import UIKit

class PixivLaunchViewController: ADViewController {
    private var launchImage = UIImageView(image: UIImage(named: "PixivLaunchImage"))
    private var isfinLogin = false{
        didSet{
            if isfinLogin{
                PixivSystem.reloadTagBookmark()
                startAnimation()
            }
        }
    }
    
    override func setSetting() {
        isStatusBarHidden = true
    }
    override func setUISetting() {
        launchImage.center = view.center
        launchImage.frame.size = Size(92, 92)
        view.backgroundColor = UIColor.white
    }
    override func setUIScreen() {
        
    }
    override func addUIs() {
        addSubview(launchImage)
    }
    func startAnimation(){
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: UIViewAnimationOptions.curveEaseOut,
            animations: {
                self.launchImage.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            },
            completion: {_ in}
        )
        UIView.animate(
            withDuration: 0.2,
            delay: 0.3,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: {
                self.launchImage.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                self.launchImage.alpha = 0
            },
            completion: {_ in
                self.go(to: PixivMainViewController.instance(),usePush: false,animated: false)
            }
        )
    }
    override func setLoadControl() {
        
    }
}


















