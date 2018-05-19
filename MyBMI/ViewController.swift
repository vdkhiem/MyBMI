//
//  ViewController.swift
//  MyBMI
//
//  Created by Khiem on 17/05/18.
//  Copyright © 2018 Khiem Vo. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var unitsSegmentControl: UISegmentedControl!
    @IBOutlet weak var weightText: UITextField!
    @IBOutlet weak var heightText: UITextField!
    @IBOutlet weak var bmiResultLabel: UILabel!
    @IBOutlet weak var bmiMessageLabel: UILabel!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var tableViewHistoryData: UITableView!
    
    let historyDataMaxCount = 5
    var bmiData:Set<Bmi> = []
    
    @IBAction func unitsChange(_ sender: Any) {
        loadTextMeasurement()
    }
    
    @IBAction func calculateBMITouchUp(_ sender: UIButton) {
        displayBMI()
        updateHistoryData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAppearance()
        loadBMIData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let historyDataList = fetchHistoryDataList()
        return historyDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "History Data Cell")
        let historyDataList = fetchHistoryDataList()
        let index = (historyDataList.count - 1) - indexPath.row
        
        if (historyDataList.count > 0) {
            let item = historyDataList[index]
            var value: String = ""
            
            if let createdDate = item.value(forKey: "createdDate") as? String {
                value += createdDate + ": "
            }
            if let result = item.value(forKey: "result") as? String {
                value += result + ". "
            }
            if let message = item.value(forKey: "message") as? String {
                value += message + "."
            }
            cell.textLabel?.text = value + "\n"
            cell.textLabel?.font = UIFont(name:"Avenir", size:12)
        }
        
        return cell
    }
    
    func loadAppearance() {
        weightText.keyboardType = .decimalPad
        heightText.keyboardType = .decimalPad
        bmiResultLabel.text = nil
        bmiMessageLabel.text = nil
        calculateButton.backgroundColor = UIColor(red:0.96, green:0.54, blue:0.10, alpha:1.0)
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
    
    func updateHistoryData() {
        addToHistoryData()
        deleteLastHistoryData()
    }
        
    func addToHistoryData() {
        do {
            let context = getContextFromCoreData()
            let newValue = NSEntityDescription.insertNewObject(forEntityName: "BmiData", into: context)
    
            newValue.setValue(getNow(), forKey: "createdDate")
            newValue.setValue(bmiResultLabel.text, forKey: "result")
            newValue.setValue(bmiMessageLabel.text, forKey: "message")

            try context.save()
            self.tableViewHistoryData.reloadData()
        } catch {
            print("Failed to save")
            print("Unexpected error: \(error).")
        }
    }
    
    func deleteLastHistoryData() {
        do {
            let context = getContextFromCoreData()
            
            var historyDataList = fetchHistoryDataList()
            if historyDataList.count > historyDataMaxCount {
                context.delete(historyDataList[0] )
            }
            
            try context.save()
            self.tableViewHistoryData.reloadData()
        } catch {
            print("Failed to save")
            print("Unexpected error: \(error).")
        }
    }
    
    func getContextFromCoreData () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        return context
    }
    
    func fetchHistoryDataList() -> [NSManagedObject] {
        let context = getContextFromCoreData()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BmiData")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            return results as! [NSManagedObject]
        } catch {
            print("Request failed")
            print("Unexpected error: \(error).")
        }
        
        return [NSManagedObject]()
    }
    
    func getNow() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let now = dateformatter.string(from: Date())
        return now
    }
}

