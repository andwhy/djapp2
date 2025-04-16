import UIKit

struct SelectionViewConstants {
    static let containerHeight: CGFloat = 48
    static let checkboxSideLength: CGFloat = 24
    static let horizontalPadding: CGFloat = 12
    static let verticalMargin: CGFloat = 12
    static let cornerRadius: CGFloat = 12
    static let borderWidth: CGFloat = 2
}

class SelectionView: UIView {
    
    private let stackView = UIStackView()
    private let label = UILabel()
    private let checkboxImageView = UIImageView()

    private var checkedImage = UIImage(named: "checkbox_selected")
    private var uncheckedImage = UIImage(named: "checkbox_unselected")

    private var isChecked: Bool = false {
        didSet {
            animateSelectionChange()
        }
    }

    var onTap: (() -> Void)?

    // MARK: - Init

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
        stackView.spacing = SelectionViewConstants.horizontalPadding
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(
            top: SelectionViewConstants.verticalMargin,
            left: 16,
            bottom: SelectionViewConstants.verticalMargin,
            right: 16
        )
        stackView.layer.cornerRadius = SelectionViewConstants.cornerRadius
        stackView.layer.borderWidth = SelectionViewConstants.borderWidth
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
            checkboxImageView.widthAnchor.constraint(equalToConstant: SelectionViewConstants.checkboxSideLength),
            checkboxImageView.heightAnchor.constraint(equalToConstant: SelectionViewConstants.checkboxSideLength)
        ])
        stackView.addArrangedSubview(checkboxImageView)
    }

    private func setupLabel() {
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .white
        stackView.addArrangedSubview(label)
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    // MARK: - Actions

    @objc private func handleTap() {
        onTap?()
    }

    // MARK: - Configuration

    func configure(isChecked: Bool, text: String) {
        self.isChecked = isChecked
        setLabel(text)
    }

    private func setLabel(_ text: String) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 23
        paragraph.maximumLineHeight = 23

        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttributes([
            .kern: -0.44,
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
    
    private func animateSelectionChange() {
         // Animate border color
         let toColor = isChecked
             ? UIColor(named: "contextual_tint")?.cgColor ?? UIColor.systemBlue.cgColor
             : UIColor.clear.cgColor

         let borderAnimation = CABasicAnimation(keyPath: "borderColor")
         borderAnimation.fromValue = stackView.layer.borderColor
         borderAnimation.toValue = toColor
         borderAnimation.duration = 0.20
         stackView.layer.add(borderAnimation, forKey: "borderColor")
         stackView.layer.borderColor = toColor

         // Animate checkbox image change (fade transition)
         UIView.transition(with: checkboxImageView,
                           duration: 0.20,
                           options: .transitionCrossDissolve,
                           animations: {
             self.checkboxImageView.image = self.isChecked ? self.checkedImage : self.uncheckedImage
         })
     }
}
