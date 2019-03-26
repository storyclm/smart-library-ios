//
//  LibraryVC.swift
//  SmartLibrary
//
//  Created by Alexander Yolkin on 1/23/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import ContentComponent
import SVProgressHUD

class LibraryVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LibraryCellProtocol, PresentationVCProtocol, UIPopoverPresentationControllerDelegate {
    

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var viewModel = LibraryViewModel()
    private var activePresentationIndexPath: IndexPath?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    class func get() -> LibraryVC {
        let sbName = UI_USER_INTERFACE_IDIOM() == .pad ? "Library_iPad" : "Library_iPhone"
        let sb = UIStoryboard(name: sbName, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "LibraryVCSID") as! LibraryVC
        return vc
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupObservers()
        setupNavigationItem()
        
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
        
        SVProgressHUD.show(withStatus: "Loading...")
        collectionView.alpha = 0.0
        
        SCLMSyncManager.shared.synchronizeClients { (error) in

            SVProgressHUD.dismiss()
            UIView.animate(withDuration: 0.25, animations: {
                self.collectionView.alpha = 1.0
            })
            
            if error != nil {
                AlertController.showAlert(title: "Error", message: error?.localizedDescription, presentedFor: self, buttonLeft: .ok, buttonRight: nil, buttonLeftHandler: nil, buttonRightHandler: nil)
            } else {
                self.reloadData()
            }
            
            
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        
        if let _ = self.presentedViewController?.popoverPresentationController {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // reserved

    }
    
    private func setupNavigationItem() {
        let logoutBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logout))
        
        navigationItem.rightBarButtonItem = logoutBarButtonItem
        navigationItem.hidesBackButton = true
    }
    
    @objc func logout() {
        SCLMAuthService.shared.logout()
    }
    
    func reloadData() {
        do {
            try viewModel.fetchedResultsController.performFetch()
            collectionView.reloadData()
        } catch {
            print("fetchedResultsController performFetch error")
        }
        
    }
    
    @objc func handleRefresh() {
       
        SCLMSyncManager.shared.synchronizeClients { (success) in
            
            self.refreshControl.endRefreshing()
            self.reloadData()
            
        }
        
    }
    
    // MARK: - Helpers
    
    private func showActionSheet(for cell: LibraryCell, presentation: Presentation) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let sendAction = UIAlertAction(title: "Отправить".libraryLocalized, style: .default) { (action) in
            print("sendAction for presentation with id \(String(describing: presentation.presentationId))")
        }
        let deleteAction = UIAlertAction(title: "Удалить".libraryLocalized, style: .destructive) { (action) in
            self.viewModel.deleteContentFolderForPresentation(presentation)
            cell.updateSyncButton(with: presentation)
            cell.updateInfoButton(with: presentation)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)

        alertController.addAction(sendAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            alertController.popoverPresentationController?.sourceView = cell.infoButton
            alertController.popoverPresentationController?.sourceRect = cell.infoButton.bounds
        }
        
