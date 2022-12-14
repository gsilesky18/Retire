//
//  DetailViewController.swift
//  Retire
//
//  Created by H Steve Silesky on 8/9/16.
//  Copyright © 2016 STEVE SILESKY. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, CloudKitDelegate {

    //to calculate median of an array
    
    @IBOutlet weak var cashStepper: UIStepper!
    @IBOutlet weak var yearStepper: UIStepper!
    @IBOutlet weak var expenseStepper: UIStepper!
    @IBOutlet weak var cashStepperLabel: UILabel!
    @IBOutlet weak var yearsStepperLabel: UILabel!
    @IBOutlet weak var expenseStepperLabel: UILabel!
    @IBOutlet weak var taxRateLabel: UILabel?
    @IBOutlet weak var assetsLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var yearsLabel: UILabel!
    @IBOutlet weak var medianLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var probabilityLabel: UILabel!
    @IBOutlet weak var graphview: GraphView!
    
    var growthSAndP = [String]()
    var splash = UIImageView()
    var distributionArray = [Double]()
    let calc = EstateCalc()
    var profileDictionary = ["title":"Sample Profile","assets":"2000","expenses":"150","%Cash":"10","years":"20","taxRate":"0"] {
        didSet{
            //must occur before viewdidload and each time stepper is used
            configureView()
            distributionArray = calc.calculateEstateNetworthUsingDictionary(inputDict: profileDictionary)
            let (lowArray, highArray) = calculateLowAndHighArrays()
            graphview.labelArray = lowArray + highArray
            graphview.percentArray = calculateHistogramData()
        }
    }
    
    enum AppendString :String {
        case growth = "growth.plist"
        case inflation = "inflation.plist"
        case priceEarnings = "pe.plist"
    }

    func pathURL(append:AppendString) -> URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(append.rawValue)
    }
    
    // checks for recent data
    func dataIsComplete(yearsOfData: Int) -> Bool {
        let firstDataYear = 1910
        let year = Updater.findYear()
        let requiredDataPts = year - firstDataYear
        if yearsOfData < requiredDataPts {
            return false
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let update = Updater()
        update.delegate = self
        
        if pathURL(append: AppendString.growth).isFileURL &&
            NSArray(contentsOf: pathURL(append: AppendString.growth)) as? [String] != nil {
            growthSAndP = NSArray(contentsOf: pathURL(append: AppendString.growth)) as! [String]
            if !dataIsComplete(yearsOfData: growthSAndP.count) {
                let startYear = 1910 + growthSAndP.count - 1
                update.getCloudData(startingYear: startYear)
            }
        }else {
            update.loadSavedArrays()
            update.getCloudData(startingYear: 2015)
            print("got here")
        }

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.deviceDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem?.title = "Profiles"
        configureView()
        distributionArray = calc.calculateEstateNetworthUsingDictionary(inputDict: profileDictionary)
        let (lowArray, highArray) = calculateLowAndHighArrays()
        graphview.labelArray = lowArray + highArray
        graphview.percentArray = calculateHistogramData()
    }
    
    @objc func deviceDidRotate() {
        graphview.setNeedsDisplay()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        distributionArray = calc.calculateEstateNetworthUsingDictionary(inputDict: profileDictionary)
       
        view.bringSubview(toFront: splash)
    }

    func configureView() {
        let myCount = distributionArray.count
        if myCount > 0 {
            splash.isHidden = true
            assetsLabel.text = formatWithComma(profileDictionary["assets"]! as NSString)
            expensesLabel.text = formatWithComma(profileDictionary["expenses"]! as NSString)
            cashLabel.text = profileDictionary["%Cash"]! + "%"
            yearsLabel.text = profileDictionary["years"]
            taxRateLabel?.text = profileDictionary["taxRate"]
            let minLegacy:Double = distributionArray.min()!
            lowLabel.text = formatDoubles(minLegacy)
            lowLabel.textColor = AdjustTextColor(minLegacy)
            let maxLegacy:Double = distributionArray.max()!
            highLabel.text = formatDoubles(maxLegacy)
            highLabel.textColor = AdjustTextColor(maxLegacy)
            let average:Double =  distributionArray.reduce(0, +) / Double(distributionArray.count)
            averageLabel.text = formatDoubles(average)
            averageLabel.textColor = AdjustTextColor(average)
            let median:Double = distributionArray.median
            medianLabel.text = formatDoubles(median)
            medianLabel.textColor = AdjustTextColor(median)
            probabilityLabel.text = NSString.localizedStringWithFormat("%.1f", calculateAssetsZero() * 100) as String + "%"
            stepperInit()
        }else {
            
            if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait ||
                UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portraitUpsideDown {
                splash = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: view.bounds.height))
                splash.image = UIImage(imageLiteralResourceName:"splash.png")
                
                
            }else{
                splash = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.height, height: view.bounds.height))
                splash.image = UIImage(imageLiteralResourceName: "splash.png")
            }
            
            splash.contentMode = .scaleAspectFill
            
            view.addSubview(splash)
        }
    }
    //calculates probability of estate
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
    
    //Setup Stepper Target Action functions
    func stepperInit() {
        cashStepper.minimumValue = 0.0
        cashStepper.maximumValue = 100.0
        expenseStepper.minimumValue = 0.0
        expenseStepper.maximumValue = Double(profileDictionary["assets"]!)!
        yearStepper.minimumValue = 1.0
        yearStepper.maximumValue = 60.0
        //set stepper initial values
        cashStepper.value = Double(profileDictionary["%Cash"]!)!
        expenseStepper.value = Double(profileDictionary["expenses"]!)!
        yearStepper.value = Double(profileDictionary["years"]!)!
        cashStepperLabel.text = profileDictionary["%Cash"]
        expenseStepperLabel.text = profileDictionary["expenses"]
        yearsStepperLabel.text = profileDictionary["years"]
    }
    
    
    @IBAction func cash(_ sender: UIStepper) {
        cashStepperLabel.text = NSString(format: "%.f", cashStepper.value) as String
        profileDictionary["%Cash"] = cashStepperLabel.text
        distributionArray = calc.calculateEstateNetworthUsingDictionary(inputDict: profileDictionary)
        let (lowArray, highArray) = calculateLowAndHighArrays()
        graphview.labelArray = lowArray + highArray
        graphview.percentArray = calculateHistogramData()
        configureView()
    }
    
    @IBAction func years(_ sender: UIStepper) {
        yearsStepperLabel.text = NSString(format: "%.f", yearStepper.value) as String
        distributionArray = calc.calculateEstateNetworthUsingDictionary(inputDict: profileDictionary)
        profileDictionary["years"] = yearsStepperLabel.text
        let (lowArray, highArray) = calculateLowAndHighArrays()
        graphview.labelArray = lowArray + highArray
        graphview.percentArray = calculateHistogramData()
        configureView()
    }
    
    @IBAction func expense(_ sender: UIStepper) {
        expenseStepperLabel.text = NSString(format: "%.f", expenseStepper.value) as String
        distributionArray = calc.calculateEstateNetworthUsingDictionary(inputDict: profileDictionary)
        profileDictionary["expenses"] = expenseStepperLabel.text
        let (lowArray, highArray) = calculateLowAndHighArrays()
        graphview.labelArray = lowArray + highArray
        graphview.percentArray = calculateHistogramData()
        configureView()
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
            var intCount:Int = 0
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
    
    func formatCurrency(_ numberDouble:Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 0
        let newString = numberFormatter.string(from: NSNumber(value:numberDouble))
        return newString!
    }
    
    //CloudKit Delegate Methods
    func noAuthentication() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "iCloud sign-in required",
                                          message: "Please go to Settings and sign in", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func dataUpdated(records:Int) {
        let number = String(records)
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Database updated", message: number + " year(s) added", preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)
            Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(DetailViewController.dismissAlert), userInfo: nil, repeats: false)
        }
    }
    @objc func dismissAlert(){
        dismiss(animated: true, completion: nil)
    }

        // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //For iPhone transfer data to ResultsViewController & YearSimViewController
        if segue.identifier == "toYearSim" {
            let destination = segue.destination
            if let ysv = destination as? YearSimViewController {
                ysv.profileDictionary = profileDictionary
                //load growthSAndP after update
                if pathURL(append: AppendString.growth).isFileURL &&
                    NSArray(contentsOf: pathURL(append: AppendString.growth)) as? [String] != nil {
                    growthSAndP = NSArray(contentsOf: pathURL(append: AppendString.growth)) as! [String]
                }
                ysv.growthArray = growthSAndP
            }
        }
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
                mvc.probability = probabilityLabel.text! as String
            }
        }
    }
}
