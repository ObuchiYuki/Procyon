import UIKit

//============================================================================
//ADHorizontalMenuDelegate
//literally
@objc protocol ADHorizontalMenuDelegate: NSObjectProtocol {
    @objc optional func horizontalMenuWillMove(at index: Int)
    @objc optional func horizontalMenuDidMove(at index: Int)
}
//============================================================================
//ADHorizontalMenuOption
enum ADHorizontalMenuOption {
    //indicator height of ADHorizontalMenuItem
    //indicator is showed when item selected
    case selectionIndicatorHeight(CGFloat)
    //separator width of ADHorizontalMenuItem
    case menuItemSeparatorWidth(CGFloat)
    //please use .main
    case scrollMenuBackgroundColor(UIColor)
    //please use .main
    case viewBackgroundColor(UIColor)
    //hairline color
    //下に出る細いやつの色
    case bottomMenuHairlineColor(UIColor)
    //書くのめんどい
    case selectionIndicatorColor(UIColor)
    //逃げちゃダメだ
    case menuItemSeparatorColor(UIColor)
    //逃げちゃダメだ
    case menuMargin(CGFloat)
    //逃げちゃダメだ
    case menuItemMargin(CGFloat)
    //逃げちゃダメだ
    case menuHeight(CGFloat)
    //逃げちゃダメだ
    case selectedMenuItemLabelColor(UIColor)
    //逃げてるじゃん
    case unselectedMenuItemLabelColor(UIColor)
    case useMenuLikeSegmentedControl(Bool)
    case menuItemSeparatorRoundEdges(Bool)
    case menuItemFont(UIFont)
    case menuItemSeparatorPercentageHeight(CGFloat)
    case menuItemWidth(CGFloat)
    case enableHorizontalBounce(Bool)
    case addBottomMenuHairline(Bool)
    case menuItemWidthBasedOnTitleTextWidth(Bool)
    case titleTextSizeBasedOnMenuItemWidth(Bool)
    case scrollAnimationDurationOnMenuItemTap(Int)
    case centerMenuItems(Bool)
    case hideTopMenuBar(Bool)
}
//============================================================================
//ADHorizontalMenuMenuScrollDirection
//I'll make Virtical scroll !!
//縦も作るお...　そのうちね....
//おい！俺すごいことに気づいたぞ！縦作っちゃたらHorizontalじゃない！
enum ADHorizontalMenuMenuScrollDirection{
    case left
    case right
    case other
}
//============================================================================
//ADHorizontalMenu
//this class creates horizontal menu like youtube, twitter...
//あとスマートニュースってそんな感じだった気がする。
class ADHorizontalMenu: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate{
    
    let menuScrollView = UIScrollView()
    var currentIndex = 0
    
    private let menuShadowView = RMView()
    private let controllerScrollView = UIScrollView()
    private var controllerArray : [UIViewController] = []
    private var menuItems : [ADHorizontalMenuItemView] = []
    private var menuItemWidths : [CGFloat] = []
    
    private var menuHeight : CGFloat = 34.0
    private var menuMargin : CGFloat = 15.0
    private var menuItemWidth : CGFloat = 111.0
    private var selectionIndicatorHeight : CGFloat = 3.0
    private var totalMenuItemWidthIfDifferentWidths : CGFloat = 0.0
    private var scrollAnimationDurationOnMenuItemTap = 500 // Millisecons
    private var startingMenuMargin : CGFloat = 0.0
    private var menuItemMargin : CGFloat = 0.0
    
    private var selectionIndicatorView = UIView()
    
    private var lastPageIndex = 0
    
    private var selectionIndicatorColor = UIColor.hex("1")
    private var selectedMenuItemLabelColor = UIColor.hex("1")
    private var unselectedMenuItemLabelColor = UIColor.hex("444444")
    private var scrollMenuBackgroundColor = UIColor.hex("0")
    private var viewBackgroundColor = UIColor.hex("444444")
    private var bottomMenuHairlineColor = UIColor.hex("444444")
    private var menuItemSeparatorColor = UIColor.hex("444444")
    
    private var menuItemFont = Font.Roboto.font(15)
    private var menuItemSeparatorPercentageHeight : CGFloat = 0.2
    private var menuItemSeparatorWidth : CGFloat = 0.5
    private var menuItemSeparatorRoundEdges = false
    
    private var addBottomMenuHairline = true
    private var menuItemWidthBasedOnTitleTextWidth = false
    private var titleTextSizeBasedOnMenuItemWidth = false
    private var useMenuLikeSegmentedControl = false
    private var centerMenuItems = false
    private var enableHorizontalBounce = true
    private var hideTopMenuBar = false
    
    private var currentOrientationIsPortrait = true
    private var pageIndexForOrientationChange = 0
    private var didLayoutSubviewsAfterRotation = false
    private var didScrollAlready = false
    
    private var lastControllerScrollViewContentOffset : CGFloat = 0.0
    
    private var lastScrollDirection = ADHorizontalMenuMenuScrollDirection.other
    private var startingPageForScroll = 0
    private var didTapMenuItemToScroll = false
    
    private var pagesAddedDictionary:[Int:Int] = [:]
    
    weak var delegate : ADHorizontalMenuDelegate?
    
    private var tapTimer : Timer?
    
    init(viewControllers: [UIViewController],options: [String: AnyObject]?) {
        super.init(nibName: nil, bundle: nil)
        
        controllerArray = viewControllers
        
        self.view.frame = CGRect(origin: CGPoint.zero, size: screen.size)
    }
    
