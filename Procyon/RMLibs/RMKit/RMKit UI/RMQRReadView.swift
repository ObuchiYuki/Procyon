import UIKit
import AVFoundation

class RMQRreadView: RMCameraView {
    
    private var actions:[stringBlock] = []
    private var isfirstCall = true
    private var string = ""
    
    override func setup() {
        super.setup()
        self.metadataObjectTypes = [AVMetadataObjectTypeQRCode as AnyObject]
    }

    func loadNext(){
        isfirstCall = true
    }
    func addAction(_ block:@escaping stringBlock){
        actions.append(block)
    }
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects.count > 0 {
            if isfirstCall{
                string = (metadataObjects[0] as! AVMetadataMachineReadableCodeObject).stringValue
                for block in actions{
                    block(string)
                }
                isfirstCall = false
            }
        }
    }
}





