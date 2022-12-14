//
//  GraphView.swift
//  Retire
//
//  Created by H Steve Silesky on 7/10/16.
//  Copyright © 2016 STEVE SILESKY. All rights reserved.
//

import UIKit

class GraphView: UIView {
    var attr1size:CGFloat = 0.0
    var attr2size:CGFloat = 0.0
    var attr3size:CGFloat = 0.0
    var attr4size:CGFloat = 0.0
    var attr5size:CGFloat = 0.0
    var adjustHL:CGFloat = 0.0
    var botLabelsTxt: String?
    var percentArray = [Double]() {
        didSet{
            setNeedsDisplay()
        }
    }
    //the six lows(0...5 then the 6 highs(6...10)
    var labelArray = [Double()] {
        didSet{
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        //Check for device
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            attr1size = 15.0
            attr2size = 14.0
            attr3size = 13.0
            attr4size = 13.0
            attr5size = 13.0
            adjustHL = 10.0
        }else{
            attr1size = 13.0
            attr2size = 11.0
            attr3size = 11.0
            attr4size = 11.0
            attr5size = 11.0
            adjustHL = 30.0
        }
        //Create base path
        let basePath = UIBezierPath()
        let baseWidth:CGFloat = 2.0
        basePath.lineWidth = baseWidth
        basePath.move(to: CGPoint(x: 8.0, y: bounds.height - 35.0))
        basePath.addLine(to: CGPoint(x: bounds.width - 8.0, y: bounds.height - 35.0))
        UIColor.black.setStroke()
        basePath.stroke()
        //create increments
        let incrPath = UIBezierPath()
        let incrWidth:CGFloat = 0.03
        incrPath.lineWidth = incrWidth
        let pathLength:CGFloat = bounds.width - 16.0
        var interval:CGFloat = pathLength / 50.0
        for i in 1 ..< 50 {
            incrPath.move(to: CGPoint(x: 8.0 + CGFloat(i) * interval, y: bounds.height - 30.0))
            incrPath.addLine(to: CGPoint(x: 8.0 + CGFloat(i) * interval, y: 30.0))
            UIColor.gray.setStroke()
            incrPath.stroke()
        }
        //Create major increments
        for i in 0...5 {
            interval = pathLength / 5.0
            let majorPath = UIBezierPath()
            let majorWidth:CGFloat = 1.0
            majorPath.lineWidth = majorWidth
            majorPath.move(to: CGPoint(x: 8.0 + CGFloat(i) * interval, y: bounds.height - 32.0))
            majorPath.addLine(to: CGPoint(x: 8.0 + CGFloat(i) * interval, y: 30.0))
            UIColor.black.setStroke()
            majorPath.stroke()
        }
        
        //Create Top labels
        let attr1 = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: attr1size)!]
        let attr2 = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: attr2size)!]
        
        let myHigh = NSMutableAttributedString(string: "High", attributes: attr1)
        var xPlace:CGFloat = pathLength / 5.0 * 4.0 + pathLength / 10.0
        myHigh.draw(in: CGRect(x: xPlace, y: 10.0, width: 34.0, height: 20.0))
        let myLow =  NSMutableAttributedString(string: "Low", attributes: attr1)
        xPlace = pathLength / 5.0 * 3.0 + pathLength / 10.0
        myLow.draw(in: CGRect(x: xPlace, y: 10.0, width: 34.0, height: 20.0))
        let myDollars = NSMutableAttributedString(string: "$000s", attributes: attr2)
        xPlace = pathLength / 5.0 * 4.0
        myDollars.draw(in: CGRect(x: xPlace, y: 0.0, width: 40.0, height: 20.0))
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.left
        let title = NSMutableAttributedString(string: "Probability Histogram", attributes: [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: attr1size)!,  NSAttributedStringKey.paragraphStyle: style])
        xPlace = 25.0
        title.draw(in: CGRect(x: xPlace, y: 0.0, width: 200.0, height: 20.0))
        
        
        //Create Bottom Labels
        let array = ["0","10","20","30","40","50"]
        let attr3 = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: attr3size)!]
        interval = (bounds.width - 16.0) / 5.0
        for i in 0 ... 5 {
            let label = NSMutableAttributedString(string: array[i], attributes: attr3)
            xPlace = interval * CGFloat(i)
            if i == 0 {
                xPlace = 5.0
            }
            label.draw(in: CGRect(x: xPlace, y: bounds.height - 35.0, width: 20, height: 20))
        }
        
        //Create low labels
        let style2 = NSMutableParagraphStyle()
        style2.alignment = NSTextAlignment.right
        let barHeight = (bounds.height - 125.0) / 6.0
        xPlace = pathLength / 5.0 * 3.0 + pathLength / 10.0 - adjustHL
        var yPos:CGFloat
        var low = NSMutableAttributedString()
        let attr4 = [NSAttributedStringKey.foregroundColor: (UIColor).red, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: attr4size)!, NSAttributedStringKey.paragraphStyle: style2 ]
        let attr5 = [NSAttributedStringKey.foregroundColor: (UIColor).black, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: attr4size)!, NSAttributedStringKey.paragraphStyle: style2]
        for i in 0 ... 5 {
            yPos = rect.height - 45.0 - barHeight / 2.0 - (CGFloat(i) * (barHeight + 10.0))
            let myLabel = formatDoubles(labelArray[i])
            if labelArray[i] > 0.0  {
              low = NSMutableAttributedString(string: myLabel, attributes: attr5)
            }else{
                low = NSMutableAttributedString(string: myLabel, attributes: attr4)
            }
            low.draw(in: CGRect(x: xPlace, y: yPos, width: 60.0, height: 25.0))
        }
        
        //Create high labels
        xPlace = pathLength / 5.0 * 4.0 + pathLength / 10.0 - adjustHL
        var high = NSMutableAttributedString()
        for i in 6 ... 11 {
            yPos = rect.height - 45.0 - barHeight / 2.0 - (CGFloat(i - 6) * (barHeight + 10.0))
            let myLabel = formatDoubles(labelArray[i])
            if labelArray[i] > 0.0  {
                high = NSMutableAttributedString(string: myLabel, attributes: attr5)
            }else{
                high = NSMutableAttributedString(string: myLabel, attributes: attr4)
            }
            high.draw(in: CGRect(x: xPlace, y: yPos, width: 55.0, height: 25.0))
        }

        
        //create graphical bars
        for i in 0...5 {
            let barLength = (bounds.width - 16.0) * CGFloat(percentArray[i] / 50.0)
            let yValue = (rect.height - barHeight - 35.0) - (barHeight + 10.0) * CGFloat(i)
            let myRect = CGRect(x: 9.0, y: yValue, width: barLength, height: barHeight)
            let barPath = UIBezierPath(roundedRect: myRect, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: 2.0, height: 2.0))
            barPath.lineWidth = 0.5
            UIColor.black.setStroke()
            UIColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 0.1).setFill()
            barPath.stroke()
            barPath.fill()
        }
    }
    func formatDoubles(_ numberDouble:Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 0
        let newString = numberFormatter.string(from: NSNumber(value:numberDouble))
        return newString!
    }

}
