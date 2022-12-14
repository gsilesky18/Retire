//
//  InstructionsViewController.swift
//  Retire
//
//  Created by H Steve Silesky on 7/22/16.
//  Copyright © 2016 STEVE SILESKY. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {

   
    @IBOutlet weak var instrTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Instructions"
        let bundle = Bundle.main
        let textURL = bundle.url(forResource: "instructions", withExtension: "txt")
        let myText =  try! NSString(contentsOf: textURL!, encoding: String.Encoding.utf8.rawValue)
        instrTextView.text = myText as String
    }
}
