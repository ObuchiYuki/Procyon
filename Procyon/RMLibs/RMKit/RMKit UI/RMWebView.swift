import UIKit
import WebKit

class RMWebView: WKWebView {
    var didProgressChange:floatBlock = {_ in}
    var didTitleChange:stringBlock = {_ in}
    
    deinit {
        didProgressChange = {_ in}
        didTitleChange = {_ in}
        self.removeObserver(self, forKeyPath: "estimatedProgress")
        self.removeObserver(self, forKeyPath: "title")
    }
    func setup(){
        self.addObserver(self, forKeyPath:"estimatedProgress", options:.new, context:nil)
        self.addObserver(self, forKeyPath:"title", options: .new, context:nil)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {return}
        switch keyPath {
        case "estimatedProgress": if let progress = change?[.newKey] as? Float {didProgressChange(progress)}
        case "title": if let title = change?[.newKey] as? String {didTitleChange(title)}
        default: break
        }
    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}
