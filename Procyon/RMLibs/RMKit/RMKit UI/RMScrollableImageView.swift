import UIKit

class RMScrollableImageView: RMView ,UIScrollViewDelegate{
    var image:UIImage?{
        set{
            imageView.image = newValue
            imageType = ImageType(size: newValue?.size ?? .zero)
            if let imageSize = self.imageView.image?.size{
                if imageType == .vertical{
                    scrollView.maximumZoomScale = size.width/(imageSize.smallerScale/(imageSize.biggerScale/size.height))
                }else if imageType == .horizontal {
                    scrollView.maximumZoomScale = size.height/(imageSize.smallerScale/(imageSize.biggerScale/size.width))
                }
            }
        }
        get{return imageView.image}
    }
    override var clipsToBounds: Bool{
        set{
            super.clipsToBounds = newValue
            imageView.clipsToBounds = newValue
        }
        get{return super.clipsToBounds}
    }
    override var contentMode:UIViewContentMode{
        set{imageView.contentMode = newValue}
        get{return imageView.contentMode}
    }
    
    private var imageView = UIImageView()
    private var scrollView = UIScrollView()
    private var imageType:ImageType = .normal
    
    private enum ImageType {
        case normal
        case vertical
        case horizontal
        init(size:Size) {
            if size.height/size.width>3.5{
                self = .vertical
            }else if size.width/size.height>3.5{
                self = .horizontal
            }else{
                self = .normal
            }
        }
    }
    override func didChangeFrame() {
        scrollView.size = self.size
        imageView.size = self.size
    }
    override func setup() {
        super.setup()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 8
        scrollView.isDirectionalLockEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        let doubleTapGesture = UITapGestureRecognizer(
            target: self,
            action:#selector(RMScrollableImageView.doubleTap(_:))
        )
        doubleTapGesture.numberOfTapsRequired = 2
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(doubleTapGesture)
        
        scrollView.addSubview(imageView)
        addSubview(scrollView)
    }
    
    func didFrameChange() {
        scrollView.frame = self.frame
        imageView.frame = self.frame
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    private func resizeImageView(center: CGPoint,animated: Bool){
        if let imageSize = self.imageView.image?.size{
            if scrollView.zoomScale == 1{
                var center = center
                var scale:CGFloat = 1
                switch imageType {
                case .vertical:
                    center = pointMake(imageView.centerX, center.y)
                    scale = size.width/(imageSize.smallerScale/(imageSize.biggerScale/size.height))
                    scrollView.isDirectionalLockEnabled = true
                case .horizontal:
                    center = pointMake(center.x, imageView.centerY)
                    scale = size.height/(imageSize.smallerScale/(imageSize.biggerScale/size.width))
                    scrollView.maximumZoomScale = scale
                    scrollView.isDirectionalLockEnabled = true
                case .normal:
                    scale = scrollView.zoomScale*2.5
                    scrollView.isDirectionalLockEnabled = false
                }
                self.scrollView.contentSize.width = self.width
                self.scrollView.zoom(to: zoomRect(for: scale,center: center),animated:animated)
                
            }else{
                self.scrollView.zoom(to: zoomRect(for: 1,center: center),animated:animated)
            }
        }
    }
    @objc private func doubleTap(_ gesture: UITapGestureRecognizer){
        resizeImageView(center: gesture.location(in: gesture.view),animated: true)
    }
    private func zoomRect(for scale:CGFloat, center: CGPoint) -> CGRect{
        var zoomRect = CGRect()
        zoomRect.size.height = self.scrollView.frame.size.height / scale
        zoomRect.size.width = self.scrollView.frame.size.width / scale
        
        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0
        
        return zoomRect
    }
}
