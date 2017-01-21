//
//  BlacklistViewController.swift
//  Serenus
//
//  Created by Robert Anderson on 11/20/16.
//  Copyright © 2016 Robert Anderson. All rights reserved.
//

import UIKit
import SafariServices

final class BlacklistViewController: UITableViewController, AddKeywordViewControllerDelegate {

    private let userDefaults = UserDefaults(suiteName: "group.com.noisysocks.Serenus")
    
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
    }
    
    // MARK: - Actions
    
    func appliationWillEnterForeground() {
        tableView.reloadData()
    }
    
    func didTapEdit() {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    func didTapAdd() {
        let viewController = AddKeywordViewController()
        viewController.delegate = self
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDefaults?.stringArray(forKey: "BlacklistKeywords")?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeywordCell") ?? UITableViewCell(style: .default, reuseIdentifier: "KeywordCell")
        
        if let items = userDefaults?.stringArray(forKey: "BlacklistKeywords") {
             cell.textLabel?.text = items[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            mutateItems { items in
                items.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        mutateItems { items in
            let item = items.remove(at: sourceIndexPath.row)
            items.insert(item, at: destinationIndexPath.row)
        }
    }
    
    // MARK: - AddKeywordViewControllerDelegate
    
    func addKeywordViewController(_ viewController: AddKeywordViewController, didSaveKeyword keyword: String) {
        mutateItems { items in
            items.append(keyword)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Private
    
    private func mutateItems(action: (inout [String]) -> Void) {
        var items = userDefaults?.stringArray(forKey: "BlacklistKeywords") ?? []
        action(&items)
        userDefaults?.set(items, forKey: "BlacklistKeywords")
        
        SFContentBlockerManager.reloadContentBlocker(
            withIdentifier: "com.noisysocks.Serenus.ContentBlocker",
            completionHandler: { error in
                if let error = error {
                    fatalError(error.localizedDescription)
                }
            }
        )
    }
}