    convenience init(viewControllers: [UIViewController],defaultOption: ADHorizontalMenuDefaultOptions) {
        self.init(viewControllers:viewControllers, pageMenuOptions: defaultOption.parameters)
    }
    convenience init(viewControllers: [UIViewController],pageMenuOptions: [ADHorizontalMenuOption]?) {
        self.init(viewControllers:viewControllers, options:nil)
        
        if let options = pageMenuOptions {
            for option in options {
                switch (option) {
                case let .selectionIndicatorHeight(value):
                    selectionIndicatorHeight = value
                case let .menuItemSeparatorWidth(value):
                    menuItemSeparatorWidth = value
                case let .scrollMenuBackgroundColor(value):
                    scrollMenuBackgroundColor = value
                case let .viewBackgroundColor(value):
                    viewBackgroundColor = value
                case let .bottomMenuHairlineColor(value):
                    bottomMenuHairlineColor = value
                case let .selectionIndicatorColor(value):
                    selectionIndicatorColor = value
                case let .menuItemSeparatorColor(value):
                    menuItemSeparatorColor = value
                case let .menuMargin(value):
                    menuMargin = value
                case let .menuItemMargin(value):
                    menuItemMargin = value
                case let .menuHeight(value):
                    menuHeight = value
                case let .selectedMenuItemLabelColor(value):
                    selectedMenuItemLabelColor = value
                case let .unselectedMenuItemLabelColor(value):
                    unselectedMenuItemLabelColor = value
                case let .useMenuLikeSegmentedControl(value):
                    useMenuLikeSegmentedControl = value
                case let .menuItemSeparatorRoundEdges(value):
                    menuItemSeparatorRoundEdges = value
                case let .menuItemFont(value):
                    menuItemFont = value
                case let .menuItemSeparatorPercentageHeight(value):
                    menuItemSeparatorPercentageHeight = value
                case let .menuItemWidth(value):
                    menuItemWidth = value
                case let .enableHorizontalBounce(value):
                    enableHorizontalBounce = value
                case let .addBottomMenuHairline(value):
                    addBottomMenuHairline = value
                case let .menuItemWidthBasedOnTitleTextWidth(value):
                    menuItemWidthBasedOnTitleTextWidth = value
                case let .titleTextSizeBasedOnMenuItemWidth(value):
                    titleTextSizeBasedOnMenuItemWidth = value
                case let .scrollAnimationDurationOnMenuItemTap(value):
                    scrollAnimationDurationOnMenuItemTap = value
                case let .centerMenuItems(value):
                    centerMenuItems = value
                case let .hideTopMenuBar(value):
                    hideTopMenuBar = value
                }
            }
            
            if hideTopMenuBar {
                addBottomMenuHairline = false
                menuHeight = 0.0
            }
        }
        
        setupUserInterface()
        
        if menuScrollView.subviews.count == 0 {
            configureUserInterface()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var shouldAutomaticallyForwardAppearanceMethods : Bool {
        return true
    }
    
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return true
    }
    
    func setupUserInterface() {
        let viewsDictionary = ["menuScrollView":menuScrollView, "controllerScrollView":controllerScrollView]
        
        controllerScrollView.isPagingEnabled = true
        controllerScrollView.translatesAutoresizingMaskIntoConstraints = false
        controllerScrollView.alwaysBounceHorizontal = enableHorizontalBounce
        controllerScrollView.bounces = enableHorizontalBounce
        
        controllerScrollView.frame = CGRect(x: 0.0, y: menuHeight, width: self.view.frame.width, height: self.view.frame.height)
        
        self.view.addSubview(controllerScrollView)
        
        let controllerScrollView_constraint_H = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[controllerScrollView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary
        )
        let controllerScrollView_constraint_V = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[controllerScrollView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary
        )
        
        self.view.addConstraints(controllerScrollView_constraint_H)
        self.view.addConstraints(controllerScrollView_constraint_V)
        
        menuScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        menuScrollView.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: self.view.frame.width,
            height: menuHeight
        )
        menuShadowView.frame = menuScrollView.frame
        menuShadowView.frame.origin.y = 0.5
        menuShadowView.shadowLevel = 2
        menuShadowView.layer.shadowRadius = 1
        menuShadowView.backgroundColor = .hex("")
        view.addSubview(menuShadowView)
        view.addSubview(menuScrollView)
        
        let menuScrollView_constraint_H = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[menuScrollView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary
        )
        let menuScrollView_constraint_V = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[menuScrollView(\(menuHeight))]",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary
        )
        
        self.view.addConstraints(menuScrollView_constraint_H)
        self.view.addConstraints(menuScrollView_constraint_V)
        
