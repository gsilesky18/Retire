//
//  EstateCalc.swift
//  Retire
//
//  Created by H Steve Silesky on 2/22/18.
//  Copyright © 2018 STEVE SILESKY. All rights reserved.
//

import Foundation
class EstateCalc {
    
    var growthSP = [String]()
    var inflation = [String]()
    var peRatio = [String]()
    var estateNetworth = [Double]()
    var cash = 0.0
    var stock = 0.0
    var assets = 0.0
    enum AppendString :String {
        case growth = "growth.plist"
        case inflation = "inflation.plist"
        case priceEarnings = "pe.plist"
    }
    func pathURL(append:AppendString) -> URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(append.rawValue)
    }
    func calculateEstateNetworthUsingDictionary(inputDict:Dictionary<String,String>) ->Array<Double>{
        growthSP = NSArray(contentsOf: pathURL(append: AppendString.growth)) as! [String]
        inflation = NSArray(contentsOf: pathURL(append: AppendString.inflation)) as! [String]
        peRatio = NSArray(contentsOf: pathURL(append: AppendString.priceEarnings)) as! [String]
        estateNetworth.removeAll()
        let cashPercent = Double(inputDict["%Cash"]!)! * 0.01
        let years = Int(inputDict["years"]!)!
        let taxRate = Double(inputDict["taxRate"]!)
        let expenses = Double(inputDict["expenses"]!)
        let withdrawal =  expenses! / ((100.0 - taxRate!) * 0.01)
        print("\(String(describing: growthSP.count)) years of data")
        for simYrs in 1 ... growthSP.count - years {
            assets = Double(inputDict["assets"]!)!
            cash = cashPercent * assets
            stock = assets - cash
            for eachYr in simYrs ..< (years + simYrs) {
                let growth = Double(growthSP[eachYr])! - Double(inflation[eachYr])!
                let pe = Double(peRatio[eachYr])! - Double(peRatio[eachYr - 1])!
                //if equities = 0
                if stock <= 0 {
                    cash += -withdrawal
                    assets = cash + stock
                }else {
                    //if S&P and PE ratio growth are both positive and cash is needed to meet % then
                    //stock is sold to meet withdrawal
                    if ( growth > 0 && pe > 0) {
                        if cash >= cashPercent * assets {
                            stock = stock - withdrawal + stock * growth * 0.01
                            assets = cash + stock
                        } else {
                           //Otherwise pay withdrawal + gross up % Cash
                            stock = stock - withdrawal - (cashPercent * assets - cash) + stock * growth * 0.01
                            cash = cashPercent * assets
                            assets = stock + cash
                        }
                    } else {
                        //If cash > withdrawal, pay withdrawal with cash
                        if cash > withdrawal {
                            stock += stock * growth * 0.01
                            cash = cash - withdrawal
                            assets = cash + stock
                        } else {
                        //otherwise zero out cash and sell stock for balance of withdrawal
                        stock = stock + stock * growth * 0.01 - (withdrawal - cash)
                        cash = 0.0
                        assets = stock
                        }
                    }
                }
            }
            estateNetworth.append(assets)
        }
         return estateNetworth
    }
}
