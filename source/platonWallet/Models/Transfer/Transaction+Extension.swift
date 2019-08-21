//
//  Transaction+Extension.swift
//  platonWallet
//
//  Created by Admin on 13/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

extension Transaction {
    var toAvatarImage: UIImage? {
        switch txType! {
        case .transfer,
             .unknown:
            let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.key?.address == to }.first
            guard let wallet = localWallet else {
                return UIImage(named: "walletAvatar_1")
            }
            return wallet.image()
        default:
            if toType == .contract {
                return UIImage(named: "2.icon_Shared")
            } else {
                return UIImage(named: "2.icon_node")
            }
        }
    }
    
    var fromAvatarImage: UIImage? {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.key?.address == from }.first
        guard let wallet = localWallet else {
            return UIImage(named: "walletAvatar_1")
        }
        return wallet.image()
    }
    
    var toNameString: String? {
        switch txType! {
        case .transfer,
             .unknown:
            let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.key?.address.lowercased() == to?.lowercased() }.first
            guard let wallet = localWallet else {
                return to?.addressForDisplayShort()
            }
            return wallet.name
        default:
            return nodeName ?? to?.addressForDisplayShort()
        }
    }
    
    var fromNameString: String? {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.key?.address.lowercased() == from?.lowercased() }.first
        guard let wallet = localWallet else {
            return from?.addressForDisplayShort()
        }
        return wallet.name
    }
    
    var valueString: (String?, UIColor?) {
        if txReceiptStatus == -1 {
            return (nil, nil)
        }
        
        switch direction {
        case .Sent:
            guard let string = valueDescription else {
                return (nil, nil)
            }
            return ("-" + string, UIColor(rgb: 0xff3b3b))
        case .Receive:
            guard let string = valueDescription else {
                return (nil, nil)
            }
            return ("+" + string, UIColor(rgb: 0x19a20e))
        default:
            return (nil, nil)
        }
    }
    
    var toIconImage: UIImage? {
        switch toType {
        case .contract:
            return UIImage(named: "2.icon_Shared2")
        default:
            return nil
        }
    }
    
    var amountTextColor: UIColor {
        switch direction {
        case .Receive:
            return UIColor(rgb: 0x19a20e)
        case .Sent:
            return UIColor(rgb: 0xff3b3b)
        default:
            return UIColor(rgb: 0xb6bbd0)
        }
    }
    
    var txTypeIcon: UIImage? {
        switch direction {
        case .Receive:
            if txType! == .transfer {
                return UIImage(named: "txRecvSign")
            }
            return UIImage(named: "1.icon_Undelegate")
        case .Sent:
            if txType! == .transfer {
                return UIImage(named: "txSendSign")
            }
            return UIImage(named: "1.icon_Delegate")
        default:
            return nil
        }
    }
}


extension Transaction {
    var recordIconIV: UIImage? {
        switch txType! {
        case .delegateCreate:
            return UIImage(named: "1.icon_Delegate")
        case .delegateWithdraw:
            return UIImage(named: "1.icon_Undelegate")
        default:
            return UIImage(named: "1.icon_Delegate")
        }
    }
    
    var recordAmount: String? {
        switch txType! {
        case .delegateCreate:
            return value
        case .delegateWithdraw:
            return unDelegation
        default:
            return value
        }
    }
    
    var recordAmountForDisplay: String {
        return recordAmount?.vonToLATString.balanceFixToDisplay(maxRound: 8).ATPSuffix() ?? "--"
    }
    
    var recordStatus: (String, UIColor) {
        switch txType! {
        case .delegateCreate:
            if txReceiptStatus == 1 {
                return (Localized("TransactionStatus_succeed_delegate"), status_green_color)
            } else if txReceiptStatus == 0 {
                return (Localized("TransactionStatus_failed_delegate"), status_red_color)
            } else {
                return (Localized("TransactionStatus_pending_desc"), status_blue_color)
            }
        case .delegateWithdraw:
            if redeemStatus == 1 {
                return (Localized("TransactionStatus_loading_undelegate"), status_blue_color)
            } else if redeemStatus == 2 {
                return (Localized("TransactionStatus_succeed_undelegate"), status_green_color)
            } else {
                if txReceiptStatus == 1 {
                    return (Localized("TransactionStatus_succeed_desc"), status_green_color)
                } else if txReceiptStatus == 0 {
                    return (Localized("TransactionStatus_failed_desc"), status_red_color)
                } else {
                    return (Localized("TransactionStatus_pending_desc"), status_blue_color)
                }
            }
            
        default:
            if txReceiptStatus == 1 {
                return (Localized("TransactionStatus_succeed_desc"), status_green_color)
            } else if txReceiptStatus == 0 {
                return (Localized("TransactionStatus_failed_desc"), status_red_color)
            } else {
                return (Localized("TransactionStatus_pending_desc"), status_blue_color)
            }
        }
    }
    
    var recordTime: String? {
        let format = DateFormatter()
        let date = Date(timeIntervalSince1970: TimeInterval(confirmTimes/1000))
        let localZone = NSTimeZone.local
        format.timeZone = localZone
        format.locale = NSLocale.current
        format.dateFormat = "#yyyy/MMdd HH:mm"
        let strDate = format.string(from: date)
        return strDate
    }
    
    var recordWalletName: String? {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.key?.address.lowercased() == from?.lowercased() }.first
        return (localWallet?.name ?? "--") + "(" + (from?.addressForDisplayShort() ?? "--") + ")"
    }
}