import UIKit
import AVFoundation

class RMCameraView: RMView ,AVCaptureMetadataOutputObjectsDelegate{
    
    private var videoLayer:AVCaptureVideoPreviewLayer!
    private let metaDataOutput = AVCaptureMetadataOutput()
    private let imageOutput = AVCaptureStillImageOutput()
    var metadataObjectTypes:[AnyObject] = []
    
    func takePhoto(_ completion:@escaping imageBlock){
        imageOutput.captureStillImageAsynchronously(
        from: imageOutput.connection(withMediaType: AVMediaTypeVideo)){buffer , error  in
            completion(UIImage(data: AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer))!)
        }
    }
    
    override func setup() {
        super.setup()
        runInNextLoop{
            let session = AVCaptureSession()
            var device: AVCaptureDevice!
            
            
            for item in AVCaptureDevice.devices(){
                if((item as AnyObject).position == AVCaptureDevicePosition.back){
                    device = item as! AVCaptureDevice
                }
            }
            session.addInput(try! AVCaptureDeviceInput(device: device) as AVCaptureDeviceInput)
            session.addOutput(self.metaDataOutput)
            session.addOutput(self.imageOutput)
            self.metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            self.metaDataOutput.metadataObjectTypes = self.metadataObjectTypes
            
            self.videoLayer = AVCaptureVideoPreviewLayer(session: session)
            self.videoLayer.frame = self.bounds
            self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            session.startRunning()
            self.layer.addSublayer(self.videoLayer)
        }
    }
    override func didChangeFrame() {
        if videoLayer != nil{
            videoLayer.frame = self.frame
        }
    }
}
