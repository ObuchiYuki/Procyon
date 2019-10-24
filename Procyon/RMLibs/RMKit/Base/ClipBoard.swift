import UIKit

class RMClipBoard:NSObject {
    //==========================================================================
    //you can get and set String to Clip Board
    var text:String{
        get{
            let inText = UIPasteboard.general.value(forPasteboardType: "public.text") as? String
            if inText != nil {
                return inText!
            }else{
                return ""
            }
        }
        set(value){
            asyncQ {UIPasteboard.general.setValue(value, forPasteboardType: "public.text")}
        }
    }
    //==========================================================================
    //you can get and set UIImage to Clip Board
    var image:UIImage?{
        get{
            return UIPasteboard.general.value(forPasteboardType: "public.image") as? UIImage
        }
        set(value){
            if value != nil {
                asyncQ {UIPasteboard.general.setValue(value!, forPasteboardType: "public.image")}
            }
        }
    }
}
