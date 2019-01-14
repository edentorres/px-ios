//
//  PXOneTapSplitPaymentView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 09/01/2019.
//

import UIKit

class PXOneTapSplitPaymentView: PXComponentView {
    let callback : ((_ isOn: Bool, _ isUserSelection: Bool) -> Void)
    var splitConfiguration: PXSplitConfiguration
    var splitPaymentSwitch: UISwitch?
    var splitMessageLabel: UILabel?

    init(splitConfiguration: PXSplitConfiguration, callback : @escaping ((_ isOn: Bool, _ isUserSelection: Bool) -> Void)) {
        self.splitConfiguration = splitConfiguration
        self.callback = callback
        super.init()
        render()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(splitConfiguration: PXSplitConfiguration) {
        self.splitConfiguration = splitConfiguration
        splitMessageLabel?.attributedText = splitConfiguration.message?.toAttributedString()

        if splitPaymentSwitch?.isOn != splitConfiguration.splitEnabled {
            callback(splitConfiguration.splitEnabled, false)
        }

        splitPaymentSwitch?.setOn(splitConfiguration.splitEnabled, animated: true)
    }

    private func render() {
        removeAllSubviews()
        self.backgroundColor = .white
        let splitSwitch = UISwitch()
        self.splitPaymentSwitch = splitSwitch
        splitSwitch.addTarget(self, action: #selector(PXOneTapSplitPaymentView.switchStateChanged(_:)), for: UIControl.Event.valueChanged)

        splitSwitch.setOn(splitConfiguration.splitEnabled, animated: false)
        splitSwitch.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(splitSwitch)
        PXLayout.pinRight(view: splitSwitch, withMargin: PXLayout.L_MARGIN).isActive = true
        PXLayout.centerVertically(view: splitSwitch).isActive = true
        splitSwitch.onTintColor = ThemeManager.shared.getAccentColor()

        let label = UILabel()
        self.splitMessageLabel = label
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        PXLayout.centerVertically(view: label).isActive = true
        PXLayout.pinLeft(view: label, withMargin: PXLayout.L_MARGIN).isActive = true
        PXLayout.put(view: label, leftOf: splitSwitch, withMargin: PXLayout.XXXS_MARGIN).isActive = true
        PXLayout.pinTop(view: label, withMargin: PXLayout.S_MARGIN).isActive = true
        PXLayout.pinBottom(view: label, withMargin: PXLayout.S_MARGIN).isActive = true
        label.attributedText = splitConfiguration.message?.toAttributedString()

        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.addSubview(separatorView)
        PXLayout.setHeight(owner: separatorView, height: 1).isActive = true
        PXLayout.pinBottom(view: separatorView).isActive = true
        PXLayout.pinLeft(view: separatorView, withMargin: PXLayout.L_MARGIN).isActive = true
        PXLayout.pinRight(view: separatorView, withMargin: PXLayout.L_MARGIN).isActive = true
    }

    @objc private func switchStateChanged(_ sender: UISwitch) {
        callback(sender.isOn, true)
    }
}
