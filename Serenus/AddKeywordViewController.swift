//
//  AddKeywordViewController.swift
//  Serenus
//
//  Created by Robert Anderson on 11/20/16.
//  Copyright © 2016 Robert Anderson. All rights reserved.
//

import UIKit

protocol AddKeywordViewControllerDelegate: class {
    
    func addKeywordViewController(_ viewController: AddKeywordViewController, didSaveKeyword keyword: String)
}

final class AddKeywordViewController: UITableViewController, UITextFieldDelegate {
    
    private weak var delegate: AddKeywordViewControllerDelegate?
    
    private lazy var textFieldCell: TextFieldCell = {
        let textFieldCell = TextFieldCell()
        textFieldCell.textField.delegate = self
        textFieldCell.textField.placeholder = "example.com"
        textFieldCell.textField.keyboardType = .URL
        textFieldCell.textField.autocorrectionType = .no
        textFieldCell.textField.autocapitalizationType = .none
        return textFieldCell
    }()
    
    init(delegate: AddKeywordViewControllerDelegate, keyword: String? = nil) {
        self.delegate = delegate
        
        super.init(style: .grouped)
        
        textFieldCell.textField.text = keyword
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        navigationItem.title = "Add to blacklist"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textFieldCell.textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        textFieldCell.textField.resignFirstResponder()
    }
    
    // MARK: - Actions
    
    func didTapSave() {
        if let keyword = textFieldCell.textField.text {
            delegate?.addKeywordViewController(self, didSaveKeyword: keyword)
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Enter a case-insensitive keyword to blacklist. Domains which contain this keyword will be blocked."
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return textFieldCell
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSave()
        
        return false
    }
}
