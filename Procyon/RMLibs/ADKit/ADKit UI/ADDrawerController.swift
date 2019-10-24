import UIKit

class ADDrawerController: UIViewController, UIGestureRecognizerDelegate {
    enum DrawerDirection: Int {case left, right}
    enum DrawerState: Int {case opened, closed}
    
    var containerViewMaxAlpha: CGFloat = 0.2
    var drawerAnimationDuration = 0.25
    var screenEdgePanGestureEnabled = true
    var drawerState: DrawerState {
        get {return _containerView.isHidden ? .closed : .opened}
        set {setDrawerState(drawerState, animated: false)}
    }
    var didStateChange:(DrawerState)->() = {_ in}
    
    private var _drawerConstraint: NSLayoutConstraint!
    private var _drawerWidthConstraint: NSLayoutConstraint!
    private var _panStartLocation = CGPoint.zero
    private var _panDelta: CGFloat = 0
    private var _isAppearing: Bool?
    
    
    lazy private var _containerView: UIView = {
        let view = UIView(frame: self.view.frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.0, alpha: 0)
        view.addGestureRecognizer(self.containerViewTapGesture)
        return view
    }()
    private(set) lazy var screenEdgePanGesture: UIScreenEdgePanGestureRecognizer = {
        let gesture = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(ADDrawerController.handlePanGesture(_:))
        )
        switch self.drawerDirection {
        case .left:     gesture.edges = .left
        case .right:    gesture.edges = .right
        }
        gesture.delegate = self
        return gesture
    }()
    
    private(set) lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self,
            action: #selector(ADDrawerController.handlePanGesture(_:))
        )
        gesture.delegate = self
        return gesture
    }()

    private(set) lazy var containerViewTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self,action: #selector(ADDrawerController.didtapContainerView(_:)))
        gesture.delegate = self
        return gesture
    }()
    
    public var drawerDirection: DrawerDirection = .left {
        didSet {
            switch drawerDirection {
            case .left:  screenEdgePanGesture.edges = .left
            case .right: screenEdgePanGesture.edges = .right
            }
            let tmp = drawerViewController
            drawerViewController = tmp
        }
    }
    
    @IBInspectable public var drawerWidth: CGFloat = 280 {
        didSet { _drawerWidthConstraint?.constant = drawerWidth }
    }

    public var displayingViewController: UIViewController? {
        switch drawerState {
        case .closed:
            return mainViewController
        case .opened:
            return drawerViewController
        }
    }

    public var mainViewController: UIViewController! {
        didSet {
            if let oldController = oldValue {
                oldController.willMove(toParentViewController: nil)
                oldController.view.removeFromSuperview()
                oldController.removeFromParentViewController()
            }

            guard let mainViewController = mainViewController else { return }
            addChildViewController(mainViewController)

            mainViewController.view.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(mainViewController.view, at: 0)

            let viewDictionary = ["mainView" : mainViewController.view!]
            view.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-0-[mainView]-0-|",
                    options: [],
                    metrics: nil,
                    views: viewDictionary
                )
            )
            view.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-0-[mainView]-0-|",
                    options: [],
                    metrics: nil,
                    views: viewDictionary
                )
            )

            mainViewController.didMove(toParentViewController: self)
        }
    }
    
    public var drawerViewController : UIViewController? {
        didSet {
            if let oldController = oldValue {
                oldController.willMove(toParentViewController: nil)
                oldController.view.removeFromSuperview()
                oldController.removeFromParentViewController()
            }

            guard let drawerViewController = drawerViewController else { return }
            addChildViewController(drawerViewController)

            drawerViewController.view.layer.shadowColor   = UIColor.black.cgColor
            drawerViewController.view.layer.shadowOpacity = 0.4
            drawerViewController.view.layer.shadowRadius  = 5.0
            drawerViewController.view.translatesAutoresizingMaskIntoConstraints = false
            _containerView.addSubview(drawerViewController.view)

            let itemAttribute: NSLayoutAttribute
            let toItemAttribute: NSLayoutAttribute
            switch drawerDirection {
            case .left:
                itemAttribute   = .right
                toItemAttribute = .left
            case .right:
                itemAttribute   = .left
                toItemAttribute = .right
            }

            _drawerWidthConstraint = NSLayoutConstraint(
                item: drawerViewController.view,
                attribute: NSLayoutAttribute.width,
                relatedBy: NSLayoutRelation.equal,
                toItem: nil,
                attribute: NSLayoutAttribute.width,
                multiplier: 1,
                constant: drawerWidth
            )
            drawerViewController.view.addConstraint(_drawerWidthConstraint)
            
            _drawerConstraint = NSLayoutConstraint(
                item: drawerViewController.view,
                attribute: itemAttribute,
                relatedBy: NSLayoutRelation.equal,
                toItem: _containerView,
                attribute: toItemAttribute,
                multiplier: 1,
                constant: 0
            )
            _containerView.addConstraint(_drawerConstraint)

            let viewDictionary = ["drawerView" : drawerViewController.view!]
            _containerView.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-0-[drawerView]-0-|",
                    options: [],
                    metrics: nil,
                    views: viewDictionary
                )
            )
            _containerView.updateConstraints()
            drawerViewController.updateViewConstraints()
            drawerViewController.didMove(toParentViewController: self)
        }
    }
    public init(drawerDirection: DrawerDirection, drawerWidth: CGFloat) {
        super.init(nibName: nil, bundle: nil)
        self.drawerDirection = drawerDirection
        self.drawerWidth     = drawerWidth
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override open func viewDidLoad() {
        super.viewDidLoad()
        let viewDictionary = ["_containerView": _containerView]
        
        
        
        view.addGestureRecognizer(screenEdgePanGesture)
        view.addGestureRecognizer(panGesture)
        view.addSubview(_containerView)
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[_containerView]-0-|",
                options: [],
                metrics: nil,
                views: viewDictionary
            )
        )
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[_containerView]-0-|",
                options: [],
                metrics: nil,
                views: viewDictionary
            )
        )
        _containerView.isHidden = true
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayingViewController?.beginAppearanceTransition(true, animated: animated)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayingViewController?.endAppearanceTransition()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayingViewController?.beginAppearanceTransition(false, animated: animated)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        displayingViewController?.endAppearanceTransition()
    }
    override open var shouldAutomaticallyForwardAppearanceMethods: Bool {
        get {
            return false
        }
    }
    public func setDrawerState(_ state: DrawerState, animated: Bool) {
        _containerView.isHidden = false
        let duration: TimeInterval = animated ? drawerAnimationDuration : 0

        let isAppearing = state == .opened
        if _isAppearing != isAppearing {
            _isAppearing = isAppearing
            drawerViewController?.beginAppearanceTransition(isAppearing, animated: animated)
            mainViewController?.beginAppearanceTransition(!isAppearing, animated: animated)
        }

        UIView.animate(withDuration: duration,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                switch state {
                case .closed:
                    self._drawerConstraint.constant  = 0
                    self._containerView.backgroundColor = UIColor(white: 0, alpha: 0)
                case .opened:
                    let constant: CGFloat
                    switch self.drawerDirection {
                    case .left: constant = self.drawerWidth
                    case .right: constant = -self.drawerWidth
                    }
                    self._drawerConstraint.constant     = constant
                    self._containerView.backgroundColor = UIColor(white: 0, alpha: self.containerViewMaxAlpha)
                }
                self._containerView.layoutIfNeeded()
            }) {_ in
                self._containerView.isHidden = state == .closed
                self.drawerViewController?.endAppearanceTransition()
                self.mainViewController?.endAppearanceTransition()
                self._isAppearing = nil
                application.isStatusBarHidden = state == .opened
                self.didStateChange(state)
        }
    }
    
    final func handlePanGesture(_ sender: UIGestureRecognizer) {
        _containerView.isHidden = false
        if sender.state == .began {_panStartLocation = sender.location(in: view)}
        
        let delta           = CGFloat(sender.location(in: view).x - _panStartLocation.x)
        let constant        : CGFloat
        let backGroundAlpha : CGFloat
        let drawerState     : DrawerState
        
        switch drawerDirection {
        case .left:
            drawerState     = _panDelta <= 0 ? .closed : .opened
            constant        = min(_drawerConstraint.constant + delta, drawerWidth)
            backGroundAlpha = min(containerViewMaxAlpha,containerViewMaxAlpha*(abs(constant)/drawerWidth))
        case .right:
            drawerState     = _panDelta >= 0 ? .closed : .opened
            constant        = max(_drawerConstraint.constant + delta, -drawerWidth)
            backGroundAlpha = min(containerViewMaxAlpha,containerViewMaxAlpha*(abs(constant)/drawerWidth))
        }
        
        _drawerConstraint.constant = constant
        _containerView.backgroundColor = UIColor(white: 0,alpha: backGroundAlpha)
        
        switch sender.state {
        case .changed:
            let isAppearing = drawerState != .opened
            if _isAppearing == nil {
                _isAppearing = isAppearing
                drawerViewController?.beginAppearanceTransition(isAppearing, animated: true)
                mainViewController?.beginAppearanceTransition(!isAppearing, animated: true)
            }

            _panStartLocation = sender.location(in: view)
            _panDelta         = delta
        case .ended, .cancelled:
            setDrawerState(drawerState, animated: true)
        default:
            break
        }
    }
    
    final func didtapContainerView(_ gesture: UITapGestureRecognizer) {
        setDrawerState(.closed, animated: true)
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        switch gestureRecognizer {
        case panGesture:
            return drawerState == .opened
        case screenEdgePanGesture:
            return screenEdgePanGestureEnabled ? drawerState == .closed : false
        default:
            return touch.view == gestureRecognizer.view
        }
   }
}
extension ADDrawerController{
    func open(){self.setDrawerState(.opened, animated: true)}
    func close(){self.setDrawerState(.closed, animated: true)}
}

