import UIKit
import StoreKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        let sys = System()
        system.delegate = sys
        system.mainWindow = window
        info.setup()
        SKPaymentQueue.default().add(store.helper)
        system.appLuanch()
        
        return true
    }
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        system.appOpenURL(url: url)
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        system.appClose()
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        system.appOpen()
    }
    func applicationWillTerminate(_ application: UIApplication) {
        system.appEnd()
    }
}

