//
// Copyright © 2018 Smirnov Maxim. All rights reserved.
//

import ReSwift

struct AppState: StateType, Equatable {
    var currencyDownloadState: CurrencyDownloadState
    var multiplier: Double
    var lastCurrencyMap: CurrencyMap?
    static let initial = AppState(currencyDownloadState: .initial,
                                  multiplier: 100,
                                  lastCurrencyMap: nil)
}

enum CurrencyDownloadState: StateType, Equatable {
    case initial
    case loading
    case loaded(CurrencyDownloadResult)
}
