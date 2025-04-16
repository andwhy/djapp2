import UIKit

struct SelectionListViewOption {
    let title: String
    var isSelected: Bool
}

struct SelectionListViewConstants {
    static let stackSpacing: CGFloat = 12

    struct Colors {
        static let selectedBackground = UIColor.systemBlue
        static let unselectedBackground = UIColor.darkGray
        static let textColor = UIColor.white
        static let iconColor = UIColor.white
    }
}

class SelectionListView: UIView {
    
    private var options: [SelectionListViewOption] = []
    private var selectionViews: [SelectionView] = []
    private let stackView = UIStackView()
    private var selectedIndex: Int?

    var onSelectionChanged: ((Int, String) -> Void)?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
    }

    // MARK: - Public

    func configureOptions(_ titles: [String]) {
        options = titles.map { SelectionListViewOption(title: $0, isSelected: false) }
        reloadOptions()
    }
    
    var isOptionSelected: Bool {
        return selectedIndex != nil
    }

    // MARK: - Setup

    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = SelectionListViewConstants.stackSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
    }

    private func reloadOptions() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        selectionViews.removeAll()

        for (index, option) in options.enumerated() {
            let selectionView = SelectionView()
            selectionView.translatesAutoresizingMaskIntoConstraints = false
            selectionView.configure(isChecked: option.isSelected, text: option.title)

            selectionView.onTap = { [weak self] in
                self?.handleSelection(at: index)
            }

            selectionViews.append(selectionView)
            stackView.addArrangedSubview(selectionView)
        }
    }

    private func handleSelection(at index: Int) {
        guard index != selectedIndex else { return }

        for i in 0..<options.count {
            let isSelected = (i == index)
            options[i].isSelected = isSelected
            selectionViews[i].configure(isChecked: isSelected, text: options[i].title)
        }

        selectedIndex = index
        onSelectionChanged?(index, options[index].title)
    }
}
