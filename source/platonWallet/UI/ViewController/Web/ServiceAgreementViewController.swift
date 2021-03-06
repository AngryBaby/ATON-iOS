//
//  ServiceAgreementViewController.swift
//  platonWallet
//
//  Created by Admin on 24/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import WebKit
import Localize_Swift

class ServiceAgreementViewController: BaseViewController {

    var nextActionHandler: (() -> Void)?

    lazy var webView = { () -> WKWebView in
        let wk = WKWebView()
        wk.navigationDelegate = self
        wk.allowsBackForwardNavigationGestures = true
        return wk
    }()

    public let nextButton = PButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        title = Localized("service_agreement_title")

        view.backgroundColor = normal_background_color

        let footerView = UIView()
        footerView.backgroundColor = .white
        view.addSubview(footerView)
        footerView.snp.makeConstraints { make in
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(93)
        }

        let selectedButton = UIButton()
        selectedButton.setImage(UIImage(named: "icon_box"), for: .normal)
        selectedButton.setImage(UIImage(named: "icon_box2"), for: .selected)
        selectedButton.addTarget(self, action: #selector(agreementSelected(_:)), for: .touchUpInside)
        footerView.addSubview(selectedButton)
        selectedButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
            make.height.width.equalTo(20)
        }

        let selectedLabel = UILabel()
        selectedLabel.textAlignment = .left
        selectedLabel.font = UIFont.systemFont(ofSize: 12)
        selectedLabel.textColor = .black
        selectedLabel.text = Localized("service_agreement_selected_text")
        footerView.addSubview(selectedLabel)
        selectedLabel.snp.makeConstraints { make in
            make.leading.equalTo(selectedButton.snp.trailing).offset(5)
            make.centerY.equalTo(selectedButton.snp.centerY)
            make.trailing.equalToSuperview().offset(-16)
        }

        nextButton.setTitle(Localized("service_agreement_button_next"), for: .normal)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        footerView.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(selectedButton.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(44)
        }
        footerView.layoutIfNeeded()
        nextButton.style = .disable

        webView.backgroundColor = normal_background_color
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top)
        }

        loadRequest()
    }

    private func loadRequest() {
        showLoadingHUD()
        let request = URLRequest(url: URL(string: AppConfig.H5URL.LisenceURL.serviceurl)!)
        webView.load(request)
    }

    @objc func agreementSelected(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        nextButton.style = sender.isSelected ? .blue : .disable
    }

    @objc func nextAction() {
        nextActionHandler?()
    }
}

extension ServiceAgreementViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoadingHUD()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideLoadingHUD()
    }
}
