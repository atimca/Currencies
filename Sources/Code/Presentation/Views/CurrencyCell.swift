//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import UIKit

protocol CurrencyCellDelegate: class {
    func textDidChanged(on text: String?, for cell: AnyHashable)
}

class CurrencyCell: UITableViewCell {

    static let identifier = String(describing: CurrencyCell.self)

    // MARK: - UI

    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.Currency.color
        label.font = Constants.Currency.font
        return label
    }()

    private let inputField: UITextField = {

        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.borderStyle = .none
        field.textColor = Constants.TextField.color
        field.tintColor = Constants.TextField.tintColor
        field.font = Constants.TextField.font
        field.keyboardType = .decimalPad
        field.isUserInteractionEnabled = false

        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = Constants.TextField.color
        field.addSubview(borderView)

        NSLayoutConstraint.activate([
            borderView.heightAnchor.constraint(equalToConstant: 1),
            borderView.topAnchor.constraint(equalTo: field.bottomAnchor),
            borderView.leadingAnchor.constraint(equalTo: field.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: field.trailingAnchor)
            ])
        return field
    }()

    // MARK: - Variables

    var info: AnyHashable?
    weak var delegate: CurrencyCellDelegate?
    var isFieldResponder: Bool {
        return inputField.isFirstResponder
    }

    // MARK: - Init

    override func prepareForReuse() {
        super.prepareForReuse()
        inputField.text = nil
        currencyLabel.text = nil
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        contentView.addSubview(currencyLabel)
        NSLayoutConstraint.activate([
            currencyLabel
                .leadingAnchor
                .constraint(equalTo: leadingAnchor,
                            constant: Constants.Currency.leading),
            currencyLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])

        contentView.addSubview(inputField)
        inputField.addTarget(self,
                             action: #selector(replaceCommaToDots(textField:)),
                             for: .editingChanged)
        inputField.addTarget(self,
                             action: #selector(textDidChange(textField:)),
                             for: .editingChanged)
        inputField.delegate = self
        NSLayoutConstraint.activate([
            inputField
                .leadingAnchor
                .constraint(greaterThanOrEqualTo: currencyLabel.trailingAnchor,
                            constant: Constants.TextField.leading),
            inputField
                .trailingAnchor
                .constraint(equalTo: trailingAnchor,
                            constant: Constants.TextField.trailing),
            inputField
                .centerYAnchor
                .constraint(equalTo: centerYAnchor)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - DataDriven
extension CurrencyCell: DataDriven {
    struct ViewState: Equatable {
        let currency: String?
        let field: String?
        let info: AnyHashable
    }

    func render(state: ViewState) {
        currencyLabel.text = state.currency
        inputField.text = state.field
        info = state.info
    }

    func update(field: String?) {
        inputField.text = field
        inputField.isUserInteractionEnabled = false
    }
}

// MARK: - Events
extension CurrencyCell {
    @objc private func replaceCommaToDots(textField: UITextField) {
        textField.text = textField.text?.replacingOccurrences(of: ",", with: ".")
    }

    @objc private func textDidChange(textField: UITextField) {
        guard let info = info, let delegate = delegate else { return }
        delegate.textDidChanged(on: textField.text, for: info)
    }

    func makeTextFieldFirstResponder() {
        inputField.isUserInteractionEnabled = true
        inputField.becomeFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension CurrencyCell: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        let currentText = textField.text ?? ""
        let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return Double(replacementText.replacingOccurrences(of: ",", with: ".")) != nil
    }
}

//swiftlint:disable nesting
private extension CurrencyCell {
    enum Constants {
        enum Currency {
            static let color = Colors.white
            static let font = UIFont.systemFont(ofSize: fontSize, weight: .heavy)
            static let fontSize: CGFloat = 36
            static let leading: CGFloat = 16
        }
        enum TextField {
            static let color = Colors.white
            static let font = UIFont.systemFont(ofSize: fontSize)
            static let fontSize: CGFloat = 20
            static let tintColor = Colors.gray
            static let trailing: CGFloat = -16
            static let leading: CGFloat = 16
        }
    }
}
//swiftlint:enable nesting
