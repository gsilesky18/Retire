//
//  GraphViewController.swift
//  Retire
//
//  Created by H Steve Silesky on 6/11/16.
//  Copyright © 2016 STEVE SILESKY. All rights reserved.
//

import UIKit
//for iPhones
class GraphViewController: UIViewController {
    
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var yearsLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var cashStepper: UIStepper!
    @IBOutlet weak var yearsStepper: UIStepper!
    @IBOutlet weak var expenseStepper: UIStepper!
    @IBOutlet weak var graphview: GraphView!
    
    var probability:String = ""
    let calc = EstateCalc()
    var profileDictionary = [String:String]()
    var distributionArray = [Double]()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let rootVC = self.navigationController!.topViewController
        if rootVC!.isKind(of: ResultsViewController.self) {
            performSegue(withIdentifier: "unwindGraph", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let (lowArray, highArray) = calculateLowAndHighArrays()
        //set minimum and maximum for steppers
        cashStepper.minimumValue = 0.0
        cashStepper.maximumValue = 100.0
        expenseStepper.minimumValue = 0.0
        expenseStepper.maximumValue = (profileDictionary["assets"]! as NSString).doubleValue
        yearsStepper.minimumValue = 1.0
        yearsStepper.maximumValue = 60.0
        //set stepper values
        cashStepper.value = (profileDictionary["%Cash"]! as NSString).doubleValue
        expenseStepper.value = (profileDictionary["expenses"]! as NSString).doubleValue
        yearsStepper.value = (profileDictionary["years"]! as NSString).doubleValue
        cashLabel.text = profileDictionary["%Cash"]
        expenseLabel.text = profileDictionary["expenses"]
        yearsLabel.text = profileDictionary["years"]
        graphview.labelArray = lowArray + highArray
        graphview.percentArray = calculateHistogramData()
    }
    
    
    func formatDoubles(_ numberDouble:Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        let newString = numberFormatter.string(from: NSNumber(value:numberDouble))
        return newString!
    }
    func formatCurrency(_ numberDouble:Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 0
        let newString = numberFormatter.string(from: NSNumber(value:numberDouble))
        return newString!
    }

    func calculateLowAndHighArrays() -> (Array<Double> , Array<Double>) {
        let interval:Double = (distributionArray.max()! - distributionArray.min()!) * 1.0/6.0
        let minimum:Double = distributionArray.min()!
        var lowArray = [Double]()
        var highArray = [Double]()
        for i in 1...6 {
            let low = Double(i - 1) * interval + minimum
            let high = Double(i) * interval + minimum - 1
            lowArray.append(low)
            highArray.append(high)
        }
        return (lowArray, highArray)
    }
    
    func calculateHistogramData() -> Array<Double> {
        let totCount:Double = Double(distributionArray.count)
        let minimum:Double = distributionArray.min()!
        let interval:Double = (distributionArray.max()! - minimum) / 6.0
        var percentArray = [Double]()
        for i in 1...6 {
            var intCount:UInt = 0
            let low:Double = Double(i-1) * interval + minimum
            let high:Double = Double(i) * interval + minimum
            for value in distributionArray {
                if value >= low && value <= high {
                    intCount += 1
                }
            }
            let percent = Double(intCount)/totCount * 100
            percentArray.append(percent)
        }
        return percentArray
    }

    @IBAction func cashChanged(_ sender: UIStepper) {
        cashLabel.text = NSString.localizedStringWithFormat("%.f", cashStepper.value) as String
        profileDictionary["%Cash"] = cashLabel.text
        distributionArray = calc.calculateEstateNetworthUsingDictionary(inputDict: profileDictionary)
        let (lowArray, highArray) = calculateLowAndHighArrays()
        graphview.labelArray = lowArray + highArray
        graphview.percentArray = calculateHistogramData()
        
    }
    @IBAction func yearsChanged(_ sender: UIStepper) {
        yearsLabel.text = NSString.localizedStringWithFormat("%.f", yearsStepper.value) as String
        profileDictionary["years"] = yearsLabel.text
        distributionArray = calc.calculateEstateNetworthUsingDictionary(inputDict: profileDictionary)
        let (lowArray, highArray) = calculateLowAndHighArrays()
        graphview.labelArray = lowArray + highArray
        graphview.percentArray = calculateHistogramData()
    }
    
    @IBAction func expensesChanged(_ sender: UIStepper) {
        expenseLabel.text = NSString.localizedStringWithFormat("%.f", expenseStepper.value) as String
        profileDictionary["expenses"] = expenseLabel.text
        distributionArray = calc.calculateEstateNetworthUsingDictionary(inputDict: profileDictionary)
        let (lowArray, highArray) = calculateLowAndHighArrays()
        graphview.labelArray = lowArray + highArray
        graphview.percentArray = calculateHistogramData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory overload")
    }
    

    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMeaning" {
            let destination = segue.destination
            if let mvc = destination as? MeaningViewViewController {
                let (lowArray, highArray) = calculateLowAndHighArrays()
                mvc.lowValue1 = formatCurrency(lowArray[0])
                mvc.highValue1 = formatCurrency(highArray[0])
                mvc.lowValue2 = formatCurrency(lowArray[1])
                mvc.highValue2 = formatCurrency(highArray[1])
                let percentArray:Array = calculateHistogramData()
                mvc.percent1 = NSString(format: "%.1f", percentArray[0]) as String
                mvc.percent2 = NSString(format: "%.1f", percentArray[1]) as String
                mvc.probability = probability
            }
        }
    }

}
