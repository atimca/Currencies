//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import XCTest
@testable import Currencies

class NetworkClientIntegrationTests: XCTestCase {

    func testClient() {
        // Given
        let exp = expectation(description: "network test")
        // When
        CurrenciesNetworkClient()
            .performGet(endpoint: URL(string: "https://revolut.duckdns.org/latest?base=EUR")!,
                        for: CurrencyResponse.self) { result in
                            // Then
                            XCTAssertNotNil(result.value)
                            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)
    }
}
