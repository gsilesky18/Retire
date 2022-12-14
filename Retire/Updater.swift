 //
//  Updater.swift
//  Retire
//
//  Created by H Steve Silesky on 5/2/17.
//  Copyright © 2017 STEVE SILESKY. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

protocol CloudKitDelegate {
    func noAuthentication()
    func dataUpdated(records:Int)
}

class Updater {
    
    var delegate: CloudKitDelegate?
    
    func loadNewData(dataPoints: Int) {
        let firstDataYear = 1910
        let year = Updater.findYear()
        let lastDataYear = dataPoints + firstDataYear - 1
        print("\(lastDataYear) is current data")
        print("\(year) is current year")
        if year > lastDataYear + 1 {
            getCloudData(startingYear: lastDataYear)
        }
    }
    
    static func findYear() -> Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        return year
    }
    
    enum AppendString :String {
        case growth = "growth.plist"
        case inflation = "inflation.plist"
        case priceEarnings = "pe.plist"
    }
    
    func pathURL(append:AppendString) -> URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(append.rawValue)
    }
    
    
    func loadSavedArrays() {
        let growth = Bundle.main.path(forResource: "growthRates", ofType: "plist")
        let growthArray = NSArray(contentsOfFile: growth!)
        growthArray?.write(to: pathURL(append: AppendString.growth), atomically: true)
        let inflation = Bundle.main.path(forResource: "inflation", ofType: "plist")
        let inflationArray = NSArray(contentsOfFile: inflation!)
        inflationArray?.write(to: pathURL(append: AppendString.inflation), atomically: true)
        let pe = Bundle.main.path(forResource: "pe", ofType: "plist")
        let peArray = NSArray(contentsOfFile: pe!)
        peArray?.write(to: pathURL(append: AppendString.priceEarnings), atomically: true)
        
    }
    
    func getLastYearOfData() -> String {
        let growthSandP = NSArray(contentsOf: pathURL(append: AppendString.growth))
        let year:String = String(growthSandP!.count + 1909)
        return year
    }

    func getCloudData(startingYear: Int) {
        //get bundle files to append
        var growthArray = NSArray(contentsOf: pathURL(append: AppendString.growth)) as? [String]
        var inflationArray = NSArray(contentsOf: pathURL(append: AppendString.inflation)) as? [String]
        var peArray = NSArray(contentsOf: pathURL(append: AppendString.priceEarnings)) as? [String]
        //setup for Cloud public Database fetch
        var recordDictArray = [CKRecord]()
        let ckContainer = CKContainer.default()
        let publicDB:CKDatabase = ckContainer.publicCloudDatabase
        CKContainer.default().accountStatus {
            (accountStatus, error) in
            if accountStatus == CKAccountStatus.noAccount {
                self.delegate?.noAuthentication()
            }else {
                var recordCount:Int = 0
                let predicate = NSPredicate(format: "year > %d", startingYear)
                let query = CKQuery(recordType: "RecordsForUpdate", predicate: predicate)
                query.sortDescriptors = [NSSortDescriptor(key: "year", ascending: true)]
                let queryOp = CKQueryOperation(query: query)
                queryOp.resultsLimit = 5
                publicDB.add(queryOp)
                queryOp.recordFetchedBlock = {
                    record in
                    recordCount += 1
                    recordDictArray.append(record)
                }
                queryOp.queryCompletionBlock = {
                    cursor, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "error in completion Block")
                    }else {
                        print("\(recordCount) years to be added")
                        //Append and store data
                        for record in recordDictArray {
                            let growth:String = record["growthSP"] as! String
                            let pe:String = record["peRatio"] as! String
                            let inflation = record["inflation"] as! String
                            growthArray?.append(growth)
                            peArray?.append(pe)
                            inflationArray?.append(inflation)
                        }
                        (growthArray! as NSArray).write(to: self.pathURL(append: AppendString.growth), atomically: true)
                        (inflationArray! as NSArray).write(to: self.pathURL(append: AppendString.inflation), atomically: true)
                        (peArray! as NSArray).write(to: self.pathURL(append: AppendString.priceEarnings), atomically: true)
                        if recordCount > 0 {
                        self.delegate?.dataUpdated(records: recordCount)
                        }
                    }
                }
            }
        }
    }
}

