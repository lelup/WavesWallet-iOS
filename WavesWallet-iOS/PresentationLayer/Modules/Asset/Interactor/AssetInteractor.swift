//
//  AssetViewInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

fileprivate enum Constants {
    static let transactionLimit: Int = 10
}

final class AssetInteractor: AssetInteractorProtocol {

    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let accountBalanceInteractor: AccountBalanceInteractorProtocol = FactoryInteractors.instance.accountBalance
    private let accountBalanceRepositoryLocal: AccountBalanceRepositoryProtocol = FactoryRepositories.instance.accountBalanceRepositoryLocal

    private let transactionsInteractor: TransactionsInteractorProtocol = FactoryInteractors.instance.transactions

    private let walletSortInteractor: WalletSortInteractor = WalletSortInteractor()

    private let refreshAssetsSubject: PublishSubject<[AssetTypes.DTO.Asset]> = PublishSubject<[AssetTypes.DTO.Asset]>()
    private let disposeBag: DisposeBag = DisposeBag()

    func assets(by ids: [String]) -> Observable<[AssetTypes.DTO.Asset]> {

        return Observable.merge(refreshAssetsSubject.asObserver(),
                                assets(by: ids,
                                       isNeedUpdate: false))
    }

    private func assets(by ids: [String], isNeedUpdate: Bool) -> Observable<[AssetTypes.DTO.Asset]> {

        return authorizationInteractor
            .authorizedWallet()
            .flatMap(weak: self) { owner, wallet -> Observable<[AssetTypes.DTO.Asset]> in

                owner.accountBalanceInteractor
                    .balances(by: wallet,
                              isNeedUpdate: isNeedUpdate)
                    .map {
                        $0.filter { asset -> Bool in
                            ids.contains(asset.assetId)
                        }
                    }
                    .map { $0.map { $0.mapToAsset() } }
            }
    }

    func transactions(by assetId: String) -> Observable<[DomainLayer.DTO.SmartTransaction]> {

        return authorizationInteractor
            .authorizedWallet()
            .flatMap { [weak self] wallet -> Observable<[DomainLayer.DTO.SmartTransaction]> in

                guard let owner = self else { return Observable.never() }
                
                return owner.transactionsInteractor.transactionsSync(by: wallet.address,
                                                                     specifications: .init(page: .init(offset: 0,
                                                                                                   limit: Constants.transactionLimit),
                                                                                       assets: [assetId],
                                                                                       senders: [],
                                                                                       types: TransactionType.all))
                    .flatMap { (txs) -> Observable<[DomainLayer.DTO.SmartTransaction]> in
                        return Observable.just(txs.resultIngoreError ?? [])
                    }
            }
    }

    func refreshAssets(by ids: [String]) {

        assets(by: ids, isNeedUpdate: true)
            .take(1)
            .subscribe(weak: self, onNext: { owner, assets in
                owner.refreshAssetsSubject.onNext(assets)
            })
            .disposed(by: disposeBag)
    }

    func toggleFavoriteFlagForAsset(by id: String, isFavorite: Bool) {



        authorizationInteractor
            .authorizedWallet()
            .flatMap { [weak self] wallet -> Observable<(wallet: DomainLayer.DTO.Wallet,
                balance: DomainLayer.DTO.AssetBalance)> in

                guard let owner = self else { return Observable.never() }
                return owner
                    .accountBalanceRepositoryLocal
                    .balance(by: id, accountAddress: wallet.address)
                    .map { (wallet: wallet.wallet, balance: $0) }
            }
            .flatMap { [weak self] data -> Observable<Bool> in

                guard let owner = self else { return Observable.never() }

                let a = WalletSort.DTO.Asset.init(id: data.balance.assetId,
                                          name: data.balance.asset!.displayName,
                                          isLock: data.balance.asset!.isWaves,
                                          isMyWavesToken: data.balance.asset!.isMyWavesToken,
                                          isFavorite: isFavorite,
                                          isGateway: data.balance.asset!.isGateway,
                                          isHidden: data.balance.settings!.isHidden,
                                          sortLevel: data.balance.settings!.sortLevel,
                                          icon: data.balance.asset!.icon)

                owner.walletSortInteractor.update(asset: a)
                return Observable.just(true)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}

private extension DomainLayer.DTO.AssetBalance {

    func mapToAsset() -> AssetTypes.DTO.Asset {
        return AssetTypes.DTO.Asset(info: mapToInfo(),
                                    balance: mapToBalance())
    }

    func mapToBalance() -> AssetTypes.DTO.Asset.Balance {

        let decimal = asset?.precision ?? 0

        let totalMoney = Money(balance, decimal)
        let avaliableMoney = Money(avaliableBalance, decimal)
        let leasedMoney = Money(leasedBalance, decimal)
        let inOrderMoney = Money(inOrderBalance, decimal)

        return AssetTypes.DTO.Asset.Balance(totalMoney: totalMoney,
                                            avaliableMoney: avaliableMoney,
                                            leasedMoney: leasedMoney,
                                            inOrderMoney: inOrderMoney,
                                            isFiat: asset?.isFiat ?? false)
    }

    func mapToInfo() -> AssetTypes.DTO.Asset.Info {

        let id = asset?.id ?? ""
        let issuer = asset?.sender ?? ""
        let name = asset?.displayName ?? ""
        let description = asset?.description ?? ""
        let issueDate = asset?.timestamp ?? Date()
        let isReusable = asset?.isReusable ?? false
        let isMyWavesToken = asset?.isMyWavesToken ?? false
        let isWavesToken = asset?.isWavesToken ?? false
        let isWaves = asset?.isWaves ?? false
        let isFavorite = settings?.isFavorite ?? false
        let isFiat = asset?.isFiat ?? false
        let isSpam = asset?.isSpam ?? false
        let isGateway = asset?.isGateway ?? false
        let sortLevel = settings?.sortLevel ?? 0
        let icon = asset?.icon ?? ""

        return .init(id: id,
                     issuer: issuer,
                     name: name,
                     description: description,
                     issueDate: issueDate,
                     isReusable: isReusable,
                     isMyWavesToken: isMyWavesToken,
                     isWavesToken: isWavesToken,
                     isWaves: isWaves,
                     isFavorite: isFavorite,
                     isFiat: isFiat,
                     isSpam: isSpam,
                     isGateway: isGateway,
                     sortLevel: sortLevel,
                     icon: icon,
                     assetBalance: self)
    }
}
