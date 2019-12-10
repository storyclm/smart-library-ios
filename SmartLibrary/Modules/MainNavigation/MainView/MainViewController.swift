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

    private let contentManager = ContentManager.instance

    private var mainView: MainView {
        self.view as! MainView
    }

    override func loadView() {
        self.view = MainView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mainView.loader.play(state: SLLoaderView.AnimationState.start)
        
        self.checkContent()
    }

    // MARK: - Content

    private func checkContent() {
        contentManager.checkUpdateAvailability { (state) in
            switch state {
            case .needUpdate(let updatePresentations):
                self.showBatchLoader(for: updatePresentations)
            case .allUpdated(let mainPresentation):
                if let presentation = mainPresentation {
                    self.openMainPresentation(presentation)
                } else {
                    self.openLibrary()
                }

            case .fetchError(let error):
                self.showErrorAlert(error.localizedDescription)
            case .error(let error):
                self.showErrorAlert(error.localizedDescription)
            }
        }
    }

    private func showBatchLoader(for presentations: [Presentation]) {
        let batchVC = SCLMBatchLoadingViewController()
        batchVC.viewModel = self.batchViewModel
        batchVC.onDissmis = {[weak self] in
            self?.checkContent()
        }

        let batchManager = SCLMBatchLoadingManager()
        batchManager.addBatchLoadable(batchVC)
        batchManager.addPresentations(presentations)
        batchVC.present(on: self) {
            batchManager.startLoading()
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
        self.navigationController?.pushViewController(libraryVC, animated: true)
    }

    private func openMainPresentation(_ presentation: Presentation) {
        let presentationVC = PresentationViewController.get()
        presentationVC.inject(presentation: presentation)
        presentationVC.delegate = self
        self.navigationController?.pushViewController(presentationVC, animated: true)
    }

}

extension MainViewController: PresentationViewControllerDelegate {

    func presentationViewControllerWillClose() {
        // TODO: 
    }
}

extension MainViewController: LibraryViewControllerDelegate {

    func needToCheckUpdate() {
        // TODO:
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
