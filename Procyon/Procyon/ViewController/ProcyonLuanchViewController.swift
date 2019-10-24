import UIKit

class ProcyonLuanchViewController: ADViewController {
    let logoView = UIImageView()
    let overlayView = UIView()
    
    override func setSetting() {
        device.useVibrate = info.boolValue(forKey: "vibrate")
    }
    override func setUISetting() {
        view.backgroundColor = .back
        overlayView.backgroundColor = ProcyonSystem.mainColor
        overlayView.shadowLevel = 3
        
        logoView.image = UIImage(named: "ProcyonLogo")
    }
    override func setUIScreen() {
        overlayView.size = screen.size
        logoView.size = sizeMake(128, 128)
        logoView.center = center
    }
    override func addUIs() {
        addSubview(overlayView)
        addSubview(logoView)
    }

    override func setLoadControl() {
        
        let accounts = (info.array(forKey: "account") as? [[String:String]]) ?? []
        let PixivDefalutIndex = info.intValue(forKey: "pixiv-default-account-index")
        
        func enter(_ index:Int){
           
            
            let viewCon = PixivLaunchViewController()
            self.go(to: viewCon,usePush: false,animated: false)
        }
        if PixivDefalutIndex>0{
            if accounts.count>=PixivDefalutIndex{
                enter(PixivDefalutIndex-1)
            }
        }else if accounts.count == 1{
            enter(0)
        }
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.logoView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        },
            completion: {_ in}
        )
        UIView.animate(
            withDuration: 0.2,
            delay: 0.3,
            options: .curveEaseOut,
            animations: {
                self.logoView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        },
            completion: {_ in}
        )
        UIView.animate(
            withDuration: 0.5,
            delay: 0.3,
            options: .curveEaseIn,
            animations: {
                self.overlayView.frame.size.height = 200
                self.logoView.frame.size = sizeMake(100, 100)
                self.logoView.center.y = 110
                self.logoView.frame.origin.x = 45
            },
            completion: {_ in
                self.go(to: ProcyonMainViewController.instance(),animated: false)
            }
        )
    }
}


















