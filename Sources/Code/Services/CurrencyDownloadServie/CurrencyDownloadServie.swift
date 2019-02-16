//
// Copyright © 2018 Smirnov Maxim. All rights reserved.
//

import Foundation

typealias CurrencyDownloadResult = Currencies.Result<CurrencyMap, CurrencyDownloadError>

enum CurrencyDownloadError: Error, Equatable {
    case unknown
}

protocol CurrencyDownloadServie {
    func fetchCurrencies(basedOn currency: Currency,
                         completion: @escaping (CurrencyDownloadResult) -> Void)
}
