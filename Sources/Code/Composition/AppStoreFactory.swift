//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import ReSwift

typealias AppStore = Store<AppState>

class AppStoreFactory {

    private let middlewares: [Middleware<AppState>]
    private let initialState: AppState
    private let reducer: AppReducer

    init(middlewares: [Middleware<AppState>],
         initialState: AppState,
         reducer: @escaping Reducer<AppState>) {
        self.middlewares = middlewares
        self.initialState = initialState
        self.reducer = reducer
    }

    private var appStore: AppStore?
    func make() -> AppStore {
        if let appStore = appStore {
            return appStore
        }

        appStore = AppStore(reducer: reducer,
                            state: nil,
                            middleware: middlewares)

        return appStore!
    }
}
