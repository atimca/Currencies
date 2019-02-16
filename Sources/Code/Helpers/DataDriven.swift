//
//  Copyright © 2018 Tutu.tu. All rights reserved.
//

//swiftlint:disable type_name
/// Generic Data-driven протокол.
public protocol DataDriven {
    /// Тип стейта.
    associatedtype S
    /// Рендер стейта.
    ///
    /// - Parameter state: стейт
    func render(state: S)
}
