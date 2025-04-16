import XCTest
@testable import djapp2

final class SelectionListViewTests: XCTestCase {

    func test_selectionCallbackTriggersWithCorrectIndexAndTitle() {
        // Arrange
        let selectionList = SelectionListView()
        let options = ["Beginner", "Intermediate", "Pro"]

        var selectedIndex: Int?
        var selectedTitle: String?

        selectionList.configureOptions(options)
        selectionList.onSelectionChanged = { index, title in
            selectedIndex = index
            selectedTitle = title
        }

        // Act
        // Simulate tap on the first SelectionView via its public onTap closure
        let selectionView = selectionList.subviews
            .compactMap { $0 as? UIStackView }
            .flatMap { $0.arrangedSubviews }
            .compactMap { $0 as? SelectionView }
            .first

        selectionView?.onTap?()

        // Assert
        XCTAssertEqual(selectedIndex, 0)
        XCTAssertEqual(selectedTitle, "Beginner")
    }

    func test_configureOptions_setsCorrectNumberOfOptions() {
        // Arrange
        let selectionList = SelectionListView()
        let titles = ["One", "Two", "Three"]

        // Act
        selectionList.configureOptions(titles)

        // Assert
        // Check that the number of SelectionView instances matches the titles
        let arranged = selectionList.subviews
            .compactMap { $0 as? UIStackView }
            .flatMap { $0.arrangedSubviews }
            .filter { $0 is SelectionView }

        XCTAssertEqual(arranged.count, 3)
    }
}
