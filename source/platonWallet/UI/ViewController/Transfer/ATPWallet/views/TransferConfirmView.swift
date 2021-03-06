//
//  TransferConfirmView.swift
//  platonWallet
//
//  Created by matrixelement on 27/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Spring

class TransferConfirmView: UIView {

    @IBOutlet weak var submitBtn: PButton!

    @IBOutlet weak var totalLabel: UILabel!

    @IBOutlet weak var transactionTypeLabel: UILabel!

    @IBOutlet weak var toAddressLabel: UILabel!

    @IBOutlet weak var feeLabel: UILabel!

    @IBOutlet weak var walletName: UILabel!

    @IBOutlet weak var closeButton: UIButton!

    @IBOutlet weak var executorLabel: UILabel!

    @IBOutlet weak var topToSenderName: NSLayoutConstraint!

    @IBOutlet weak var executorDes: UILabel!

    @IBOutlet weak var executorNameLabel: UILabel!

    var onCompletion: (() -> Void)?
    var dismissCompletion: (() -> Void)?

    override func awakeFromNib() {
        submitBtn.style = .blue
        totalLabel.adjustsFontSizeToFitWidth = true
        submitBtn.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
    }

    func hideExecutor() {
        topToSenderName.constant = 16
        self.executorDes.isHidden = true
        self.executorNameLabel.isHidden = true
    }

    @objc func submitAction() {
        onCompletion?()
    }

    @objc func closeAction() {
        dismissCompletion?()
    }
}
