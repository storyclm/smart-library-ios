//
//  BatchLoadingManager.swift
//  StoryCLM
//
//  Created by Sergey Ryazanov on 26.11.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation
import StoryContent

public protocol BatchLoadingManagerDelegate: class {
    var batchLoadingManager: BatchLoadingManager? {get set}

    /// Возвращает кол-во презентаций, который будут загружены менеджером
    /// - Parameters:
    ///   - manager: Экземпляр BatchLoadingManager
    ///   - presentationCount: Количество презентаций для скачивания в менеджере
    /// - Note: Метод вызывается при вызове методов: `addBatchLoadable` и `addPresentations`
    func batchManagerPrepareForDownloading(_ manager: BatchLoadingManager, presentationCount: Int)

    /// Начало загрузки презентации
    /// - Parameters:
    ///   - manager: Экземпляр BatchLoadingManager
    ///   - presentation: Презентация, которая начала загружаться
    /// - Note: Вызывается в main queue
    func batchManagerStartLoading(_ manager: BatchLoadingManager, presentation: Presentation)

    /// Изменение прогресса загрузки презентации
    /// - Parameters:
    ///   - manager: Экземпляр BatchLoadingManager
    ///   - progress: Экземпляр Progress с прогрессом синхронизации для презентации
    ///   - presentation: Загружаемая презентация
    /// - Note: Вызывается в main queue
    func batchManagerProgressChanged(_ manager: BatchLoadingManager, progress: Progress, for presentation: Presentation)

    /// Успешная загрузка презентации
    /// - Parameters:
    ///   - manager: Экземпляр BatchLoadingManager
    ///   - presentation: Загруженная презентация
    /// - Note: Вызывается в main queue
    func batchManagerDidLoadPresentation(_ manager: BatchLoadingManager, presentation: Presentation)

    /// Запрос на повторную загрузку презентациий при ошибке
    /// - Parameters:
    ///   - manager: Экземпляр BatchLoadingManager
    ///   - error: Экземпляр Error с описанием ошибки
    ///   - presentation: Презентация при загрузке которой возникла ошибка
    /// - Returns: true - Поместить презентацию в конец очереди загрузки, false - пропустить загрузку презентации
    func batchManagerShouldRepeatLoadingPresentation(_ manager: BatchLoadingManager, error: Error, presentation: Presentation) -> Bool

    /// Ошибка при загрузке презентации (вызывается если метод `batchManagerShouldRepeatLoadingPresentation` вернул false)
    /// - Parameters:
    ///   - manager: Экземпляр BatchLoadingManager
    ///   - error: Экземпляр Error с описанием ошибки
    ///   - presentation: Презентация при загрузке которой возникла ошибка
    /// - Note: Вызывается в main queue
    func batchManagerFailedLoadingPresentation(_ manager: BatchLoadingManager, error: Error, presentation: Presentation)

    /// Вызывается по окончании загрузки всех презентаций
    /// - Parameters:
    ///   - manager: Экземпляр BatchLoadingManager
    ///   - isCanceled: true - загрузка презентаций закончилась по вызову метода `cancelLoading`, false - все презентации были загружены (возможно с ошибками)
    func batchManagerDone(_ manager: BatchLoadingManager, isCanceled: Bool)
}

public class BatchLoadingManager {

    private(set) var presentations: [Presentation] = []
    private weak var currentSyncPresentation: Presentation?
    private var isCanceled: Bool = false

    private weak var loadingDelegate: BatchLoadingManagerDelegate?

    public init() {}

    // MARK: - BatchLoadable

    /// Установка делегата загрузки
    /// - Parameter loadingDelegate: Делегат BatchLoadingManagerDelegate
    /// - Info: Присваивает переменной `loadingDelegate` себя в качестве `batchLoadingManager`
    /// - Note: По окончании вызывает метод делегата `batchManagerPrepareForDownloading`
    public func addBatchLoadable(_ loadingDelegate: BatchLoadingManagerDelegate) {
        loadingDelegate.batchLoadingManager = self
        self.loadingDelegate = loadingDelegate

        self.loadingDelegate?.batchManagerPrepareForDownloading(self, presentationCount: self.presentations.count)
    }

    // MARK: - Loading

    /// Добавляет презентации в очередь загрузки
    /// - Parameter presentations: Презентации для загрузки
    /// - Note: Удаляет все старые презентации из очереди
    /// - Note: По окончании вызывает метод делегата `batchManagerPrepareForDownloading`
    public func addPresentations(_ presentations: [Presentation]) {
        self.presentations = presentations
        self.loadingDelegate?.batchManagerPrepareForDownloading(self, presentationCount: presentations.count)
    }

    /// Начать загрузку презентаций из очереди
    public func startLoading() {
        self.isCanceled = false
        self.loadNextPresentationIfNeeded()
    }

    private func loadNextPresentationIfNeeded() {
        guard self.isCanceled == false else { return }

        if self.presentations.isEmpty == false {
            let presentation = self.presentations.removeFirst()
            self.currentSyncPresentation = presentation

            DispatchQueue.main.async {
                self.loadingDelegate?.batchManagerStartLoading(self, presentation: presentation)
            }

            SCLMSyncManager.shared.synchronizePresentation(presentation, completionHandler: {[weak self] (error) in
                guard let self = self else { return }
                if let error = error {
                    if let presentation = self.currentSyncPresentation {
                        if self.loadingDelegate?.batchManagerShouldRepeatLoadingPresentation(self, error: error, presentation: presentation) ?? false {
                            self.presentations.append(presentation)
                        } else {
                            DispatchQueue.main.async {
                                self.loadingDelegate?.batchManagerFailedLoadingPresentation(self, error: error, presentation: presentation)
                            }
                        }
                    }
                    self.loadNextPresentationIfNeeded()
                } else {
                    if let presentation = self.currentSyncPresentation {
                        DispatchQueue.main.async {
                            self.loadingDelegate?.batchManagerDidLoadPresentation(self, presentation: presentation)
                        }
                    }
                    self.loadNextPresentationIfNeeded()
                }
            }, progressHandler: {[weak self] (progress) in
                guard let self = self, let presentation = self.currentSyncPresentation else { return }
                DispatchQueue.main.async {
                    self.loadingDelegate?.batchManagerProgressChanged(self, progress: progress, for: presentation)
                }
            }) { (_) in
                // Do nothing
            }
        } else {
            self.doneLoading(isCanceled: false)
        }
    }

    /// Отмена загрузки презентаций.
    /// Прерывает загрузку текущей презентации и очищает очередь загрузки.
    /// - Note: По окончании вызывает метод делегата `batchManagerDone`
    public func cancelLoading() {
        self.isCanceled = true
        if let presentation = self.currentSyncPresentation {
            SCLMSyncManager.shared.cancelSynchronizePresentation(presentation)
        }
        self.doneLoading(isCanceled: true)
    }

    // MARK: - Done

    private func doneLoading(isCanceled: Bool) {
        self.presentations = []
        self.currentSyncPresentation = nil
        self.loadingDelegate?.batchManagerDone(self, isCanceled: isCanceled)
    }
}
