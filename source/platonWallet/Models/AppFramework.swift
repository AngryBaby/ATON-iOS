//
//  AppFramework.swift
//  platonWallet
//
//  Created by matrixelement on 19/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift
import RealmSwift
import BigInt
import Bugly
import platonWeb3

class AppFramework {
    
    static let sharedInstance = AppFramework()
    
    func initialize() -> Bool {
        languageSetting()
        initBugly()
        initUMeng()
        doSwizzle()
        if !RealmConfiguration(){
            return false
        }
        modulesConfigure()
        return true
    }
    
    func initweb3(){
        Debugger.enableDebug(true)
    }
    
    func initBugly(){
        Bugly.start(withAppId: BuglyAppleID)
    }
    
    func initUMeng() {
        UMConfigure.initWithAppkey(Production_Umeng_key, channel: "App Store")
        MobClick.setAutoPageEnabled(true)
        UMConfigure.setLogEnabled(true)
    }
    
    func modulesConfigure(){
        let _ = AssetService.sharedInstace
        let _ = TransactionService.service
    }
     
    func languageSetting() {
        let defaullt = UserDefaults.standard.object(forKey: "LCLCurrentLanguageKey")
        if  defaullt == nil {
            let curlan = GetCurrentSystemSettingLanguage()
            if curlan == "cn"{
                Localize.setCurrentLanguage("zh-Hans")
            }else{
                Localize.setCurrentLanguage("en")
            }
        }
    }

    func RealmConfiguration() -> Bool {
        
        let readRealm = try? Realm(configuration: RealmHelper.getConfig())
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                RealmHelper.initWriteRealm()
            })
        }
        
        RealmReadeQueue.async {
            RealmHelper.initReadRealm()
        }
        
        RealmHelper.setDefaultInstance(r: readRealm)
        
        guard readRealm != nil else {
            print("realm open fail")
            return false
        }
        //set node storage first
        let nodeStorge = NodeInfoPersistence(realm: RealmInstance!)
        SettingService.shareInstance.nodeStorge = nodeStorge

        let walletStorge = WallletPersistence(realm: RealmInstance!)
        WalletService.sharedInstance.walletStorge = walletStorge
        
        // 删除缓存在本地且已经被链上确认删除的交易
        TransferPersistence.deleteConfirmedTransaction()
        
        return true
        
    }
    
    func doSwizzle(){
        
        //RTRootNavigationController.doBadSwizzleStuff()
        UIViewController.doBadSwizzleStuff()
    }
}
