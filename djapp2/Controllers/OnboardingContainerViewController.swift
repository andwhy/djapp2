import UIKit

class OnboardingContainerViewController: UIViewController {

    private let pageVC: OnboardingPageViewController
    private let pageControl = UIPageControl()

    init(steps: [OnboardingStep]) {
        self.pageVC = OnboardingPageViewController(steps: steps)
        super.init(nibName: nil, bundle: nil)
        self.pageVC.pageDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()
        setupLayout()
    }

    private func setupLayout() {
        // Добавляем сабвью
        addChild(pageVC)
        view.addSubview(pageVC.view)
        view.addSubview(pageControl)
        pageVC.didMove(toParent: self)

        // Настройка layout
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        pageControl.numberOfPages = pageVC.numberOfPages()
        pageControl.currentPage = pageVC.currentPageIndex()
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .gray

        NSLayoutConstraint.activate([
            // Пейдж вью контроллер занимает всё до точек
            pageVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -16),

            // Точки внизу
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        if let gradientLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            gradientLayer.frame = view.bounds
        }
    }
    
    func addGradientBackground() {
        let gradientLayer = CAGradientLayer()
        
        // Цвета градиента
        gradientLayer.colors = [
            (UIColor(named: "background_gardient_1") ?? .black).cgColor,
            (UIColor(named: "background_gardient_2") ?? .black).cgColor,
        ]
        
        // Направление — сверху вниз
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        // Задать размер
        gradientLayer.frame = view.bounds
        gradientLayer.zPosition = -1 // чтобы он был за всем

        // Удалим старые градиенты (если есть)
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension OnboardingContainerViewController: OnboardingPageDelegate {
    func onboardingPage(didMoveTo index: Int) {
        pageControl.currentPage = index
    }
}
