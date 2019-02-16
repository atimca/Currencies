//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import ReSwift
import UIKit

class CurrencyController: UITableViewController {

    private var isAnimating = false
    private var viewState = ViewState.initial

    private let viewStateConverter: CurrencyControllerViewStateConverter
    private let appStore: AppStore

    init(appStore: AppStore,
         viewStateConverter: CurrencyControllerViewStateConverter) {
        self.appStore = appStore
        self.viewStateConverter = viewStateConverter
        super.init(nibName: nil, bundle: nil)
        appStore.subscribe(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Life Cycle
extension CurrencyController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = Constants.Table.background
        tableView.separatorStyle = .none
        tableView.rowHeight = Constants.Table.rowHeight
        tableView.register(CurrencyCell.self,
                           forCellReuseIdentifier: CurrencyCell.identifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appStore.subscribe(self)
        appStore.dispatch(CurrenciesAction.fetch)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appStore.unsubscribe(self)
    }
}

// MARK: - UITableViewDataSource
extension CurrencyController {
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return viewState.table.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyCell.identifier,
                                                       for: indexPath) as? CurrencyCell else {
                                                        assertionFailure()
                                                        return UITableViewCell()
        }

        cell.render(state: viewState.table[indexPath.row])
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CurrencyController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard
            let cell = tableView.cellForRow(at: indexPath) as? CurrencyCell,
            let currency = cell.info?.base as? Currency else {
                assertionFailure()
                return
        }

        isAnimating = true
        tableView.performBatchUpdates({

            tableView.moveRow(at: indexPath, to: IndexPath.zero)

        }, completion: { [weak self] _ in
            guard let self = self else { return }

            cell.makeTextFieldFirstResponder()
            self.appStore.dispatch(NewBaseCurrencySelected(newValue: currency))

            let selectedWontBeVisibleAfterScrolling =
                tableView.indexPathsForVisibleRows?.contains(IndexPath.zero) == false

            if selectedWontBeVisibleAfterScrolling {
                tableView.scrollToRow(at: IndexPath.zero, at: .top, animated: true)
                return
            }
            self.isAnimating = false
        })

    }
}

// MARK: - UIScrollViewDelegate
extension CurrencyController {
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let afterTopScrolling = isAnimating
        if afterTopScrolling {
            let cell = tableView.cellForRow(at: IndexPath.zero) as? CurrencyCell
            cell?.makeTextFieldFirstResponder()
        }
        isAnimating = false
    }
}

// MARK: - StoreSubscriber
extension CurrencyController: StoreSubscriber {
    func newState(state: AppState) {
        render(state: viewStateConverter
            .convert(state: state,
                     previousState: viewState))
    }
}

// MARK: - CurrencyCellDelegate
extension CurrencyController: CurrencyCellDelegate {
    func textDidChanged(on text: String?, for cell: AnyHashable) {
        guard let text = text else { return }
        appStore.dispatch(MultiplierChanged(newValue: Decimal(string: text) ?? 0))
    }
}

// MARK: - DataDriven
extension CurrencyController: DataDriven {
    struct ViewState: Equatable {

        //swiftlint:disable nesting
        struct ErrorMessage: Equatable {
            let title: String
            let text: String
        }
        //swiftlint:enable nesting

        let table: [CurrencyCell.ViewState]
        let errorMessage: ErrorMessage?

        static let initial = ViewState(table: [], errorMessage: nil)
    }

    private func softUpdate() {
        let states = tableView.indexPathsForVisibleRows?.map { viewState.table[$0.row].field } ?? []
        tableView.visibleCells.compactMap { $0 as? CurrencyCell }
            .enumerated().forEach { index, cell in
                if index != 0 {
                    cell.update(field: states[index])
                }
        }
    }

    func render(state: ViewState) {

        if handleErrorIfNeeded(state: state) {
            return
        }

        let oldCurrencies = Set(viewState.table.map { $0.info })
        let newCurrencies = Set(state.table.map { $0.info })

        let firstRender = viewState == ViewState.initial
        let currenciesListChanged = oldCurrencies != newCurrencies
        viewState = state

        if firstRender || currenciesListChanged {
            tableView.reloadData()
            return
        }

        let isSomethingGoingOn = isAnimating &&
            tableView.isDragging &&
            tableView.isDecelerating &&
            tableView.isTracking
        if !isSomethingGoingOn {
            softUpdate()
        }
    }

    private func handleErrorIfNeeded(state: ViewState) -> Bool {
        guard let error = state.errorMessage else {
            return false
        }
        viewState = state
        let alert = UIAlertController(title: error.title,
                                      message: error.text,
                                      preferredStyle: .alert)
        alert.addAction(.init(title: L10n.ErrorMessage.ok, style: .cancel, handler: nil))
        show(alert, sender: nil)
        return true
    }
}

//swiftlint:disable nesting
private extension CurrencyController {
    enum Constants {
        enum Table {
            static let rowHeight: CGFloat = 60
            static let background = Colors.black
        }
    }
}
//swiftlint:enable nesting

private extension IndexPath {
    static let zero = IndexPath(row: 0, section: 0)
}
