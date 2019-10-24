import UIKit

class PixivAlbumViewController: PixivBaseViewController{
    var data:pixivAlbumData! = nil
    let inner = PixivAlbumInner()
    
    override func setSetting() {
        inner.playButton.addAction {[weak self] in
            guard let me = self else {return}
            let dialog = ADDialog()
            dialog.title = "スライドショーを再生？"
            dialog.addOKButton {
                var workData = pixivWorkData()
                for data in me.inner.datas.works{
                    workData.metaPages.append(contentsOf: data.metaPages)
                }
                workData.title = me.data.title
                let vc = PixivImagePageViewController()
                vc.data = workData
                vc.isAuto = true
                self?.go(to: vc)
            }
            dialog.addCancelButton()
            dialog.show()
        }
        inner.settingView.tip.addAction {[weak self] in
            let menu = ADMenu()
            menu.titles = ["アルバムを削除","アルバム名を変更","スライド時間を変更"]
            menu.iconArr = ["delete","edit","timer"]
            menu.indexAction = {index in
                switch index{
                case 0:
                    let dialog = ADDialog()
                    dialog.title = "削除しますか？"
                    dialog.addOKButton {
                        albumApi.deleteAlbum(id: self?.data.id ?? -1, completion: {
                            self?.back()
                            ADSnackbar.show("削除しました。")
                        })
                    }
                    dialog.addCancelButton()
                    dialog.show()
                case 1:
                    let dialog = ADDialog()
                    dialog.title = "アルバム名を変更"
                    dialog.textFieldPlaceHolder = "アルバム名"
                    dialog.textFieldText = self?.data.title ?? ""
                    dialog.addOKButton {
                        let text = dialog.textFieldText
                        if text.isEmpty{
                            dialog.close()
                            let dialog = ADDialog()
                            dialog.title = "error".l()
                            dialog.message = "アルバム名を入力してください"
                            dialog.addOKButton()
                            dialog.show()
                        }else{
                            albumApi.renameAlbum(id: self?.data.id ?? -1, title: dialog.textFieldText, completion: {
                                self?.title = dialog.textFieldText
                            })
                        }
                    }
                    dialog.addCancelButton()
                    dialog.show()
                case 2:
                    let dialog = ADDialog()
                    dialog.setTableView(titles: ["3秒","5秒","10秒","30秒","その他",], style: .select){i in
                        if i == 4{
                            let dialog = ADDialog()
                            dialog.title = "時間を入力"
                            dialog.textFieldPlaceHolder = "秒"
                            dialog.textFieldText = "\(PixivSystem.slideTime)"
                            dialog.addOKButton {
                                if let time = dialog.textFieldText.int{
                                    ADSnackbar.show("\(time)秒に設定しました。")
                                    PixivSystem.slideTime = UInt32(time)
                                }else{
                                    ADSnackbar.show("数字を入力してください。")
                                }
                            }
                            dialog.addCancelButton()
                            dialog.show()
                        }else{
                            PixivSystem.slideTime = [3,5,10,30].index(i) ?? 5
                            ADSnackbar.show("\([3,5,10,30].index(i) ?? 5)秒に設定しました。")
                        }
                    }
                    dialog.title = "スライドの時間"
                    dialog.addCancelButton()
                    dialog.show()
                default:
                    break
                }
            }
            menu.show(windowAnimated: true)
        }
        title = data.title
        inner.data = data
        inner.size = contentSize
        inner.delegate = self
        addSubview(inner.view)
    }
    override func setLoadControl() {
        inner.viewDidAppear(true)
    }
}
