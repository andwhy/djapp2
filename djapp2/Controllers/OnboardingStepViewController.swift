import UIKit

class OnboardingStepViewController: UIViewController {
    let step: OnboardingStep
    var onNext: (() -> Void)?
    var onSkillSelected: ((DJSkillLevel) -> Void)?
    
    weak var parentPageViewController: OnboardingPageViewController?
    private var selectionView: SelectionListView?
    private var emojiFinaleLabel: UILabel?

    
    init(step: OnboardingStep) {
        self.step = step
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        switch step {
        case .welcome:
            configureWelcome()
        case .mixMusic:
            configureMixMusic()
        case .selectSkill:
            configureSkillSelection()
        case .finale:
            configureFinale()
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
    
    private func configureWelcome() {
        // Centered logo
        let logo = UIImageView()
        logo.image = UIImage(named: "djay_logo")
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.setContentHuggingPriority(.defaultLow, for: .vertical)
        logo.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        logo.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true

        let centeredStack = CenteredStackView(arrangedSubviews: [logo])
        centeredStack.translatesAutoresizingMaskIntoConstraints = false

        // Description label
        let description = UILabel.subtitle("Welcome to djay")

        // Button
        let button = makeNextButton(text: "Continue", action: #selector(nextTapped))
        button.translatesAutoresizingMaskIntoConstraints = false

        // Outer stack
        let stack = UIStackView(arrangedSubviews: [centeredStack, description, button])
        stack.axis = .vertical
        stack.spacing = 24
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }



    private func configureMixMusic() {
        // Views
        let logo = UIImageView()
        logo.image = UIImage(named: "djay_logo")
        logo.contentMode = .scaleAspectFit

        let hero = UIImageView()
        hero.image = UIImage(named: "hero")
        hero.contentMode = .scaleAspectFit

        let description = UILabel.heading("Mix Your Favorite Music")

        let ada = UIImageView()
        ada.image = UIImage(named: "ada")
        ada.contentMode = .scaleAspectFit

        // Content stack
        let contentStack = CenteredStackView()
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.stackView.spacing = 32
        contentStack.stackView.addArrangedSubview(logo)
        contentStack.stackView.addArrangedSubview(hero)
        contentStack.stackView.addArrangedSubview(description)
        contentStack.stackView.addArrangedSubview(ada)

        // Scroll setup
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let scrollContainer = UIView()
        scrollContainer.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(scrollContainer)
        scrollContainer.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            scrollContainer.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor), // 💡 важно!

            contentStack.topAnchor.constraint(equalTo: scrollContainer.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollContainer.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor)
        ])


        // Button
        let button = makeNextButton(text: "Continue", action: #selector(nextTapped))
        button.translatesAutoresizingMaskIntoConstraints = false

        // Main layout
        let mainStack = UIStackView(arrangedSubviews: [scrollView, button])
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.spacing = 25
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            mainStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }


    private func configureSkillSelection() {
        // Views
        let logo = UIImageView()
        logo.image = UIImage(named: "head_with_earphones")
        logo.contentMode = .scaleAspectFit

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

        // Content stack inside scroll
        let contentStack = CenteredStackView(arrangedSubviews: [logo, heading, subtitle, selectionView])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.stackView.spacing = 40

        NSLayoutConstraint.activate([
            selectionView.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            selectionView.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor)
        ])

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let scrollContainer = UIView()
        scrollContainer.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(scrollContainer)
        scrollContainer.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollContainer.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollContainer.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor),
        ])

        // Button
        let button = makeNextButton(text: "Let’s go", action: #selector(nextTapped))
        button.translatesAutoresizingMaskIntoConstraints = false
        updateViewInteractions(isOptionSelected: selectionView.isOptionSelected, button: button)

        // Final layout
        let mainStack = UIStackView(arrangedSubviews: [scrollView, button])
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.spacing = 25
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            mainStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])

        selectionView.onSelectionChanged = { [weak self] _, _ in
            self?.updateViewInteractions(isOptionSelected: selectionView.isOptionSelected, button: button)
        }
    }

    
    private func updateViewInteractions(isOptionSelected: Bool, button: UIButton) {
        button.isEnabled = isOptionSelected
        button.layer.opacity = isOptionSelected ? 1 : 0.3
        
        (self.parent as? OnboardingPageViewController)?.reloadCurrentPage()
    }

    private func configureFinale() {
        // Emoji label with animation config
        let emoji = UILabel()
        emoji.text = "🎉"
        emoji.font = UIFont.systemFont(ofSize: 80)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        emoji.alpha = 0
        emoji.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        self.emojiFinaleLabel = emoji

        // Heading text
        let message = UILabel.heading("You're all set! Let’s DJ!")
        message.translatesAutoresizingMaskIntoConstraints = false

        // Content stack (centered)
        let contentStack = CenteredStackView(arrangedSubviews: [emoji, message])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.stackView.spacing = 25

        // Main stack (just content here, but scalable if you add button)
        let stack = UIStackView(arrangedSubviews: [contentStack])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 25
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32)
        ])
    }


    @objc private func nextTapped() {
        onNext?()
    }

    @objc private func skillTapped(_ sender: UIButton) {
        guard let level = DJSkillLevel.allCases.first(where: { $0.hashValue == sender.tag }) else { return }
        onSkillSelected?(level)
        onNext?()
    }
    
    private func makeDescriptionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(named: "contextual_primary")

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.minimumLineHeight = 22 // 100% от font-size
        paragraphStyle.maximumLineHeight = 22

        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont(name: "SFProDisplay-Regular", size: 22) ?? UIFont.systemFont(ofSize: 22),
                .kern: 0.44, // 2% от 22pt
                .paragraphStyle: paragraphStyle
            ]
        )

        label.attributedText = attributedText
        return label
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
}
