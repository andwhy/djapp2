import UIKit

class OnboardingStepViewController: UIViewController {
    // MARK: - Properties

    let step: OnboardingStep
    var onNext: (() -> Void)?
    var onSkillSelected: ((DJSkillLevel) -> Void)?

    weak var parentPageViewController: OnboardingPageViewController?
    private var selectionView: SelectionListView?
    private var emojiFinaleLabel: UILabel?

    private enum Constants {
        static let horizontalPadding: CGFloat = 32
        static let buttonHeight: CGFloat = 44
        static let spacing: CGFloat = 25
        static let logoMinHeight: CGFloat = 100
    }

    // MARK: - Init

    init(step: OnboardingStep) {
        self.step = step
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        switch step {
        case .welcome: configureWelcome()
        case .mixMusic: configureMixMusic()
        case .selectSkill: configureSkillSelection()
        case .finale: configureFinale()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if step == .finale {
            animateEmoji()
        }
    }

    var isStepCompleted: Bool {
        switch step {
        case .selectSkill:
            return selectionView?.isOptionSelected ?? false
        default:
            return true
        }
    }

    // MARK: - Setup Steps

    private func configureWelcome() {
        let logo = makeImageView(named: "djay_logo")
        logo.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.logoMinHeight).isActive = true

        let centeredStack = CenteredStackView(arrangedSubviews: [logo])
        centeredStack.translatesAutoresizingMaskIntoConstraints = false

        let description = UILabel.subtitle("Welcome to djay")
        let button = makeNextButton(text: "Continue", action: #selector(nextTapped))

        let stack = makeVerticalStack(views: [centeredStack, description, button])
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalPadding),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalPadding),
            button.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    private func configureMixMusic() {
        let logo = makeImageView(named: "djay_logo")
        let hero = makeImageView(named: "hero")
        let description = UILabel.heading("Mix Your Favorite Music")
        let ada = makeImageView(named: "ada")

        let contentStack = CenteredStackView(arrangedSubviews: [logo, hero, description, ada])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.stackView.spacing = 32

        let button = makeNextButton(text: "Continue", action: #selector(nextTapped))
        let mainStack = makeScrollableStack(content: contentStack, button: button)

        view.addSubview(mainStack)
        applyMainStackConstraints(mainStack, button: button)
    }

    private func configureSkillSelection() {
        let logo = makeImageView(named: "head_with_earphones")
        let heading = UILabel.heading("Welcome DJ")
        let subtitle = UILabel.subtitle("What's your DJ skill level?")
        subtitle.textColor = UIColor(named: "contextual_secondary")

        let selectionView = SelectionListView()
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        self.selectionView = selectionView
        selectionView.configureOptions([
            "I'm new to DJing",
            "I've used DJ apps before",
            "I'm a professional DJ"
        ])

        let contentStack = CenteredStackView(arrangedSubviews: [logo, heading, subtitle, selectionView])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.stackView.spacing = 40

        NSLayoutConstraint.activate([
            selectionView.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            selectionView.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor)
        ])

        let button = makeNextButton(text: "Let’s go", action: #selector(nextTapped))
        updateViewInteractions(isOptionSelected: selectionView.isOptionSelected, button: button)

        let mainStack = makeScrollableStack(content: contentStack, button: button)
        view.addSubview(mainStack)
        applyMainStackConstraints(mainStack, button: button)

        selectionView.onSelectionChanged = { [weak self] _, _ in
            self?.updateViewInteractions(isOptionSelected: selectionView.isOptionSelected, button: button)
        }
    }

    private func configureFinale() {
        let emoji = UILabel()
        emoji.text = "🎉"
        emoji.font = UIFont.systemFont(ofSize: 80)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        emoji.alpha = 0
        emoji.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        self.emojiFinaleLabel = emoji

        let message = UILabel.heading("You're all set! Let’s DJ!")
        message.translatesAutoresizingMaskIntoConstraints = false

        let contentStack = CenteredStackView(arrangedSubviews: [emoji, message])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.stackView.spacing = 25

        let stack = UIStackView(arrangedSubviews: [contentStack])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = Constants.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalPadding),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalPadding)
        ])
    }

    // MARK: - Helpers

    private func updateViewInteractions(isOptionSelected: Bool, button: UIButton) {
        button.isEnabled = isOptionSelected
        button.layer.opacity = isOptionSelected ? 1 : 0.3
        (self.parent as? OnboardingPageViewController)?.reloadCurrentPage()
    }

    private func animateEmoji() {
        guard let emojiLabel = emojiFinaleLabel else { return }
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: [.curveEaseOut],
                       animations: {
            emojiLabel.alpha = 1
            emojiLabel.transform = .identity
        }, completion: nil)
    }

    private func makeImageView(named: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: named)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private func makeNextButton(text: String, action: Selector?) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: 22)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.setTitleColor(UIColor(named: "contextual_primary"), for: .normal)
        button.backgroundColor = UIColor(named: "contextual_tint")

        if let action = action {
            button.addTarget(self, action: action, for: .touchUpInside)
        }
        return button
    }

    private func makeVerticalStack(views: [UIView]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = Constants.spacing
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    private func makeScrollableStack(content: UIView, button: UIButton) -> UIStackView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(container)
        container.addSubview(content)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: scrollView.topAnchor),
            container.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            container.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            container.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),

            content.topAnchor.constraint(equalTo: container.topAnchor),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        let mainStack = UIStackView(arrangedSubviews: [scrollView, button])
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.spacing = Constants.spacing
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        return mainStack
    }

    private func applyMainStackConstraints(_ stack: UIStackView, button: UIButton) {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalPadding),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalPadding),
            button.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    // MARK: - Actions

    @objc private func nextTapped() {
        onNext?()
    }
}
