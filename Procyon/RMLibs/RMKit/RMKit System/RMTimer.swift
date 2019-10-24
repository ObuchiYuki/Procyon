import Foundation

class RMTimer: Timer {
    private var block:voidBlock = {}
    private var timer = Timer()
    var repeatCount = 0
    func start(_ interval:Double,block:@escaping voidBlock){
        self.block = block
        Action()
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(RMTimer.Action), userInfo: nil, repeats: true)
    }
    func startStopWatch(_ time:Double,endAction:@escaping voidBlock){
        self.block = endAction
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(RMTimer.Action), userInfo: nil, repeats: false)
    }
    func stop(){
        timer.invalidate()
        block = {}
    }
    @objc private func Action(){
        repeatCount+=1
        block()
    }
}
