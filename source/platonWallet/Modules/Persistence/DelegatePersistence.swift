//
//  DelegatePersistence.swift
//  platonWallet
//
//  Created by Admin on 15/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import RealmSwift

class DelegatePersistence {
    public class func add(delegates: [DelegateDetailDel]) {
        let delegates = delegates.detached

        _ = delegates.map { $0.chainUrl = SettingService.shareInstance.getCurrentChainId() }

        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())

                try? realm.write {
                    realm.add(delegates, update: true)
                }
            })
        }
    }

    // 只返回blocknum，不要在这里进行blocknum判断
    public class func isDeleted(_ walletAddress: String, _ delegateDetail: DelegateDetail) -> Bool {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let predicate = NSPredicate(format: "compoundKey == %@ AND chainUrl == %@", "\(walletAddress)\(delegateDetail.nodeId)", SettingService.shareInstance.getCurrentChainId())
        let r = realm.objects(DelegateDetailDel.self).filter(predicate)
        let result = Array(r)
        guard result.count > 0 else {
            return false
        }

        if result.first?.delegationBlockNum != delegateDetail.delegationBlockNum {
            DelegatePersistence.delete(walletAddress, delegateDetail.nodeId)
            return false
        } else {
            return true
        }
    }

    public class func delete(_ walletAddress: String, _ nodeId: String) {
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                 let realm = try! Realm(configuration: RealmHelper.getConfig())

                let predicate = NSPredicate(format: "compoundKey == %@ AND chainUrl == %@", "\(walletAddress)\(nodeId)", SettingService.shareInstance.getCurrentChainId())
                try? realm.write {
                    realm.delete(realm.objects(DelegateDetailDel.self).filter(predicate))
                }
            })
        }
    }
}