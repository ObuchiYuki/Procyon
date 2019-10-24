//==========================================================================
//this class manage audio
import AudioToolbox

class RMAudioManager:NSObject{
    //===================================================
    //Literally!
    //not sabotage just Literally literally...
    private var seIds:[String:SystemSoundID] = [:]
    private var bgmIds:[String:SystemSoundID] = [:]
    
    func stopSEWithName(_ name:String){
        if seIds[name] != nil {
            AudioServicesRemoveSystemSoundCompletion(seIds[name]!)
        }
    }
    
    func stopBGMWithName(_ name:String){
        if bgmIds[name] != nil {
            AudioServicesRemoveSystemSoundCompletion(bgmIds[name]!)
        }
    }
    
    func stopAllSE(){
        for id in seIds.values{
            AudioServicesRemoveSystemSoundCompletion(id)
        }
    }
    func stopAllBGM(){
        for id in bgmIds.values{
            AudioServicesRemoveSystemSoundCompletion(id)
        }
    }
    
    func playSE(_ name:String,type:String){
        var soundIdRing:SystemSoundID = 0
        let path = Bundle.main.path(forResource: name, ofType: type)!
        let fileURL = URL(fileURLWithPath: path as String)
        AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundIdRing)
        AudioServicesPlaySystemSound(soundIdRing)
        
        self.seIds[name] = soundIdRing
    }
    func playBGM(_ name:String,type:String){
        var soundIdRing:SystemSoundID = 0
        let path = Bundle.main.path(forResource: name, ofType: type)!
        let fileURL = URL(fileURLWithPath: path as String)
        AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundIdRing)
        AudioServicesPlaySystemSound(soundIdRing)
        
        self.bgmIds[name] = soundIdRing
    }
}
