//
//  PListManager.swift
//  MyBMI
//
//  Created by Tran Quynh Tran on 20/05/18.
//  Copyright © 2018 Khiem Vo. All rights reserved.
//

import Foundation

class PListManager {
    let resourceName: String
    init (resourceName: String) {
        self.resourceName = resourceName
    }
    
    /*
        unit = plistManager.readProperties(byKey: "MetricUnit")
        let abc = unit!["Weight"] as? String
    */
    public func readProperties(byKey: String) -> AnyObject? {
        //Property List file name = regions.plist
        let pListFileURL = Bundle.main.url(forResource: resourceName, withExtension: "plist")
        if let pListPath = pListFileURL?.path,
            let pListData = FileManager.default.contents(atPath: pListPath) {
            do {
                let pListObject = try PropertyListSerialization.propertyList(from: pListData, options:PropertyListSerialization.ReadOptions(), format:nil)
                //Cast pListObject - If expected data type is Dictionary
                if let pListDict = pListObject as? Dictionary<String, AnyObject>  {
                    return pListDict[byKey]!
                }
            } catch {
                print("Error reading regions plist file: \(error)")
            }
        }
        return nil
    }
}
