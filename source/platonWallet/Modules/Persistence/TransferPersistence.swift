//
//  TransferPersistence.swift
//  platonWallet
//
//  Created by matrixelement on 19/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift

class TransferPersistence {
    
    public class func add(tx : Transaction){
        let tx = tx.detached()
        
        tx.nodeURLStr = SettingService.getCurrentNodeURLString()
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                try? realm.write {
                    realm.add(tx, update: true)
                }
            })
        }
    }
    
    public class func update(
        txhash: String,
        status: Int,
        blockNumber: String,
        gasUsed: String,
        _ completion: (() -> Void)?) {
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                
                let predicate = NSPredicate(format: "txhash == %@ AND nodeURLStr == %@", txhash, SettingService.getCurrentNodeURLString())
                
                guard let transaction = realm.objects(Transaction.self).filter(predicate).first else {
                    completion?()
                    return
                }
                
                try? realm.write {
                    transaction.txReceiptStatus = (status == 0) ? 1 : 0
                    transaction.blockNumber = blockNumber
                    transaction.gasUsed = gasUsed
                    completion?()
                }
            })
        }
    }
    
    public class func getAll() -> [Transaction] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        
        let wallets = AssetVCSharedData.sharedData.walletList.filterClassicWallet
        let addresses = wallets.map { w -> String in
            return w.address.lowercased()
        }
        let predicate = NSPredicate(format: "nodeURLStr == %@", SettingService.getCurrentNodeURLString())
        let r = realm.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r)
        let result = array.filter { t -> Bool in
            return addresses.contains(t.from?.lowercased() ?? "")
        }
        return result
    }
    
    public class func getAllPendingTransactionsByAddress(from: String) -> [Transaction] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let predicate = NSPredicate(format: "(from contains[cd] %@ OR to contains[cd] %@) AND nodeURLStr == %@ AND blockNumber == %@ AND txhash != %@", from, from, SettingService.getCurrentNodeURLString(), "", "")
        let r = realm.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r)
        return array
    }
    
    public class func getUnConfirmedTransactions() -> [Transaction] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        
        let predicate = NSPredicate(format: "txhash != %@ AND blockNumber == %@ AND nodeURLStr == %@", "","",SettingService.getCurrentNodeURLString())
        let r = realm.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime")
        let array = Array(r)
        return array
    }
    
    public class func getByTxhash(_ hash : String?) -> Transaction? {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        
        let predicate = NSPredicate(format: "txhash == %@ AND nodeURLStr == %@", hash!,SettingService.getCurrentNodeURLString())
        let r = realm.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime")
        let array = Array(r)

        if array.count > 0{
            return array.first!
        } else {
            return nil
        }
    }
    
    public class func deleteConfirmedTransaction() {
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                let predicate = NSPredicate(format: "txhash != %@ AND blockNumber != %@", "","")
                try? realm.write {
                    realm.delete(realm.objects(Transaction.self).filter(predicate))
                }
            })
        }
    }
}
