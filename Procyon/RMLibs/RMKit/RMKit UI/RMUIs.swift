//======================================================================
//UIControl継承クラス全部上書きして、closure使えるようにしているだけ。
//本当にSelector大っ嫌い。

import UIKit

enum RMGestureType {
    case tap
    case longHold
    case pinch
    case pan
    case swipe
    case rotation
}
class RMImage: UIImage {
    private var saveToPhotoAlbumAction = {}
    @objc private func saveEnd(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer){
        saveToPhotoAlbumAction()
    }
    func saveToPhotoAlbum(_ then:@escaping voidBlock){
        self.saveToPhotoAlbumAction = then
        UIImageWriteToSavedPhotosAlbum(self, self, #selector(RMImage.saveEnd(_:didFinishSavingWithError:contextInfo:)), nil)
    }
}
class RMCollectionViewCell:UICollectionViewCell{
    override var frame: CGRect{
        set{
            super.frame = newValue
            didFrameChange()
        }
        get{
            return super.frame
        }
    }
    func didFrameChange(){}
    func setup(){}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}
class RMCollectionView: UICollectionView {
    init(layout:UICollectionViewLayout){
        super.init(frame: .zero, collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class RMTableViewCell: UITableViewCell {
    func setup(){
        separator.width = self.width
        separator.height = 0.5
        separator.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        addSubview(separator)
        backgroundColor = .clear
    }
    func didFrameChange(){}
    let separator = UIView()
    
    override var frame: CGRect{
        set{
            super.frame = newValue
            didFrameChange()
        }
        get{return super.frame}
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }
}

class RMImageView:UIImageView{
    func setup(){}
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}
class RMView: UIView{
    override var frame: CGRect{
        set{
            super.frame = newValue
            didChangeFrame()
        }
        get{
            return super.frame
        }
    }
    func didChangeFrame(){}
    func setup(){}
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}
class RMControl: UIControl {
    //===================================================
    //これボタンの意味もうなくない？
    private var tapActions = [voidBlock]()
    private var longHoldActions = [voidBlock]()
    private var pinchActions = [voidBlock]()
    private var panActions = [voidBlock]()
    private var swipeActions = [voidBlock]()
    private var rotationActions = [voidBlock]()
    
    private var tapGestureRecognizer:UITapGestureRecognizer? = nil
    private var longHoldGestureRecognizer:UILongPressGestureRecognizer? = nil
    private var pinchGestureRecognizer:UIPinchGestureRecognizer? = nil
    private var panGestureRecognizer:UIPanGestureRecognizer? = nil
    private var swipeGestureRecognizer:UISwipeGestureRecognizer? = nil
    private var rotationGestureRecognizer:UIRotationGestureRecognizer? = nil
    
    func addGestureAction(_ gestureType:RMGestureType,action:@escaping voidBlock){
        switch gestureType {
        case .tap:
            tapActions.append(action)
            if tapGestureRecognizer == nil{
                tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RMControl.TapAction))
                self.addGestureRecognizer(tapGestureRecognizer!)
            }
        case .longHold:
            longHoldActions.append(action)
            if longHoldGestureRecognizer == nil{
                longHoldGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RMControl.LongHoldAction))
                self.addGestureRecognizer(longHoldGestureRecognizer!)
            }
        case .pinch:
            pinchActions.append(action)
            if pinchGestureRecognizer == nil{
                pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(RMControl.PinchAction))
                self.addGestureRecognizer(pinchGestureRecognizer!)
            }
        case .pan:
            panActions.append(action)
            if panGestureRecognizer == nil{
                panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(RMControl.PanAction))
                self.addGestureRecognizer(panGestureRecognizer!)
            }
        case .swipe:
            swipeActions.append(action)
            if swipeGestureRecognizer == nil{
                swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(RMControl.swipeAction))
                self.addGestureRecognizer(swipeGestureRecognizer!)
            }
        case .rotation:
            rotationActions.append(action)
            if rotationGestureRecognizer == nil{
                rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(RMControl.rotationAction))
                self.addGestureRecognizer(rotationGestureRecognizer!)
            }
        }
    }
    @objc private func TapAction(){
        tapActions.runAll()
    }
    @objc private func LongHoldAction(){
        longHoldActions.runAll()
    }
    @objc private func PinchAction(){
        pinchActions.runAll()
    }
    @objc private func PanAction(){
        panActions.runAll()
    }
    @objc private func swipeAction(){
        swipeActions.runAll()
    }
    @objc private func rotationAction(){
        rotationActions.runAll()
    }
    init(){
        super.init(frame: CGRect.zero)
        setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setup(){}
    
    private var actions = [voidBlock]()
    private var isfirst = true
    
    func addAction(_ block:@escaping voidBlock,forControlEvents ControlEvents:UIControlEvents){
        actions.append(block)
        if isfirst {
            addTarget(self, action: #selector(RMControl.Actions), for: ControlEvents)
            isfirst = false
        }
    }
    func addAction(_ block:@escaping voidBlock){
        addAction(block, forControlEvents: .touchUpInside)
    }
    func removeAllActions(){
        actions = []
    }
    @objc private func Actions(){
        actions.runAll()
    }
    func removeGestureAction(type:RMGestureType){
        switch type {
        case .tap:
            guard let tapGestureRecognizer = tapGestureRecognizer else { return }
            self.removeGestureRecognizer(tapGestureRecognizer)
            self.tapActions = []
        case .longHold:
            guard let longHoldGestureRecognizer = longHoldGestureRecognizer else { return }
            self.removeGestureRecognizer(longHoldGestureRecognizer)
            self.longHoldActions = []
        case .pan:
            guard let panGestureRecognizer = panGestureRecognizer else { return }
            self.removeGestureRecognizer(panGestureRecognizer)
            self.panActions = []
        case .pinch:
            guard let pinchGestureRecognizer = pinchGestureRecognizer else { return }
            self.removeGestureRecognizer(pinchGestureRecognizer)
            self.pinchActions = []
        case .rotation:
            guard let rotationGestureRecognizer = rotationGestureRecognizer else { return }
            self.removeGestureRecognizer(rotationGestureRecognizer)
            self.rotationActions = []
        case .swipe:
            guard let swipeGestureRecognizer = swipeGestureRecognizer else { return }
            self.removeGestureRecognizer(swipeGestureRecognizer)
            self.swipeActions = []
        }
    }
}
class RMRefreshControl:UIRefreshControl {
    private var actions = [voidBlock]()
    private var isfirst = true
    func addAction(_ block:@escaping voidBlock,forControlEvents ControlEvents:UIControlEvents){
        actions.append(block)
        if isfirst {
            addTarget(self,action: #selector(RMRefreshControl.Actions),for: ControlEvents)
            isfirst = false
        }
    }
    func addAction(_ block:@escaping voidBlock){
        addAction(block, forControlEvents: .valueChanged)
    }
    func removeAllActions(){
        actions = []
    }
    @objc private func Actions(){
        actions.runAll()
    }
}
class RMButton: UIButton {
    
    private var actions = [voidBlock]()
    private var isfirst = true
    
    private var tapActions = [voidBlock]()
    private var longHoldActions = [voidBlock]()
    private var pinchActions = [voidBlock]()
    private var panActions = [voidBlock]()
    private var swipeActions = [voidBlock]()
    private var rotationActions = [voidBlock]()
    
    private var tapGestureRecognizer:UITapGestureRecognizer? = nil
    private var longHoldGestureRecognizer:UILongPressGestureRecognizer? = nil
    private var pinchGestureRecognizer:UIPinchGestureRecognizer? = nil
    private var panGestureRecognizer:UIPanGestureRecognizer? = nil
    private var swipeGestureRecognizer:UISwipeGestureRecognizer? = nil
    private var rotationGestureRecognizer:UIRotationGestureRecognizer? = nil
    
    func addGestureAction(_ gestureType:RMGestureType,action:@escaping voidBlock){
        switch gestureType {
        case .tap:
            tapActions.append(action)
            if tapGestureRecognizer == nil{
                tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RMButton.TapAction))
                self.addGestureRecognizer(tapGestureRecognizer!)
            }
        case .longHold:
            longHoldActions.append(action)
            if longHoldGestureRecognizer == nil{
                longHoldGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RMButton.LongHoldAction))
                self.addGestureRecognizer(longHoldGestureRecognizer!)
            }
        case .pinch:
            pinchActions.append(action)
            if pinchGestureRecognizer == nil{
                pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(RMButton.PinchAction))
                self.addGestureRecognizer(pinchGestureRecognizer!)
            }
        case .pan:
            panActions.append(action)
            if panGestureRecognizer == nil{
                panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(RMButton.PanAction))
                self.addGestureRecognizer(panGestureRecognizer!)
            }
        case .swipe:
            swipeActions.append(action)
            if swipeGestureRecognizer == nil{
                swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(RMButton.swipeAction))
                self.addGestureRecognizer(swipeGestureRecognizer!)
            }
        case .rotation:
            rotationActions.append(action)
            if rotationGestureRecognizer == nil{
                rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(RMButton.rotationAction))
                self.addGestureRecognizer(rotationGestureRecognizer!)
            }
        }
    }
    @objc private func TapAction(){
        tapActions.runAll()
    }
    @objc private func LongHoldAction(){
        longHoldActions.runAll()
    }
    @objc private func PinchAction(){
        pinchActions.runAll()
    }
    @objc private func PanAction(){
        panActions.runAll()
    }
    @objc private func swipeAction(){
        swipeActions.runAll()
    }
    @objc private func rotationAction(){
        rotationActions.runAll()
    }
    func removeGestureAction(type:RMGestureType){
        switch type {
        case .tap:
            guard let tapGestureRecognizer = tapGestureRecognizer else { return }
            self.removeGestureRecognizer(tapGestureRecognizer)
            self.tapActions = []
        case .longHold:
            guard let longHoldGestureRecognizer = longHoldGestureRecognizer else { return }
            self.removeGestureRecognizer(longHoldGestureRecognizer)
            self.longHoldActions = []
        case .pan:
            guard let panGestureRecognizer = panGestureRecognizer else { return }
            self.removeGestureRecognizer(panGestureRecognizer)
            self.panActions = []
        case .pinch:
            guard let pinchGestureRecognizer = pinchGestureRecognizer else { return }
            self.removeGestureRecognizer(pinchGestureRecognizer)
            self.pinchActions = []
        case .rotation:
            guard let rotationGestureRecognizer = rotationGestureRecognizer else { return }
            self.removeGestureRecognizer(rotationGestureRecognizer)
            self.rotationActions = []
        case .swipe:
            guard let swipeGestureRecognizer = swipeGestureRecognizer else { return }
            self.removeGestureRecognizer(swipeGestureRecognizer)
            self.swipeActions = []
        }
    }
    
    var title = ""{
        didSet{
            setTitle(title, for: UIControlState())
        }
    }
    var titleColor = UIColor.text{
        didSet{
            setTitleColor(titleColor, for: UIControlState())
        }
    }
    func addAction(_ block:@escaping voidBlock,forControlEvents ControlEvents:UIControlEvents){
        actions.append(block)
        if isfirst {
            addTarget(self, action: #selector(RMButton.Actions), for: ControlEvents)
            isfirst = false
        }
    }
    func setup(){}
    @objc private func touchDown(){
        device.shortVibrate()
    }
    init(){
        super.init(frame: .zero)
        setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(RMButton.touchDown), for: .touchDown)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(RMButton.touchDown), for: .touchDown)
        setup()
    }
    func addAction(_ block:@escaping voidBlock){
        addAction(block, forControlEvents: .touchUpInside)
    }
    func removeAllActions(){
        actions = actions.map{_ in
            return {}
        }
        actions = []
    }
    @objc private func Actions(){
        actions.runAll()
    }
}
class RMLabel: UILabel {
    