        present(alertController, animated: true, completion: nil)

    }
    
    private func dismissPopoverPresentationControllerIfNeed() {
        if let vc = self.presentedViewController, let _ = vc.popoverPresentationController {
            vc.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if sender is LibraryCell {
            if let cell = sender as? LibraryCell {
                activePresentationIndexPath = self.collectionView.indexPath(for: cell)
                if let presentation = cell.presentation {
                    
                    let presentationVC = segue.destination as! PresentationVC
                    presentationVC.inject(presentation: presentation)
                    presentationVC.delegate = self
                    
                }
            }
        }

    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if sender is LibraryCell {
            if let cell = sender as? LibraryCell {
                if let presentation = cell.presentation {
                    
                    if presentation.isSyncReady() == false {
                        return true
                    } else {
                        libraryCell(cell, syncButtonPressedForPresentation: presentation, progressHandler: cell.progressHandler, completionHandler: cell.completionHandler)
                    }
                    
                }
            }
        }
        return false
        
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if let sections = viewModel.fetchedResultsController.sections {
            return sections.count
        }
        return 0
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let sections = viewModel.fetchedResultsController.sections {
            if sections.count > section {
                return sections[section].numberOfObjects
            }
        }
        return 0
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryCell.identifier, for: indexPath) as! LibraryCell
        
        let presentation = viewModel.fetchedResultsController.object(at: indexPath) as! Presentation
        
        let contentPackageDownloadingNow = SCLMSyncManager.shared.isContentPackageDownloadingNow(contentPackageId: presentation.contentPackage?.contentPackageId, presentationId: presentation.presentationId)
        
        cell.setup(with: presentation, delegate: self, contentPackageDownloadingNow: contentPackageDownloadingNow)
        
        return cell
        
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            
            let width = collectionView.frame.size.width / CGFloat(cellCountForCurrentOrientation()) - 30
            let height = width * 1.1300

            return CGSize(width: width, height: height)
            
        } else {
            
            let width = collectionView.bounds.size.width
            let height = width * 1.1867
            
            return CGSize(width: width, height: height);
            
        }
        
    }
    
    func cellCountForCurrentOrientation() -> Int {
        let orientation = UIApplication.shared.statusBarOrientation
        return orientation.isPortrait ? 2 : 3
    }
    
    
    // MARK: - LibraryCellProtocol
    func libraryCell(_ cell: LibraryCell, infoButtonPressedForPresentation presentation: Presentation) {
        showActionSheet(for: cell, presentation: presentation)
    }

    func libraryCell(_ cell: LibraryCell, syncButtonPressedForPresentation presentation: Presentation, progressHandler: ((Int?, Progress) -> Void)?, completionHandler: ((Int?) -> Void)?) {
        
        if presentation.isSyncNow() {
            return
        }
        
        let size = presentation.contentSize() / 1024 / 1024
        let mediaSize = presentation.mediaSize() / 1024 / 1024
        let title = presentation.isSyncReady() ? "Загрузка презентации" : "Обновление презентации"
        var message = ""
        var insufficientStorageMessage = ""
        if let freeSpace = FileManager.default.deviceRemainingFreeSpaceInBytes() {
            let freeSpaceMb = freeSpace / 1024 / 1024
            if freeSpaceMb < size + mediaSize {
                insufficientStorageMessage = "Недостаточно места на диске для загрузки всего контента.\n"
            }
        }
        if let cp = presentation.contentPackage, cp.isDownloadCanBeResumed() {
            message = "Размер контента \(size + mediaSize) Мб.\n\(insufficientStorageMessage)\n Продолжить загрузку?"
        } else {
            message = "Размер контента \(size + mediaSize) Мб.\n\(insufficientStorageMessage)\n Начать загрузку?"
        }
        
        AlertController.showAlert(title: title.libraryLocalized, message: message.libraryLocalized , presentedFor: self, buttonLeft: .cancel, buttonRight: .yes, buttonLeftHandler: { (action) in
            
            cell.updateSyncButton(with: presentation)
            
        }) { (action) in
            
            self.viewModel.synchronizePresentation(presentation, completionHandler: { (error) in
                
                if let error = error as NSError?, error.code != -999 { // -999 is about Cancelled
                    AlertController.showAlert(title: "Ошибка", message: error.localizedDescription, presentedFor: self, buttonLeft: .ok, buttonRight: nil, buttonLeftHandler: nil, buttonRightHandler: nil)
                }
                
                if let completionHandler = completionHandler {
                    completionHandler(presentation.presentationId?.intValue)
                }
                
            }, progressHandler: { progress in
                if let progressHandler = progressHandler {
                    progressHandler(presentation.presentationId?.intValue, progress)
                }
                
            })
            
        }
        
    }
    
    // MARK: - PresentationVCProtocol
    
    func presentationVCWillClose() {
        print("presentationVCWillClose")
        if let indexPath = activePresentationIndexPath {
            if let cell = collectionView.cellForItem(at: indexPath) as? LibraryCell, let presentation = viewModel.fetchedResultsController.object(at: indexPath) as? Presentation {
                cell.updateUnreadImageViewIfNeed(with: presentation)
            }
            
        }
        
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    public func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
    
}
