//
//  UIColorManager.swift
//  MyBMI
//
//  Created by Khiem Vo on 20/05/18.
//  Copyright © 2018 Khiem Vo. All rights reserved.
//

import Foundation
import UIKit

class UIColorManager {
    
    let plistManager = PListManager(resourceName: "MyBMI")
    
    public func normalColor() -> UIColor {
        return getColorSetting(withName: "NormalColor")
    }
    
    public func warningColor() -> UIColor {
        return getColorSetting(withName: "WarningColor")
    }
    
    public func dangerColor() -> UIColor {
        return getColorSetting(withName: "DangerColor")
    }
    
    public func actionColor() -> UIColor {
        return getColorSetting(withName: "ActionColor")
    }
    
    func UIColorFromRGB(red: UInt, green: UInt, blue: UInt, alpha: Double) -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/255.0)
    }
    
    func getColorSetting(withName: String) -> UIColor {
        let unit = plistManager.readProperties(byKey: withName)
        let red = unit!["Red"] as? UInt
        let green = unit!["Green"] as? UInt
        let blue = unit!["Blue"] as? UInt
        let alpha = unit!["Alpha"] as? Double
        
        return UIColorFromRGB(red:red!, green:green!, blue:blue!, alpha: alpha!)
    }
}
