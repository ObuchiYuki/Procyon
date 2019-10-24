import UIKit

let pixivSaveManager = PixivSaveManager()

class PixivSaveManager: NSObject {
    private var nowSaveing = false
    private var datas = [pixivWorkData]()
    
    private var nowPdfSaving = false
    private var pdfDJsons:[JSON] = []
    private lazy var docController:UIDocumentInteractionController! = nil
    
    private func save(at index:Int,data:pixivWorkData,completion:@escaping voidBlock){
        asyncQ{
            let request = (data.metaPages.index(index)?.original ?? "").request
            request.sync = true
            request.getImage{image in
                image.saveToPhotoAlbum()
                completion()
            }
        }
    }
    private func savein(){
        nowSaveing = true
        let helper = PixivSaveHelper()
        let snack = ADSnackbar()
        var title = datas[0].title
        if title.characters.count >= 8{
            title = title.substring(to: 8)+"..."
        }
        snack.title =  "downloading_[item_name]".l(title)+"1/\(self.datas[0].pageCount)"
        snack.duration = -1
        snack.setProgress()
        snack.show()
        helper.saveAll(
            datas[0],
            progress: {count in
                snack.title = "downloading_[item_name]".l(title)+"\(count+1)/\(self.datas[0].pageCount)"
                let per = (Float(count+1)/Float(self.datas[0].pageCount))/2.0
                snack.progessPer = per
            },
            process: {count in
                snack.title = "saveing_[item_name]".l(title)+"\(count)/\(self.datas[0].pageCount)"
                let per = (Float(count+1)/Float(self.datas[0].pageCount))/2.0+0.5
                snack.progessPer = per
            },
            completion: {
                snack.progessPer = 1
                snack.close()
                
                self.datas.remove(at: 0)
                if self.datas.count == 0{ADSnackbar.show("done".l())
                    self.nowSaveing = false
                }else{
                    self.savein()
                }
            }
        )
    }
    func saveAll(data:pixivWorkData){
        datas.append(data)
        if datas.count != 1{
            let snack = ADSnackbar()
            
            var title = data.title
            if title.characters.count >= 8{
                title = title.substring(to: 8)+"..."
            }
            snack.title = "[item_name]_will_be_save_next".l(title)
            snack.show()
        }
        if !nowSaveing{
            savein()
        }
    }
    func savePDF(data:pixivWorkData){
        if !nowPdfSaving{
            nowPdfSaving = true
            let helper = PixivSaveHelper()
            let snack = ADSnackbar()
            var title = data.title
            if title.characters.count >= 8{
                title = title.substring(to: 8)+"..."
            }
            snack.title = "downloading_[item_name]".l(title)+"1/\(data.pageCount)"
            snack.duration = -1
            snack.setProgress()
            snack.show()
            helper.savePdf(
                data,
                progress: {count in
                    snack.title = "downloading_[item_name]".l(title)+"\(count+1)/\(data.pageCount)"
                    let per = (Float(count+1)/Float(data.pageCount))
                    snack.progessPer = per
                    
                    if count == data.pageCount{
                        snack.title = "converting_to_pdf".l()
                    }
                },
                completion: {url in
                    snack.progessPer = 1
                    snack.close()
                    self.nowPdfSaving = false
                    
                    ADSnackbar.show("done".l())
                    self.nowSaveing = false
                    
                    RMDocumentController.show(url: url)
                }
            )
        }else{
            let dialog = ADDialog()
            
            var title = data.title
            if title.characters.count >= 8{
                title = title.substring(to: 8)+"..."
            }
            dialog.title = "error".l()
            dialog.message = "同時に2つのファイルの変換はできません。"
            dialog.addOKButton()
            dialog.show()
        }
    }
}

private class PixivSaveHelper:NSObject{
    var count = 0
    var total = 0
    var completion = {}
    var process:intBlock = {_ in}
    var images:[UIImage] = []
    var saveAsPdf = false
    var pdfCompletion:(URL)->() = {_ in}
    var progress:intBlock = {_ in}
    
    @objc private func saveEnd(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer){
        count -= 1
        if count == 0{
            self.completion()
        }else{
            save()
        }
    }
    func save(){
        if saveAsPdf{
            images.createPDF{data in data.save(withName: "tmp.pdf",atPath: .cache, completion: self.pdfCompletion)}
        }else{
            process(total-count+1)
            UIImageWriteToSavedPhotosAlbum(images[total-count], self, #selector(PixivSaveHelper.saveEnd(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    func savePdf(_ data:pixivWorkData,progress:@escaping intBlock,completion:@escaping (URL)->()){
        self.progress = progress
        self.pdfCompletion = completion
        saveAsPdf = true
        self.saveAll(data, progress: progress, process: {_ in}, completion: {})
    }
    func saveAll(_ data:pixivWorkData,progress:@escaping intBlock,process:@escaping intBlock,completion:@escaping voidBlock){
        self.completion = completion
        self.process = process
        self.progress = progress
        
        let imageULRs = data.metaPages.map{urls in urls.original}
        
        self.total = imageULRs.count
        self.count = imageULRs.count
        asyncQ{
            for i in 0..<imageULRs.count{
                let request = imageULRs[i].request
                request.sync = true
                request.referer = pixiv.referer
                request.getImage{[weak self] image in
                    self?.images.append(image)
                }
                mainQ{
                    self.progress(i)
                }
            }
            mainQ{
                self.progress(imageULRs.count)
                self.save()
            }
        }
    }
}








