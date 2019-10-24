import UIKit

class PixivUgoiraViewController: PixivBaseViewController{
    var data:pixivWorkData! = nil
    
    private var ugoiraData:pixivUgoiraData? = nil
    private var canMove = true
    private let imageView = UIImageView()
    private let progressBar = UIProgressView()
    
    override func setSetting() {
        self.themeColor = .hex("121212")
        self.backgroundColor = .hex("222")
        
        pixiv.getUgoiraMatadata(id: data.id, completion: {json in
            let ugoiraData = pixivUgoiraData(json: json)
            self.ugoiraData = ugoiraData
            let request = ugoiraData.zipUrl.request
            request.referer = pixiv.referer
            request.get(
                {[weak self] per in self?.gettingUgoira(per: per)},
                {[weak self] data in
                    guard let me = self else {return}
                    file.unZip("ugoira", contents: data, completion: me.getUgoiraDataFin)
                }
            )
        })
    }
    override func setUISetting() {
        imageView.contentMode = .scaleAspectFit
        progressBar.x = 30
        progressBar.centerY = contentView.height/2
    }
    override func setUIScreen() {
        imageView.size = contentSize
        progressBar.width = screen.width - 60
    }
    override func addUIs() {
        addSubview(imageView)
        addSubview(progressBar)
    }
    override func viewDidDisappear(_ animated: Bool) {
        canMove = false
    }
    private func gettingUgoira(per:Float){
        progressBar.progress = per
        if per == 1.0{
            progressBar.isHidden = true
        }
    }
    private func getUgoiraDataFin(path:String?) {
        if let path = path{
            asyncQ {[weak self] in
                guard let me = self else {return}
                var i = 0
                while(me.canMove){
                    if let url = ("file://"+path+me.ugoiraData!.files[i%me.ugoiraData!.count]).url{
                        do{
                            let data = try Data(contentsOf: url)
                            mainQ {me.imageView.image = UIImage(data: data)}
                        }
                        catch{ADSnackbar.show(error.localizedDescription)}
                    }
                    usleep(me.ugoiraData!.deleys[i%me.ugoiraData!.count]*1000)
                    i+=1
                }
            }
        }else{
            ADSnackbar.show("error".l())
        }
    }
}














