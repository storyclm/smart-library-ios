//
//  ContentManager.swift
//  SmartLibrary
//
//  Created by Sergey Ryazanov on 10.12.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation
import CoreData
import StoryContent

final class ContentManager {

    enum AvailabilityState {
        case needUpdate([Presentation])
        case allUpdated(Presentation?)
        case error(StoryContent.SCLMError)
        case fetchError(Error)
    }

    static let instance = ContentManager()

    let mainViewModel = MainViewModel()

    private init() {}

    // MARK: -

    func checkUpdateAvailability(availability: ((AvailabilityState) -> Void)?) {
        SCLMSyncManager.shared.synchronizeClients { (error) in
            if let error = error {
                availability?(AvailabilityState.error(error))
            } else {
                let availableUpdatePresentations = self.availableForUpdatePresentations()
                switch availableUpdatePresentations {
                case .success(let presentations):
                    if presentations.isEmpty {
                        switch self.findMainPresentation() {
                        case .success(let mainPresentation):
                            availability?(AvailabilityState.allUpdated(mainPresentation))
                        case .failure(let error):
                            availability?(AvailabilityState.fetchError(error))
                        }
                    } else {
                        availability?(AvailabilityState.needUpdate(presentations))
                    }
                case .failure(let error):
                    availability?(AvailabilityState.fetchError(error))
                }
            }
        }
    }

    private func availableForUpdatePresentations() -> Result<[Presentation], Error> {
        let invisibleFetcher = self.mainViewModel.fetchedResultsControllerInvisible
        let visibleFetcher = self.mainViewModel.fetchedResultsController

        do {
            try visibleFetcher.performFetch()
            try invisibleFetcher.performFetch()
        } catch {
            print("fetchedResultsControllerInvisible performFetch error: \(error)")
            return Result.failure(error)
        }

        var presentationsForDownload: [Presentation] = []
        presentationsForDownload.append(contentsOf: self.listOfDownloadRequeredPresentation(from: invisibleFetcher))
        presentationsForDownload.append(contentsOf: self.listOfDownloadRequeredPresentation(from: visibleFetcher))

        return Result.success(presentationsForDownload)
    }

    private func listOfPresentation(from fetcher: NSFetchedResultsController<NSFetchRequestResult>) -> [Presentation] {
        var result: [Presentation] = []

        for client in fetcher.sections ?? [] {
            if let objects = client.objects {
                let presentations = objects.compactMap { $0 as? Presentation }
                result.append(contentsOf: presentations)
            }
        }

        return result
    }

    private func listOfDownloadRequeredPresentation(from fetcher: NSFetchedResultsController<NSFetchRequestResult>) -> [Presentation] {
        return self.listOfPresentation(from: fetcher).filter { (presentation) -> Bool in
            return presentation.contentPackage != nil && (presentation.isSyncReady() || presentation.isUpdateAvailable())
        }
    }

    private func findMainPresentation() -> Result<Presentation?, Error> {
        let mainName = "index"
        let visibleFetcher = self.mainViewModel.fetchedResultsController

        do {
            try visibleFetcher.performFetch()
        } catch {
            return Result.failure(error)
        }

        let filtered = self.listOfPresentation(from: visibleFetcher)
            .filter {  (presentation) -> Bool in
                guard presentation.contentPackage != nil else { return false }
                guard let name = presentation.name else { return false }
                return name.caseInsensitiveCompare(mainName) == ComparisonResult.orderedSame
            }
        .sorted { (lhs, rhs) -> Bool in
            guard let lhsOrder = lhs.order else { return true }
            guard let rhsOrder = rhs.order else { return false }
            return lhsOrder.intValue < rhsOrder.intValue
        }
        return Result.success(filtered.first)
    }
}
