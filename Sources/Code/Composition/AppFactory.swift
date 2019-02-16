//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

struct AppFactory {
    let sceneFactory: SceneFactory
    let appStoreFactory: AppStoreFactory

    init() {

        let middlewareFactory = MiddlewareFactory(downloadService: ServiceFactory().makeCurrencyDownloadService())

        let download = middlewareFactory.createMiddleware(middlewareFactory.makeDownloadMiddleware())
        let log = middlewareFactory.createMiddleware(middlewareFactory.makeLoginMiddleware())

        appStoreFactory = AppStoreFactory(middlewares: [download, log],
                                          initialState: AppState.initial,
                                          reducer: ReducerFactory.make())

        sceneFactory = SceneFactory(appStore: appStoreFactory.make())
    }
}
