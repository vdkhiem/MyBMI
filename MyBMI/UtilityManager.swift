//
//  UtilityManager.swift
//  MyBMI
//
//  Created by Tran Quynh Tran on 19/05/18.
//  Copyright © 2018 Khiem Vo. All rights reserved.
//

import Foundation

class UtilityManager {
    public func getNow() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let now = dateformatter.string(from: Date())
        return now
    }
}
