//
//  ResultsViewController.swift
//  Retire
//
//  Created by H Steve Silesky on 6/9/16.
//  Copyright © 2016 STEVE SILESKY. All rights reserved.
//

import UIKit

//to calculate median of an array
extension Array where Element: Comparable {
    
    var median: Element {
        return self.sorted(by: <)[self.count / 2]
    }
}

class ResultsViewController: UIViewController {
    
    @IBOutlet weak var expenseStepperLabel: UILabel!
    @IBOutlet weak var assetsLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var yearsLabel: UILabel!
    @IBOutlet weak var taxRateLabel: UILabel!
    @IBOutlet weak var medianLabel: UILabel!
    @IBOutlet weak var aveageLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var probabilityLabel: UILabel!
    @IBOutlet weak var graphview: GraphView!
    
    var profileDictionary = [String:String]()
    var distributionArray = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        let myCount = profileDictionary.count
        if myCount > 0 {
            assetsLabel.text = formatWithComma(profileDictionary["assets"]! as NSString)
            expensesLabel.text = formatWithComma(profileDictionary["expenses"]! as NSString)
            cashLabel.text = profileDictionary["%Cash"]! + "%"
            yearsLabel.text = profileDictionary["years"]
            taxRateLabel.text = profileDictionary["taxRate"]! + "%"
            let minLegacy:Double = distributionArray.min()!
            lowLabel.text = formatDoubles(minLegacy)
            lowLabel.textColor = AdjustTextColor(minLegacy)
            let maxLegacy:Double = distributionArray.max()!
            highLabel.text = formatDoubles(maxLegacy)
            highLabel.textColor = AdjustTextColor(maxLegacy)
            let average:Double =  distributionArray.reduce(0, +) / Double(distributionArray.count)
            aveageLabel.text = formatDoubles(average)
            aveageLabel.textColor = AdjustTextColor(average)
            let median:Double = distributionArray.median
            medianLabel.text = formatDoubles(median)
            medianLabel.textColor = AdjustTextColor(median)
            probabilityLabel.text = NSString.localizedStringWithFormat("%.1f", calculateAssetsZero() * 100) as String + "%"
        }
    }
    @IBAction func unwindToResultsScene(_ sender: UIStoryboardSegue) {
        
        if let controller = sender.source as? GraphViewController {
            profileDictionary = controller.profileDictionary
            distributionArray = controller.distributionArray
            configureView()
        }
    }
    
    //nnumber of values > 0
    func calculateAssetsZero() -> Double{
        var zero = 0
        var total = 0
        
        for value in distributionArray {
            if value > 0 {
                zero += 1
            }
            total += 1
        }
        let zeroF:Double = Double(zero)
        let totalF:Double = Double(total)
        return zeroF/totalF
    }
    
    func formatDoubles(_ numberDouble:Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 0
        let newString = numberFormatter.string(from: NSNumber(value:numberDouble))
        return newString!
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
    
    func AdjustTextColor(_ testNumber:Double) -> UIColor {
        var resultColor:UIColor = UIColor.black
        if testNumber < 0 {
            resultColor = UIColor.red
        }
        return resultColor
    }
    
   
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGraph" {
            let destination = segue.destination
            if let gc = destination as? GraphViewController {
                gc.profileDictionary = profileDictionary
                gc.distributionArray = distributionArray
                gc.probability = probabilityLabel.text!
            }
        }
    }
}
