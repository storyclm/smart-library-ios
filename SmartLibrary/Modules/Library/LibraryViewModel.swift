//
//  LibraryViewModel.swift
//  SmartLibrary
//
//  Created by Alexander Yolkin on 1/23/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation
import CoreData
import ContentComponent

class LibraryViewModel: NSObject {
    
    private let syncManager = SCLMSyncManager.shared
    
    public lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        
        let fetchResult = self.fetchRequest(for: Presentation.entityName(), batchSize: 100, sortKey: "client.name", context: syncManager.context)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchResult, managedObjectContext: syncManager.context, sectionNameKeyPath: "client.name", cacheName: nil)
        
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("FetchedResultsController performFetch error")
        }
        
        return fetchedResultsController
        
    }()
    
    public lazy var fetchedResultsControllerSectionLess: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        
        let fetchResult = self.fetchRequest(for: Presentation.entityName(), batchSize: 100, sortKey: "client.name", context: syncManager.context)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchResult, managedObjectContext: syncManager.context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("FetchedResultsController performFetch error")
        }
        
        return fetchedResultsController
        
    }()
    
    func fetchRequest(for name: String, batchSize:Int, sortKey: String?, context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = batchSize
        
        if let sortKey = sortKey {
            let sd1 = NSSortDescriptor(key: sortKey, ascending: true)
            let sd2 = NSSortDescriptor(key: "order", ascending: false)
            let sds = [sd1, sd2]
            
            fetchRequest.sortDescriptors = sds
        }
        
        return fetchRequest
        
    }
    
    public func synchronizePresentation(_ presentation: Presentation,
                                        completionHandler: @escaping (_ error: Error?) -> Void,
                                        progressHandler: @escaping (_ progress :Progress) -> Void) {
        
        syncManager.synchronizePresentation(presentation, completionHandler: { (error) in
            completionHandler(error)
            
        }) { (progress) in
            progressHandler(progress)
            
        }
        
    }
    
    public func deleteContentFolderForPresentation(_ presentation: Presentation) {
        syncManager.deletePresentationContentPackage(presentation)
    }
    
    public func updatePresentation(_ presentation: Presentation, completionHandler: @escaping (_ error: Error?) -> Void) {
        syncManager.updatePresentation(presentation) { (error) in
            completionHandler(error)
        }
    }
    
}
