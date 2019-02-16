//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import Foundation

struct CurrencyDownloader {

    private let client: NetworkClient
    private let converter: ApiCurrencyConverter

    init(client: NetworkClient, converter: ApiCurrencyConverter) {
        self.client = client
        self.converter = converter
    }
}

// MARK: - CurrencyDownloadServie
extension CurrencyDownloader: CurrencyDownloadServie {

    func fetchCurrencies(basedOn currency: Currency,
                         completion: @escaping (CurrencyDownloadResult) -> Void) {

        let endpoint = URL(string: EndPoint.currencies + currency.rawValue)!
        client.performGet(endpoint: endpoint,
                          for: CurrencyResponse.self) { result in

                            guard
                                let value = result.value,
                                let converted = self.converter.convert(response: value) else {
                                    DispatchQueue.main.async {
                                        completion(.failure(CurrencyDownloadError.unknown))
                                    }
                                    return
                            }
                            DispatchQueue.main.async {
                                completion(.success(converted))
                            }
        }
    }
}

private extension CurrencyDownloader {
    enum EndPoint {
        static let currencies = "https://revolut.duckdns.org/latest?base="
    }
}
