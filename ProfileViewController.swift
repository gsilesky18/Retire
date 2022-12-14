//
//  ProfileViewController.swift
//  Retire
//
//  Created by H Steve Silesky on 6/5/16.
//  Copyright © 2016 STEVE SILESKY. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var assetsTextField: UITextField!
    @IBOutlet weak var cashPercentTextField: UITextField!
    @IBOutlet weak var expenseTextField: UITextField!
    @IBOutlet weak var yearsTextField: UITextField!
    @IBOutlet weak var taxRateTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var instructionsTextView: UITextView!
    
    var activeField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        // load profile text instructions
        let updater = Updater()
        let lastYearData = updater.getLastYearOfData()

        instructionsTextView.text = "Using these inputs we calculate a series of simulations representing retirement taking place between 1910-" + lastYearData + " to get a full range of potential outcomes over a variety of economic conditions. The simulations assume a portfolio of the S&P 500 stocks and near cash investments per your inputs. All data is adjusted for inflation to yield a result in today's dollars. \n \n NOTE: PROFILES MAY BE DELETED BY SWIPING THEM TO THE LEFT AND TAPPING DELETE."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillShow(_:)) , name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)) , name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //unregister for keyboard notifications
        if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
    }
    
    // MARK: Move keyboard when necessary
   @objc func keyboardWillHide(_ notification: Notification)
    {
        //Once keyboard disappears, restore original positions
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    
     @objc func keyboardwillShow(_ notification: Notification)
    {
        //Need to calculate keyboard exact size 
        if let activeField = self.activeField, let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.size.height
            if (!aRect.contains(activeField.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Format a number string with a comma
    func formatWithComma(_ numberString:NSString) -> String {
        let noComma = numberString.replacingOccurrences(of: ",", with: "")
        let number = NSNumber(value: Int(noComma)! as Int)
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.groupingSeparator = ","
        let numberAsString = numberFormatter.string(from: number)
        return numberAsString!
    }
    
    // MARK: TextField Delegate methods
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField != titleTextField  && textField.text != ""{
            textField.text = formatWithComma(textField.text! as NSString)
        }
        activeField = nil
    }
    
    //restrict keys used
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == assetsTextField || textField == cashPercentTextField || textField == expenseTextField || textField == yearsTextField) || textField == taxRateTextField {
           if (string == "0") || (string == "1") || (string == "2") || (string == "3") || (string == "4") || (string == "5") ||
            (string == "6") || (string == "7") || (string == "8") || (string == "9") || (string as NSString).length == 0 {
            return true
            }
        }
        if textField == titleTextField {
            return true
        }
        return false
    }
    //lower keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Setup alerts for incomplete fields or percent greater than 100
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var titleMessage = ""
        if titleTextField.text != "" && assetsTextField.text != "" && cashPercentTextField.text != ""
             && expenseTextField.text != "" && yearsTextField.text != "" && taxRateTextField.text != ""
             && Int(cashPercentTextField.text!)! <= 100 && Int(taxRateTextField.text!)! <= 100
        {
            return true
        }else{
            if titleTextField.text == "" || assetsTextField.text == "" || cashPercentTextField.text == ""
                || expenseTextField.text == "" || yearsTextField.text == "" || taxRateTextField.text == ""  {
                titleMessage = "All fields must have entries"
            }else{
                titleMessage = "Percent fields must be less than 100"
            }
            let alert = UIAlertController(title: titleMessage, message: "Please re-enter", preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            return false
        }
    }
}
