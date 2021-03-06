//
//  TransactionViewControllerV060.swift
//  platonWallet
//
//  Created by juzix on 2019/3/5.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import MJRefresh

protocol ChildScrollViewDidScrollDelegate: AnyObject {
    func childScrollViewDidScroll(childScrollView: UIScrollView)
}

class MultiGestureTableView: UITableView {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class AssetTransactionViewControllerV060: BaseViewController, EmptyDataSetDelegate, EmptyDataSetSource {

    var tableView: MultiGestureTableView = MultiGestureTableView(frame: .zero, style: .plain)

    weak var delegate: ChildScrollViewDidScrollDelegate?

    var dataSource = [String: [Transaction]]() {
        didSet {
            if
                let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress,
                let dataCount = dataSource[selectedAddress]?.count, dataCount >= listSize {
                tableView.mj_footer.isHidden = false
            } else {
                tableView.mj_footer.isHidden = true
            }
        }
    }

    var localDataSource = [String: [Transaction]]()

    var walletAddress: String?

    var pollingTimer: Timer?

    var assetHeaderHide = false

    weak var parentController: AssetViewControllerV060?

    lazy var refreshFooterView: MJExtensionLoadMoreFooterView = {
        let view = MJExtensionLoadMoreFooterView(refreshingTarget: self, refreshingAction: nil)!
        return view
    }()

    let listSize = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.emptyDataSetView { [weak self] view in
            let holder = self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, nil, "empty_no_data_img") as? TableViewNoDataPlaceHolder
            view.customView(holder)
            view.isScrollAllowed(true)
        }
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        tableView.registerCell(cellTypes: [WalletDetailCell.self])
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-49)
            make.leading.trailing.top.equalToSuperview()
        }

        self.walletAddress = AssetVCSharedData.sharedData.selectedWalletAddress
        AssetVCSharedData.sharedData.registerHandler(object: self) {[weak self] in
            self?.walletAddress = AssetVCSharedData.sharedData.selectedWalletAddress
            self?.refreshData()
            self?.tableView.reloadData()
        }
        self.setplaceHolderBG(hide: true, tableView: tableView)

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(willDeleteWallet(_:)), name: Notification.Name.ATON.WillDeleateWallet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateWalletList), name: Notification.Name.ATON.updateWalletList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(nodeDidSwitch), name: Notification.Name(NodeStoreService.didSwitchNodeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pollingWalletTransactions), name: Notification.Name.ATON.UpdateTransactionList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTransactionUpdate(_:)), name: Notification.Name.ATON.DidUpdateTransactionByHash, object: nil)

        refreshFooterView.loadMoreTapHandle = { [weak self] in
            self?.goTransactionList()
        }
        tableView.mj_footer = refreshFooterView
    }

    func setHeaderStyle(hide: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.reloadData()
            self.assetHeaderHide = hide
            self.setplaceHolderBG(hide: hide, tableView: self.tableView)
        }
    }

}

// MARK: - business logic

extension AssetTransactionViewControllerV060 {

    func refreshData() {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        dataSource[selectedAddress] = dataSource[selectedAddress]?.filter { !$0.isInvalidated }
        commonInit()
        refreshPendingData()
        fetchTransactionLastest()

        if AssetVCSharedData.sharedData.walletList.count == 0 {
            self.tableNodataHolderView.descriptionLabel.localizedText = "IndividualWallet_EmptyView_tips"
        } else {
            self.tableNodataHolderView.descriptionLabel.localizedText = "walletDetailVC_no_transactions_text"
        }
    }

    func commonInit() {
        if pollingTimer == nil {
            pollingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(AppConfig.TimerSetting.balancePollingTimerInterval), target: self, selector: #selector(pollingGetBalance), userInfo: nil, repeats: true)
        }
    }

    @objc func pollingGetBalance() {
        AssetService.sharedInstace.fetchWalletBalanceForV7(nil)
    }

    func refreshPendingData() {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        let pendingTransactions = getPendingTransation()
        dataSource[selectedAddress] = dataSource[selectedAddress]?.filter { $0.sequence != nil && $0.sequence != 0 }
        guard dataSource[selectedAddress] != nil else {
            dataSource[selectedAddress] = pendingTransactions
            return
        }
        dataSource[selectedAddress]!.insert(contentsOf: pendingTransactions, at: 0)
        tableView.reloadData()
    }

    func getPendingTransation() -> [Transaction] {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return [] }

