//
//  TextFieldCell.swift
//  Serenus
//
//  Created by Robert Anderson on 1/21/17.
//  Copyright © 2017 Robert Anderson. All rights reserved.
//

import UIKit

final class TextFieldCell: UITableViewCell {
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        return textField
    }()
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        contentView.addSubview(textField)
        
        textField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        textField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 20).isActive = true
        textField.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
