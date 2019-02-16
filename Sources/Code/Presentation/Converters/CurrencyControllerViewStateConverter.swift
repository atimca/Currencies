//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import UIKit

struct CurrencyControllerViewStateConverter {

    func convert(state: AppState,
                 previousState: CurrencyController.ViewState) -> CurrencyController.ViewState {

        if let errorState = error(state: state, previousState: previousState) {
            return errorState
        }

        guard let value = state.lastCurrencyMap else { return .initial }
        let isFirstConversion = (previousState == CurrencyController.ViewState.initial)

        let ordering: [Currency?: Int]
        if !isFirstConversion {
            ordering = Dictionary(uniqueKeysWithValues: previousState
                .table
                .enumerated()
                .map { ($1.info.base as? Currency, $0) })
        } else {
            ordering = [:]
        }

        let table = value.rates
            .sorted {
                if isFirstConversion {
                    return sort($0, $1)
                }
                return sort($0, $1, basedOn: ordering)
            }
            .map {
                convert(currency: $0.kind, rate: state.multiplier * $0.value)
        }
        return CurrencyController.ViewState(table: [convert(currency: value.base,
                                                            rate: state.multiplier)] + table,
                                            errorMessage: nil)
    }

    private func sort(_ lhs: CurrencyMap.Rate, _ rhs: CurrencyMap.Rate) -> Bool {
        return lhs.kind.rawValue < rhs.kind.rawValue
    }

    private func sort(_ lhs: CurrencyMap.Rate,
                      _ rhs: CurrencyMap.Rate,
                      basedOn ordering: [Currency?: Int]) -> Bool {
        return ordering[lhs.kind] ?? 0 < ordering[rhs.kind] ?? 0
    }

    private func convert(currency: Currency, rate: Decimal) -> CurrencyCell.ViewState {
        return .init(currency: currency.rawValue.uppercased(),
                     field: String(format: "%.2f", Double("\(rate)")!),
                     info: currency)
    }

    private func error(state: AppState,
                       previousState: CurrencyController.ViewState) -> CurrencyController.ViewState? {
        guard
            state.lastCurrencyMap == nil,
            case .loaded(.failure) = state.currencyDownloadState else {
            return nil
        }

        return .init(table: previousState.table,
                     errorMessage: .init(title: L10n.ErrorMessage.title,
                                         text: L10n.ErrorMessage.text))
    }
}
