import UIKit

class ProcyonFirstLoginedViewController: UIViewController{
    let naviBar = UIView()
    let titleLabel = UILabel()
    let accountEditViewController = ProcyonAccountEditViewController()
    let goNextButton = ADMainButton(icon: "arrow_forward")
    
    override func viewDidLoad() {
        naviBar.size = sizeMake(screen.width, 52)
        naviBar.y = -54
        naviBar.shadowLevel = 2
        naviBar.backgroundColor = ProcyonSystem.mainColor
        naviBar.layer.shadowRadius = 1
        naviBar.runAction(.origin(to: .zero, duration: 0.5))
        
        titleLabel.size = sizeMake(screen.width, 30)
        titleLabel.font = Font.Roboto.font(15)
        titleLabel.textColor = .text
        titleLabel.y = 65
        titleLabel.text = "these_accounts_are_converted".l()
        titleLabel.textAlignment = .center
        
        accountEditViewController.view.size = sizeMake(screen.width, screen.height-110)
        accountEditViewController.tableView.y = 110
        accountEditViewController.withAction = false
        
        goNextButton.layer.position = pointMake(screen.width/2, screen.height-100)
        goNextButton.runAction(.seqence([.wait(duration: 0.3),.run{self.goNextButton.animate()}]))
        goNextButton.addAction {
            self.goNextButton.runAction(
                RMAction.seqence([
                    RMAction.groupe([
                        .run {self.goNextButton.titleLabel?.runAction(.opacity(to: 0, duration: 0.1))},
                        .resize(to: screen.size, duration: 1),
                        .cornerRadius(to: 0, duration: 1),
                        .backgroundColor(to: .back, duration: 1),
                        .position(to: self.view.center, duration: 1),
                    ]).setEase(RMActionEaseMode.easeInOutCubic),
                    .run{
                        PixivSystem.resetAccountData(ProcyonSystem.accounts[0])
                        info.set(true, forKey: "first_initial_end")
                        info.set([], forKey: "account")
                        self.present(PixivMainViewController.instance(), animated: false)
                    }
                ])
            )
        }
        
        view.backgroundColor = .back
        view.addSubviews(naviBar,titleLabel,accountEditViewController.tableView,goNextButton)
        
    }
}
