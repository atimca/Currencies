//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import XCTest
@testable import Currencies

class CurrencyDownloadServieTests: XCTestCase {

    func test_whenNetworkReturnsSuccess_thereWillBeCurrenciesOnResult() {
        // Given
        let service = CurrencyDownloader(client: NetworkSuccessStub(),
                                         converter: ApiCurrencyConverter())
        let exp = expectation(description: "CurrencyDownloader")
        // When
        service.fetchCurrencies(basedOn: TestData.currency) { result in
            // Then
            XCTAssertEqual(result.value, .init(base: .eur,
                                               rates: [.init(kind: .aud,
                                                             value: TestData.rateValue0),
                                                       .init(kind: .bgn,
                                                             value: TestData.rateValue1),
                                                       .init(kind: .brl,
                                                             value: TestData.rateValue2)]))
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)
    }

    func test_whenNetowrkClientProduceFailure_thereWillBeUnknownErrorOnResult() {
        // Given
        let service = CurrencyDownloader(client: NetworkFailureStub(),
                                         converter: ApiCurrencyConverter())
        let exp = expectation(description: "CurrencyDownloader")
        // When
        service.fetchCurrencies(basedOn: TestData.currency) { result in
            // Then
            XCTAssertEqual(result.error, CurrencyDownloadError.unknown)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)
    }
}

private class NetworkSuccessStub: NetworkClient {

    //swiftlint:disable force_try
    func performGet<T: Decodable>(endpoint: URL,
                                  for type: T.Type,
                                  completion: @escaping ((Result<T, NetworkError>) -> Void)) {
        let json: [String: Any] = [ "base": "EUR",
                                    "date": "2018-09-06",
                                    "rates": [
                                        "AUD": TestData.rateValue0,
                                        "BGN": TestData.rateValue1,
                                        "BRL": TestData.rateValue2]
        ]
        completion(.success(try! JSONDecoder().decode(T.self, from: data(from: json))))
    }
    //swiftlint:enable force_try

    private func data(from dic: Any) -> Data {
        do {
            return try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        } catch {
            return Data()
        }
    }
}

private class NetworkFailureStub: NetworkClient {

    func performGet<T: Decodable>(endpoint: URL,
                                  for type: T.Type,
                                  completion: @escaping ((Result<T, NetworkError>) -> Void)) {
        completion(.failure(.unknown))
    }
}
