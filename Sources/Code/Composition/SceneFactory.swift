//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import UIKit

struct SceneFactory {

    private let appStore: AppStore
    init(appStore: AppStore) {
        self.appStore = appStore
    }

    func makeCurrencyScene() -> UIViewController {
        let controller = CurrencyController(appStore: appStore,
                                            viewStateConverter: CurrencyControllerViewStateConverter())
        return controller
    }
}
