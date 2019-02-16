//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import XCTest
@testable import Currencies

class ApiCurrencyConverterTests: XCTestCase {

    func testConversionWithValidCurrenciesAndFilteringUnexisting() {
        // Given
        let response = CurrencyResponse(base: "MXN",
                                        date: "",
                                        rates: ["TRY": TestData.rateValue0,
                                                "RUB": TestData.rateValue1,
                                                "nonexisting": TestData.rateValue2])
        // When
        let converted = ApiCurrencyConverter().convert(response: response)
        // Then
        let expected = CurrencyMap(base: .mxn,
                                     rates: [.init(kind: .try,
                                                   value: TestData.rateValue0),
                                             .init(kind: .rub,
                                                   value: TestData.rateValue1)])

        XCTAssertEqual(expected, converted)
    }

    func testWhenBaseCurrencyNonExistsThenResultWouldBeEmpty() {
        // Given
        let response = CurrencyResponse(base: "Nonexisting",
                                        date: "",
                                        rates: ["TRY": TestData.rateValue0])
        // When
        let converted = ApiCurrencyConverter().convert(response: response)
        // Then
        XCTAssertNil(converted)
    }
}
