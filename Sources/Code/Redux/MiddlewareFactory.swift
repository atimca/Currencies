//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import ReSwift

struct MiddlewareFactory {

    private let downloadService: CurrencyDownloadServie

    init(downloadService: CurrencyDownloadServie) {
        self.downloadService = downloadService
    }

    private func basedCurrency(for action: Action,
                               in context: MiddlewareContext<AppState>) -> Currency? {
        switch action {

        case let selectAction as NewBaseCurrencySelected:
            return selectAction.newValue

        case let currenciesAction as CurrenciesAction:
            guard case .fetch = currenciesAction else { return nil }
            return context.state?.lastCurrencyMap?.base ?? .eur

        default:
            return nil
        }
    }

    func makeDownloadMiddleware() -> SimpleMiddleware<AppState> {
        return { action, context in

            guard let currency = self.basedCurrency(for: action, in: context) else {
                return action
            }

            self.downloadService.fetchCurrencies(basedOn: currency) {
                context.dispatch(CurrenciesAction.set(.loaded($0)))
            }

            if action is NewBaseCurrencySelected {
                return action
            }

            return CurrenciesAction.set(.loading)
        }
    }

    func makeLoginMiddleware() -> SimpleMiddleware<AppState> {
        return { action, _ in
            print(action)
            return action
        }
    }

    /// Creates a middleware function using SimpleMiddleware to create a ReSwift Middleware function.
    func createMiddleware<State: StateType>(_ middleware: @escaping SimpleMiddleware<State>) -> Middleware<State> {

        return { dispatch, getState in
            return { next in
                return { action in

                    let context = MiddlewareContext(dispatch: dispatch, getState: getState, next: next)
                    if let newAction = middleware(action, context) {
                        next(newAction)
                    }
                }
            }
        }
    }
}
