//
//  MediaViewModel.swift
//  SmartLibrary
//
//  Created by Oleksandr Yolkin on 2/25/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation
import ContentComponent

enum MediaViewModelFilter: Int {
    case all = 0
    case pdf = 1
    case mov = 2
}

class MediaViewModel {
    weak var presentation: Presentation!
    var mediaFiles = [MediaFile]()
    var filteredMediaFiles = [MediaFile]()
    
    deinit {
        print("MediaViewModel deinit")
    }
    
    func mediaFilesCount() -> Int {
        return mediaFiles.count
    }
    
    func filteredMediaFilesCount() -> Int {
        return filteredMediaFiles.count
    }
    
    func prepareMediaFiles() {
        guard let presentation = presentation, let _mediaFiles = presentation.mediaFiles else {
            return
        }
        
        presentation.checkMediaFiles {
            self.mediaFiles = Array(_mediaFiles).filter(){ $0.MIMEType() != .other }
            self.mediaFiles.sort{ $0.title ?? "" > $1.title ?? "" }
            self.filteredMediaFiles = self.mediaFiles
        }
    }
    
    func downloadButtonPressed(_ sender: NFDownloadButton, for mediaFile: MediaFile?, completion: @escaping () -> Void) {
        
        if sender.downloadState == .toDownload {
            sender.downloadState = .readyToDownload
            
            mediaFile?.loadMediaFile(completionHandler: { (error) in
                completion()
            }) { (progress) in
                DispatchQueue.main.async {
                    if sender.tag == mediaFile?.mediaFileId?.intValue {
                        sender.downloadPercent = CGFloat(progress.fractionCompleted)
                    }
                }
                
            }
            
        } else if sender.downloadState == .readyToDownload {
            sender.downloadState = .toDownload
            
            let mediaFileDownloadingNow = SCLMSyncManager.shared.isMediaFileDownloadingNow(mediaFileId: mediaFile?.mediaFileId, presentationId: self.presentation.presentationId)
            
            if let mediaFileDownloadingNow = mediaFileDownloadingNow {
                mediaFileDownloadingNow.downloadRequest?.cancel()
                
            }
            
        }
        
    }
    
    func filterChanged(_ filter: MediaViewModelFilter) {
        switch filter {
        case .all:
            filteredMediaFiles = mediaFiles
        case .mov:
            filteredMediaFiles = mediaFiles.filter{ $0.MIMEType() == .audioVideo }
        case .pdf:
            filteredMediaFiles = mediaFiles.filter{ $0.MIMEType() == .PDF }
        }
        self.filteredMediaFiles.sort{ $0.title ?? "" > $1.title ?? "" }
    }
    
}

