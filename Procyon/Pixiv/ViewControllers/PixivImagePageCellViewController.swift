import UIKit

class PixivImagePageCellViewController: ADPageCellViewController{
    //====================================================================
    //properties
    var image:UIImage? = nil{
        didSet{backgroundImageView.image = image}
    }
    //==================================
    //views
    private var backgroundImageView = RMScrollableImageView()
    private var indicator = ADActivityIndicator()
    //====================================================================
    //method
    //======================================
    //setDataObject
    override func set(data: Any?) {
        guard let data = data as? pixivWorkData.pixivImageUrlsData else {return}
        let request = data.original.request
        request.referer = pixiv.referer
        request.getImage{image in
            self.image = image
            self.indicator.stop()
            self.indicator.removeFromSuperview()
        }
    }
    //====================================================================
    //delegateMethod
    func longHold(){
        let dialog = ADDialog()
        if image == nil{
            dialog.title = "error".l()
            dialog.message = "image_has_not_been_downloaded".l()
            dialog.addOKButton()
        }else{
            dialog.title = "save_to_cameraroll?".l()
            dialog.addOKButton{
                self.image?.saveToPhotoAlbum()
                ADSnackbar.show("image_saved".l())
            }
            dialog.addCancelButton()
        }
        dialog.show()
    }
    
    func tap(){
        sendToRoot(identifier: "cellViewTapped", info: nil)
    }
    override func setUISetting() {
        isStatusBarHidden = true
        contentView.backgroundColor = .hex("222222")
        contentView.addGestureAction(.tap, action: tap)
        contentView.addGestureAction(.longHold, action: longHold)
        
        backgroundImageView.contentMode = .scaleAspectFit
    }
    override func setUIScreen() {
        indicator.center = center
        
        backgroundImageView.size = fullScreenSize
    }
    override func addUIs() {
        addSubview(indicator)
        addSubview(backgroundImageView)
    }
}


