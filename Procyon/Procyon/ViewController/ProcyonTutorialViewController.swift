import UIKit
import SpriteKit

class ProcyonFirstAnimationViewController: UIViewController{
    static var current:ProcyonFirstAnimationViewController? = nil
    let procyonLogo = UIImageView(image: #imageLiteral(resourceName: "ProcyonLogo"))
    let skView = SKView(frame: UIScreen.main.bounds)
    let wrapperView = UIView(frame: UIScreen.main.bounds)
    let shadowView = UIView()
    let naviBar = UIView()
    let welcomeLabel = UILabel()
    let goNextButton = ADMainButton(icon: "arrow_forward")
    let noConnectionLabel = UILabel()
    var safeyNet = false
    func startViewAnimation(){
        guard net.isReachable else {return}
        wrapperView.runAction(
            .seqence([
                .groupe([.resize(to: sizeMake(140, 140), duration: 2),.cornerRadius(to: 40, duration: 2)]),
                .position(to: pointMake(wrapperView.centerX, 200), duration: 1)
            ])
        )
        procyonLogo.runAction(
            RMAction.seqence([
                .resize(to: procyonLogo.image?.size ?? .zero, duration: 2),
                .position(to: pointMake(wrapperView.centerX, 200), duration: 1)
            ])
        )
        shadowView.runAction(
            RMAction.seqence([
                .wait(duration: 2),
                .position(to: pointMake(wrapperView.centerX, 200), duration: 1),
                .groupe([
                    .shadowColor(to: .black, duration: 1),
                    .shadowOpacity(to: 0.7, duration: 1),
                    .shadowOffset(to: sizeMake(0, 4), duration: 1),
                    .shadowRadius(to: 5, duration: 1)
                ])
            ])
        )
        naviBar.runAction(
            RMAction.seqence([
                .wait(duration: 2),
                .groupe([
                    .origin(to: .zero, duration: 1),
                    .shadowColor(to: .black, duration: 1),
                    .shadowOpacity(to: 0.4, duration: 1),
                    .shadowOffset(to: sizeMake(0, 1.4), duration: 1),
                    .shadowRadius(to: 1, duration: 1)
                ])
            ])
        )
        welcomeLabel.runAction(
            .seqence([
                .wait(duration: 2),
                .opacity(to: 1, duration: 1)
            ])
        )
        goNextButton.runAction(
            .seqence([
                .wait(duration: 3),
                .run {goNextButton.animate()}
            ])
        )
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .back
        ProcyonFirstAnimationViewController.current = self
        
        noConnectionLabel.alpha = 0
        noConnectionLabel.y = view.centerY
        noConnectionLabel.text = "no_connection".l()
        noConnectionLabel.textAlignment = .center
        noConnectionLabel.textColor = .white
        noConnectionLabel.size = sizeMake(screen.width, 30)
        noConnectionLabel.font = Font.Roboto.font(20)
        if !net.isReachable{noConnectionLabel.runAction(.opacity(to: 1, duration: 6))}

        (info.arrayValue(forKey: "account") as! [[String:String]]).map{accountDaya in
            pixiv.logIn(username: accountDaya["mail"] ?? "", password: accountDaya["pass"] ?? ""){data in
                if data.hasError{return}
                pixiv.getAccountImage(userData: data.user){image in
                    let account = ProcyonAccountData(
                        type: .pixiv, name: data.user.name, id: data.user.account, password: accountDaya["pass"]!, image: image
                    )
                    ProcyonSystem.accounts.append(account)
                }
            }
        }
        run(after: 1, block: {
            if self.safeyNet == false{
                self.startViewAnimation()
            }
        })
        wrapperView.addSubview(skView)
        wrapperView.clipsToBounds = true
        
        procyonLogo.size = .zero
        procyonLogo.center = view.center
        
        shadowView.size = sizeMake(139, 139)
        shadowView.center = view.center
        shadowView.backgroundColor = .hex("1",alpha: 1)
        shadowView.layer.cornerRadius = 40
        
        naviBar.backgroundColor = ProcyonSystem.mainColor
        naviBar.size = sizeMake(screen.width, 52)
        naviBar.origin = pointMake(0, -52)
        
        welcomeLabel.text = "welcome_to_procyon".l()
        welcomeLabel.font = Font.Roboto.font(24,style: .normal)
        welcomeLabel.size = sizeMake(screen.width, 30)
        welcomeLabel.textAlignment = .center
        welcomeLabel.origin = pointMake(0, 80)
        welcomeLabel.alpha = 0
        welcomeLabel.textColor = .text
        
        goNextButton.layer.position = pointMake(screen.width/2, screen.height-100)
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
                    .run{self.present(ProcyonSystem.accounts.isEmpty ?
                        ProcyonFirstNoAccountsViewController() : ProcyonFirstLoginedViewController(), animated: false
                    )}
                ])
            )
        }
        
        self.view.addSubviews(shadowView,wrapperView,procyonLogo,naviBar,welcomeLabel,goNextButton,noConnectionLabel)
        
        let scene = LuanchScreenEmuratedScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
}
class LuanchScreenEmuratedScene: SKScene {
    let procyonLogo = SKSpriteNode(imageNamed: "ProcyonLogo")
    
    override func sceneDidLoad() {
        self.backgroundColor = .hex("3A49AA")
        procyonLogo.size = sizeMake(128, 128)
        procyonLogo.position = pointMake(size.width/2, size.height/2)
        ProcyonFirstAnimationViewController.current?.safeyNet = true
        
        addChild(procyonLogo)
        
        let timer = RMTimer()
        timer.startStopWatch(0.5){
            self.view?.presentScene(StarsScene(), transition: .fade(with: .black, duration: 1))
        }
    }
}
class StarsScene: SKScene {
    override func sceneDidLoad() {
        self.backgroundColor = .black
        self.size = UIScreen.main.bounds.size
        
        let timer = RMTimer()
        timer.start(0.3){[weak self] in
            guard let this = self else {return}
            let star = SKSpriteNode(color: .white, size: sizeMake(0, 0))
            let action = SKAction.sequence([
                SKAction.rotate(byAngle: π/4, duration: 0),
                SKAction.resize(toWidth: 0, height: 0, duration: 0),
                SKAction.resize(toWidth: 5, height: 5, duration: 5),
                SKAction.resize(toWidth: 0, height: 0, duration: 5),
                SKAction.run {star.removeFromParent()}
            ])
            action.timingMode = .easeInEaseOut
            star.run(action)
            star.position = pointMake(random(0...this.size.width.int), random(0...this.size.height.int))
            this.addChild(star)
        }
        runAfter(10){
            guard net.isReachable else {return}
            self.scene?.run(SKAction.colorize(with: .hex("3A49AA"), colorBlendFactor: 1, duration: 2))
            ProcyonFirstAnimationViewController.current?.startViewAnimation()
            ProcyonFirstAnimationViewController.current = nil
        }
    }
}
extension SKAction{
    func setEase(_ timingMode:SKActionTimingMode) -> SKAction {
        self.timingMode = timingMode
        return self
    }
}