    override var frame: CGRect{
        set(value){
            super.frame = value
            didChangeFrame()
        }
        get{
            return super.frame
        }
    }
    func didChangeFrame(){
        
    }
    func setup(){
        self.textColor = .text
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    init(text:String){
        super.init(frame: .zero)
        setup()
        self.text = text
    }
}
enum RMTextFieldControlEvent{
    case valueChanged
    case beginEditing
    case endEditing
    case cleared
    case `return`
}

class RMTextField: UITextField ,UITextFieldDelegate{
    //===================================================
    //for Action
    private var isfirst = true
    
    private var ValueChangedActions = [voidBlock]()
    private var BeginEditingActions = [voidBlock]()
    private var EndEditingActions = [voidBlock]()
    private var ClearedActions = [voidBlock]()
    private var ReturnActions = [voidBlock]()
    
    func setup(){
        self.delegate = self
    }
    func textFieldDidBeginEditing(_ textField: UITextField){
        BeginEditingActions.runAll()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        EndEditingActions.runAll()
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool{
        ClearedActions.runAll()
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        ReturnActions.runAll()
        return true
    }
    func addAction(_ block:@escaping voidBlock,forTextFieldControlEvents TextFieldControlEvents: RMTextFieldControlEvent){
        switch TextFieldControlEvents {
        case .valueChanged:
            if isfirst {
                addTarget(self, action: #selector(RMTextField.valueChange), for: .valueChanged)
                isfirst = false
            }
            ValueChangedActions.append(block)
        case .beginEditing:
            BeginEditingActions.append(block)
        case .endEditing:
            EndEditingActions.append(block)
        case .cleared:
            ClearedActions.append(block)
        case .return:
            ReturnActions.append(block)
        }
    }
    func valueChange(){
        ValueChangedActions.runAll()
    }
}
class RMSegmentedControl: UISegmentedControl {
    private var actions = [voidBlock]()
    private var isfirst = true
    func addAction(_ block:@escaping voidBlock,forControlEvents ControlEvents:UIControlEvents){
        actions.append(block)
        if isfirst {
            addTarget(self, action: #selector(RMSegmentedControl.Actions), for: ControlEvents)
            isfirst = false
        }
    }
    func addAction(_ block:@escaping voidBlock){
        addAction(block, forControlEvents: .touchUpInside)
    }
    func removeAllActions(){
        actions = []
    }
    @objc private func Actions(){
        actions.runAll()
    }
}

class RMSwitch: UISwitch {
    var saveIdentifier:String? = nil{
        didSet{
            guard let identifier = saveIdentifier else {return}
            self.setOn(info.boolValue(forKey: identifier), animated: false)
        }
    }
    override func setOn(_ on: Bool, animated: Bool) {
        super.setOn(on, animated: animated)
        didChangeOn()
    }
    
    @objc private func didChangeOn(){
        if saveIdentifier != nil {
            guard let identifier = saveIdentifier else {return}
            info.set(isOn, forKey: identifier)
        }
    }
    private var actions = [voidBlock]()
    private var isfirst = true
    private func setup(){
        self.tintColor = .main
        self.onTintColor = .main
        guard let identifier = saveIdentifier else {return}
        
        self.setOn(info.boolValue(forKey: identifier), animated: false)
        addTarget(self, action: #selector(RMSwitch.didChangeOn), for: .valueChanged)
    }
    init(){
        super.init(frame: CGRect.zero)
        setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    func addAction(_ block:@escaping voidBlock,forControlEvents ControlEvents:UIControlEvents){
        actions.append(block)
        if isfirst {
            addTarget(self, action: #selector(RMSwitch.Actions), for: ControlEvents)
            isfirst = false
        }
    }
    func addAction(_ block:@escaping voidBlock){
        addAction(block, forControlEvents: .valueChanged)
    }
    func removeAllActions(){
        actions = []
    }
    func sync(WithIdentifier identifier:String){
        self.isOn = info.boolValue(forKey: identifier)
    }
    @objc private func Actions(){
        actions.runAll()
    }
}
class RMPageControl: UIPageControl {
    private var actions = [voidBlock]()
    private var isfirst = true
    func addAction(_ block:@escaping voidBlock,forControlEvents ControlEvents:UIControlEvents){
        actions.append(block)
        if isfirst {
            addTarget(self, action: #selector(RMPageControl.Actions), for: ControlEvents)
            isfirst = false
        }
    }
    func addAction(_ block:@escaping voidBlock){
        addAction(block, forControlEvents: .touchUpInside)
    }
    func removeAllActions(){
        actions = []
    }
    @objc private func Actions(){
        actions.runAll()
    }
}
class RMStepper: UIStepper {
    private var actions = [voidBlock]()
    private var isfirst = true
    func addAction(_ block:@escaping voidBlock,forControlEvents ControlEvents:UIControlEvents){
        actions.append(block)
        if isfirst {
            addTarget(self, action: #selector(RMStepper.Actions), for: ControlEvents)
            isfirst = false
        }
    }
    func addAction(_ block:@escaping voidBlock){
        addAction(block, forControlEvents: .touchUpInside)
    }
    func removeAllActions(){
        actions = []
    }
    @objc private func Actions(){
        actions.runAll()
    }
}




















