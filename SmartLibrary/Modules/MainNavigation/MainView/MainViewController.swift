//
//  MainViewController.swift
//  SmartLibrary
//
//  Created by Sergey Ryazanov on 10.12.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import StoryContent

final class MainViewController: UIViewController {

    private var router: Router
    private let contentManager = ContentManager.instance

    private weak var currentPresentationViewController: PresentationViewController?
    private weak var currentLibraryViewController: LibraryViewController?
    private weak var currentBatchLoaderViewController: SCLMBatchLoadingViewController?

    private var additionalLoader: SLLoader?
    private lazy var loader = SLLoader(view: self.view)

    init(with router: Router) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        self.view = MainView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loader.showAnimation(isFullScreen: true)

        self.checkLogin { (success) in
            if success {
                self.checkContent()
                self.addObservers()
            } else {
                // Repeat
            }
        }
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func checkLogin(completion: @escaping (Bool) -> Void) {
        self.router.checkLogin { (error) in
            if let error = error {
                let alert = UIAlertController(title: "Ошибка", message: "Ошибка во время логина\n\(error.localizedDescription)", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Повторить", style: UIAlertAction.Style.default, handler: { (_) in
                    self.checkLogin(completion: completion)
                }))
                alert.addAction(UIAlertAction(title: "Закрыть", style: UIAlertAction.Style.cancel, handler: { (_) in
                    completion(false)
                }))
                self.present(alert, animated: true)
            } else {
                completion(true)
            }
        }
    }

    // MARK: - Notifications

    @objc private func didBecomeActive(_ notification: Notification) {
        guard currentBatchLoaderViewController == nil else { return }
        self.checkContent(isBackground: true)
    }

    // MARK: - Content

    private func checkContent(isBackground: Bool = false) {
        if isBackground {
            self.showLoaderOnSubController()
        }
        contentManager.checkUpdateAvailability { (state) in
            switch state {
            case .needUpdate(let updatePresentations):
                self.handleNeedUpdate(with: updatePresentations, isBackground: isBackground)
            case .allUpdated(let mainPresentation):
                self.handleAllUpdated(with: mainPresentation, isBackground: isBackground)
            case .fetchError(let error):
                self.removeLoaderFromSubController() {
                    self.showErrorAlert(error.localizedDescription)
                }
            case .error(let error):
                self.removeLoaderFromSubController() {
                    self.showErrorAlert(error.localizedDescription)
                }
            }
        }
    }

    private func handleNeedUpdate(with presentations: [Presentation], isBackground: Bool) {
        self.removeLoaderFromSubController() {
            if isBackground, let currentPresentationVC = self.currentPresentationViewController {
                let alert = UIAlertController(title: "Обновление контента", message: "Контент приложения готов к обновлению", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Сохранить и обновить контент", style: UIAlertAction.Style.default, handler: { (_) in
                    currentPresentationVC.close(mode: ClosePresentationMode.closeSessionComplete) {
                        currentPresentationVC.dismiss(animated: true) {
                            self.showBatchLoader(for: presentations)
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Продолжить работу", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true)
            } else {
                if let libraryVC = self.currentLibraryViewController {
                    libraryVC.navigationController?.popToRootViewController(animated: true)
                }
                self.showBatchLoader(for: presentations)
            }
        }
    }

    private func handleAllUpdated(with mainPresentation: Presentation?, isBackground: Bool) {
        self.removeLoaderFromSubController() {
            if isBackground, let currentPresentationVC = self.currentPresentationViewController {
                if currentPresentationVC.mainPresentation != mainPresentation {
                    let alert = UIAlertController(title: "Обновление контента", message: "Главная презентация изменилась", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Сохранить и открыть новую презентацию", style: UIAlertAction.Style.default, handler: { (_) in
                        currentPresentationVC.close(mode: ClosePresentationMode.closeSessionComplete) {
                            currentPresentationVC.dismiss(animated: true) {
                                self.openMainPresentationIfNeeded(mainPresentation)
                            }
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Продолжить работу", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true)
                }
            } else {
                if let libraryVC = self.currentLibraryViewController {
                    libraryVC.navigationController?.popToRootViewController(animated: true)
                }
                self.openMainPresentationIfNeeded(mainPresentation)
            }
        }
    }

    private func openMainPresentationIfNeeded(_ mainPresentation: Presentation?) {
        if let presentation = mainPresentation {
            self.openPresentation(presentation, isMain: true)
        } else {
            self.openLibrary()
        }
    }

    // MARK: - Loader

    private func showLoaderOnSubController() {
        func addLoader(to view: UIView) {
            let loader = SLLoader(view: view)
            loader.showAnimation(isFullScreen: true)
            self.additionalLoader = loader
        }

        if let presentationVC = self.currentPresentationViewController {
            addLoader(to: presentationVC.view)
        } else if let libraryVC = self.currentLibraryViewController {
            addLoader(to: libraryVC.view)
        }
    }

    private func removeLoaderFromSubController(completion: (() -> Void)?) {
        guard let libLoader = self.additionalLoader else {
            completion?()
            return
        }
        libLoader.hideAnimation(isAnimated: true) {
            self.additionalLoader = nil
            completion?()
        }
    }

    func currentLoader() -> SLLoader {
        guard let libraryLoader = self.additionalLoader else { return self.loader }
        return libraryLoader
    }

    // MARK: - Batch loader

    private func showBatchLoader(for presentations: [Presentation]) {
        let batchVC = SCLMBatchLoadingViewController()
        batchVC.viewModel = self.batchViewModel
        batchVC.onDissmis = { _, _ in
            self.currentBatchLoaderViewController = nil
        }

        let batchManager = SCLMBatchLoadingManager()
        batchManager.addBatchLoadable(batchVC)
        batchManager.addPresentations(presentations)

        batchVC.transitioningDelegate = self

        self.currentBatchLoaderViewController = batchVC
        self.loader.loader?.play(state: SLLoaderView.AnimationState.end, completion: {
            batchVC.present(on: self) {
                batchManager.startLoading()
            }
        })
    }

    private func afterBatchLoaderBehaviour() {
        if case let Result.success(mainPresentation) = self.contentManager.findMainPresentation() {
            if let presentation = mainPresentation {
                self.openPresentation(presentation, isMain: true)
            } else {
                self.openLibrary()
            }
        } else {
            self.openLibrary()
        }
    }

    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
    }

    // MARK: - Navigate

    private func openLibrary() {
        let libraryVC = LibraryViewController.get()
        libraryVC.delegate = self
        libraryVC.inject(viewModel: contentManager.mainViewModel)
        self.currentLibraryViewController = libraryVC

        self.navigationController?.pushViewController(libraryVC, animated: true)
    }

    private func openPresentation(_ presentation: Presentation, isMain: Bool) {
        let presentationVC = PresentationViewController.get()
        presentationVC.inject(presentation: presentation, isMain: isMain)
        presentationVC.delegate = self
        presentationVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.currentPresentationViewController = presentationVC

        self.present(presentationVC, animated: true)
    }

}

extension MainViewController: PresentationViewControllerDelegate {

    func presentationViewControllerWillClose() {
        self.currentPresentationViewController = nil
    }
}

extension MainViewController: LibraryViewControllerDelegate {

    func libraryNeedToCheckUpdate(_ viewController: LibraryViewController) {
        self.checkContent(isBackground: true)
    }

    func libraryNeedOpenPresentation(_ viewController: LibraryViewController, presentation: Presentation, isMain: Bool) {
        self.openPresentation(presentation, isMain: isMain)
    }
}

// MARK: - SCLMBatchLoading ViewModel
extension MainViewController {

    var batchViewModel: SCLMBatchLoadingViewModel {
        let batchViewModel = SCLMBatchLoadingViewModel()
        batchViewModel.loader = BatchLoaderView()

        batchViewModel.subtitleViewModel = {
            let viewModel = batchViewModel.subtitleViewModel
            viewModel.numberOfLines = 3
            return viewModel
        }()

        batchViewModel.cancelButtonViewModel = {
            let buttonViewModel = SCLMBatchLoadingViewModel.ButtonViewModel()
            buttonViewModel.isHidden = true
            return buttonViewModel
        }()

        return batchViewModel
    }
}

extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

extension MainViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LoaderAnimator(isPresenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = LoaderAnimator(isPresenting: false)
        animator.dismissCompletion = {
            self.loader.loader?.play(state: SLLoaderView.AnimationState.start, completion: {
                self.afterBatchLoaderBehaviour()
            })
        }
        return animator
    }
}
