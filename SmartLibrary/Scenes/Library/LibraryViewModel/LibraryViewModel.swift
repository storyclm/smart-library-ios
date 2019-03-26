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
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        return SCLMSyncManager.shared.fetchedResultsController
    }
    
    public func synchronizePresentation(_ presentation: Presentation,
                                        completionHandler: @escaping (_ error: Error?) -> Void,
                                        progressHandler: @escaping (_ progress :Progress) -> Void) {
        
        SCLMSyncManager.shared.synchronizePresentation(presentation, completionHandler: { (error) in
            completionHandler(error)
            
        }) { (progress) in
            progressHandler(progress)
            
        }
        
    }
    
    public func deleteContentFolderForPresentation(_ presentation: Presentation) {
        SCLMSyncManager.shared.deletePresentationContentPackage(presentation)
    }
    
    public func updatePresentation(_ presentation: Presentation, completionHandler: @escaping (_ error: Error?) -> Void) {
        SCLMSyncManager.shared.updatePresentation(presentation) { (error) in
            completionHandler(error)
        }
    }
    
}
