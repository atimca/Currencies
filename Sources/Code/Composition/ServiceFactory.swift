//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import Foundation

protocol RepeatingTimerFactory {
    func makeRepeatingTimer(timeInterval: TimeInterval,
                            eventHandler: @escaping (() -> Void)) -> RepeatingTimer
}

struct ServiceFactory: RepeatingTimerFactory {

    func makeCurrencyDownloadService() -> CurrencyDownloadServie {
        let plainDownloader = CurrencyDownloader(client: CurrenciesNetworkClient(),
                                                 converter: ApiCurrencyConverter())
        return RepeatingCurrencyDownloader(downloadService: plainDownloader,
                                           repeatingTimerFactory: self)
    }

    func makeRepeatingTimer(timeInterval: TimeInterval,
                            eventHandler: @escaping (() -> Void)) -> RepeatingTimer {
        return DispatchTimer(timeInterval: timeInterval, eventHandler: eventHandler)
    }
}
