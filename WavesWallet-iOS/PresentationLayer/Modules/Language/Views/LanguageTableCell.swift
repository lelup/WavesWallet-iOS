//
//  LanguageTableCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 07/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class LanguageTableCell: UITableViewCell, NibReusable {
    
    struct Model {
        let icon: UIImage?
        let title: String
        let isOn: Bool
    }
    
    @IBOutlet fileprivate weak var iconLanguage: UIImageView!
    @IBOutlet fileprivate weak var labelTitle: UILabel!
    @IBOutlet fileprivate weak var iconCheckmark: UIImageView!

    @IBOutlet fileprivate weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var rightConstraint: NSLayoutConstraint!

    // TODO: Add constant

    class func cellHeight() -> CGFloat {
        return 60
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // TODO: Add constant and remove Platform

        if Platform.isIphone5 {
            leftConstraint.constant = 16
            rightConstraint.constant = 16
        } else {
            leftConstraint.constant = 24
            rightConstraint.constant = 24
        }
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .white
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            selectedBackgroundView?.backgroundColor = .basic50
        } else {
            selectedBackgroundView?.backgroundColor = .white
        }
        
    }
    
}

extension LanguageTableCell: ViewConfiguration {
    
    func update(with model: LanguageTableCell.Model) {
        iconLanguage.image = model.icon
        labelTitle.text = model.title
        
        if model.isOn {
            iconCheckmark.image = Images.on.image
        } else {
            iconCheckmark.image = Images.off.image
        }
    }
    
}
