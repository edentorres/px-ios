//
//  MPXTracker.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 6/1/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

internal struct PXTrackingEnvironment {
    public static let production = "production"
    public static let staging = "staging"
}

@objc internal class MPXTracker: NSObject {
    @objc internal static let sharedInstance = MPXTracker()

    internal static let kTrackingSettings = "tracking_settings"
    internal var public_key: String = ""
    internal var sdkVersion = Utils.getSetting(identifier: "sdk_version") ?? ""

    private static let kTrackingEnabled = "tracking_enabled"
    private var trackListener: PXTrackerListener?
    private var flowDetails: [String: Any] = [:]
    private var flowService: FlowService = FlowService()
    private lazy var currentEnvironment: String = PXTrackingEnvironment.production
}

// MARK: Getters/setters.
internal extension MPXTracker {
    internal func setPublicKey(_ public_key: String) {
        self.public_key = public_key.trimSpaces()
    }

    internal func getPublicKey() -> String {
        return self.public_key
    }

    internal func setEnvironment(environment: String) {
        self.currentEnvironment = environment
    }

    internal func getSdkVersion() -> String {
        return sdkVersion
    }

    internal func getPlatformType() -> String {
        return "/mobile/ios"
    }

    internal func setTrack(listener: PXTrackerListener) {
        trackListener = listener
    }

    internal func setFlowDetails(flowDetails: [String: Any]) {
        self.flowDetails = flowDetails
    }

    internal func startNewFlow() {
        flowService.startNewFlow()
    }

    internal func startNewFlow(externalFlowId: String) {
        flowService.startNewFlow(externalFlowId: externalFlowId)
    }

    internal func getFlowID() -> String {
        return flowService.getFlowId()
    }

    internal func clean() {
        MPXTracker.sharedInstance.flowDetails = [:]
        MPXTracker.sharedInstance.trackListener = nil
    }
}

// MARK: Public interfase.
internal extension MPXTracker {
    internal func trackScreen(screenName: String, properties: [String: Any] = [:]) {
        if let trackListenerInterfase = trackListener {
            var metadata = properties
            metadata["flow_detail"] = flowDetails
            trackListenerInterfase.trackScreen(screenName: screenName, extraParams: metadata)
        }
    }

    internal func trackEvent(path: String, properties: [String: Any] = [:]) {
        if let trackListenerInterfase = trackListener {
            var metadata = properties
            if path != TrackingPaths.Events.getErrorPath() {
                metadata["flow_detail"] = flowDetails
            }
            trackListenerInterfase.trackEvent(screenName: path, action: "", result: "", extraParams: metadata)
        }
    }
}
