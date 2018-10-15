//
//  UIButton+WithoutAnimation.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

extension UIButton {
    func setTitleWithoutAnimated(_ title: String?, for state: UIControlState) {
        UIView.performWithoutAnimation {
            setTitle(title, for: state)
        }
    }
}
