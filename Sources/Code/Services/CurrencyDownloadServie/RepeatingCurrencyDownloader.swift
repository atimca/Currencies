//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

class RepeatingCurrencyDownloader {

    private let downloadService: CurrencyDownloadServie
    private let repeatingTimerFactory: RepeatingTimerFactory
    private var timer: RepeatingTimer?
    private var wasFetched = true

    public init(downloadService: CurrencyDownloadServie,
                repeatingTimerFactory: RepeatingTimerFactory) {
        self.downloadService = downloadService
        self.repeatingTimerFactory = repeatingTimerFactory
    }
}

// MARK: - CurrencyDownloadServie
extension RepeatingCurrencyDownloader: CurrencyDownloadServie {
    func fetchCurrencies(basedOn currency: Currency,
                         completion: @escaping (CurrencyDownloadResult) -> Void) {
        timer = repeatingTimerFactory.makeRepeatingTimer(timeInterval: 1) {
            self.downloadService.fetchCurrencies(basedOn: currency, completion: completion)
        }
        timer?.go()
    }
}
