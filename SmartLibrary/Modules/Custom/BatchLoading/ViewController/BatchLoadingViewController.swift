//
//  BatchLoadingViewController.swift
//  StoryCLM
//
//  Created by Sergey Ryazanov on 26.11.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import StoryContent

class BatchLoadingViewController: UIViewController {

    /// Число попыток загрузки презентации при ошибке
    /// - Значение по умолчанию: 2
    var maximumFailCount: Int = 2

    /// Вызывается при закрытии контроллера
    /// - Note: Параметры:
    ///     - Bool: *true* - если все презентации загружены успешно, иначе *false*
    ///     - [Int]: Id перезнтации, которые загрузились с ошибкой
    ///
    var onDismiss: ((_ success: Bool, _ failedPresentations: [Int]) -> Void)?

    private var _batchLoadingManager: BatchLoadingManager?

    private let batchLoaderView = BatchLoadingView()
    private var failedPresentations: [Int: Int] = [:]

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.batchLoaderView.frame = self.view.bounds
        self.batchLoaderView.autoresizingMask = [ UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleWidth ]
        self.batchLoaderView.closeButton.addTarget(self, action: #selector(cancelButtonAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.batchLoaderView)
    }

    // MARK: - Actions

    @objc func cancelButtonAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Отменить обновление",
                                      message: "Вы действительно хотите отменить обновление презентации?",
                                      preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Нет", style: UIAlertAction.Style.destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Да", style: UIAlertAction.Style.default, handler: {[weak self] (_) in
            self?.batchLoadingManager?.cancelLoading()
        }))
        self.present(alert, animated: true)
    }

    // MARK: - UITraitCollection

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.batchLoaderView.updateAppearance()
    }

    // MARK: - Show/Hide

    /// Показывает *BatchLoadingViewController* модально на *viewController*
    /// - Parameters:
    ///   - viewController: контроллер для отображения *BatchLoadingViewController*
    ///   - completion: возвращается при показе *BatchLoadingViewController* на *viewController*
    /// - Note: Устанавливает свойство *modalPresentationStyle* в *.fullScreen*
    /// - Warning: Данный метод не начинает загрузку презентаций при появлении, для этого испульзуйте метод `startLoading` класса *BatchLoadingManager*
    func present(on viewController: UIViewController, completion: @escaping (() -> Void)) {
        self.modalPresentationStyle = UIModalPresentationStyle.fullScreen

        viewController.present(self, animated: true) {
            completion()
        }
    }

    private func dismissWithCompletion(isCanceled: Bool) {
        self.dismiss(animated: true) {[weak self] in
            guard let self = self else { return }

            let listOfFailedPresentations = Array(self.failedPresentations.keys)
            let isSuccess = listOfFailedPresentations.isEmpty && isCanceled == false
            self.onDismiss?(isSuccess, listOfFailedPresentations)
        }
    }
}

extension BatchLoadingViewController: BatchLoadingManagerDelegate {

    public var batchLoadingManager: BatchLoadingManager? {
        get { return _batchLoadingManager }
        set { _batchLoadingManager = newValue }
    }

    public func batchManagerPrepareForDownloading(_ manager: BatchLoadingManager, presentationCount: Int) {
        self.batchLoaderView.setProgress(current: 0, total: presentationCount)
        self.batchLoaderView.loader.startLoading()
    }

    public func batchManagerStartLoading(_ manager: BatchLoadingManager, presentation: Presentation) {
        let loadingText = "\(presentation.name ?? "Презентация без имени") - 0%"
        self.batchLoaderView.setLoadingText(loadingText)
    }

    public func batchManagerProgressChanged(_ manager: BatchLoadingManager, progress: Progress, for presentation: Presentation) {
        let progressText = String(format: "%.02f", progress.fractionCompleted * 100)
        let loadingText = "\(presentation.name ?? "Презентация без имени") - \(progressText)%"
        self.batchLoaderView.setLoadingText(loadingText)
    }

    public func batchManagerDidLoadPresentation(_ manager: BatchLoadingManager, presentation: Presentation) {
        if let presentationId = presentation.presentationId?.intValue {
            self.failedPresentations.removeValue(forKey: presentationId)
        }

        let loadingText = "\(presentation.name ?? "Презентация без имени") - 100%"
        self.batchLoaderView.setLoadingText(loadingText)
        self.batchLoaderView.increaseProgressText()
    }

    public func batchManagerShouldRepeatLoadingPresentation(_ manager: BatchLoadingManager, error: Error, presentation: Presentation) -> Bool {
        guard let presentationId = presentation.presentationId?.intValue else { return false }
        var failedCount = self.failedPresentations[presentationId] ?? 0
        guard failedCount < maximumFailCount else { return false }

        failedCount += 1
        self.failedPresentations[presentationId] = failedCount
        return true
    }

    public func batchManagerFailedLoadingPresentation(_ manager: BatchLoadingManager, error: Error, presentation: Presentation) {
        if let presentationId = presentation.presentationId?.intValue {
            self.failedPresentations[presentationId] = maximumFailCount
        }
        self.batchLoaderView.increaseProgressText()
    }

    public func batchManagerDone(_ manager: BatchLoadingManager, isCanceled: Bool) {
        self.batchLoaderView.loader.stopLoading()
        self.dismissWithCompletion(isCanceled: isCanceled)
    }

}
