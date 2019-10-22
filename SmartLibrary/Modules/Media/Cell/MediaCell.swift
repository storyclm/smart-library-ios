//
//  MediaCell.swift
//  SmartLibrary
//
//  Created by Oleksandr Yolkin on 2/25/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import AVFoundation
import StoryContent

protocol MediaCellProtocol: class {
    func downloadButtonPressed(_ sender: NFDownloadButton, for mediaFile: MediaFile?, completion: @escaping () -> Void)
}

class MediaCell: UICollectionViewCell {
    
    static let identifier = "MediaCell"
    
    weak var delegate: MediaCellProtocol?
    weak var mediaFile: MediaFile?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var pdfIcon: UIImageView!
    
    var downloadButton: NFDownloadButton!
    var mediaFileDownloadingNow: MediaFileDownloadingNow?
    
    // MARK: -
    
    override func awakeFromNib() {

        downloadButton = NFDownloadButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        downloadButton.addTarget(self, action: #selector(downloadButtonPressed(_:)), for: .touchUpInside)
        self.addSubview(downloadButton)
        downloadButton.center = imageView.center
        
        downloadButton.style = NFDownloadButtonStyle.iOS.rawValue
        downloadButton.buttonBackgroundColor = UIColor.clear
        downloadButton.initialColor = UIColor.white
        downloadButton.rippleColor = UIColor.white
        downloadButton.deviceColor = UIColor.clear
        downloadButton.downloadColor = UIColor.white
//        downloadButton.backgroundColor = UIColor(rgb: 0x45B5F3)
//        downloadButton.layer.cornerRadius = downloadButton.frame.width / 2
        
    }
    
    override func prepareForReuse() {
        
        self.downloadButton.isHidden = true
        self.playIcon.alpha = 0.0
        self.pdfIcon.isHidden = true
        
    }
    
    public func setup(with mediaFile: MediaFile, delegate: MediaCellProtocol, mediaFileDownloadingNow: MediaFileDownloadingNow?) {
        
        // general setup
        self.mediaFile = mediaFile
        self.delegate = delegate
        self.mediaFileDownloadingNow = mediaFileDownloadingNow
        self.downloadButton.tag = mediaFile.mediaFileId?.intValue ?? 0
        
        // restore state if mediaFileDownloadingNow
        if let _ = mediaFileDownloadingNow {
            downloadButton.downloadState = .readyToDownload
        } else {
            downloadButton.downloadState = .toDownload
        }
        self.mediaFileDownloadingNow?.progressHandler = { [weak self] progress in
            DispatchQueue.main.async {
                if self?.downloadButton.tag == mediaFile.mediaFileId?.intValue {
                    self?.downloadButton.downloadPercent = CGFloat(progress.fractionCompleted)
                }
            }
        }
        self.mediaFileDownloadingNow?.completionHandler = { [weak self] in
            self?.updateThumbnail()
            self?.updateDownloadPlayButtonAnimated(true)
        }
        
        
        // labels, images, buttons
        nameLabel.text = mediaFile.title
        pdfIcon.isHidden = mediaFile.MIMEType() != .PDF
        
        updateThumbnail()
        updateDownloadPlayButtonAnimated(false)
        
 
    }
    
    private func updateThumbnail() {
        self.imageView.image = mediaFile?.thumbnail()
    }
    
    private func updateDownloadPlayButtonAnimated(_ animated: Bool) {
        if let mediaFile = mediaFile, mediaFile.isMediaFileExists() {
            hideDownloadButton()
            if mediaFile.MIMEType() != .audioVideo {
                hidePlayIconAnimated()
            } else {
                showPlayIconAnimated(animated)
            }
            
        } else {
            showDownloadButton()
            hidePlayIconAnimated()
            
        }
    }
    
    private func showPlayIconAnimated(_ animated: Bool) {
        let duration = animated ? 0.25 : 0.0
        let delay = animated ? 0.25 : 0.0
        UIView.animate(withDuration: duration, delay: delay, options: [], animations: {
            self.playIcon.alpha = 1.0
        }, completion: nil)
    }
    
    private func hidePlayIconAnimated() {
        UIView.animate(withDuration: 0.0, delay: 0.0, options: [], animations: {
            self.playIcon.alpha = 0.0
        }, completion: nil)
    }
    
    private func showDownloadButton() {
        downloadButton.isHidden = false
    }
    
    private func hideDownloadButton() {
        downloadButton.isHidden = true
    }
    
    @IBAction func downloadButtonPressed(_ sender: NFDownloadButton) {
        delegate?.downloadButtonPressed(downloadButton, for: mediaFile, completion: { [weak self] in
            self?.updateThumbnail()
            self?.updateDownloadPlayButtonAnimated(true)
        })
    }
    
    
}

extension MediaCell: NFDownloadButtonDelegate {

    func stateChanged(button: NFDownloadButton, newState: NFDownloadButtonState) {
        
    }
    
}
