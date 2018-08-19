//
//  CustomNavigationController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 17/03/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

extension UINavigationItem {

        private enum AssociatedKeys {
            static var prefersLargeTitles = "prefersLargeTitles"
            static var backgroundImage = "backgroundImage"
            static var shadowImage = "shadowImage"
        }

        @objc var prefersLargeTitles: Bool {
            get {
                return associatedObject(for: &AssociatedKeys.prefersLargeTitles) ?? false
            }

            set {
                setAssociatedObject(newValue, for: &AssociatedKeys.prefersLargeTitles)
            }
    }

    @objc var backgroundImage: UIImage? {
        get {
            return associatedObject(for: &AssociatedKeys.backgroundImage)
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.backgroundImage)
        }
    }

    @objc var shadowImage: UIImage? {
        get {
            return associatedObject(for: &AssociatedKeys.shadowImage)
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.shadowImage)
        }
    }
}

private enum Constants {
    static var prefersLargeTitles = "prefersLargeTitles"
    static var backgroundImage = "backgroundImage"
    static var shadowImage = "shadowImage"
}

class CustomNavigationController: UINavigationController {

    private weak var prevViewContoller: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.interactivePopGestureRecognizer?.delegate = self

    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        if let prevViewContoller = prevViewContoller {
            apperanceNavigationItemProperties(prevViewContoller)
        }
    }

//    override func popViewController(animated: Bool) -> UIViewController? {
//        let vc = super.popViewController(animated: animated)
//
//        if let topViewController = topViewController {
////            apperanceNavigationItemProperties(topViewController)
//        }
//        return vc
//    }
//
//    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
//        super.pushViewController(viewController, animated: animated)
////        apperanceNavigationItemProperties(viewController)
//    }

    private func apperanceNavigationItemProperties(_ viewController: UIViewController) {

        navigationBar.setBackgroundImage(viewController.navigationItem.backgroundImage, for: .default)
        navigationBar.shadowImage = viewController.navigationItem.shadowImage

        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = viewController.navigationItem.prefersLargeTitles
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension CustomNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: UINavigationControllerDelegate

extension CustomNavigationController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

        apperanceNavigationItemProperties(viewController)

        if let prevViewContoller = prevViewContoller {
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.shadowImage)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.backgroundImage)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.prefersLargeTitles)
        }

        prevViewContoller = viewController

        viewController.navigationItem.addObserver(self, forKeyPath: Constants.backgroundImage, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.shadowImage, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.prefersLargeTitles, options: [.new, .old], context: nil)
    }
}
