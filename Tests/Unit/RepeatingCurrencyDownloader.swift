//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

@testable import Currencies
import XCTest

class RepeatingCurrencyDownloaderTests: XCTestCase {

    let serviceMock = CurrencyDownloadServiceMock()
    private let timerFactory = TimerFactory()
    var repeatingDownloader: CurrencyDownloadServie!

    override func setUp() {
        super.setUp()
        repeatingDownloader = RepeatingCurrencyDownloader(downloadService: serviceMock,
                                                          repeatingTimerFactory: timerFactory)
    }

    func testThatServiceMockWillInvokeSeveralTimersPerTimer() {
        // Given
        timerFactory.timerCount = 40
        let exp = expectation(description: "timer")
        var invocations: [CurrencyDownloadServiceMock.Invocation] = []

        // When
        repeatingDownloader.fetchCurrencies(basedOn: TestData.currency) { _ in
            invocations.append(.fetchCurrencies(currency: TestData.currency))
        }

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(self.serviceMock.invocations, invocations)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)
    }
}

private class TimerFactory: RepeatingTimerFactory {
    var timerCount = 1

    func makeRepeatingTimer(timeInterval: TimeInterval,
                            eventHandler: @escaping (() -> Void)) -> RepeatingTimer {
        let timer = TimerMock(timeInterval: timeInterval, eventHandler: eventHandler)
        timer.timerCount = timerCount
        return timer
    }
}

private class TimerMock: RepeatingTimer {

    var timerCount = 1
    let eventHandler: (() -> Void)

    required init(timeInterval: TimeInterval, eventHandler: @escaping (() -> Void)) {
        self.eventHandler = eventHandler
    }

    func go() {
        for _ in 0..<timerCount {
            eventHandler()
        }
    }
}
