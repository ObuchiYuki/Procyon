import UIKit

class ADViewController: RMViewController {
    //==================================
    // mainButton {getter and setter}
    //this is android like Main button
    //you make button in setUISetting() and add here
    final var mainButton:ADMainButton? = nil{
        willSet(value){
            if mainButton == nil {
                setMainButtonPosition(value)
                view.addSubview(value!)
            }
        }
    }
    var drawerController:ADDrawerController? {
        if let drawerController = navigationController?.parent as? ADDrawerController {return drawerController}else{return nil}
    }
    override func setupScreen_P(){
        super.setupScreen_P()
        addKeyCommand(input: "d", modifierFlags: .command, action: {[weak self] in self?.drawerController?.open()})
        addKeyCommand(input: "w", modifierFlags: .command, action: {[weak self] in self?.drawerController?.close()})
        if mainButton != nil{
            setMainButtonPosition(mainButton)
        }
    }
    override func setupSetting_P(){
        super.setupSetting_P()
        mainButton?.setup()
    }
    override func setLoadControl_P(){
        mainButton?.animate()
    }
    //====================================================================
    //private method
    private func setMainButtonPosition(_ button:ADMainButton?){
        switch button!.position {
        case .lowerRight:
            button?.frame.origin = CGPoint(x: view.frame.width - 75, y: view.frame.height - 75)
        case .lowerLeft:
            button?.frame.origin = CGPoint(x: 15, y: view.frame.height - 75)
        case .lowerCenter:
            button?.frame.origin = CGPoint(x: 0, y: view.frame.height - 75)
            button?.layer.position.x = self.view.layer.position.x
        case .upperRight:
            button?.frame.origin = CGPoint(x: screen.width - 75, y: 45)
        case .upperLeft:
            button?.frame.origin = CGPoint(x: 15, y: 42)
        case .upperCenter:
            button?.frame.origin = CGPoint(x: 0, y: 42)
            button?.layer.position.x = self.view.layer.position.x
        }
    }
}
