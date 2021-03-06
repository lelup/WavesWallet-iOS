//
//  TokenBurnLoadingInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol TokenBurnSendInteractorProtocol {
    
    func burnAsset(asset: DomainLayer.DTO.AssetBalance, fee: Money, quiantity: Money) -> Observable<TokenBurnTypes.TransactionStatus>
}
