import UIKit

protocol OnboardingPageDelegate: AnyObject {
    func onboardingPage(didMoveTo index: Int)
}

class OnboardingPageViewController: UIPageViewController {

    private let steps: [OnboardingStep]
    private var pages: [OnboardingStepViewController] = []
    private var currentIndex = 0
    weak var pageDelegate: OnboardingPageDelegate?

    init(steps: [OnboardingStep]) {
        self.steps = steps
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        setupPages()
        self.dataSource = self
        self.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: false)
        }
    }

    func reloadCurrentPage() {
        guard let currentVC = viewControllers?.first else { return }
        setViewControllers([currentVC], direction: .forward, animated: false)
    }

    func numberOfPages() -> Int {
        return pages.count
    }

    func currentPageIndex() -> Int {
        return currentIndex
    }

    private func setupPages() {
        self.pages = steps.map { step in
            let vc = OnboardingStepViewController(step: step)
            vc.onNext = { [weak self] in self?.goToNextPage() }
            vc.parentPageViewController = self
            return vc
        }
    }

    private func goToNextPage() {
        let nextIndex = currentIndex + 1
        guard nextIndex < pages.count else { return }
        setViewControllers([pages[nextIndex]], direction: .forward, animated: true)
        currentIndex = nextIndex
        pageDelegate?.onboardingPage(didMoveTo: currentIndex)
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController as! OnboardingStepViewController), index > 0 else {
            return nil
        }
        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let current = viewController as? OnboardingStepViewController,
              let index = pages.firstIndex(of: current),
              index < pages.count - 1 else {
            return nil
        }

        // Block forward swipe if current step is not completed
        guard current.isStepCompleted else {
            return nil
        }

        return pages[index + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let visible = viewControllers?.first,
              let index = pages.firstIndex(of: visible as! OnboardingStepViewController) else { return }
        currentIndex = index
        pageDelegate?.onboardingPage(didMoveTo: index)
    }
}