        if addBottomMenuHairline {
            let menuBottomHairline : UIView = UIView()
            
            menuBottomHairline.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(menuBottomHairline)
            
            let menuBottomHairline_constraint_H = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[menuBottomHairline]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["menuBottomHairline":menuBottomHairline]
            )
            let menuBottomHairline_constraint_V = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-\(menuHeight)-[menuBottomHairline(0.5)]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["menuBottomHairline":menuBottomHairline]
            )
            
            self.view.addConstraints(menuBottomHairline_constraint_H)
            self.view.addConstraints(menuBottomHairline_constraint_V)
            
            menuBottomHairline.backgroundColor = bottomMenuHairlineColor
        }
        menuScrollView.showsHorizontalScrollIndicator = false
        menuScrollView.showsVerticalScrollIndicator = false
        controllerScrollView.showsHorizontalScrollIndicator = false
        controllerScrollView.showsVerticalScrollIndicator = false
        
        self.view.backgroundColor = viewBackgroundColor
        menuScrollView.backgroundColor = scrollMenuBackgroundColor
    }
    
    func configureUserInterface() {
        let menuItemTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ADHorizontalMenu.handleMenuItemTaped(_:)))
        menuItemTapGestureRecognizer.numberOfTapsRequired = 1
        menuItemTapGestureRecognizer.numberOfTouchesRequired = 1
        menuItemTapGestureRecognizer.delegate = self
        menuScrollView.addGestureRecognizer(menuItemTapGestureRecognizer)
        
        controllerScrollView.delegate = self
        menuScrollView.scrollsToTop = false;
        controllerScrollView.scrollsToTop = false;
        
        if useMenuLikeSegmentedControl {
            menuScrollView.isScrollEnabled = false
            menuScrollView.contentSize = sizeMake(self.view.frame.width, menuHeight)
            menuMargin = 0.0
        } else {
            menuScrollView.contentSize = sizeMake((menuItemWidth + menuMargin) * CGFloat(controllerArray.count) + menuMargin, menuHeight)
        }
        

        controllerScrollView.contentSize = sizeMake(self.view.frame.width * CGFloat(controllerArray.count), 0.0)
        
        var index: CGFloat = 0.0
        
        for controller in controllerArray {
            if index == 0.0 {
                addPage(at: 0)
            }
        
            var menuItemFrame = CGRect()
            
            if useMenuLikeSegmentedControl {
                if menuItemMargin > 0 {
                    let marginSum = menuItemMargin * CGFloat(controllerArray.count + 1)
                    let menuItemWidth = (self.view.frame.width - marginSum) / CGFloat(controllerArray.count)
                    menuItemFrame = CGRect(x: CGFloat(menuItemMargin * (index + 1)) + menuItemWidth * CGFloat(index), y: 0.0, width: CGFloat(self.view.frame.width) / CGFloat(controllerArray.count), height: menuHeight)
                } else {
                    menuItemFrame = CGRect(x: self.view.frame.width / CGFloat(controllerArray.count) * CGFloat(index), y: 0.0, width: CGFloat(self.view.frame.width) / CGFloat(controllerArray.count), height: menuHeight)
                }
            } else if menuItemWidthBasedOnTitleTextWidth {
                let controllerTitle = controller.title
                
                let title = controllerTitle != nil ? controllerTitle! : "Menu \(Int(index) + 1)"
                
                let itemWidthRect = (title as NSString).boundingRect(
                    with: sizeMake(1000, 1000),
                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                    attributes: [NSFontAttributeName:menuItemFont],
                    context: nil
                )
                
                menuItemWidth = itemWidthRect.width
                
                menuItemFrame = CGRect(x: totalMenuItemWidthIfDifferentWidths + menuMargin + (menuMargin * index), y: 0.0, width: menuItemWidth, height: menuHeight)
                
                totalMenuItemWidthIfDifferentWidths += itemWidthRect.width
                menuItemWidths.append(itemWidthRect.width)
            } else {
                if centerMenuItems && index == 0.0  {
                    startingMenuMargin = ((self.view.frame.width - ((CGFloat(controllerArray.count) * menuItemWidth) + (CGFloat(controllerArray.count - 1) * menuMargin))) / 2.0) -  menuMargin
                    
                    if startingMenuMargin < 0.0 {
                        startingMenuMargin = 0.0
                    }
                    
                    menuItemFrame = CGRect(x: startingMenuMargin + menuMargin, y: 0.0, width: menuItemWidth, height: menuHeight)
                } else {
                    menuItemFrame = CGRect(x: menuItemWidth * index + menuMargin * (index + 1) + startingMenuMargin, y: 0.0, width: menuItemWidth, height: menuHeight)
                }
            }
            
            let menuItemView : ADHorizontalMenuItemView = ADHorizontalMenuItemView(frame: menuItemFrame)
            if useMenuLikeSegmentedControl {
                if menuItemMargin > 0 {
                    let marginSum = menuItemMargin * CGFloat(controllerArray.count + 1)
                    let menuItemWidth = (self.view.frame.width - marginSum) / CGFloat(controllerArray.count)
                    menuItemView.setupMenuItemView(menuItemWidth, menuScrollViewHeight: menuHeight, indicatorHeight: selectionIndicatorHeight, separatorPercentageHeight: menuItemSeparatorPercentageHeight, separatorWidth: menuItemSeparatorWidth, separatorRoundEdges: menuItemSeparatorRoundEdges, menuItemSeparatorColor: menuItemSeparatorColor)
                } else {
                    menuItemView.setupMenuItemView(CGFloat(self.view.frame.width) / CGFloat(controllerArray.count), menuScrollViewHeight: menuHeight, indicatorHeight: selectionIndicatorHeight, separatorPercentageHeight: menuItemSeparatorPercentageHeight, separatorWidth: menuItemSeparatorWidth, separatorRoundEdges: menuItemSeparatorRoundEdges, menuItemSeparatorColor: menuItemSeparatorColor)
                }
            } else {
                menuItemView.setupMenuItemView(menuItemWidth, menuScrollViewHeight: menuHeight, indicatorHeight: selectionIndicatorHeight, separatorPercentageHeight: menuItemSeparatorPercentageHeight, separatorWidth: menuItemSeparatorWidth, separatorRoundEdges: menuItemSeparatorRoundEdges, menuItemSeparatorColor: menuItemSeparatorColor)
            }
            
            menuItemView.titleLabel!.font = menuItemFont
            menuItemView.titleLabel!.textAlignment = NSTextAlignment.center
            menuItemView.titleLabel!.textColor = unselectedMenuItemLabelColor
            menuItemView.titleLabel!.adjustsFontSizeToFitWidth = titleTextSizeBasedOnMenuItemWidth
            
            if controller.title != nil {
                menuItemView.titleLabel!.text = controller.title!
            } else {
                menuItemView.titleLabel!.text = "Menu \(Int(index) + 1)"
            }
            
            if useMenuLikeSegmentedControl {
                if Int(index) < controllerArray.count - 1 {
                    menuItemView.menuItemSeparator!.isHidden = false
                }
            }
            
            menuScrollView.addSubview(menuItemView)
            menuItems.append(menuItemView)
            
            index += 1
        }
        
        if menuItemWidthBasedOnTitleTextWidth {
            menuScrollView.contentSize = sizeMake((totalMenuItemWidthIfDifferentWidths + menuMargin) + CGFloat(controllerArray.count) * menuMargin, menuHeight)
        }
        
        if menuItems.count > 0 {
            if menuItems[currentIndex].titleLabel != nil {
                menuItems[currentIndex].titleLabel!.textColor = selectedMenuItemLabelColor
            }
        }
        
        var selectionIndicatorFrame : CGRect = CGRect()
        
        if useMenuLikeSegmentedControl {
            selectionIndicatorFrame = CGRect(
                x: 0.0,
                y: menuHeight - selectionIndicatorHeight,
                width: self.view.frame.width / CGFloat(controllerArray.count),
                height: selectionIndicatorHeight
            )
        } else if menuItemWidthBasedOnTitleTextWidth {
            selectionIndicatorFrame = CGRect(
                x: menuMargin,
                y: menuHeight - selectionIndicatorHeight,
                width: menuItemWidths[0],
                height: selectionIndicatorHeight
            )
        } else {
            if centerMenuItems  {
                selectionIndicatorFrame = CGRect(
                    x: startingMenuMargin + menuMargin,
                    y: menuHeight - selectionIndicatorHeight,
                    width: menuItemWidth,
                    height: selectionIndicatorHeight
                )
            } else {
                selectionIndicatorFrame = CGRect(
                    x: menuMargin,
                    y: menuHeight - selectionIndicatorHeight,
                    width: menuItemWidth,
                    height: selectionIndicatorHeight
                )
            }
        }
        
        selectionIndicatorView = UIView(frame: selectionIndicatorFrame)
        selectionIndicatorView.backgroundColor = selectionIndicatorColor
        menuScrollView.addSubview(selectionIndicatorView)
        
        if menuItemWidthBasedOnTitleTextWidth && centerMenuItems {
            self.configureMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems()
            let leadingAndTrailingMargin = self.getMarginForMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems()
            selectionIndicatorView.frame = CGRect(
                x: leadingAndTrailingMargin,
                y: menuHeight - selectionIndicatorHeight,
                width: menuItemWidths[0],
                height: selectionIndicatorHeight
            )
        }
    }
    
    private func configureMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems() {
        if menuScrollView.contentSize.width < self.view.bounds.width {
            let leadingAndTrailingMargin = self.getMarginForMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems()
            
            for (index, menuItem) in menuItems.enumerated() {
                let controllerTitle = controllerArray[index].title!
                
                let itemWidthRect = controllerTitle.boundingRect(
                    with: sizeMake(1000, 1000),
                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                    attributes: [NSFontAttributeName:menuItemFont],
                    context: nil
                )
                
                menuItemWidth = itemWidthRect.width
                
                var margin: CGFloat
                if index == 0 {
                    margin = leadingAndTrailingMargin
                } else {
                    let previousMenuItem = menuItems[index-1]
                    let previousX = previousMenuItem.frame.maxX
                    margin = previousX + menuMargin
                }
                
                menuItem.frame = CGRect(x: margin, y: 0.0, width: menuItemWidth, height: menuHeight)
            }
        } else {
            for (index, menuItem) in menuItems.enumerated() {
                var menuItemX: CGFloat
                if index == 0 {
                    menuItemX = menuMargin
                } else {
                    menuItemX = menuItems[index-1].frame.maxX + menuMargin
                }
                
                menuItem.frame = CGRect(x: menuItemX, y: 0.0, width: menuItem.bounds.width, height: menuItem.bounds.height)
            }
        }
    }
    
    private func getMarginForMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems() -> CGFloat {
        let menuItemsTotalWidth = menuScrollView.contentSize.width - menuMargin * 2
        let leadingAndTrailingMargin = (self.view.bounds.width - menuItemsTotalWidth) / 2
        
        return leadingAndTrailingMargin
    }
        func scrollViewDidScroll(_ scrollView:UIScrollView) {
        if !didLayoutSubviewsAfterRotation {
            if scrollView.isEqual(controllerScrollView) {
                if scrollView.contentOffset.x >= 0.0 &&
                   scrollView.contentOffset.x <= (CGFloat(controllerArray.count - 1) * self.view.frame.width)
                {
                    if (currentOrientationIsPortrait &&
                        UIApplication.shared.statusBarOrientation.isPortrait) ||
                        (!currentOrientationIsPortrait && UIApplication.shared.statusBarOrientation.isLandscape)
                    {
                        if !didTapMenuItemToScroll {
                            if didScrollAlready {
                                var newScrollDirection : ADHorizontalMenuMenuScrollDirection = .other
                                
                                if (CGFloat(startingPageForScroll) * scrollView.frame.width > scrollView.contentOffset.x) {
                                    newScrollDirection = .right
                                } else if (CGFloat(startingPageForScroll) * scrollView.frame.width < scrollView.contentOffset.x) {
                                    newScrollDirection = .left
                                }
                                
                                if newScrollDirection != .other {
                                    if lastScrollDirection != newScrollDirection {
                                        let index : Int = newScrollDirection == .left ? currentIndex + 1 : currentIndex - 1
                                        
                                        if index >= 0 && index < controllerArray.count {

                                            if pagesAddedDictionary[index] != index {
                                                addPage(at: index)
                                                pagesAddedDictionary[index] = index
                                            }
                                        }
                                    }
                                }
                                lastScrollDirection = newScrollDirection
                            }
                            if !didScrollAlready {
                                if (lastControllerScrollViewContentOffset > scrollView.contentOffset.x) {
                                    if currentIndex != controllerArray.count - 1 {
                                        let index : Int = currentIndex - 1
                                        
                                        if pagesAddedDictionary[index] != index && index < controllerArray.count && index >= 0 {
                                            addPage(at: index)
                                            pagesAddedDictionary[index] = index
                                        }
                                        
                                        lastScrollDirection = .right
                                    }
                                } else if (lastControllerScrollViewContentOffset < scrollView.contentOffset.x) {
                                    if currentIndex != 0 {
                                        let index : Int = currentIndex + 1
                                        
                                        if pagesAddedDictionary[index] != index && index < controllerArray.count && index >= 0 {
                                            addPage(at: index)
                                            pagesAddedDictionary[index] = index
                                        }
                                        
                                        lastScrollDirection = .left
                                    }
                                }
                                
                                didScrollAlready = true
                            }
                            
                            lastControllerScrollViewContentOffset = scrollView.contentOffset.x
                        }
                        
                        var ratio : CGFloat = 1.0
                        
                        ratio = (menuScrollView.contentSize.width - self.view.frame.width) / (controllerScrollView.contentSize.width - self.view.frame.width)
                        
                        if menuScrollView.contentSize.width > self.view.frame.width {
                            var offset : CGPoint = menuScrollView.contentOffset
                            offset.x = controllerScrollView.contentOffset.x * ratio
                            menuScrollView.setContentOffset(offset, animated: false)
                        }
                        
                        let width : CGFloat = controllerScrollView.width;
                        let page : Int = Int((controllerScrollView.contentOffset.x + (0.5 * width)) / width)
                        
                        if page != currentIndex {
                            lastPageIndex = currentIndex
                            currentIndex = page
                            
                            if pagesAddedDictionary[page] != page && page < controllerArray.count && page >= 0 {
                                addPage(at: page)
                                pagesAddedDictionary[page] = page
                            }
                            
                            if !didTapMenuItemToScroll {
                                if pagesAddedDictionary[lastPageIndex] != lastPageIndex {
                                    pagesAddedDictionary[lastPageIndex] = lastPageIndex
                                }
                                
                                let indexLeftTwo : Int = page - 2
                                if pagesAddedDictionary[indexLeftTwo] == indexLeftTwo {
                                    pagesAddedDictionary.removeValue(forKey: indexLeftTwo)
                                    removePage(at: indexLeftTwo)
                                }
                                let indexRightTwo : Int = page + 2
                                if pagesAddedDictionary[indexRightTwo] == indexRightTwo {
                                    pagesAddedDictionary.removeValue(forKey: indexRightTwo)
                                    removePage(at: indexRightTwo)
                                }
                            }
                        }
                        
                        moveSelectionIndicator(page)
                    }
                } else {
                    var ratio : CGFloat = 1.0
                    
                    ratio = (menuScrollView.contentSize.width - self.view.frame.width) / (controllerScrollView.contentSize.width - self.view.frame.width)
                    
                    if menuScrollView.contentSize.width > self.view.frame.width {
                        var offset = menuScrollView.contentOffset
                        offset.x = controllerScrollView.contentOffset.x * ratio
                        menuScrollView.setContentOffset(offset, animated: false)
                    }
                }
            }
        } else {
            didLayoutSubviewsAfterRotation = false
            
            moveSelectionIndicator(currentIndex)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView:UIScrollView) {
        if scrollView.isEqual(controllerScrollView) {
            delegate?.horizontalMenuDidMove?(at: currentIndex)
            
            for key in pagesAddedDictionary.keys {
                if key != currentIndex {
                    removePage(at: key)
                }
            }
            
            didScrollAlready = false
            startingPageForScroll = currentIndex
            
            pagesAddedDictionary.removeAll(keepingCapacity: false)
        }
    }
    
    func scrollViewDidEndTapScrollingAnimation() {
        delegate?.horizontalMenuDidMove?(at: currentIndex)
        
        for key in pagesAddedDictionary.keys {
            if key != currentIndex {
                removePage(at: key)
            }
        }
        
        startingPageForScroll = currentIndex
        didTapMenuItemToScroll = false
        
        pagesAddedDictionary.removeAll(keepingCapacity: false)
    }
    
    func moveSelectionIndicator(_ pageIndex:Int) {
        if pageIndex >= 0 && pageIndex < controllerArray.count {
            UIView.animate(
                withDuration: 0.15,
                animations: {
                    var selectionIndicatorWidth = self.selectionIndicatorView.frame.width
                    var selectionIndicatorX : CGFloat = 0.0
                
                    if self.useMenuLikeSegmentedControl {
                        selectionIndicatorX = CGFloat(pageIndex) * (self.view.frame.width / CGFloat(self.controllerArray.count))
                        selectionIndicatorWidth = self.view.frame.width / CGFloat(self.controllerArray.count)
                    } else if self.menuItemWidthBasedOnTitleTextWidth {
                        selectionIndicatorWidth = self.menuItemWidths[pageIndex]
                        selectionIndicatorX = self.menuItems[pageIndex].frame.minX
                    } else {
                        if self.centerMenuItems && pageIndex == 0 {
                            selectionIndicatorX = self.startingMenuMargin + self.menuMargin
                        } else {
                            selectionIndicatorX = self.menuItemWidth * CGFloat(pageIndex) + self.menuMargin * CGFloat(pageIndex + 1) + self.startingMenuMargin
                        }
                    }
                    
                    self.selectionIndicatorView.frame = CGRect(
                        x: selectionIndicatorX,
                        y: self.selectionIndicatorView.frame.origin.y,
                        width: selectionIndicatorWidth,
                        height: self.selectionIndicatorView.frame.height
                    )
                
                    if self.menuItems.count > 0 {
                        if self.menuItems[self.lastPageIndex].titleLabel != nil && self.menuItems[self.currentIndex].titleLabel != nil {
                            self.menuItems[self.lastPageIndex].titleLabel!.textColor = self.unselectedMenuItemLabelColor
                            self.menuItems[self.currentIndex].titleLabel!.textColor = self.selectedMenuItemLabelColor
                        }
                    }
                }
            )
        }
    }
    
    
    
    func handleMenuItemTaped(_ gestureRecognizer:UITapGestureRecognizer) {
        let tappedPoint = gestureRecognizer.location(in: menuScrollView)
        
        if tappedPoint.y < menuScrollView.frame.height {
            
            var itemIndex = 0
            
            if useMenuLikeSegmentedControl {
                itemIndex = Int(tappedPoint.x / (self.view.frame.width / CGFloat(controllerArray.count)))
            } else if menuItemWidthBasedOnTitleTextWidth {
                var menuItemLeftBound: CGFloat
                var menuItemRightBound: CGFloat
                
                if centerMenuItems {
                    menuItemLeftBound = menuItems[0].frame.minX
                    menuItemRightBound = menuItems[menuItems.count-1].frame.maxX
                    
                    if (tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound) {
                        for (index, _) in controllerArray.enumerated() {
                            menuItemLeftBound = menuItems[index].frame.minX
                            menuItemRightBound = menuItems[index].frame.maxX
                            
                            if tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound {
                                itemIndex = index
                                break
                            }
                        }
                    }
                } else {
                    menuItemLeftBound = 0.0
                    menuItemRightBound = menuItemWidths[0] + menuMargin + (menuMargin / 2)
                    
                    if !(tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound) {
                        for i in 1...controllerArray.count - 1 {
                            menuItemLeftBound = menuItemRightBound + 1.0
                            menuItemRightBound = menuItemLeftBound + menuItemWidths[i] + menuMargin
                            
                            if tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound {
                                itemIndex = i
                                break
                            }
                        }
                    }
                }
            } else {
                let rawItemIndex = ((tappedPoint.x - startingMenuMargin) - menuMargin / 2) / (menuMargin + menuItemWidth)
                
                if rawItemIndex < 0 {
                    itemIndex = -1
                } else {
                    itemIndex = Int(rawItemIndex)
                }
            }
            
            if itemIndex >= 0 && itemIndex < controllerArray.count {
                if itemIndex != currentIndex {
                    startingPageForScroll = itemIndex
                    lastPageIndex = currentIndex
                    currentIndex = itemIndex
                    didTapMenuItemToScroll = true
                    
                    let smallerIndex = lastPageIndex < currentIndex ? lastPageIndex : currentIndex
                    let largerIndex = lastPageIndex > currentIndex ? lastPageIndex : currentIndex
                    
                    if smallerIndex + 1 != largerIndex {
                        for index in (smallerIndex + 1)...(largerIndex - 1) {
                            if pagesAddedDictionary[index] != index {
                                addPage(at: index)
                                pagesAddedDictionary[index] = index
                            }
                        }
                    }
                    
                    addPage(at: itemIndex)
                    
                    pagesAddedDictionary[lastPageIndex] = lastPageIndex
                }
            
                let duration = Double(scrollAnimationDurationOnMenuItemTap) / Double(1000)
                
                UIView.animate(withDuration: duration, animations: { () -> Void in
                    let xOffset = CGFloat(itemIndex) * self.controllerScrollView.frame.width
                    self.controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y), animated: false)
                })
                
                if tapTimer != nil {
                    tapTimer!.invalidate()
                }
                
                let timerInterval : TimeInterval = Double(scrollAnimationDurationOnMenuItemTap) * 0.001
                tapTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(ADHorizontalMenu.scrollViewDidEndTapScrollingAnimation), userInfo: nil, repeats: false)
            }
        }
    }

    func addPage(at index:Int) {
        delegate?.horizontalMenuWillMove?(at: index)
        
        let newVC = controllerArray[index]
        
        newVC.willMove(toParentViewController: self)
        
        newVC.view.frame = CGRect(x: self.view.frame.width * CGFloat(index), y: menuHeight, width: self.view.frame.width, height: self.view.frame.height - menuHeight)
        
        self.addChildViewController(newVC)
        self.controllerScrollView.addSubview(newVC.view)
        newVC.didMove(toParentViewController: self)
    }
    
    func removePage(at index:Int) {
        let oldVC = controllerArray[index]
        
        oldVC.willMove(toParentViewController: nil)
        
        oldVC.view.removeFromSuperview()
        oldVC.removeFromParentViewController()
    }
    
    
    override func viewDidLayoutSubviews() {
        controllerScrollView.contentSize = sizeMake(self.view.frame.width * CGFloat(controllerArray.count), self.view.frame.height - menuHeight)
        
        let oldCurrentOrientationIsPortrait : Bool = currentOrientationIsPortrait
        currentOrientationIsPortrait = UIApplication.shared.statusBarOrientation.isPortrait
        
        if (oldCurrentOrientationIsPortrait && UIDevice.current.orientation.isLandscape) || (!oldCurrentOrientationIsPortrait && UIDevice.current.orientation.isPortrait) {
            didLayoutSubviewsAfterRotation = true
            
            if useMenuLikeSegmentedControl {
                menuScrollView.contentSize = sizeMake(self.view.frame.width, menuHeight)
                
                let selectionIndicatorX = CGFloat(currentIndex) * (self.view.frame.width / CGFloat(self.controllerArray.count))
                let selectionIndicatorWidth : CGFloat = self.view.frame.width / CGFloat(self.controllerArray.count)
                selectionIndicatorView.frame =  CGRect(x: selectionIndicatorX, y: self.selectionIndicatorView.frame.origin.y, width: selectionIndicatorWidth, height: self.selectionIndicatorView.frame.height)
                
                var index = 0
                
                for item : ADHorizontalMenuItemView in menuItems as [ADHorizontalMenuItemView] {
                    item.frame = CGRect(x: self.view.frame.width / CGFloat(controllerArray.count) * CGFloat(index), y: 0.0, width: self.view.frame.width / CGFloat(controllerArray.count), height: menuHeight)
                    item.titleLabel!.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width / CGFloat(controllerArray.count), height: menuHeight)
                    item.menuItemSeparator!.frame = CGRect(x: item.frame.width - (menuItemSeparatorWidth / 2), y: item.menuItemSeparator!.frame.origin.y, width: item.menuItemSeparator!.frame.width, height: item.menuItemSeparator!.frame.height)
                    
                    index += 1
                }
            } else if menuItemWidthBasedOnTitleTextWidth && centerMenuItems {
                self.configureMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems()
                let selectionIndicatorX = menuItems[currentIndex].frame.minX
                selectionIndicatorView.frame = CGRect(x: selectionIndicatorX, y: menuHeight - selectionIndicatorHeight, width: menuItemWidths[currentIndex], height: selectionIndicatorHeight)
            } else if centerMenuItems {
                startingMenuMargin = ((self.view.frame.width - ((CGFloat(controllerArray.count) * menuItemWidth) + (CGFloat(controllerArray.count - 1) * menuMargin))) / 2.0) -  menuMargin
                
                if startingMenuMargin < 0.0 {
                    startingMenuMargin = 0.0
                }
                
                let selectionIndicatorX : CGFloat = self.menuItemWidth * CGFloat(currentIndex) + self.menuMargin * CGFloat(currentIndex + 1) + self.startingMenuMargin
                selectionIndicatorView.frame =  CGRect(
                    x: selectionIndicatorX,
                    y: self.selectionIndicatorView.frame.origin.y,
                    width: self.selectionIndicatorView.frame.width,
                    height: self.selectionIndicatorView.frame.height
                )
                var index  = 0
                
                for item : ADHorizontalMenuItemView in menuItems as [ADHorizontalMenuItemView] {
                    if index == 0 {
                        item.frame = CGRect(
                            x: startingMenuMargin + menuMargin,
                            y: 0.0,
                            width: menuItemWidth,
                            height: menuHeight
                        )
                    } else {
                        item.frame = CGRect(
                            x: menuItemWidth * CGFloat(index) + menuMargin * CGFloat(index + 1) + startingMenuMargin,
                            y: 0.0,
                            width: menuItemWidth,
                            height: menuHeight
                        )
                    }
                    
                    index += 1
                }
            }
            
            for view : UIView in controllerScrollView.subviews {
                view.frame = CGRect(x: self.view.frame.width * CGFloat(currentIndex), y: menuHeight, width: controllerScrollView.frame.width, height: self.view.frame.height - menuHeight)
            }
            
            let xOffset : CGFloat = CGFloat(self.currentIndex) * controllerScrollView.frame.width
            controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: controllerScrollView.contentOffset.y), animated: false)
            
            let ratio : CGFloat = (menuScrollView.contentSize.width - self.view.frame.width) / (controllerScrollView.contentSize.width - self.view.frame.width)
            
            if menuScrollView.contentSize.width > self.view.frame.width {
                var offset = menuScrollView.contentOffset
                offset.x = controllerScrollView.contentOffset.x * ratio
                menuScrollView.setContentOffset(offset, animated: false)
            }
        }
        self.view.layoutIfNeeded()
    }
    
    
    func move(at index: Int,animated: Bool = true) {
        if index >= 0 && index < controllerArray.count {
            if index != currentIndex {
                delegate?.horizontalMenuWillMove?(at: index)
                startingPageForScroll = index
                lastPageIndex = currentIndex
                currentIndex = index
                didTapMenuItemToScroll = true
                let smallerIndex = lastPageIndex < currentIndex ? lastPageIndex : currentIndex
                let largerIndex = lastPageIndex > currentIndex ? lastPageIndex : currentIndex
                
                if smallerIndex + 1 != largerIndex {
                    for i in (smallerIndex + 1)...(largerIndex - 1) {
                        if pagesAddedDictionary[i] != i {
                            addPage(at: i)
                            pagesAddedDictionary[i] = i
                        }
                    }
                }
                
                addPage(at: index)
                pagesAddedDictionary[lastPageIndex] = lastPageIndex
            }
            
            let duration = Double(scrollAnimationDurationOnMenuItemTap) / Double(1000)
            if animated{
                UIView.animate(
                    withDuration: duration,
                    animations: {
                        let xOffset = CGFloat(index) * self.controllerScrollView.frame.width
                        self.controllerScrollView.setContentOffset(
                            CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y),
                            animated: false
                        )
                    },
                    completion:{_ in self.delegate?.horizontalMenuDidMove?(at: index)}
                )
            }else{
                let xOffset = CGFloat(index) * self.controllerScrollView.frame.width
                self.controllerScrollView.setContentOffset(
                    CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y),
                    animated: false
                )
                self.delegate?.horizontalMenuDidMove?(at: index)
            }
        }
        else{self.delegate?.horizontalMenuDidMove?(at: index)}
    }
}


