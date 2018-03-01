//
//  HardwareInfoProvider.swift
//  map-ping
//
//  Created by Nicholas Whyte on 1/3/18.
//  Copyright © 2018 Nicholas Whyte. All rights reserved.
//

import Foundation
import CoreTelephony
import UIKit

protocol InfoProvider {
    func getRadioAccessTechnology() -> String?
    func getNetworkProvider() -> String?
    func getSignalStrength() -> Int
}

class SimulatorInfoProvider: InfoProvider {
    func getRadioAccessTechnology() -> String? {
        return "SIMULATOR"
    }
    
    func getNetworkProvider() -> String? {
        return "SIMULATOR"
    }
    func getSignalStrength() -> Int {
        return 4
    }
}

class HardwareInfoProvider: InfoProvider {
    func getNetworkProvider() -> String? {
        let networkInfo = CTTelephonyNetworkInfo()
        return networkInfo.subscriberCellularProvider?.carrierName
    }
    
    func getRadioAccessTechnology() -> String? {
        let networkInfo = CTTelephonyNetworkInfo()
        return networkInfo.currentRadioAccessTechnology?.replacingOccurrences(of: "CTRadioAccessTechnology", with: "")
    }
    
    func getSignalStrength() -> Int {
        let application = UIApplication.shared
        let statusBarView = application.value(forKey: "statusBar") as! UIView
        let foregroundView = statusBarView.value(forKey: "foregroundView") as! UIView
        let foregroundViewSubviews = foregroundView.subviews
        
        var dataNetworkItemView:UIView!
        
        for subview in foregroundViewSubviews {
            if subview.isKind(of: NSClassFromString("UIStatusBarSignalStrengthItemView")!) {
                dataNetworkItemView = subview
                break
            } else {
                return 0 //NO SERVICE
            }
        }
        
        return dataNetworkItemView.value(forKey: "signalStrengthBars") as! Int
    }
}

class InfoProviderFactory {
    class func create() -> InfoProvider {
        #if IOS_SIMULATOR
        return SimulatorInfoProvider()
        #else
        return HardwareInfoProvider()
        #endif
    }
}


