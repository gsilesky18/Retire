//
//  SimCalculator.swift
//  Retire
//
//  Created by H Steve Silesky on 5/16/17.
//  Copyright © 2017 STEVE SILESKY. All rights reserved.
//

import Foundation

class SimCalculator: NSObject {
    
    var growthSP = [String]()
    var inflation = [String]()
    var peRatio = [String]()
    var cash = 0.0
    var stock = 0.0
    var assets = 0.0
    var expenses = 0.0
    
    enum AppendString :String {
        case growth = "growth.plist"
        case inflation = "inflation.plist"
        case priceEarnings = "pe.plist"
    }
    func pathURL(append:AppendString) -> URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(append.rawValue)
    }
    
    func calculateSimNetworth( inputDict:Dictionary<String,String>, startYr:Int) -> Double {
        growthSP = NSArray(contentsOf: pathURL(append: AppendString.growth)) as! [String]
        inflation = NSArray(contentsOf: pathURL(append: AppendString.inflation)) as! [String]
        peRatio = NSArray(contentsOf: pathURL(append: AppendString.priceEarnings)) as! [String]
        let cashPercent = Double(inputDict["%Cash"]!)! * 0.01
        let years = Int(inputDict["years"]!)!
        let taxRate = Double(inputDict["taxRate"]!)
        let expenses = Double(inputDict["expenses"]!)
        let withdrawal =  expenses! / ((100.0 - taxRate!) * 0.01)
        //loop appropriate years
        assets = Double(inputDict["assets"]!)!
        cash = cashPercent * assets
        stock = assets - cash
        for j in (startYr + 1)...(startYr + years) {
            let growth = (growthSP[j] as NSString).doubleValue - (inflation[j] as NSString).doubleValue
            let pe = (peRatio[j] as NSString).doubleValue  - (peRatio[j-1] as NSString).doubleValue
            if stock <= 0 {
                cash += -withdrawal
                assets = cash + stock
            }else {
                if (growth > 0 && pe > 0) {
                    if cash >= cashPercent * assets {
                        stock = stock - withdrawal + stock * growth * 0.01
                        assets = cash + stock
                    } else {
                        stock = stock - withdrawal - (cashPercent * assets - cash) + stock * growth * 0.01
                        cash = cashPercent * assets
                        assets = cash + stock
                    }
                }else {
                    if cash > withdrawal {
                        stock += stock * growth * 0.01
                        cash = cash - withdrawal
                        assets = cash + stock
                    } else {
                        stock = stock + stock * growth * 0.01 - (withdrawal - cash)
                        cash = 0
                        assets = stock
                    }
                }
            }
        }
        return assets
    }
}
