//
//  YearSimViewController.swift
//  Retire
//
//  Created by H Steve Silesky on 5/14/17.
//  Copyright © 2017 STEVE SILESKY. All rights reserved.
//

import UIKit

class YearSimViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet weak var assetLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var yearsRemainingLabel: UILabel!
    @IBOutlet weak var finalYearLabel: UILabel!
    @IBOutlet weak var finalAmountLabel: UILabel!
    @IBOutlet weak var taxRateLabel: UILabel!
    
    var growthArray = [String]()
    var profileDictionary = [String:String]()
    var firstYear:Int?
    let dataStart = 1910
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yearPicker.selectRow(growthArray.count / 2, inComponent: 0, animated: true)
        configureView()
    }
    func configureView() {
        let myCount = profileDictionary.count
        if myCount > 0 {
            assetLabel.text = formatWithComma(profileDictionary["assets"]! as NSString)
            expenseLabel.text = formatWithComma(profileDictionary["expenses"]! as NSString)
            cashLabel.text = profileDictionary["%Cash"]! + "%"
            yearsRemainingLabel.text = profileDictionary["years"]
            taxRateLabel?.text = profileDictionary["taxRate"]! + "%"
        }
    }

    func formatWithComma(_ numberString:NSString) -> String {
        let noComma = numberString.replacingOccurrences(of: ",", with: "")
        let number = NSNumber(value: Int(noComma)! as Int)
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        let numberAsString = numberFormatter.string(from: number)
        return numberAsString!
    }
    
    func formatDoubles(_ numberDouble:Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 0
        let newString = numberFormatter.string(from: NSNumber(value:numberDouble))
        return newString!
    }

    @IBAction func calculateButton(_ sender: UIButton) {
        let selectedInteger = yearPicker.selectedRow(inComponent: 0)
        let selectedYear = yearsArray()[selectedInteger]
        if (Int(selectedYear)! + Int(profileDictionary["years"]!)!) > Int(yearsArray().last!)! {
            let message = "Selected Year + Remaining Years must not exceed " + yearsArray().last!
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }else{
            let simCalc = SimCalculator()
            let amount = simCalc.calculateSimNetworth(inputDict: profileDictionary, startYr: selectedInteger)
            finalAmountLabel.text = formatDoubles(amount)
            finalYearLabel.text = String((Int(selectedYear)! + Int(profileDictionary["years"]!)!))
            finalAmountLabel.textColor = AdjustTextColor(amount)
        }
    }
    func AdjustTextColor(_ testNumber:Double) -> UIColor {
        var resultColor:UIColor = UIColor.black
        if testNumber < 0 {
            resultColor = UIColor.red
        }
        return resultColor
    }

    func yearsArray() -> [String] {
        let count = growthArray.count + 1909
        let years = Array(1910...count)
        let stringArray = years.map
        {
            String($0)
        }
        return stringArray
    }
    
    // MARK: - Picker Delegates and DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return growthArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let stringArray = yearsArray()
        return stringArray[row]
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
