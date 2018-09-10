//
//  DexChartCandleAxisValueFormatter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Charts

//MARK: - DexChartCandleRightAxisFormatter
final class DexChartCandleRightAxisFormatter: IAxisValueFormatter {

    private var isFiatPair: Bool

    init(isFiatPair: Bool) {
        self.isFiatPair = isFiatPair
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        let numberFormatter = isFiatPair ? DexChart.DTO.Candle.fiatFormatter : DexChart.DTO.Candle.defaultFormatter

        if let string = numberFormatter.string(from: NSNumber(value: value)) {
            return string
        }
        return ""
    }
}

//MARK: - DexChartCandleAxisFormatter
final class DexChartCandleAxisFormatter: IAxisValueFormatter {
    
    private let dateFormatter = DateFormatter()
    
    var timeFrame: Int = 0
    
    init() {
        dateFormatter.dateFormat = "HH:mm\ndd.MM.yyyy"
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        let time = value * 60 * Double(timeFrame)
        let date = Date(timeIntervalSince1970: time)
        return dateFormatter.string(from: date)
    }
}

//MARK: - DexChartBarAxisFormatter
final class DexChartBarAxisFormatter: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return ""
    }
}


//MARK: - DexChartBarRightAxisFormatter
final class DexChartBarRightAxisFormatter: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        if value < 10 {
            return String(Int(value))
        }
        else if value < 100 {
            return String(roundTo(value: value, to: 10))
        }
        else if value < 1000 {
            return String(roundTo(value: value, to: 100))
        }
        else {
            let val = roundTo(value: value, to: 1000)
            return String(val / 1000) + "K"
        }
    }
    
    private func roundTo(value: Double, to: Int) -> Int {
        return Int(Double(to) * floor(value / Double(to) + 0.5))
        
    }
}
