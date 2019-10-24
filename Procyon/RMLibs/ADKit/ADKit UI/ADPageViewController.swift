import UIKit

protocol ADPageViewControllerDelegate:NSObjectProtocol {
    func receiveMessage(identifier: String,info: Any?)
}

class ADPageViewController: ADNavigationController, UIPageViewControllerDelegate,UIPageViewControllerDataSource,ADPageViewControllerDelegate {
    //==========================================================
    //Propaties
    var firstPageIndex = 0//set before start pageing
    var pageSpace:CGFloat = 20//set before start pageing
    var currentIndex:Int{
        get{return currentViewController?.index ?? 0}
        set{move(at: newValue, animated: true)}
    }
    var trasitionStyle = UIPageViewControllerTransitionStyle.scroll
    var navigationOrientation = UIPageViewControllerNavigationOrientation.horizontal
    //=============================
    //UI
    var pageViewController: UIPageViewController!
    var viewControllers:[ADPageCellViewController]{
        return pageViewController?.viewControllers as? [ADPageCellViewController] ?? []
    }
    var currentViewController:ADPageCellViewController? {
        return (pageViewController?.viewControllers as? [ADPageCellViewController])?.index(0)
    }
    
    private var isTransitionInProgress = false
    //==========================================================
    //func
    func receiveMessage(identifier: String, info: Any?) {}
    func didAfterPaging(from: Int, to: Int) {}
    func didBeforePaging(from: Int, to: Int) {}
    func viewController(at index: Int)->ADPageCellViewController {return ADPageCellViewController()}
    func pageData()->[Any] {return []}
    func startPageing(){
        pageViewController = UIPageViewController(
            transitionStyle: trasitionStyle,
            navigationOrientation: navigationOrientation,
            options: [UIPageViewControllerOptionInterPageSpacingKey : pageSpace]
        )
        pageViewController.edgesForExtendedLayout = UIRectEdge()
        pageViewController.view.frame = fullContentsFrame
        pageViewController.setViewControllers([createViewController(at: firstPageIndex)!], direction: .forward, animated: false)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.didMove(toParentViewController: self)
        
        addKeyCommand(input: UIKeyInputRightArrow, modifierFlags: .none){[weak self] in self?.currentIndex+=1}
        addKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: .none){[weak self] in self?.currentIndex-=1}
        
        view.gestureRecognizers = pageViewController.gestureRecognizers
        
        contentView.addSubview(pageViewController!.view)
    }
    func move(at index: Int,animated: Bool = true) {
        if index != currentIndex && !isTransitionInProgress{
            guard let viewController = createViewController(at: index) else {return}
            isTransitionInProgress = true
            didBeforePaging(from: currentIndex, to: index)
            pageViewController?.setViewControllers(
                [viewController],
                direction: index<=currentIndex ? .reverse : .forward,
                animated: animated,
                completion: {_ in
                    self.isTransitionInProgress = false
                    self.didAfterPaging(from: self.currentIndex, to: index)
                }
            )
        }
    }
    
    private func createViewController(at index: Int)->UIViewController?{
        if index >= pageData().count || index < 0 {
            return nil
        }else{
            let pagingCellViewController = viewController(at: index)
            pagingCellViewController.set(data: pageData()[index])
            pagingCellViewController.index = index
            pagingCellViewController.delegate = self
            pagingCellViewController.pageViewController = self
            return pagingCellViewController
        }
    }
    //==========================================================
    //delegate func
    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]
    ){
        let toViewController = pendingViewControllers[0] as! ADPageCellViewController
        let to = toViewController.index
        didBeforePaging(from: currentIndex, to: to)
    }
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ){
        let from = (previousViewControllers[0] as! ADPageCellViewController).index
        let to = currentIndex
        didAfterPaging(from: from, to: to)
    }
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
        )->UIViewController?
    {
        let index = (viewController as! ADPageCellViewController).index
        if (index == 0) || (index == NSNotFound) {return nil}
        return self.createViewController(at: index-1)
    }
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
        ) -> UIViewController?
    {
        let index = (viewController as! ADPageCellViewController).index
        if index == NSNotFound {return nil}
        return self.createViewController(at: index+1)
    }
}

class ADPageCellViewController: ADViewController {
    var index = 0
    weak var delegate: ADPageViewControllerDelegate? = nil
    weak var pageViewController:ADPageViewController? = nil
    override func setupSetting_P() {
        super.setupSetting_P()
        self.view.backgroundColor = .clear
    }
    override var contentSize: CGSize{
        return sizeMake(super.contentSize.width, super.contentSize.height-72)
    }
    func set(data: Any){}
    func sendToRoot(identifier: String,info: Any?) {
        delegate?.receiveMessage(identifier: identifier, info: info)
    }
}






















