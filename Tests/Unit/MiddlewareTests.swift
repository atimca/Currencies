//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

@testable import Currencies
import ReSwift
import XCTest

class MiddlewareTests: XCTestCase {

    private let downloadService = CurrencyDownloadServiceMock()
    var middleware: SimpleMiddleware<AppState>!
    var context: MiddlewareContext<AppState>!

    override func setUp() {
        super.setUp()
        middleware = MiddlewareFactory(downloadService: downloadService)
            .makeDownloadMiddleware()
        context = MiddlewareContext<AppState>(dispatch: { _  in },
                                              getState: { nil },
                                              next: { _ in })
    }

    func testThatAfterFetchActionMiddlewareReturnsLoading() {
        // When
        let action = middleware(CurrenciesAction.fetch, context)
        // Then
        XCTAssertEqual(action as? CurrenciesAction, CurrenciesAction.set(.loading))
    }

    func testThatMiddlewareEmitsLoadedWithResultFromService() {
        // Given
        let exp = expectation(description: "EmitsLoaded")

        let dispatch: DispatchFunction = { action in
            // Then
            XCTAssertEqual(action as? CurrenciesAction,
                           CurrenciesAction.set(.loaded(.failure(.unknown))))
            exp.fulfill()
        }

        let context = MiddlewareContext<AppState>(dispatch: dispatch,
                                                  getState: { nil },
                                                  next: { _ in })
        // When
        _ = middleware(CurrenciesAction.fetch, context)
        wait(for: [exp], timeout: 3)
    }

    func testThatMiddlewareEmitsLoadedMoreThanOnceIfServiceCompleMoreThanOnece() {
        // Given
        let exp = expectation(description: "EmitsLoaded")
        downloadService.completionCount = 3
        var dispatchCounter = 0

        let dispatch: DispatchFunction = { action in
            // Then
            dispatchCounter += 1
            if dispatchCounter == 3 {
                exp.fulfill()
            }
        }

        let context = MiddlewareContext<AppState>(dispatch: dispatch,
                                                  getState: { nil },
                                                  next: { _ in })
        // When
        _ = middleware(CurrenciesAction.fetch, context)
        wait(for: [exp], timeout: 3)
    }

    func testThatMiddlewareTakesBasedCurrencyFromAppState() {
        // Given
        var appState = AppState.initial
        appState.lastCurrencyMap = CurrencyMap(base: TestData.currency, rates: [])
        let context = MiddlewareContext<AppState>(dispatch: { _ in },
                                                  getState: { appState },
                                                  next: { _ in })

        // When
        _ = middleware(CurrenciesAction.fetch, context)
        // Then
        XCTAssertEqual(downloadService.invocations, [.fetchCurrencies(currency: TestData.currency)])
    }

    func testThatDefaultCurrencyIsEur() {
        // Given
        let context = MiddlewareContext<AppState>(dispatch: { _ in },
                                                  getState: { nil },
                                                  next: { _ in })
        // When
        _ = middleware(CurrenciesAction.fetch, context)
        // Then
        XCTAssertEqual(downloadService.invocations, [.fetchCurrencies(currency: .eur)])
    }

    func testWhenBaseCurrencyChangedMiddlewareSendAnotherRequestToService() {
        // Given
        var appState = AppState.initial
        appState.lastCurrencyMap = CurrencyMap(base: TestData.currency, rates: [])
        let context = MiddlewareContext<AppState>(dispatch: { _ in },
                                                  getState: { appState },
                                                  next: { _ in })
        // When
        _ = middleware(CurrenciesAction.fetch, context)
        _ = middleware(NewBaseCurrencySelected(newValue: TestData.currency0), context)
        // Then
        XCTAssertEqual(downloadService.invocations, [.fetchCurrencies(currency: TestData.currency),
                                                     .fetchCurrencies(currency: TestData.currency0)])
    }

    func testWhenNewBaseComesMiddlewareReturnOldAction() {
        // When
        let baseAction = NewBaseCurrencySelected(newValue: TestData.currency)
        let middlewareAction = middleware(baseAction, context)
        // Then
        XCTAssertEqual(middlewareAction as? NewBaseCurrencySelected, baseAction)
    }
}
