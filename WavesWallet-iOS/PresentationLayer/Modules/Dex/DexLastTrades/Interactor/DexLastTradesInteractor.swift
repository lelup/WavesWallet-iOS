//
//  DexLastTradesInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

final class DexLastTradesInteractor: DexLastTradesInteractorProtocol {
    
    private let account = FactoryInteractors.instance.accountBalance
    private let disposeBag = DisposeBag()
    
    var pair: DexTraderContainer.DTO.Pair!

    func displayInfo() -> Observable<(DexLastTrades.DTO.DisplayData)> {

        return Observable.create({ [weak self] (subscribe) -> Disposable in
            
            guard let owner = self else { return Disposables.create() }
            
            owner.getLastTrades({ (trades) in
                owner.getLastSellBuy({ (lastSell, lastBuy) in
                    
                    //TODO: need change api to get only balances by ids
                    owner.account.balances(isNeedUpdate: false).subscribe(onNext: { (balances) in
                        
                        var amountAssetBalance =  Money(0, owner.pair.amountAsset.decimals)
                        var priceAssetBalance =  Money(0, owner.pair.priceAsset.decimals)
                        var wavesBalance = Money(0, GlobalConstants.WavesDecimals)

                        if let amountAsset = balances.first(where: {$0.assetId == owner.pair.amountAsset.id}) {
                            amountAssetBalance = Money(amountAsset.avaliableBalance, amountAsset.asset?.precision ?? 0)
                        }
                        
                        if let priceAsset = balances.first(where: {$0.assetId == owner.pair.priceAsset.id}) {
                            priceAssetBalance = Money(priceAsset.avaliableBalance, priceAsset.asset?.precision ?? 0)
                        }
                        
                        if let wavesAsset = balances.first(where: {$0.asset?.isWaves == true}) {
                            wavesBalance = Money(wavesAsset.avaliableBalance, wavesAsset.asset?.precision ?? 0)
                        }
                        let display = DexLastTrades.DTO.DisplayData(trades: trades, lastSell: lastSell, lastBuy: lastBuy,
                                                                    availableAmountAssetBalance: amountAssetBalance,
                                                                    availablePriceAssetBalance: priceAssetBalance,
                                                                    availableWavesBalance: wavesBalance)

                        subscribe.onNext(display)
                        
                    }, onError: { (error) in
                        
                        let display = DexLastTrades.DTO.DisplayData(trades: [], lastSell: nil, lastBuy:  nil,
                                                                    availableAmountAssetBalance: Money(0, owner.pair.amountAsset.decimals),
                                                                    availablePriceAssetBalance: Money(0, owner.pair.priceAsset.decimals),
                                                                    availableWavesBalance: Money(0, GlobalConstants.WavesDecimals))

                        subscribe.onNext(display)
                    }).disposed(by: owner.disposeBag)
                    
                })
            })

            return Disposables.create()
        })
    }
}

private extension DexLastTradesInteractor {
    
    func getLastTrades(_ complete:@escaping(_ trades: [DexLastTrades.DTO.Trade]) -> Void) {
        
        //TODO: need change to Observer network
        
        let url = GlobalConstants.Market.trades(pair.amountAsset.id, pair.priceAsset.id, 100)

        NetworkManager.getRequestWithUrl(url, parameters: nil) { (info, error) in
            
            var trades: [DexLastTrades.DTO.Trade] = []
            
            if let items = info?.arrayValue {

                for item in items {
                    
                    let timestamp = item["timestamp"].doubleValue
                    let time = Date(timeIntervalSince1970: timestamp / 1000)
                    
                    let type: Dex.DTO.OrderType = item["type"] == "sell" ? .sell : .buy
                    let price = Decimal(item["price"].doubleValue)
                    let amount = Decimal(item["amount"].doubleValue)
                    let sum = price * amount
                    
                    trades.append(DexLastTrades.DTO.Trade(time: time,
                                                          price: Money(value: price, self.pair.priceAsset.decimals),
                                                          amount: Money(value: amount, self.pair.amountAsset.decimals),
                                                          sum: Money(value: sum, self.pair.priceAsset.decimals),
                                                          type: type))
                }
            }
            
            complete(trades)
        }
       
    }
    
    func getLastSellBuy(_ complete:@escaping(_ lastSell: DexLastTrades.DTO.SellBuyTrade?, _ lastBuy: DexLastTrades.DTO.SellBuyTrade?) -> Void) {
        
        //TODO: need change to Observer network

        let url = GlobalConstants.Matcher.orderBook(pair.amountAsset.id, pair.priceAsset.id)
        
        NetworkManager.getRequestWithUrl(url, parameters: nil) { (info, error) in
            
            var sell: DexLastTrades.DTO.SellBuyTrade?
            var buy: DexLastTrades.DTO.SellBuyTrade?
            
            if let info = info {                
                if let bid = info["bids"].arrayValue.first {
                    
                    let price = DexList.DTO.price(amount: bid["price"].int64Value, amountDecimals: self.pair.amountAsset.decimals, priceDecimals: self.pair.priceAsset.decimals)
                    
                    sell = DexLastTrades.DTO.SellBuyTrade(price: price,
                                                          type: .sell)
                }
                
                if let ask = info["asks"].arrayValue.first {
                    
                    let price = DexList.DTO.price(amount: ask["price"].int64Value, amountDecimals: self.pair.amountAsset.decimals, priceDecimals: self.pair.priceAsset.decimals)

                    buy = DexLastTrades.DTO.SellBuyTrade(price: price,
                                                         type: .buy)
                }
            }
            
            complete(sell, buy)
        }
    }
}