//============================================================================
//ADHorizontalMenuItemView
class ADHorizontalMenuItemView: UIView {
    
    var titleLabel : UILabel?
    var menuItemSeparator : UIView?
    
    func setupMenuItemView(
        _ menuItemWidth: CGFloat,
        menuScrollViewHeight: CGFloat,
        indicatorHeight: CGFloat,
        separatorPercentageHeight: CGFloat,
        separatorWidth: CGFloat,
        separatorRoundEdges: Bool,
        menuItemSeparatorColor: UIColor
        ){
        titleLabel = UILabel(
            frame: CGRect(
                x: 0.0,
                y: 0.0,
                width: menuItemWidth,
                height: menuScrollViewHeight - indicatorHeight
            )
        )
        
        menuItemSeparator = UIView(
            frame: CGRect(
                x: menuItemWidth - (separatorWidth / 2),
                y: floor(menuScrollViewHeight * ((1.0 - separatorPercentageHeight) / 2.0)),
                width: separatorWidth, height: floor(menuScrollViewHeight * separatorPercentageHeight)
            )
        )
        menuItemSeparator!.backgroundColor = menuItemSeparatorColor
        
        if separatorRoundEdges {
            menuItemSeparator!.layer.cornerRadius = menuItemSeparator!.frame.width / 2
        }
        menuItemSeparator!.isHidden = true
        self.addSubview(menuItemSeparator!)
        
        self.addSubview(titleLabel!)
    }
    
