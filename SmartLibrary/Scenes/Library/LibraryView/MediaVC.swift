//
//  MediaVC.swift
//  SmartLibrary
//
//  Created by Alexander Yolkin on 2/5/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import AVKit
import QuickLook
import Kingfisher
import SVProgressHUD
import ContentComponent

class MediaVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, QLPreviewControllerDelegate, QLPreviewControllerDataSource, MediaCellProtocol {

    private var viewModel = MediaViewModel()
    
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private var previewItems = [URL]()
    
    deinit {
        print("MediaVC deinit")
    }
    
    override var prefersStatusBarHidden: Bool {
        return StatusBarInfo.isToHiddenStatus
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let _ = viewModel.presentation else {
            fatalError("Presentation should be injected before viewDidLoad")
        }
        
        setupBackView()
        viewModel.prepareMediaFiles()
        
    }
    
    // MARK: - Setup
    
    private func setupBackView() {
    
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backImageView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backImageView.addSubview(blurEffectView)
        
        if let imageId = viewModel.presentation.imgId, let downloadURL = URL(string: imageId) {
            let resource = ImageResource(downloadURL: downloadURL)
            
//            imageView.kf.indicatorType = .activity
//            let dice = arc4random_uniform(3) + 1
//            let placeholderName = "placeholder\(dice)"
//            let placeholder = UIImage(named: placeholderName)
            backImageView.kf.setImage(with: resource, placeholder: nil, options: [.transition(.fade(0.2))] ) { (result) in 
            }
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if let filter = MediaViewModelFilter(rawValue: sender.selectedSegmentIndex) {
            viewModel.filterChanged(filter)
            collectionView.reloadData()
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredMediaFilesCount()
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCell.identifier, for: indexPath) as! MediaCell

        let mediaFile = viewModel.filteredMediaFiles[indexPath.row]
        
        let mediaFileDownloadingNow = SCLMSyncManager.shared.isMediaFileDownloadingNow(mediaFileId: mediaFile.mediaFileId, presentationId: mediaFile.presentation?.presentationId)

        cell.setup(with: mediaFile, delegate: self, mediaFileDownloadingNow: mediaFileDownloadingNow)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let mediaFile = viewModel.filteredMediaFiles[indexPath.row]
        
        if let mediaFileUrl = mediaFile.mediaFileUrl(), mediaFile.isMediaFileExists() {
            
            if mediaFile.MIMEType() == .audioVideo {
                let playerController = SLPlayerViewController()
                playerController.player = AVPlayer(url: mediaFileUrl)
                playerController.player?.play()
                present(playerController, animated: true, completion: nil)
                
            } else if mediaFile.MIMEType() == .PDF {
                previewItems = [mediaFileUrl]
                
                SVProgressHUD.setContainerView(self.view)
                SVProgressHUD.show()
                let previewController = SLPreviewController()
                previewController.delegate = self
                previewController.dataSource = self
                present(previewController, animated: true, completion: {
                    SVProgressHUD.setContainerView(nil)
                    SVProgressHUD.dismiss()
                })
                
                
            }
            
        } else {
            
        }
        
    }

    
    // MARK: - QLPreviewControllerDataSource
    
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewItems.count
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItems[0] as QLPreviewItem
    }
    
    
    // MediaCellProtocol
    
    func downloadButtonPressed(_ sender: NFDownloadButton, for mediaFile: MediaFile?, completion: @escaping () -> Void) {
        viewModel.downloadButtonPressed(sender, for: mediaFile, completion: completion)
    }
    
}

extension MediaVC {
    func inject(presentation: Presentation) {
        viewModel.presentation = presentation
    }
}
