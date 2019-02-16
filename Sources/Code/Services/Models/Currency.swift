//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import Foundation

struct CurrencyMap: Equatable {
    let base: Currency
    let rates: Set<Rate>
}

extension CurrencyMap {
    struct Rate: Hashable, Equatable {
        let kind: Currency
        let value: Decimal
    }
}

extension CurrencyMap: CustomStringConvertible {
    var description: String {
        return base.rawValue
    }
}

// MARK: - Kind
enum Currency: String {

    case aud
    case bgn
    case brl
    case cad
    case chf
    case cny
    case czk
    case dkk
    case eur
    case gbp
    case hkd
    case hrk
    case huf
    case idr
    case ils
    case inr
    case isk
    case jpy
    case krw
    case mxn
    case myr
    case nok
    case nzd
    case php
    case pln
    case ron
    case rub
    case sek
    case sgd
    case thb
    case `try`
    case usd
    case zar

    init?(_ string: String) {
        guard let kind = Currency(rawValue: string.lowercased()) else { return nil }
        self = kind
    }
}
