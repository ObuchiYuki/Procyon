import UIKit

class ProcyonFirstNoAccountsViewController: UIViewController {
    let naviBar = UIView()
    let cardView = UIView()
    let titleLabel = UILabel()
    let button1 = ADButton()
    let button2 = ADButton()
    
    override func viewDidLoad() {
        self.view.backgroundColor = .back
        naviBar.size = sizeMake(screen.width, 52)
        naviBar.y = -54
        naviBar.shadowLevel = 2
        naviBar.backgroundColor = ProcyonSystem.mainColor
        naviBar.layer.shadowRadius = 1
        naviBar.runAction(.origin(to: .zero, duration: 0.5))
        
        cardView.size = sizeMake(screen.width<300 ? screen.width-10 : 300, 100)
        cardView.centerY = view.centerY
        cardView.centerX = view.centerX
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 4
        cardView.layer.shadowRadius = 2
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowOffset = sizeMake(0, 0.5)
        
        titleLabel.text = "login".l()
        titleLabel.font = Font.Roboto.font(24,style: .normal)
        titleLabel.size = sizeMake(screen.width, 30)
        titleLabel.textAlignment = .center
        titleLabel.origin = pointMake(0, 80)
        titleLabel.textColor = .text
        
        button1.size = sizeMake(cardView.width, 50)
        button1.titleColor = .subText
        button1.y = 50*0
        button1.title = "login_with_created_account".l()
        button1.addAction {[weak self] in
            self?.present(ProcyonFirstLoginViewController.withNavigation, animated: true)
        }
        
        button2.size = sizeMake(cardView.width, 50)
        button2.titleColor = .subText
        button2.y = 50*1
        button2.title = "create_new_account".l()
        button2.addAction {[weak self] in
            self?.present(ProcyonFirstCreateAccountViewController(), animated: true)
        }
        
        cardView.addSubviews(button1,button2)
        view.addSubviews(naviBar,cardView,titleLabel)
    }
}
