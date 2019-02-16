//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import ReSwift

enum CurrenciesAction: Action, Equatable {
    case fetch
    case set(CurrencyDownloadState)
}

struct NewBaseCurrencySelected: Action, Equatable {
    let newValue: Currency
}

struct MultiplierChanged: Action {
    let newValue: Decimal
}
