//
//  ExportPrivateKeyOrKeystoreViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/29.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift
 
class ExportPrivateKeyOrKeystoreViewController: BaseViewController {
    
    enum ExportType {
        case privateKey,keystore
    }
    
    var tabTitles = [String]()
    var note = ""
    
    var plainText: String!
    
    lazy var pageVC: UIPageViewController = {
        
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.delegate = self
        vc.dataSource = self
        return vc
        
    }()
    
    lazy var headerView: ImportWalletHeaderView = {
        
        let view = ImportWalletHeaderView(tabLists: tabTitles, currentIndex: currentIndex)
        view.delegate = self
        return view
        
    }()
    
    lazy var viewControllers: [UIViewController] = {
        
        let vc1 = ExportToPlainTextViewController()
        vc1.plainText = plainText
        vc1.note = note
        
        let vc2 = ExportToQRCodeViewController()
        vc2.plainText = plainText
        vc2.note = note
        
        return [vc1,vc2]
        
    }()
    
    var currentIndex = 0 {
        didSet {
            if oldValue == currentIndex {
                return
            }
            headerView.curIndex = currentIndex
        }
    }

    var exportType: ExportType = .privateKey 
    
    convenience init(exportType: ExportType) {
        self.init()
        self.exportType = exportType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        
        if exportType == .privateKey {
            let alertC = PAlertController(title: Localized("alert_screenshot_ban_title"), message: Localized("alert_screenshot_privateKey_ban_msg"), image: UIImage(named: "icon_screenshot_ban"))
            alertC.addAction(title: Localized("alert_screenshot_ban_confirmBtn_title")) {
                
            }
            alertC.show(inViewController: self)
        }else {
            let alertC = PAlertController(title: Localized("alert_screenshot_ban_title"), message: Localized("alert_screenshot_keystore_ban_msg"), image: UIImage(named: "icon_screenshot_ban"))
            alertC.addAction(title: Localized("alert_screenshot_ban_confirmBtn_title")) {
                
            }
            alertC.show(inViewController: self)
        }
        
    }
    
    func setupUI() {
        
        if exportType == .privateKey {
            tabTitles = [Localized("ExportPrivateKeyVC_tab1_title"), Localized("ExportPrivateKeyVC_tab2_title")]
            note = Localized("ExportPrivateKeyVC_note")
            title = Localized("ExportPrivateKeyVC_title")
        }else {
            tabTitles = [Localized("ExportKeystoreVC_tab1_title"), Localized("ExportKeystoreVC_tab2_title")]
            note = Localized("ExportKeystoreVC_note")
            title = Localized("ExportKeystoreVC_title")
        }
        
        view.addSubview(headerView)
        headerView.snp.makeConstraints { (maker) in
            maker.top.left.right.equalToSuperview()
            maker.height.equalTo(42)
        }
        
        pageVC.setViewControllers([viewControllers[currentIndex]], direction: .forward, animated: false, completion: nil)
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            maker.top.equalTo(headerView.snp.bottom)
        }
        
    }
    
 
}


extension ExportPrivateKeyOrKeystoreViewController:UIPageViewControllerDelegate,UIPageViewControllerDataSource,ImportWalletHeaderViewDelegate {
    
    
    /// UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var curIndex:Int! = viewControllers.firstIndex { (vc) -> Bool in
            vc == viewController
        }
        
        if curIndex == 0 {
            return nil
        }
        curIndex -= 1
        
        return viewControllers[curIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var curIndex:Int! = viewControllers.firstIndex { (vc) -> Bool in
            vc == viewController
        }
        
        if curIndex == viewControllers.count - 1 {
            return nil
        }
        curIndex += 1
        
        return viewControllers[curIndex]
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let curIndex:Int! = viewControllers.firstIndex { (vc) -> Bool in
            vc == pageViewController.viewControllers![0]
        }
        
        currentIndex = curIndex
        
    }
    
    ///ImportWalletHeaderViewDelegate
    func didClickTabIndex(_ index: Int) {
        var direction = UIPageViewController.NavigationDirection.forward
        
        if index < currentIndex {
            direction = UIPageViewController.NavigationDirection.reverse
        }
        
        pageVC.setViewControllers([viewControllers[index]], direction: direction, animated: true, completion: nil)
        
        currentIndex = index
    }
    
    
}
