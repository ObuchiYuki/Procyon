import UIKit
import StoreKit

class RMStoreManager{
    private var request:SKProductsRequest? = nil
    let helper = RMStoreHelper()
    
    func buy(id: String, completion: @escaping boolBlock){
        let dialog = ADDialog()
        dialog.setIndicator(title: "お待ちください...")
        dialog.show()
        if !SKPaymentQueue.canMakePayments(){completion(false)}
        let request = SKProductsRequest(productIdentifiers: Set<String>([id]))
        self.request = request
        request.delegate = helper
        helper.buyBlock = {product in
            dialog.close()
            guard let product = product else {return}
            SKPaymentQueue.default().add(SKMutablePayment(product: product))
        }
        helper.completionBlock = {flag in
            if flag{info.set(true, forKey: id)}
            completion(flag)
        }
        request.start()
    }
    func restore(id: String, completion: @escaping boolBlock){
        if !SKPaymentQueue.canMakePayments(){completion(false)}
        helper.completionBlock = {flag in
            if flag{info.set(true, forKey: id)}
            completion(flag)
        }
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    func isBought(id: String)->Bool {
        return info.boolValue(forKey: id)
    }
}
class RMStoreHelper:NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    var buyBlock:(SKProduct?)->() = {_ in}
    var completionBlock:boolBlock = {_ in}
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        buyBlock(response.products.index(0))
    }
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                completionBlock(true)
                queue.finishTransaction(transaction)
            case .failed:
                completionBlock(false)
                queue.finishTransaction(transaction)
            default:
                break
            }
        }
    }
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {}
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        queue.transactions.map{t in
            if t.transactionState.rawValue == 3{
                queue.finishTransaction(t)
                completionBlock(true)
                completionBlock = {_ in}
            }
        }
        completionBlock(false)
        completionBlock = {_ in}
    }
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        
        completionBlock(false)
        completionBlock = {_ in}
    }
}
extension SKProduct{
    var localizedPrice:String{
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? ""
    }
}
