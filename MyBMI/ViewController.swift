//
//  ViewController.swift
//  MyBMI
//
//  Created by Alex Vasilyev on 17/05/18.
//  Copyright © 2018 Khiem Vo. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var unitsSegmentControl: UISegmentedControl!
    @IBOutlet weak var weightText: UITextField!
    @IBOutlet weak var heightText: UITextField!
    @IBOutlet weak var bmiResultLabel: UILabel!
    @IBOutlet weak var bmiMessageLabel: UILabel!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var historyDataLabel: UILabel!
    
    var bmiData:Set<Bmi> = []
    
    @IBAction func unitsChange(_ sender: Any) {
        loadTextMeasurement()
    }
    
    @IBAction func calculateBMITouchUp(_ sender: UIButton) {
        displayBMI()
        saveToHistoryData()
        loadHistoryData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAppearance()
        loadBMIData()
        loadHistoryData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadAppearance() {
        weightText.keyboardType = .decimalPad
        heightText.keyboardType = .decimalPad
        bmiResultLabel.text = nil
        bmiMessageLabel.text = nil
        calculateButton.backgroundColor = UIColor.blue
        calculateButton.layer.cornerRadius = 5
        calculateButton.tintColor = UIColor.white
        loadTextMeasurement()
    }
    
    func loadBMIData() {
        bmiData.insert(Bmi(beginWeight: 0, endWeight: 15, bmiCategory: "Very severely underweight", bmiMessageType: BmiMessageType.warning))
        bmiData.insert(Bmi(beginWeight: 15, endWeight: 16, bmiCategory: "Severely underweight", bmiMessageType: BmiMessageType.warning))
        bmiData.insert(Bmi(beginWeight: 16, endWeight: 18.5, bmiCategory: "Underweight", bmiMessageType: BmiMessageType.warning))
        bmiData.insert(Bmi(beginWeight: 18.5, endWeight: 25, bmiCategory: "Normal. Congratulation", bmiMessageType: BmiMessageType.normal))
        bmiData.insert(Bmi(beginWeight: 25, endWeight: 30, bmiCategory: "Overweight", bmiMessageType: BmiMessageType.warning))
        bmiData.insert(Bmi(beginWeight: 30, endWeight: 35, bmiCategory: "Moderately obese", bmiMessageType: BmiMessageType.danger))
        bmiData.insert(Bmi(beginWeight: 35, endWeight: 40, bmiCategory: "Severely obese", bmiMessageType: BmiMessageType.danger))
        bmiData.insert(Bmi(beginWeight: 40, endWeight: 1000, bmiCategory: "Very severely obese", bmiMessageType: BmiMessageType.danger))
        
    }
    
    func calculatBMI() -> Double {
        let weight = !(weightText.text?.isEmpty)! ? Double(weightText.text!) : 0.0
        let height = !(heightText.text?.isEmpty)! ? Double(heightText.text!) : 0.0
        
        let imperialRate = (unitsSegmentControl.selectedSegmentIndex == 1) ? 703.0 : 10000
        if (weight! <= 0 || height! <= 0) {return 0.0}
        
        return imperialRate * weight! / (height! * height!)
    }
    
    func displayBMI() {
        let bmi = calculatBMI()
        
        for item in bmiData {
            if (item.beginWeight <= bmi && bmi < item.endWeight) {
                bmiResultLabel.text = String(format: "%.2f", calculatBMI())
                bmiMessageLabel.text = item.bmiCategory
                setBmiResultLabelColor(type: item.bmiMessageType)
            }
        }
    }
    
    func setBmiResultLabelColor(type: BmiMessageType) {
        switch type
        {
            case BmiMessageType.normal:
                bmiMessageLabel.textColor = UIColor.blue
            case BmiMessageType.warning:
                bmiMessageLabel.textColor = UIColor.orange
            case BmiMessageType.danger:
                bmiMessageLabel.textColor = UIColor.red
        }
    }
    
    func loadTextMeasurement() {
        switch unitsSegmentControl.selectedSegmentIndex {
        case 0:
            weightText.placeholder = "kg"
            heightText.placeholder = "cm"
        case 1:
            weightText.placeholder = "lb"
            heightText.placeholder = "in"
        default:
            break;
        }
    }
    
    func getContextFromCoreData () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        return context
    }
    
    func loadHistoryData() {
        let context = getContextFromCoreData()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BmiData")
        request.returnsObjectsAsFaults = false
        historyDataLabel.text! = ""
        do {
            let results = try context.fetch(request)
            for index in stride(from: results.count-1, to: 0, by: -1) {
                let item = results[index] as! NSManagedObject
                if let createdDate = item.value(forKey: "createdDate") as? String {
                    historyDataLabel.text! += createdDate + ": "
                }
                if let result = item.value(forKey: "result") as? String {
                    historyDataLabel.text! += result + ". "
                }
                if let message = item.value(forKey: "message") as? String {
                    historyDataLabel.text! += message + "."
                }
                historyDataLabel.text! += "\n"
            }
        } catch {
            print("Request failed")
            print("Unexpected error: \(error).")
        }
    }
    
    func saveToHistoryData() {
        do {
            let context = getContextFromCoreData()
            let newValue = NSEntityDescription.insertNewObject(forEntityName: "BmiData", into: context)
            
            newValue.setValue(getNow(), forKey: "createdDate")
            newValue.setValue(bmiResultLabel.text, forKey: "result")
            newValue.setValue(bmiMessageLabel.text, forKey: "message")
        
            try context.save()
        } catch {
            print("Failed to save")
            print("Unexpected error: \(error).")
        }
    }
    
    func getNow() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let now = dateformatter.string(from: Date())
        return now
    }
}

