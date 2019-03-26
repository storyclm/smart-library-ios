//
//  LibraryCell.swift
//  SmartLibrary
//
//  Created by Alexander Yolkin on 1/23/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import ContentComponent
import Kingfisher

protocol LibraryCellProtocol: class {
    func libraryCell(_ cell: LibraryCell, infoButtonPressedForPresentation presentation: Presentation)
    func libraryCell(_ cell: LibraryCell, syncButtonPressedForPresentation presentation: Presentation, progressHandler: ((Int?, Progress) -> Void)?, completionHandler: ((Int?) -> Void)?)
}

class LibraryCell: UICollectionViewCell {
    
    static let identifier = "LibraryCell"
    
    weak var delegate: LibraryCellProtocol?
    weak var presentation: Presentation?
    
    private var gradientLayer: CAGradientLayer!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var syncButton: NFDownloadButton!
    @IBOutlet weak var unreadImageView: UIImageView!
    
    var contentPackageDownloadingNow: ContentPackageDownloadingNow?
    
    var progressHandler: ((_ presentationId: Int?, _ progress: Progress) -> Void)?
    var completionHandler: ((_ presentationId: Int?) -> Void)?
    
    // MARK: -
    
    override func awakeFromNib() {
        backgroundColor = UIColor.white
        
        addGradientLayer()
        
        imageView.layer.cornerRadius = 9.0
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        
        syncButton.layer.masksToBounds = false
        syncButton.layer.shadowColor = UIColor.black.cgColor
        syncButton.layer.shadowOpacity = 0.25
        syncButton.layer.shadowRadius = 8.0
        
        setupSyncButton()
    }
    
    override func prepareForReuse() {

        imageView.image = nil
        categoryLabel.text = ""
        nameLabel.text = ""
        dateLabel.text = ""
        
        unreadImageView.isHidden = true

        syncButton.downloadState = .toDownload
        syncButton.isHidden = true
        
        contentPackageDownloadingNow = nil
        
    }
    
    private func setupSyncButton() {
        syncButton.style = NFDownloadButtonStyle.iOS.rawValue
        syncButton.buttonBackgroundColor = UIColor.clear
        syncButton.initialColor = UIColor.white
        syncButton.rippleColor = UIColor.white
        syncButton.deviceColor = UIColor.clear
        syncButton.downloadColor = UIColor.white
        syncButton.backgroundColor = UIColor(rgb: 0x45B5F3)
        syncButton.layer.cornerRadius = syncButton.frame.width / 2
    }
    
    // MARK: -
    
    public func setup(with presentation: Presentation, delegate: LibraryCellProtocol, contentPackageDownloadingNow: ContentPackageDownloadingNow?) {

        // general setup
        self.delegate = delegate
        self.presentation = presentation
        self.contentPackageDownloadingNow = contentPackageDownloadingNow

        
        // hanlers
        self.progressHandler = { [weak self] presentationId, progress in
            DispatchQueue.main.async {
                if presentationId == self?.presentation?.presentationId?.intValue {
//                    print("self.progressHandler = \(progress.fractionCompleted)")
                    self?.syncButton.downloadPercent = CGFloat(progress.fractionCompleted)
                }
            }
        }
        
        self.completionHandler = { [weak self] presentationId in
            DispatchQueue.main.async {
                if presentationId == self?.presentation?.presentationId?.intValue {
//                    print("self.completionHandler")
                    if presentation.isSyncDone() {
                        self?.syncButton.isHidden = true
                        self?.updateInfoButton(with: presentation)
                    }
                }
            }
        }
        
        
        // restore state if contentPackageDownloadingNow
        if let _ = contentPackageDownloadingNow {
            print("contentPackageDownloadingNow - \(String(describing: presentation.presentationId))")
            syncButton.downloadState = .readyToDownload
        } else {
            syncButton.downloadState = .toDownload
        }
        self.contentPackageDownloadingNow?.progressHandler = self.progressHandler
        self.contentPackageDownloadingNow?.completionHandler = self.completionHandler
        
        
        setupImageView(with: presentation)
        setupLabels(with: presentation)
        setupUnreadImageView(with: presentation)
        updateInfoButton(with: presentation)
        updateSyncButton(with: presentation)

    }
    
    private func setupImageView(with presentation: Presentation) {
        
        if let imageId = presentation.imgId, let downloadURL = URL(string: imageId) {
            let resource = ImageResource(downloadURL: downloadURL)
            
//            imageView.kf.indicatorType = .activity
            let dice = arc4random_uniform(3) + 1
            let placeholderName = "placeholder\(dice)"
            let placeholder = UIImage(named: placeholderName)
            imageView.kf.setImage(with: resource, placeholder: placeholder, options: [.transition(.fade(0.2))] ) { (result) in
                
                //reserved
                
            }
        }
        
        //FIXME: - тут надо добавить установку картинки напрямую с диска исли загружена
        
    }
    
    private func setupLabels(with presentation: Presentation) {
        
        categoryLabel.text = presentation.shortdescription
        nameLabel.text = presentation.name
        
        if let created = presentation.created {
            let createdDate = created as Date
            let dateFormat = createdDate.isInSameYear(date: Date()) ? "d MMMM" : "d MMMM YYYY"
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            let dateStr = formatter.string(from: createdDate)
            dateLabel.text = dateStr.uppercased()
        }
        
    }
    
    private func setupUnreadImageView(with presentation: Presentation) {
        unreadImageView.isHidden = presentation.isOpened()
    }
    
    public func updateUnreadImageViewIfNeed(with presentation: Presentation) {
        setupUnreadImageView(with: presentation)
    }
    
    func updateSyncButton(with presentation: Presentation) {
        if presentation.presentationId?.intValue != self.presentation?.presentationId?.intValue {
            return
        }
        
        if presentation.isSyncReady() {
            syncButton.downloadState = .toDownload
            syncButton.isHidden = false
            
        } else if presentation.isSyncNow() {
            syncButton.downloadState = .readyToDownload
            syncButton.isHidden = false
            
        } else if presentation.isUpdateAvailable() {
            syncButton.downloadState = .toDownload
            syncButton.isHidden = false
            
        } else if presentation.isSyncDone() {
            syncButton.downloadState = .downloaded
            syncButton.isHidden = true
            
        } else {
            syncButton.downloadState = .downloaded
            syncButton.isHidden = true
        }

    }
    
    func updateInfoButton(with presentation: Presentation) {
        infoButton.isHidden = presentation.isSyncReady()
    }
    
    private func addGradientLayer() {
        if gradientLayer != nil {
            return
        }
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)
        gradientLayer.colors = [UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5).cgColor, UIColor.clear.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
        
        imageView.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    @IBAction func infoButtonPressed() {
        guard let presentation = presentation else {
            return
        }
    
        delegate?.libraryCell(self, infoButtonPressedForPresentation: presentation)
        
    }
    
    @IBAction func syncButtonPressed(_ sender: NFDownloadButton) {
        guard let presentation = presentation else {
            return
        }
        
        if presentation.isSyncReady() || presentation.isUpdateAvailable() {
            sender.downloadState = .readyToDownload
            
            delegate?.libraryCell(self, syncButtonPressedForPresentation: presentation, progressHandler: self.progressHandler, completionHandler: self.completionHandler)
            
  
        } else if presentation.isSyncNow() {
            sender.downloadState = .toDownload
            
            SCLMSyncManager.shared.cancelSynchronizePresentation(presentation)
            
        }
    }
    
}
