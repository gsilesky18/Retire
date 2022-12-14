//
//  MeaningViewViewController.swift
//  Retire
//
//  Created by H Steve Silesky on 6/12/16.
//  Copyright © 2016 STEVE SILESKY. All rights reserved.
//

import UIKit


class MeaningViewViewController: UIViewController {

    @IBOutlet weak var meaningTextView: UITextView!
    var lowValue1:String = ""
    var lowValue2:String = ""
    var highValue1:String = ""
    var highValue2:String = ""
    var percent1:String = ""
    var percent2:String = ""
    var probability:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Explain the Graph!"
        let intro = "This graph shows you your chances of having a comfortable retirement and leaving your heirs an inheritance. The model assumes the up and downs of the past are the key to future outcomes. The \"Probability of Estate\" in this simulation indicates a " + probability + " chance of not running out of money in your projected lifetime.\n\n"
        let end = "The sum of all the percentages is of course 100%, accounting for all the simulations. Therefore assuming our economy will see future recessions, depressions, and stock market bubbles, you are given the information you need to make an intelligent decision based on your own personal risk profile."
        let attr1 = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 15.0)!]
        let explain = NSMutableAttributedString(string: intro, attributes: attr1)
        let first:NSMutableAttributedString = firstBar()
        explain.append(first)
        let second:NSMutableAttributedString = secondBar()
        explain.append(second)
        let conclusion = NSMutableAttributedString(string: end, attributes: attr1)
        explain.append(conclusion)
        meaningTextView.attributedText = explain
    }

       func firstBar()-> NSMutableAttributedString {
        let attr1 = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 15.0)!]
        let attr2 = [NSAttributedStringKey.foregroundColor: UIColor.init(red: 0.0, green: 0.4, blue: 0.0, alpha: 1.0)]
        let firstBarString = "For example, the bottom bar indicates that you have a " + percent1 + "% chance of leaving your heirs an inheritance of between "
                             + lowValue1 + " and " + highValue1 + ".\n"
        let returnString = NSMutableAttributedString(string: firstBarString, attributes: attr1)
        returnString.addAttributes(attr2, range: NSMakeRange(0, returnString.length))
        return returnString
    }
    
    func secondBar()-> NSMutableAttributedString {
        let attr1 = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 15.0)!]
        let attr2 = [NSAttributedStringKey.foregroundColor: UIColor.init(red: 0.0, green: 0.4, blue: 0.0, alpha: 1.0)]
        let secondBarString = "The second bar up from the bottom indicates there is also a " + percent2 + "% chance of leaving your heirs an inheritance of between "
            + lowValue2 + " and " + highValue2 + "\n\n"
        let returnString = NSMutableAttributedString(string: secondBarString, attributes: attr1)
        returnString.addAttributes(attr2, range: NSMakeRange(0, returnString.length))
        return returnString
    }
    
    override func viewDidLayoutSubviews() {
        meaningTextView.contentOffset = CGPoint.zero
    }
}
