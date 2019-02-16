//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import Foundation

struct CurrencyResponse: Codable {
    let base: String
    let date: String
    let rates: [String: Decimal]
}