        var pendingTxsInDB = TransferPersistence.getTransactionsByAddress(from: selectedAddress, status: TransactionReceiptStatus.pending)
//        pendingTxsInDB.txSort()
        for tx in pendingTxsInDB {
            tx.direction = tx.getTransactionDirection(selectedAddress)
        }
        return pendingTxsInDB
    }

    func getTimeoutTransaction() -> [Transaction] {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return [] }
        var transactions = TransferPersistence.getTransactionsByAddress(from: selectedAddress, status: TransactionReceiptStatus.timeout, detached: true)
        transactions.txSort()
        for tx in transactions {
            tx.direction = tx.getTransactionDirection(selectedAddress)
        }
        return transactions
    }

    // MARK: - Notification

    @objc func willDeleteWallet(_ notification: Notification) {
        guard self.walletAddress != nil else {
            return
        }
        if let cwallet = notification.object as? Wallet {
            if (self.walletAddress?.ishexStringEqual(other: cwallet.address))! {
                self.dataSource[self.walletAddress!]?.removeAll()
                self.tableView.reloadData()
            }
        }
    }

    @objc func updateWalletList() {
        self.refreshData()
    }

    @objc func nodeDidSwitch() {
        dataSource = [String: [Transaction]]()
        self.tableView.reloadData()
    }

    func fetchTransaction(beginSequence: Int64, completion: (() -> Void)?) {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        TransactionService.service.getBatchTransaction(addresses: [selectedAddress], beginSequence: beginSequence, listSize: listSize, direction: "new") { [weak self] (result, response) in
            guard let self = self else {
                return
            }

            // 结束顶层下拉刷新的状态
            if let parentCon = self.parentController {
                parentCon.endFetchData()
            }
            switch result {
            case .success:
                // 返回的交易数据条数为0，则显示无加载更多
                guard let remoteTransactions = response, remoteTransactions.count > 0 else {
                    self.tableView.mj_footer.isHidden = (self.dataSource[selectedAddress]?.count ?? 0 < self.listSize)
                    return
                }

                for tx in remoteTransactions {
                    tx.direction = tx.getTransactionDirection(selectedAddress)
                }

                var pendingexcludedTxs: [Transaction] = []
                pendingexcludedTxs.append(contentsOf: remoteTransactions)

                let txHashes = remoteTransactions.map { $0.txhash!.add0x() }

                var timeouttxs = self.getTimeoutTransaction()
                timeouttxs = timeouttxs.filter { !txHashes.contains($0.txhash!.add0x()) }

                if timeouttxs.count > 0 {
                    let mappedTimeoutTxs = timeouttxs.map({ (t) -> Transaction in
                        //交易时间临时赋值给确认时间，仅用于交易的排序
                        if t.createTime != 0 {
                            t.confirmTimes = t.createTime
                        } else if t.confirmTimes != 0 && t.createTime == 0 {
                            t.createTime = t.confirmTimes
                        }
                        return t
                    })
                    pendingexcludedTxs.append(contentsOf: mappedTimeoutTxs)
                    pendingexcludedTxs.sortByConfirmTimes()
                }
                var pendingTransaction = self.getPendingTransation()
                pendingTransaction = pendingTransaction.filter { !txHashes.contains($0.txhash!.add0x()) }
                pendingTransaction.append(contentsOf: pendingexcludedTxs)
                self.dataSource[selectedAddress] = pendingTransaction
                AssetService.sharedInstace.fetchWalletBalanceForV7(nil)

                self.tableView.mj_footer.isHidden = (self.dataSource[selectedAddress]?.count ?? 0 < self.listSize)
                self.tableView.reloadData()
                completion?()
            case .failure(let error):
                completion?()
            }
        }
    }

    private func goTransactionList() {

        let controller = TransactionListViewController()
        controller.selectedWallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc func didReceiveTransactionUpdate(_ notification: Notification) {
        // 由于余额发生变化时会更新交易记录，因此，这里并需要再次更新

        guard let txStatus = notification.object as? TransactionsStatusByHash, let status = txStatus.txReceiptStatus else { return }
        fetchTransaction(beginSequence: -1) { [weak self] in
            guard let self = self else { return }
            for txObj in self.dataSource {
                for tx in txObj.value {
                    if tx.txhash?.lowercased() == txStatus.hash?.lowercased() {
                        tx.txReceiptStatus = status.rawValue
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

// 下拉刷新及加载更多
extension AssetTransactionViewControllerV060 {
//    func fetchDataByWalletChanged() {
//        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
//        guard let count = self.dataSource[selectedAddress]?.count, count <= 0 else {
//            pollingWalletTransactions()
//            return
//        }
//    }

    func fetchTransactionLastest() {
        fetchTransaction(beginSequence: -1, completion: nil)
    }

    @objc func pollingWalletTransactions() {
        guard AssetVCSharedData.sharedData.walletList.count > 0 else { return }
        fetchTransactionLastest()
    }
}

extension AssetTransactionViewControllerV060: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return 0 }
        return dataSource[selectedAddress]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wallet = AssetVCSharedData.sharedData.selectedWallet
        let cell: WalletDetailCell = tableView.dequeueReusableCell(withIdentifier: String(describing: WalletDetailCell.self)) as! WalletDetailCell
        if let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress, let count = dataSource[selectedAddress]?.count, count > indexPath.row {
            let tx = dataSource[selectedAddress]?[indexPath.row]
            cell.updateTransferCell(transaction: tx, wallet: wallet as? Wallet)
            cell.updateCellStyle(count: dataSource[selectedAddress]?.count ?? 0, index: indexPath.row)
        }

        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.childScrollViewDidScroll(childScrollView: scrollView)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        let tx = dataSource[selectedAddress]?[indexPath.row]
        if tx?.txReceiptStatus == TransactionReceiptStatus.pending.rawValue {
            tx?.direction = .Sent
        }
        let transferVC = TransactionDetailViewController()
        transferVC.transaction = tx
        AssetViewControllerV060.pushViewController(viewController: transferVC)
    }

}

// MARK: - Asset60

extension AssetTransactionViewControllerV060 {

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        let edgeToTop = (self.tableView.frame.size.height - self.tableNodataHolderView.frame.size.height) * 0.5
        return -edgeToTop
    }
}
