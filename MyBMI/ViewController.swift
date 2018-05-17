//
//  ViewController.swift
//  MyBMI
//
//  Created by Alex Vasilyev on 17/05/18.
//  Copyright © 2018 Khiem Vo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var unitsSegmentControl: UISegmentedControl!
    @IBOutlet weak var weightUnitLabel: UILabel!
    @IBOutlet weak var heightUnitLabel: UILabel!
    @IBOutlet weak var weightText: UITextField!
    @IBOutlet weak var heightText: UITextField!
    @IBOutlet weak var bmiResultLabel: UILabel!
    
    @IBAction func unitsChange(_ sender: Any) {
        switch unitsSegmentControl.selectedSegmentIndex {
        case 0:
            weightUnitLabel.text = "kg"
            heightUnitLabel.text = "cm"
        case 1:
            weightUnitLabel.text = "lb"
            heightUnitLabel.text = "in"
        default:
            break;
        }
    }
    
    @IBAction func calculateBMITouchUp(_ sender: UIButton) {
        displayBMI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weightText.keyboardType = .decimalPad
        heightText.keyboardType = .decimalPad
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calculatBMI() -> Double {
        let weight = !(weightText.text?.isEmpty)! ? Double(weightText.text!) : 0.0
        let height = !(heightText.text?.isEmpty)! ? Double(heightText.text!) : 0.0
        
        let imperialRate = (unitsSegmentControl.selectedSegmentIndex == 1) ? 703.0 : 10000
        if (weight! <= 0 || height! <= 0) {return 0.0}
        
        return imperialRate * weight! / (height! * height!)
    }
    
    func displayBMI() {
        bmiResultLabel.text = String(format: "%.2f", calculatBMI().rounded())
    }
}

