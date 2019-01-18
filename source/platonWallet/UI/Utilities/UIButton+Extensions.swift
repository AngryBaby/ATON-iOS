//
//  UIButton+Extenstions.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/23.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

private var AssociatedKey: UInt8 = 1

extension UIButton {
    
    @IBInspectable
    public var localizedNormalTitle: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            localizationSetup();
            updateLocalization()
        }
    }
    
    func localizationSetup(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: Notification.Name(LCLLanguageChangeNotification), object: nil)
    }
    
    @objc public func updateLocalization() {
        if let localizedNormalTitle = localizedNormalTitle, !localizedNormalTitle.isEmpty {
            titleLabel?.text = Localized(localizedNormalTitle)
            setTitle(Localized(localizedNormalTitle), for: .normal)
        }
    }
    
}


extension UIButton {
    
    struct RuntimeKey {
        static let btnKey = UnsafeRawPointer.init(bitPattern: "BTNKey".hashValue)
    }

    var hitTestEdgeInsets: UIEdgeInsets? {
        set {
            objc_setAssociatedObject(self, RuntimeKey.btnKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
        get {
            return (objc_getAssociatedObject(self, RuntimeKey.btnKey!) as? UIEdgeInsets) ?? UIEdgeInsets.zero
        }
    }

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if UIEdgeInsetsEqualToEdgeInsets(hitTestEdgeInsets!, UIEdgeInsets.zero) || !isEnabled || isHidden {
            return super.point(inside: point, with: event)
        }
        let relativeFrame = bounds
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets!)
        //let hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets!)
        return hitFrame.contains(point)
    }
    
}


extension UIButton {
    
    func setCommonEanbleStyle(_ enable: Bool)  {
        if enable{
            self.backgroundColor = UIColor(rgb: 0xEFF0F5)
            self.isUserInteractionEnabled = true
            self.setTitleColor(UIColor(rgb: 0x1b2137), for: .normal)
        }else{
            self.backgroundColor = UIColor(rgb: 0x272E47)
            self.isUserInteractionEnabled = false
            self.setTitleColor(UIColor(rgb: 0x626980), for: .normal)
        }
    }
    
    func setupSwitchWalletStyle(){
        self.addMaskView(corners: [.bottomRight,.topRight], cornerRadiiV: 5)
        
        let chooseWalletImgView = UIImageView(image: UIImage(named: "chooseWallet"))
        self.addSubview(chooseWalletImgView)
        chooseWalletImgView.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(10)
            make.size.equalTo(CGSize(width: 16, height: 16))
            make.centerY.equalTo(self)
        }
        
        let Label = UILabel()
        Label.localizedText = "transferVC_switch_des"
        Label.textColor = UIColor(rgb: 0x1b2137)
        Label.font = UIFont.systemFont(ofSize: 10)
        self.addSubview(Label)
        Label.snp.makeConstraints { (make) in
            make.leading.equalTo(chooseWalletImgView.snp_leadingMargin).offset(12)
            make.centerY.equalTo(self)
            make.trailing.equalTo(self)
        }
    }
    
}

