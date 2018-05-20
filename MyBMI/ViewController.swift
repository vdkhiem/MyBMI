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

    // Outlets declaration
    @IBOutlet weak var unitsSegmentControl: UISegmentedControl!
    @IBOutlet weak var weightText: UITextField!
    @IBOutlet weak var heightText: UITextField!
    @IBOutlet weak var bmiResultLabel: UILabel!
    @IBOutlet weak var bmiMessageLabel: UILabel!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var tableViewHistoryData: UITableView!
    
    // Member variables
    let historyDataMaxCount = 5
    var bmiData:Set<Bmi> = []
    var coreDataManager = CoreDataManager(appDelegate: UIApplication.shared.delegate as! AppDelegate, entityName: "BmiData")
    let plistManager = PListManager(resourceName: "MyBMI")
    let colorManager = UIColorManager()
    
    // Actions or Events
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
        let historyDataList = coreDataManager.fetchRows()
        return historyDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "History Data Cell")
        
        cell.textLabel?.text = loadHistoryDataForCell(index: indexPath.row)
        cell.textLabel?.font = UIFont(name:"Avenir", size:12)
        
        return cell
    }
    
    // Helpers
    func loadAppearance() {
        weightText.keyboardType = .decimalPad
        heightText.keyboardType = .decimalPad
        bmiResultLabel.text = nil
        bmiMessageLabel.text = nil
        calculateButton.backgroundColor = colorManager.actionColor()
        calculateButton.layer.cornerRadius = 5
        calculateButton.tintColor = UIColor.white
        loadTextMeasurement()
    }
    
    func loadBMIData() {
        bmiData.insert(Bmi(beginWeight: 0, endWeight: 15, bmiCategory: "Very severely underweight", bmiMessageType: BmiMessageType.danger))
        bmiData.insert(Bmi(beginWeight: 15, endWeight: 16, bmiCategory: "Severely underweight", bmiMessageType: BmiMessageType.danger))
        bmiData.insert(Bmi(beginWeight: 16, endWeight: 18.5, bmiCategory: "Underweight", bmiMessageType: BmiMessageType.warning))
        bmiData.insert(Bmi(beginWeight: 18.5, endWeight: 25, bmiCategory: "Normal. Congratulation", bmiMessageType: BmiMessageType.normal))
        bmiData.insert(Bmi(beginWeight: 25, endWeight: 30, bmiCategory: "Overweight", bmiMessageType: BmiMessageType.warning))
        bmiData.insert(Bmi(beginWeight: 30, endWeight: 35, bmiCategory: "Moderately obese", bmiMessageType: BmiMessageType.danger))
        bmiData.insert(Bmi(beginWeight: 35, endWeight: 40, bmiCategory: "Severely obese", bmiMessageType: BmiMessageType.danger))
        bmiData.insert(Bmi(beginWeight: 40, endWeight: 1000, bmiCategory: "Very severely obese", bmiMessageType: BmiMessageType.danger))
    }
    
    func calculateBMI() -> Double {
        let weight = !(weightText.text?.isEmpty)! ? Double(weightText.text!) : 0.0
        let height = !(heightText.text?.isEmpty)! ? Double(heightText.text!) : 0.0
        
        let imperialRate = (unitsSegmentControl.selectedSegmentIndex == 1) ? 703.0 : 10000
        if (weight! <= 0 || height! <= 0) {return 0.0}
        
        return imperialRate * weight! / (height! * height!)
    }
    
    func displayBMI() {
        let bmi = calculateBMI()
        
        for item in bmiData {
            if (item.beginWeight <= bmi && bmi < item.endWeight) {
                bmiResultLabel.text = String(format: "%.2f", bmi)
                bmiMessageLabel.text = item.bmiCategory
                setBmiResultLabelColor(type: item.bmiMessageType)
            }
        }
    }
    
    func setBmiResultLabelColor(type: BmiMessageType) {
        switch type
        {
            case BmiMessageType.normal:
                bmiMessageLabel.textColor = colorManager.normalColor()
            case BmiMessageType.warning:
                bmiMessageLabel.textColor = colorManager.warningColor()
            case BmiMessageType.danger:
                bmiMessageLabel.textColor = colorManager.dangerColor()
        }
    }
    
    func loadTextMeasurement() {
        var unit: AnyObject?
        switch unitsSegmentControl.selectedSegmentIndex {
            case 0:
                unit = plistManager.readProperties(byKey: "MetricUnit")
            case 1:
                unit = plistManager.readProperties(byKey: "ImperialUnit")
            default:
                break
        }
        weightText.placeholder = unit!["Weight"] as? String
        heightText.placeholder = unit!["Height"] as? String
    }
    
    func loadHistoryDataForCell(index: Int) -> String? {
        let historyDataList = coreDataManager.fetchRows()
        let index = (historyDataList.count - 1) - index
        
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
            return value + "\n"
        }
        return nil
    }
    
    func updateHistoryData() {
        addToHistoryData()
        deleteLastHistoryData()
    }
        
    func addToHistoryData() {
        let rowEntity = coreDataManager.newRowToEntity()
        rowEntity.setValue(UtilityManager().getNow(), forKey: "createdDate")
        rowEntity.setValue(bmiResultLabel.text, forKey: "result")
        rowEntity.setValue(bmiMessageLabel.text, forKey: "message")
        coreDataManager.addRowToEntity(row: rowEntity)
        self.tableViewHistoryData.reloadData()
    }
    
    func deleteLastHistoryData() {
        var historyDataList = coreDataManager.fetchRows()
        if historyDataList.count > historyDataMaxCount {
            coreDataManager.deleteRowFromEntity(row: historyDataList[0] )
        }
        self.tableViewHistoryData.reloadData()
    }
}

