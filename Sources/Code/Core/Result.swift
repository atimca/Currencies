//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

enum Result<Value, ErrorType: Error> {
    case success(Value)
    case failure(ErrorType)
}

// MARK: - Equatable
extension Result: Equatable where Value: Equatable, ErrorType: Equatable {
    static func == (lhs: Result, rhs: Result) -> Bool {
        switch (lhs, rhs) {
        case (.success(let lhs), .success(let rhs)):
            return lhs == rhs
        case (.failure(let lhs), .failure(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension Result {
    var value: Value? {
        guard case .success(let value) = self else {
            return nil
        }
        return value
    }

    var error: ErrorType? {
        guard case .failure(let error) = self else {
            return nil
        }
        return error
    }
}
