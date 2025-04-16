import UIKit

protocol OnboardingPageDelegate: AnyObject {
    func onboardingPage(didMoveTo index: Int)
}

class OnboardingPageViewController: UIPageViewController {
    
    private let steps: [OnboardingStep]
    private var pages: [OnboardingStepViewController] = []
    
    private var isSwipeEnabled = true
    
    private var currentIndex = 0
    weak var pageDelegate: OnboardingPageDelegate?

    init(steps: [OnboardingStep]) {
        self.steps = steps
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        self.pages = steps.map { step in
            let vc = OnboardingStepViewController(step: step)
            vc.onNext = { [weak self] in self?.goToNextPage() }
            return vc
        }
        self.pages.forEach { $0.parentPageViewController = self }
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

    func setSwipeEnabled(_ enabled: Bool) {
        isSwipeEnabled = enabled
        for view in view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.isScrollEnabled = enabled
            }
        }
    }
    
    func reloadCurrentPage() {
        guard let currentVC = viewControllers?.first else { return }

        // Force UIPageViewController to refresh direction
        setViewControllers([currentVC], direction: .forward, animated: false, completion: nil)
    }
    
    private func goToNextPage() {
        let nextIndex = currentIndex + 1
        guard nextIndex < pages.count else { return }
        setViewControllers([pages[nextIndex]], direction: .forward, animated: true)
        currentIndex = nextIndex
        pageDelegate?.onboardingPage(didMoveTo: currentIndex)
    }

    func goToPage(index: Int, animated: Bool = true) {
        guard index >= 0, index < pages.count else { return }
        let direction: NavigationDirection = index > currentIndex ? .forward : .reverse
        setViewControllers([pages[index]], direction: direction, animated: animated)
        currentIndex = index
        pageDelegate?.onboardingPage(didMoveTo: index)
    }

    func numberOfPages() -> Int {
        return pages.count
    }

    func currentPageIndex() -> Int {
        return currentIndex
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

        // Block forward swipe from .selectSkill if no option is selected
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
