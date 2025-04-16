import UIKit

extension UILabel {

    static func heading(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(named: "contextual_primary")
        label.numberOfLines = 0
        label.textAlignment = .center

        // Letter spacing = 2% of font size ≈ 0.68 for 34pt
        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .kern: 0.68,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.lineHeightMultiple = 38.0 / 34.0 // for line-height: 38px
                    style.alignment = .center
                    return style
                }()
            ]
        )

        label.attributedText = attributedText
        return label
    }

    static func subtitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        label.textColor = UIColor(named: "contextual_primary")
        label.numberOfLines = 0
        label.textAlignment = .center

        // Letter spacing = 2% of font size ≈ 0.44 for 22pt
        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .kern: 0.44,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.lineHeightMultiple = 1.0 // 100% line height
                    style.alignment = .center
                    return style
                }()
            ]
        )

        label.attributedText = attributedText
        return label
    }
}
