//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import ReSwift

typealias AppReducer = (Action, AppState?) -> AppState

enum ReducerFactory {

    static func make() -> AppReducer {

        return { action, state -> AppState in
            var mutatedState = state ?? AppState.initial

            switch action {
            case let changedMultiplierAction as MultiplierChanged:
                mutatedState.multiplier = changedMultiplierAction.newValue

            case let changedBaseAction as NewBaseCurrencySelected:
                mutatedState = reduce(action: changedBaseAction, state: mutatedState)

            case let currenciesAction as CurrenciesAction:
                mutatedState = reduce(action: currenciesAction, state: mutatedState)

            default:
                break
            }

            return mutatedState
        }
    }

    private static func reduce(action: CurrenciesAction, state: AppState) -> AppState {
        var mutatedState = state

        switch action {
        case .fetch:
            break
        case .set(let downloadState):
            if
                case .loaded(let result) = downloadState,
                let map = result.value {
                mutatedState.lastCurrencyMap = map
            }
            mutatedState.currencyDownloadState = downloadState
        }

        return mutatedState
    }

    private static func reduce(action: NewBaseCurrencySelected, state: AppState) -> AppState {
        var mutatedState = state

        guard action.newValue != mutatedState.lastCurrencyMap?.base else {
            return mutatedState
        }

        guard
            let lastMap = mutatedState.lastCurrencyMap,
            let selectedCurrencyRate = lastMap
                .rates
                .first(where: { $0.kind == action.newValue }) else {
                    assertionFailure("State is not valid")
                    return mutatedState
        }

        let newRates = ratesWithRecalculatedValues(lastMap: lastMap,
                                                   selectedCurrencyRate: selectedCurrencyRate)
        mutatedState.lastCurrencyMap = CurrencyMap(base: action.newValue,
                                                   rates: newRates)

        mutatedState.multiplier = selectedCurrencyRate.value * mutatedState.multiplier

        return mutatedState
    }

    private static func ratesWithRecalculatedValues(lastMap: CurrencyMap,
                                                    selectedCurrencyRate: CurrencyMap.Rate) -> Set<CurrencyMap.Rate> {

        var newRates = lastMap.rates
        newRates.remove(.init(kind: selectedCurrencyRate.kind,
                              value: selectedCurrencyRate.value))
        newRates.insert(.init(kind: lastMap.base, value: 1))
        newRates = Set(newRates.map {
            CurrencyMap.Rate(kind: $0.kind, value: $0.value / selectedCurrencyRate.value)
        })

        return newRates
    }
}
