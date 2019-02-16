//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import XCTest
@testable import Currencies

class ControllerViewStateConverterTests: XCTestCase {

    let converter = CurrencyControllerViewStateConverter()

    func testFirstConversionShouldBeSortedByCurrencyWithTheBaseCurrencyFirst() {
        // Given
        var appState = AppState.initial
        appState.lastCurrencyMap = .init(base: .cad,
                                         rates: [.init(kind: .thb, value: TestData.rateValue0),
                                                 .init(kind: .aud, value: TestData.rateValue1)])

        // When
        let converted = converter.convert(state: appState,
                                          previousState: .initial)

        let expected = [Currency.cad.rawValue.uppercased(),
                        Currency.aud.rawValue.uppercased(),
                        Currency.thb.rawValue.uppercased()]

        // Then
        XCTAssertEqual(expected, converted.table.compactMap { $0.currency })
    }

    func testThatRateForBaseCurrencyShouldBeEqualToMultiplierFromAppState() {
        // Given
        var appState = AppState.initial
        appState.lastCurrencyMap = CurrencyMap(base: TestData.currency1,
                                               rates: [])
        appState.multiplier = TestData.multiplier

        // When
        let converted = converter.convert(state: appState,
                                          previousState: .initial)

        // Then
        XCTAssertEqual(converted.table.first?.field, "\(TestData.multiplier)")
    }

    func testThatRateShouldBeRoundedByTwoLastDigitsAfterZero() {
        // Given
        var appState = AppState.initial
        appState.lastCurrencyMap = CurrencyMap(base: TestData.currency1,
                                               rates: [])
        appState.multiplier = 12.1234

        // When
        let converted = converter.convert(state: appState,
                                          previousState: .initial)

        // Then
        XCTAssertEqual(converted.table.first?.field, "12.12")
    }

    func testThatCellFieldValueShouldBeTakenByMultiplingMultiplierAndRate() {
        // Given
        var appState = AppState.initial
        appState.lastCurrencyMap = CurrencyMap(base: TestData.currency0,
                                               rates: [.init(kind: TestData.currency, value: 12.12)])
        appState.multiplier = 100

        // When
        let converted = converter.convert(state: appState,
                                          previousState: .initial)

        // Then
        XCTAssertEqual(converted.table.compactMap { $0.field }, ["100.00", "1212.00"])
    }

    func testThatCellInfoCalculatesFromMultipliedRateAndCurrencyType() {
        // Given
        var appState = AppState.initial
        appState.lastCurrencyMap = CurrencyMap(base: TestData.currency0,
                                               rates: [.init(kind: TestData.currency,
                                                             value: TestData.rateValue0)])
        appState.multiplier = TestData.multiplier

        // When
        let converted = converter.convert(state: appState,
                                          previousState: .initial)

        // Then
        XCTAssertEqual(converted.table.map { $0.info }, [TestData.currency0, TestData.currency])
    }

    func testThatIfConvertationStartedFromNonInitialPreviousStateSortShouldStay() {
        // Given
        var oldState = AppState.initial
        oldState.lastCurrencyMap = CurrencyMap(base: .eur,
                                               rates: [.init(kind: .bgn,
                                                             value: TestData.rateValue0),
                                                       .init(kind: .aud,
                                                             value: TestData.rateValue0),
                                                       .init(kind: .cad,
                                                             value: TestData.rateValue0)])

        var newState = AppState.initial
        newState.lastCurrencyMap = CurrencyMap(base: .bgn,
                                               rates: [.init(kind: .eur,
                                                             value: TestData.rateValue0),
                                                       .init(kind: .cad,
                                                             value: TestData.rateValue0),
                                                       .init(kind: .aud,
                                                             value: TestData.rateValue0)])

        // When
        let priviousState = converter.convert(state: oldState,
                                              previousState: .initial)
        let converted = converter.convert(state: newState,
                                          previousState: priviousState)

        // Then
        XCTAssertEqual(converted.table.map { $0.info }, [Currency.bgn, .eur, .aud, .cad])
    }

    func testThatIfAppStateContainsErrorAndNonLastMapThatViewStateWillContainErrorMessage() {
        // Given
        var appState = AppState.initial
        appState.lastCurrencyMap = nil
        appState.currencyDownloadState = .loaded(.failure(.unknown))

        // When
        let converted = converter.convert(state: appState,
                                          previousState: .initial)

        // Then
        XCTAssertEqual(converted.errorMessage, .init(title: L10n.ErrorMessage.title,
                                                     text: L10n.ErrorMessage.text))
    }

    func testWhenLastCurrencyMapNotNilThenWontBeErrorMessage() {
        // Given
        var appState = AppState.initial
        appState.lastCurrencyMap = CurrencyMap(base: TestData.currency,
                                               rates: [])
        appState.currencyDownloadState = .loaded(.failure(.unknown))

        // When
        let converted = converter.convert(state: appState,
                                          previousState: .initial)

        // Then
        XCTAssertNil(converted.errorMessage)
    }
}
