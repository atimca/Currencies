//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import XCTest
@testable import Currencies

class AppReducerTests: XCTestCase {

    var reducer = ReducerFactory.make()

    func test_CurrenciesActionSuccess_LastvaluesShouldBeChanged() {
        // Given
        let values = CurrencyMap(base: TestData.currency,
                                 rates: [])
        let action = CurrenciesAction.set(.loaded(.success(values)))
        // When
        let newState = reducer(action, nil)
        // Then
        XCTAssertEqual(newState.lastCurrencyMap, values)
    }

    func test_NewCurrencySelected_MutateAppStateWithNewMultiplier() {
        // Given
        let values = CurrencyMap(base: TestData.currency,
                                 rates: [.init(kind: TestData.currency0, value: TestData.rateValue0)])

        let load = CurrenciesAction.set(.loaded(.success(values)))
        let multiplier = MultiplierChanged(newValue: TestData.multiplier)
        let selection = NewBaseCurrencySelected(newValue: TestData.currency0)

        // When
        let newState = reducer(selection, reducer(multiplier, reducer(load, nil)))

        // Then
        XCTAssertEqual(newState.multiplier, TestData.rateValue0 * TestData.multiplier)
    }

    func test_NewCurrecySelected_ProduceNewRatesForTheLastCurrencyMap() {
        // Given
        let values = CurrencyMap(base: TestData.currency,
                                 rates: [.init(kind: TestData.currency0, value: TestData.rateValue0),
                                         .init(kind: TestData.currency1, value: TestData.rateValue1)])

        let load = CurrenciesAction.set(.loaded(.success(values)))
        let selection = NewBaseCurrencySelected(newValue: TestData.currency0)

        // When
        let newState = reducer(selection, reducer(load, nil))

        // Then
        XCTAssertEqual(Set(newState.lastCurrencyMap?.rates.map { $0.value } ?? []),
                       Set([1 / TestData.rateValue0,
                            TestData.rateValue1 / TestData.rateValue0]))
    }

    func testIf_NewCurrencySelectedOnTheBaseCurrency_AppStateShouldntChange() {
        // Given
        let values = CurrencyMap(base: TestData.currency,
                                 rates: [])

        let load = CurrenciesAction.set(.loaded(.success(values)))
        let selection = NewBaseCurrencySelected(newValue: TestData.currency)

        // When
        let loadedState = reducer(load, nil)
        let newState = reducer(selection, loadedState)

        // Then
        XCTAssertEqual(loadedState, newState)
    }

    func testIf_MultiplierChanged_NewAppStateWillContainsThisValue() {
        // Given
        let action = MultiplierChanged(newValue: TestData.multiplier)
        // When
        let newState = reducer(action, AppState.initial)
        // Then
        XCTAssertEqual(newState.multiplier, TestData.multiplier)
    }
}
