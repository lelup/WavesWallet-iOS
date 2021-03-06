//
//  ReceiveCardPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa

final class ReceiveCardPresenter: ReceiveCardPresenterProtocol {
    
    var interactor: ReceiveCardInteractorProtocol!
    private let disposeBag = DisposeBag()
    
    
    func system(feedbacks: [ReceiveCardPresenter.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: ReceiveCard.State.initialState,
                      reduce: { state, event -> ReceiveCard.State in
                        return ReceiveCardPresenter.reduce(state: state, event: event) },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    private func modelsQuery() -> Feedback {
        
        return react(query: { state -> ReceiveCard.State? in
            return state.isNeedLoadInfo ? state : nil
        }, effects: { [weak self] state -> Signal<ReceiveCard.Event> in
            
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.interactor.getInfo(fiatType: state.fiatType).map {.didGetInfo($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    static private func reduce(state: ReceiveCard.State, event: ReceiveCard.Event) -> ReceiveCard.State {
        
        switch event {

        case .updateAmount(let money):
            
            return state.mutate {
                $0.action = .changeUrl
                $0.isNeedLoadInfo = false
                
                if let asset = state.assetBalance?.asset {
                    
                    let params = ["crypto" : asset.wavesId ?? "",
                                 "address" : state.address,
                                 "amount" : String(money.doubleValue),
                                 "fiat" : state.fiatType.id]
                    
                    $0.link = Receive.DTO.urlFromPath(GlobalConstants.Coinomat.buy, params: params)
                }
            }
            
        case .getUSDAmountInfo:
            return state.mutate {
                $0.isNeedLoadInfo = true
                $0.fiatType = ReceiveCard.DTO.FiatType.usd
                $0.action = .none
            }

        case .getEURAmountInfo:
            return state.mutate {
                $0.isNeedLoadInfo = true
                $0.fiatType = ReceiveCard.DTO.FiatType.eur
                $0.action = .none
            }
        
        case .didGetInfo(let responce):
            return state.mutate {
                $0.isNeedLoadInfo = false
                                
                switch responce.result {
                case .success(let info):
                    
                    $0.assetBalance = info.asset
                    $0.address = info.address
                    
                    switch info.amountInfo.type {
                    case .eur:
                        $0.amountEURInfo = info.amountInfo
                        
                    case .usd:
                        $0.amountUSDInfo = info.amountInfo
                    }
                    
                    $0.action = .didGetInfo

                case .error(let error):
                    $0.action = .didFailGetInfo(error)
                }
            }
        }
    }

}

fileprivate extension ReceiveCard.State {
    
    static var initialState: ReceiveCard.State {
        return ReceiveCard.State(isNeedLoadInfo: true, fiatType: .usd, action: .none, link: "", amountUSDInfo: nil, amountEURInfo: nil, assetBalance: nil, amount: nil, address: "")
    }
}
