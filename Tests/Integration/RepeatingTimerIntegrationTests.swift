//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import XCTest
@testable import Currencies

class RepeatingTimerIntegrationTests: XCTestCase {

    func testTimer() {
        // Given
        let exp = expectation(description: "testTimer")
        var counter = 0
        // When
        var timer: RepeatingTimer? = DispatchTimer(timeInterval: 0.1) {
            counter += 1
        }
        timer?.go()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            timer = nil
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            // Then
            XCTAssertEqual(Float(counter), 6, accuracy: 2)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }
}
