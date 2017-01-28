//
//  BlacklistViewController.swift
//  Serenus
//
//  Created by Robert Anderson on 11/20/16.
//  Copyright © 2016 Robert Anderson. All rights reserved.
//

import UIKit

final class BlacklistViewController: UITableViewController, AddKeywordViewControllerDelegate {

    private let blacklist = Blacklist()
    
    private var rowBeingEdited: Int?
    
    init() {
        super.init(style: .plain)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appliationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        tableView.allowsSelection = false
        tableView.allowsSelectionDuringEditing = true
    }
    
    // MARK: - Actions
    
    func appliationWillEnterForeground() {
        tableView.reloadData()
    }
    
    func didTapEdit() {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    func didTapAdd() {
        let viewController = AddKeywordViewController(delegate: self)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blacklist.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeywordCell") ?? UITableViewCell(style: .default, reuseIdentifier: "KeywordCell")
        cell.textLabel?.text = blacklist.keyword(at: indexPath.row)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            blacklist.mutate { keywords in
                keywords.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        blacklist.mutate { keywords in
            let keyword = keywords.remove(at: sourceIndexPath.row)
            keywords.insert(keyword, at: destinationIndexPath.row)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let keyword = blacklist.keyword(at: indexPath.row) {
            let viewController = AddKeywordViewController(delegate: self, keyword: keyword)
            navigationController?.pushViewController(viewController, animated: true)
            rowBeingEdited = indexPath.row
        }
    }
    
    // MARK: - AddKeywordViewControllerDelegate
    
    func addKeywordViewController(_ viewController: AddKeywordViewController, didSaveKeyword keyword: String) {
        blacklist.mutate { keywords in
            if let rowBeingEdited = rowBeingEdited {
                keywords[rowBeingEdited] = keyword
            }
            else {
                keywords.append(keyword)
            }
        }
        
        rowBeingEdited = nil
        
        tableView.reloadData()
    }
}
