//
//  LegacyCalculator.swift
//  Retire
//
//  Created by H Steve Silesky on 6/12/16.
//  Copyright © 2016 STEVE SILESKY. All rights reserved.
//

import Foundation
class LegacyCalculator: NSObject {
    
    
    var inflation = [String]()
    var peRatioSandP = [String]()
    var growthSandP = [String]()
    var cash = 0.0
    var peRatio = 0
    var assets = 0.0
    var stock = 0.0
    var cashPercent = 0.0
    var expenses = 0.0
    var legacyNetworth = [Double]()
    
    func growthPath() ->String //dataPath for growthS&P
    {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let writePath = (documents as NSString).appendingPathComponent("/growthPath.plist")
        return writePath
    }
    
    func inflationPath() ->String //dataPath for inflation
    {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let writePath = (documents as NSString).appendingPathComponent("/inflation.plist")
        return writePath
    }
    
    func pePath() ->String //dataPath for pe
    {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let writePath = (documents as NSString).appendingPathComponent("/pe.plist")
        return writePath
    }

    
    func calculateLegacyNetworthUsingDictionary(_ inputDict:Dictionary<String,String>) -> Array<Double> {
        
        growthSandP = NSArray(contentsOfFile: growthPath()) as! [String]
        inflation = NSArray(contentsOfFile: inflationPath() as String) as! [String]
        peRatioSandP = NSArray(contentsOfFile: pePath() as String) as! [String]
        legacyNetworth.removeAll()
        cashPercent = (inputDict["%Cash"]! as NSString).doubleValue * 0.01
        //Raise amount of expenses by effective tax rate
        let taxRateDivisor = (100.0 - ((inputDict["taxRate"]! as NSString).doubleValue)) * 0.01
        expenses = ((inputDict["expenses"]! as NSString).doubleValue) / taxRateDivisor
        let years = (inputDict["years"]! as NSString).integerValue
        //loop appropriate S&P years
        print("\(growthSandP.count) years of data ")
        for i in 1 ... growthSandP.count - years {
            assets = (inputDict["assets"]! as NSString).doubleValue
            cash = cashPercent * assets
            stock = assets - cash
            for j in i ..< (years + i) {
                let growth = (growthSandP[j] as NSString).doubleValue - (inflation[j] as NSString).doubleValue
                let sp = growth
                let pe = (peRatioSandP[j] as NSString).doubleValue  - (peRatioSandP[j-1] as NSString).doubleValue
                if stock <= 0 {
                    cash += -expenses
                    assets = cash + stock
                }else {
                    if (sp > 0 && pe > 0) {
                        if cash >= cashPercent * assets {
                            stock = stock - expenses + stock * growth * 0.01
                            assets = cash + stock
                        } else {
                            stock = stock - expenses - (cashPercent * assets - cash) + stock * growth * 0.01
                            cash = cashPercent * assets
                            assets = cash + stock
                        }
                        
                    }else {
                        if cash > expenses {
                            stock += stock * growth * 0.01
                            cash = cash - expenses
                            assets = cash + stock
                        } else {
                            stock = stock + stock * growth * 0.01 - (expenses - cash)
                            cash = 0
                            assets = stock
                        }
                    }
                }
            }
            legacyNetworth.append(assets)
        }
        return legacyNetworth
    }
}



