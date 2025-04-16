import UIKit

// MARK: - Constants

private enum Constants {
    static let containerHeight: CGFloat = 48
    static let checkboxSideLength: CGFloat = 24
    static let horizontalPadding: CGFloat = 12
    static let verticalMargin: CGFloat = 12
    static let cornerRadius: CGFloat = 12
    static let borderWidth: CGFloat = 2
    static let layoutMargins = UIEdgeInsets(top: verticalMargin, left: 16, bottom: verticalMargin, right: 16)
    static let fontSize: CGFloat = 17
    static let lineHeight: CGFloat = 23
    static let kerning: CGFloat = -0.44
    static let animationDuration: CFTimeInterval = 0.2
}

// MARK: - SelectionView

class SelectionView: UIView {

    // MARK: - UI Elements

    private let stackView = UIStackView()
    private let label = UILabel()
    private let checkboxImageView = UIImageView()

    // MARK: - Resources

    private let checkedImage = UIImage(named: "checkbox_selected")
    private let uncheckedImage = UIImage(named: "checkbox_unselected")

    // MARK: - State

    private var isChecked: Bool = false {
        didSet { animateSelectionChange() }
    }

    var onTap: (() -> Void)?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        setupStackView()
        setupCheckbox()
        setupLabel()
        setupGesture()
        updateAppearance()
    }

    private func setupStackView() {
        stackView.axis = .horizontal
        stackView.spacing = Constants.horizontalPadding
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = Constants.layoutMargins
        stackView.layer.cornerRadius = Constants.cornerRadius
        stackView.layer.borderWidth = Constants.borderWidth
        stackView.backgroundColor = UIColor(named: "contextual_quaternary")
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupCheckbox() {
        checkboxImageView.translatesAutoresizingMaskIntoConstraints = false
        checkboxImageView.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([
            checkboxImageView.widthAnchor.constraint(equalToConstant: Constants.checkboxSideLength),
            checkboxImageView.heightAnchor.constraint(equalToConstant: Constants.checkboxSideLength)
        ])

        stackView.addArrangedSubview(checkboxImageView)
    }

    private func setupLabel() {
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: Constants.fontSize, weight: .regular)
        label.textColor = .white

        stackView.addArrangedSubview(label)
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    // MARK: - Interaction

    @objc private func handleTap() {
        onTap?()
    }

    // MARK: - Public API

    /// Configures the checkbox state and label text.
    func configure(isChecked: Bool, text: String) {
        self.isChecked = isChecked
        setLabel(text)
    }

    // MARK: - Appearance

    private func setLabel(_ text: String) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = Constants.lineHeight
        paragraph.maximumLineHeight = Constants.lineHeight

        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttributes([
            .kern: Constants.kerning,
            .paragraphStyle: paragraph
        ], range: NSRange(location: 0, length: attrString.length))

        label.attributedText = attrString
    }

    private func updateAppearance() {
        checkboxImageView.image = isChecked ? checkedImage : uncheckedImage
        stackView.layer.borderColor = isChecked
            ? UIColor(named: "contextual_tint")?.cgColor
            : UIColor.clear.cgColor
    }

    // MARK: - Animation

    /// Animates checkbox image and border color when selection state changes.
    private func animateSelectionChange() {
        let toColor = isChecked
            ? UIColor(named: "contextual_tint")?.cgColor ?? UIColor.systemBlue.cgColor
            : UIColor.clear.cgColor

        let borderAnimation = CABasicAnimation(keyPath: "borderColor")
        borderAnimation.fromValue = stackView.layer.borderColor
        borderAnimation.toValue = toColor
        borderAnimation.duration = Constants.animationDuration

        stackView.layer.add(borderAnimation, forKey: "borderColor")
        stackView.layer.borderColor = toColor

        UIView.transition(
            with: checkboxImageView,
            duration: Constants.animationDuration,
            options: .transitionCrossDissolve,
            animations: {
                self.checkboxImageView.image = self.isChecked ? self.checkedImage : self.uncheckedImage
            }
        )
    }
}
