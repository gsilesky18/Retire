//
//  ProfileTableViewController.swift
//  Retire
//
//  Created by H Steve Silesky on 6/5/16.
//  Copyright © 2016 STEVE SILESKY. All rights reserved.
//

import UIKit

extension UISplitViewController {
    func toggleMasterView() {
        let barButtonItem = self.displayModeButtonItem
        UIApplication.shared.sendAction(barButtonItem.action!, to: barButtonItem.target, from: nil, for: nil)
    }
}

class ProfileTableViewController: UITableViewController, UISplitViewControllerDelegate,CloudKitDelegate {
    
    var profileArray = [[String:String]]()
    var detailViewController: DetailViewController? = nil
    var growthSAndP = [String]()
    
    enum AppendString :String {
        case growth = "growth.plist"
        case inflation = "inflation.plist"
        case priceEarnings = "pe.plist"
    }
    
    func pathURL(append:AppendString) -> URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(append.rawValue)
    }

    // checks complete download of cloud data
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
        title = "Analysis"
        if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad {
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
            }
        }
        //set up splitViewController
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            let controllers = self.splitViewController!.viewControllers
            self.detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? DetailViewController
        }
        //Provide sample profile if none exists
        if FileManager.default.fileExists(atPath: dataPath()) {
            profileArray = NSArray(contentsOfFile: dataPath()) as! Array
            
        }else{
           let profileDict = ["title":"Sample Profile","assets":"2000","expenses":"150","%Cash":"10","years":"20","taxRate":"0"]
            profileArray = [profileDict]
            (profileArray as NSArray).write(toFile: dataPath(), atomically: true)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.detailViewController?.navigationItem.leftBarButtonItem?.title = "Profiles"
    }
    
    //Set Path
    func dataPath() -> String {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let writePath = (documents as NSString).appendingPathComponent("profileArray.plist")
        return writePath
    }
    
    // MARK: - unwind segueway method - Saves input values to TableView
    @IBAction func saveProfilevalues(_ unwindSegue: UIStoryboardSegue) {
        if let controller = unwindSegue.source as? ProfileViewController {
            let title = controller.titleTextField.text!
            let assets = controller.assetsTextField.text!.replacingOccurrences(of: ",", with: "")
            let expenses = controller.expenseTextField.text!.replacingOccurrences(of: ",", with: "")
            let cashPercent = controller.cashPercentTextField.text!.replacingOccurrences(of: ",", with: "")
            let years = controller.yearsTextField.text!
            let taxRate = controller.taxRateTextField.text!
            let profileDict = ["title":title,"assets":assets,"expenses":expenses,"%Cash":cashPercent,"years":years,"taxRate":taxRate]
            profileArray.append(profileDict)
            tableView.reloadData()
            (profileArray as NSArray).write(toFile: dataPath(), atomically: true)
        }
    }
    
    func formatWithComma(_ numberString:NSString) -> String {
        let noComma = numberString.replacingOccurrences(of: ",", with: "")
        let number = NSNumber(value: Int(noComma)! as Int)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 0
        let numberAsString = numberFormatter.string(from: number)
        return numberAsString!
    }
   
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileArray.count
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let dict = profileArray[(indexPath as NSIndexPath).row]
        var taxrate = ""
        cell.profileLabel.text = dict["title"]
        cell.cashPercentLabel.text = dict["%Cash"]
        cell.expenseLabel.text = formatWithComma(dict["expenses"]! as NSString)
        cell.yearsLabel.text = dict["years"]
        cell.assetLabel.text = formatWithComma(dict["assets"]! as NSString)
        //Format tax rate for each device
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            taxrate = dict["taxRate"]! + "%"
        }else{
            taxrate = "Tax rate " + dict["taxRate"]! + "%"
        }
        cell.taxRateLabel.text = taxrate
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            return 155
        }
        return 141
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            profileArray.remove(at: (indexPath as NSIndexPath).row)
            (profileArray as NSArray).write(toFile: dataPath(), atomically: true)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            //For iPad transfer data to DetailController
            let calc = EstateCalc()
            let dict = (profileArray as NSArray).object(at: (indexPath as NSIndexPath).row) as! [String:String]
            detailViewController?.distributionArray = calc.calculateEstateNetworthUsingDictionary(inputDict: dict)
            detailViewController?.profileDictionary = dict
            detailViewController?.title = dict["title"]
            //retract Profile TableView
            self.splitViewController?.toggleMasterView()
            detailViewController?.navigationItem.leftBarButtonItem?.title = "Profiles"
        }
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
            Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ProfileTableViewController.dismissAlert), userInfo: nil, repeats: false)
        }
    }
    @objc func dismissAlert(){
        dismiss(animated: true, completion: nil)
    }
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //For iPhone transfer data to ResultsViewController & YearSimViewController
        var indexPath:IndexPath = IndexPath()
        if segue.identifier == "toYearSim" {
            indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
        let destination = segue.destination
            if let yc = destination as? YearSimViewController {
                yc.profileDictionary = (profileArray as NSArray).object(at: (indexPath as NSIndexPath).row) as! [String : String]
                //load growthSandP after update
                if pathURL(append: AppendString.growth).isFileURL &&
                    NSArray(contentsOf: pathURL(append: AppendString.growth)) as? [String] != nil {
                    growthSAndP = NSArray(contentsOf: pathURL(append: AppendString.growth)) as! [String]
                }
                yc.growthArray = growthSAndP
            }
        }
        if segue.identifier == "toResults" {
            indexPath = tableView.indexPathForSelectedRow!
            let calc = EstateCalc()
            let destination = segue.destination
            if let rc = destination as? ResultsViewController {
                rc.profileDictionary = (profileArray as NSArray).object(at: (indexPath as NSIndexPath).row) as! [String : String]
                rc.distributionArray = calc.calculateEstateNetworthUsingDictionary(inputDict: (profileArray as NSArray).object(at: (indexPath as NSIndexPath).row) as! [String : String])
                let dictionary = (profileArray as NSArray).object(at: (indexPath as NSIndexPath).row) as! [String : String]
                rc.title = dictionary["title"]
            }
        }
    }
}