    func setTitleText(_ text: NSString) {
        if titleLabel != nil {
            titleLabel!.text = text as String
            titleLabel!.numberOfLines = 0
            titleLabel!.sizeToFit()
        }
    }
}
//============================================================================
//ADHorizontalMenuDefaultOptions
struct ADHorizontalMenuDefaultOptions {
    fileprivate var parameters = [ADHorizontalMenuOption]()
    static var `default`:ADHorizontalMenuDefaultOptions{
        let parameters:[ADHorizontalMenuOption] = [
            .scrollMenuBackgroundColor(.main),
            .viewBackgroundColor(.back),
            .menuItemFont(Font.MaterialIcons.font(30)),
            .bottomMenuHairlineColor(.main),
            .unselectedMenuItemLabelColor(UIColor.white.alpha(0.7)),
            .menuItemSeparatorWidth(0),
            .menuHeight(40.0),
            .menuItemWidth(63.0),
            .centerMenuItems(true)
        ]
        return ADHorizontalMenuDefaultOptions(parameters: parameters)
    }
    static var white:ADHorizontalMenuDefaultOptions{
        let parameters:[ADHorizontalMenuOption] = [
            .scrollMenuBackgroundColor(.hex("f0f0f0")),
            .viewBackgroundColor(.clear),
            .bottomMenuHairlineColor(.hex("f0f0f0")),
            .selectionIndicatorColor(.hex("212121")),
            .menuItemFont(Font.MaterialIcons.font(30)),
            .selectedMenuItemLabelColor(.hex("222222")),
            .unselectedMenuItemLabelColor(.hex("777777", alpha: 0.7)),
            .menuHeight(40.0),
            .menuItemWidth(63.0),
            .centerMenuItems(true)
        ]
        return ADHorizontalMenuDefaultOptions(parameters: parameters)
    }
    static var black:ADHorizontalMenuDefaultOptions{
        let parameters: [ADHorizontalMenuOption] = [
            .scrollMenuBackgroundColor(.hex("212121")),
            .viewBackgroundColor(.hex("303030")),
            .bottomMenuHairlineColor(.hex("212121")),
            .selectionIndicatorColor(.hex("f5f5f5")),
            .menuItemFont(Font.MaterialIcons.font(30)),
            .selectedMenuItemLabelColor(.hex("f5f5f5")),
            .unselectedMenuItemLabelColor(.hex("f5f5f5", alpha: 0.4)),
            .menuHeight(40.0),
            .menuItemWidth(65.0),
            .centerMenuItems(true)
        ]
        return ADHorizontalMenuDefaultOptions(parameters: parameters)
    }
}




