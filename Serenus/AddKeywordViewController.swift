//
//  AddKeywordViewController.swift
//  Serenus
//
//  Created by Robert Anderson on 11/20/16.
//  Copyright © 2016 Robert Anderson. All rights reserved.
//

import UIKit

protocol AddKeywordViewControllerDelegate: class {
    
    func didSave(keyword: String)
}

final class AddKeywordViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var keywordField: UITextField?
    
    weak var delegate: AddKeywordViewControllerDelegate?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        keywordField?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        keywordField?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        keywordField?.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Save", let keyword = keywordField?.text {
            delegate?.didSave(keyword: keyword)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performSegue(withIdentifier: "Save", sender: nil)
        return false
    }
}
