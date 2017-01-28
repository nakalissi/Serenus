//
//  ActionRequestHandler.swift
//  Action
//
//  Created by Robert Anderson on 11/20/16.
//  Copyright © 2016 Robert Anderson. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

    private let blacklist = Blacklist()
    private var extensionContext: NSExtensionContext?
    
    func beginRequest(with context: NSExtensionContext) {
        self.extensionContext = context
        
        var found = false
        
        // Find the item containing the results from the JavaScript preprocessing
        outer:
            for item in context.inputItems as! [NSExtensionItem] {
                if let attachments = item.attachments {
                    for itemProvider in attachments as! [NSItemProvider] {
                        if itemProvider.hasItemConformingToTypeIdentifier(String(kUTTypePropertyList)) {
                            itemProvider.loadItem(forTypeIdentifier: String(kUTTypePropertyList), options: nil, completionHandler: { (item, error) in
                                let dictionary = item as! [String: Any]
                                OperationQueue.main.addOperation {
                                    self.itemLoadCompletedWithPreprocessingResults(dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! [String: Any]? ?? [:])
                                }
                            })
                            found = true
                            break outer
                        }
                    }
                }
        }
        
        if !found {
            self.doneWithResults(nil)
        }
        
        // Do not call super in an Action extension with no user interface
    }
    
    func itemLoadCompletedWithPreprocessingResults(_ javaScriptPreprocessingResults: [String: Any]) {
        if let host = javaScriptPreprocessingResults["host"] as? String {
            blacklist.mutate { keywords in
                if !keywords.contains(host) {
                    keywords.append(host)
                }
            }
            
            self.doneWithResults(javaScriptPreprocessingResults)
        }
    }
    
    private func doneWithResults(_ resultsForJavaScriptFinalizeArg: [String: Any]?) {
        if let resultsForJavaScriptFinalize = resultsForJavaScriptFinalizeArg {
            // Construct an NSExtensionItem of the appropriate type to return our results dictionary in
            // These will be used as the arguments to the JavaScript finalize() method
            
            let resultsDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: resultsForJavaScriptFinalize]
            
            let resultsProvider = NSItemProvider(item: resultsDictionary as NSDictionary, typeIdentifier: String(kUTTypePropertyList))
            
            let resultsItem = NSExtensionItem()
            resultsItem.attachments = [resultsProvider]
            
            // Signal that we're complete, returning our results
            self.extensionContext!.completeRequest(returningItems: [resultsItem], completionHandler: nil)
        } else {
            // We still need to signal that we're done even if we have nothing to pass back
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
        
        // Don't hold on to this after we finished with it
        self.extensionContext = nil
    }
}
