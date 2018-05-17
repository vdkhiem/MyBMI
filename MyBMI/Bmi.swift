//
//  Bmi.swift
//  MyBMI
//
//  Created by Alex Vasilyev on 17/05/18.
//  Copyright © 2018 Khiem Vo. All rights reserved.
//

import Foundation

class Bmi: Equatable, Hashable {

    var hashValue: Int
    
    var beginWeight: Double
    var endWeight: Double
    var bmiCategory: String
    var bmiMessageType: BmiMessageType
    init (beginWeight: Double, endWeight: Double, bmiCategory: String, bmiMessageType: BmiMessageType) {
        self.beginWeight = beginWeight
        self.endWeight = endWeight
        self.bmiCategory = bmiCategory
        self.bmiMessageType = bmiMessageType
        self.hashValue = beginWeight.hashValue
    }
}

func ==(lhs: Bmi, rhs: Bmi) -> Bool {
    return lhs.beginWeight == rhs.beginWeight &&
        lhs.endWeight == rhs.endWeight &&
        lhs.bmiCategory == rhs.bmiCategory &&
        lhs.bmiMessageType == rhs.bmiMessageType
}

enum BmiMessageType  {
    case normal, warning, danger
}
