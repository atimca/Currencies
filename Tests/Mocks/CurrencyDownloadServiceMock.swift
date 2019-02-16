//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

@testable import Currencies

class CurrencyDownloadServiceMock: CurrencyDownloadServie {

    var completionCount = 1
    var invocations: [Invocation] = []

    func fetchCurrencies(basedOn currency: Currency,
                         completion: @escaping (CurrencyDownloadResult) -> Void) {
        invocations.append(.fetchCurrencies(currency: currency))
        for _ in 0..<completionCount {
            completion(.failure(.unknown))
        }
    }

    enum Invocation: Equatable {
        case fetchCurrencies(currency: Currency)
    }
}
