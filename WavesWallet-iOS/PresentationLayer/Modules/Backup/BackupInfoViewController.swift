//
//  NewAccountBackupInfoViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let topLogoOffset: CGFloat = 80
}

protocol BackupInfoViewModuleOutput: AnyObject {
    func userReadedBackupInfo()
}

final class BackupInfoViewController: UIViewController {

    @IBOutlet weak var contentLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var iUnderstandButton: UIButton!

    weak var output: BackupInfoViewModuleOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupConstraints()

        iUnderstandButton.setBackgroundImage(UIColor.submit300.image, for: .highlighted)
        iUnderstandButton.setBackgroundImage(UIColor.submit400.image, for: .normal)
        
        createBackButton()
        navigationItem.shadowImage = UIImage()
        navigationItem.backgroundImage = UIImage()
        
        titleLabel.text = Localizable.Waves.Backup.Infobackup.Label.title
        detailLabel.text = Localizable.Waves.Backup.Infobackup.Label.detail
        iUnderstandButton.setTitle(Localizable.Waves.Backup.Infobackup.Button.iunderstand, for: .normal)
    }

    // MARK: - Setups
    
    private func setupConstraints() {
        
        if Platform.isIphone5 {
            contentLeadingConstraint.constant = 12
            contentTrailingConstraint.constant = 12
            buttonLeadingConstraint.constant = 12
            buttonTrailingConstraint.constant = 12
            buttonBottomConstraint.constant = 14
        } else {
            contentLeadingConstraint.constant = 24
            contentTrailingConstraint.constant = 24
            buttonLeadingConstraint.constant = 16
            buttonTrailingConstraint.constant = 16
            buttonBottomConstraint.constant = 24
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func understandTapped(_ sender: Any) {
        output?.userReadedBackupInfo()
    }
    
}
