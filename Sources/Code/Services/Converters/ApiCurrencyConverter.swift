//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import Foundation

struct ApiCurrencyConverter {
    func convert(response: CurrencyResponse) -> CurrencyMap? {
        guard let base = Currency(response.base) else { return nil }
        let rates: [CurrencyMap.Rate] = response.rates
            .compactMap {
                guard let kind = Currency($0.key) else { return nil }
                return CurrencyMap.Rate(kind: kind, value: $0.value)
        }

        return CurrencyMap(base: base, rates: Set(rates))
    }
}
