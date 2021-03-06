//
//  ImportCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 20.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
private enum Constants {
    static let duration: TimeInterval = 3
}

final class ImportCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let navigationController: UINavigationController
    private let completed: ((ImportTypes.DTO.Account) -> Void)

    private let disposeBag: DisposeBag = DisposeBag()
    private let auth: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private var currentPrivateKeyAccount: PrivateKeyAccount?
    

    init(navigationController: UINavigationController, completed: @escaping ((ImportTypes.DTO.Account) -> Void)) {
        self.navigationController = navigationController
        self.completed = completed
    }

    func start() {
        let vc = StoryboardScene.Import.importAccountViewController.instantiate() as ImportAccountViewController
        
        vc.scanViewController.delegate = self
        vc.manuallyViewController.delegate = self
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Child Controllers
    
    func scannedSeed(_ seed: String) {
        if seed.utf8.count >= ImportTypes.minimumSeedLength {
            let privateKeyAccount = PrivateKeyAccount(seedStr: seed)
            currentPrivateKeyAccount = privateKeyAccount


            auth.existWallet(by: privateKeyAccount.getPublicKeyStr()).subscribe(onNext: { [weak self] wallet in

                self?.navigationController.topViewController?.showErrorSnackWithoutAction(tille: Localizable.Waves.Import.General.Error.alreadyinuse, duration: Constants.duration)

                }, onError: { [weak self] _ in

                    self?.showAccountPassword(privateKeyAccount)
                })
                .disposed(by: disposeBag)
        } else {
            if let vc = navigationController.viewControllers.first(where: {$0.isKind(of: ImportAccountViewController.classForCoder())}) {
                vc.showMessageSnack(title: Localizable.Waves.Enter.Button.Importaccount.Error.insecureSeed)
            }
        }
    }
    
    func showQRCodeReader() {
        
        QRCodeReaderControllerCoordinator(rootViewController: navigationController).start { [weak self] (result) in
            if let seed = result?.value {
                self?.scannedSeed(seed)
            }
            
            self?.navigationController.dismiss(animated: true)
        }
        
    }
    
    func showAccountPassword(_ keyAccount: PrivateKeyAccount) {

        let vc = StoryboardScene.Import.importAccountPasswordViewController.instantiate()
        vc.delegate = self
        vc.address = keyAccount.address
        self.navigationController.pushViewController(vc, animated: true)
    }
    
}

// MARK: ImportAccountViewControllerDelegate
extension ImportCoordinator: ImportAccountViewControllerDelegate {

    func scanTapped() {
        showQRCodeReader()
    }

    
}

// MARK: ImportWelcomeBackViewControllerDelegate
extension ImportCoordinator: ImportWelcomeBackViewControllerDelegate {
    
    func userCompletedInputSeed(_ keyAccount: PrivateKeyAccount) {
        currentPrivateKeyAccount = keyAccount
        showAccountPassword(keyAccount)
    }
    
}


// MARK: ImportAccountPasswordViewControllerDelegate
extension ImportCoordinator: ImportAccountPasswordViewControllerDelegate {
    
    func userCompletedInputAccountData(password: String, name: String) {

        guard let privateKeyAccount = currentPrivateKeyAccount else { return }

        completed(.init(privateKey: privateKeyAccount,
                        password: password,
                        name: name))
        
    }
    
}
