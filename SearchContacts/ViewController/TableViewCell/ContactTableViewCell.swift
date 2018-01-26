//
//  ContactTableViewCell.swift
//  TestSwift
//
//  Created by Giovanni Amati on 22/11/2017.
//  Copyright © 2017 Messagenet. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSeparatorLineToTop()
    }
    
    private func addSeparatorLineToTop(){
        let padding: CGFloat = 75
        let lineFrame = CGRect.init(x: padding, y: bounds.size.height - 1, width: bounds.size.width - padding, height: 0.8)
        let line = UIView(frame: lineFrame)
        line.backgroundColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        addSubview(line)
    }
    
    override func prepareForReuse() {
        self.avatarImageView.image = nil
        self.nameLabel.text = ""
        self.numberLabel.text = ""
    }
    
}

