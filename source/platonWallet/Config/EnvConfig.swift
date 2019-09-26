//
//  EvnConfig.swift
//  platonWallet
//
//  Created by Ned on 2019/9/17.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

struct ConfigURLInfo {
    var CenterRPCURL: String = ""
    var NodeRPCURL: String = ""
    var chainID: String = ""
}

enum EnvConfig {
    case Dev
    case Test
    case Production_Test
    case Production_main
    
    func getConfigURLInfo() -> ConfigURLInfo {
        switch self {
        case .Dev:
            let CenterRPCURL = "http://192.168.9.190:443/app/v0700"
            let NodeRPCURL = "http://192.168.9.190:443/rpc"
            let chainId = "103"
            return ConfigURLInfo(CenterRPCURL: CenterRPCURL,
                             NodeRPCURL: NodeRPCURL,
                                 chainID: chainId)
        case .Test:
            let CenterRPCURL = "http://192.168.9.190:1000/app/v0700"
            let NodeRPCURL = "http://192.168.9.190:1000/rpc"
            let chainId = "103"
            return ConfigURLInfo(CenterRPCURL: CenterRPCURL,
                                 NodeRPCURL: NodeRPCURL,
                                 chainID: chainId)
        case .Production_Test:
            let CenterRPCURL = "https://aton.test.platon.network/app/v0700"
            let NodeRPCURL = "https://aton.test.platon.network/rpc"
            let chainId = "103"
            return ConfigURLInfo(CenterRPCURL: CenterRPCURL,
                                 NodeRPCURL: NodeRPCURL,
                                 chainID: chainId)
        case .Production_main:
            let CenterRPCURL = "https://aton.main.platon.network/app/v0700"
            let NodeRPCURL = "https://aton.main.platon.network/rpc"
            let chainId = "101"
            return ConfigURLInfo(CenterRPCURL: CenterRPCURL,
                                 NodeRPCURL: NodeRPCURL,
                                 chainID: chainId)
        }
    }
    
}
