//
//  LibraryViewController.swift
//  SmartLibrary
//
//  Created by Alexander Yolkin on 1/23/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import CoreData
import StoryContent
import SVProgressHUD

class LibraryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var viewModel = LibraryViewModel()
    private var activePresentationIndexPath: IndexPath?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    class func get() -> LibraryViewController {
        let sb = UIStoryboard(name: "Library", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "LibraryVCSID") as! LibraryViewController
        return vc
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItem()
        setupView()
        
        SVProgressHUD.show(withStatus: "Loading...")
        SCLMSyncManager.shared.synchronizeClients { (error) in

            SVProgressHUD.dismiss()
            if error != nil {
                AlertController.showAlert(title: "Error", message: error?.localizedDescription, presentedFor: self, buttonLeft: .ok, buttonRight: nil, buttonLeftHandler: nil, buttonRightHandler: nil)
            } else {
                self.downloadFullContentIfNeeded {[weak self] in
                    self?.reloadData()
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        
        if self.presentedViewController?.popoverPresentationController != nil {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Setup
    
    private func setupView() {
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
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
            self.downloadFullContentIfNeeded {[weak self] in
                self?.reloadData()
            }
        }
    }
    
    // MARK: - Helpers
    
    private func showActionSheet(for cell: LibraryCell, presentation: Presentation) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let sendAction = UIAlertAction(title: "Отправить", style: .default) { (action) in
            print("sendAction for presentation with id \(String(describing: presentation.presentationId))")
        }
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { (action) in
            print("deleteAction for presentation with id \(String(describing: presentation.presentationId))")

//            self.viewModel.deleteContentFolderForPresentation(presentation)
//            cell.updateSyncButton(with: presentation)
//            cell.updateInfoButton(with: presentation)
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
        if let vc = self.presentedViewController, vc.popoverPresentationController != nil {
            vc.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Full content

    private func downloadFullContentIfNeeded(completion: (() -> Void)?) {
        let invisibleFetcher = self.viewModel.fetchedResultsControllerInvisible
        let visibleFetcher = self.viewModel.fetchedResultsController

        do {
            try visibleFetcher.performFetch()
            try invisibleFetcher.performFetch()
        } catch {
            print("fetchedResultsControllerInvisible performFetch error: \(error)")
            completion?()
        }

        var presentationsForDownload: [Presentation] = []
        presentationsForDownload.append(contentsOf: self.listOfDownloadRequeredPresentation(from: invisibleFetcher))
        presentationsForDownload.append(contentsOf: self.listOfDownloadRequeredPresentation(from: visibleFetcher))

        if presentationsForDownload.isEmpty {
            completion?()
        } else {
            self.showBatchLoader(with: presentationsForDownload, completion: completion)
        }
    }

    private func listOfDownloadRequeredPresentation(from fetcher: NSFetchedResultsController<NSFetchRequestResult>) -> [Presentation] {
        var result: [Presentation] = []

        for client in fetcher.sections ?? [] {
            if let objects = client.objects {

                let presentations = objects.compactMap ({ (object) -> Presentation? in
                    if let presentation = object as? Presentation {
                        if presentation.isSyncReady() || presentation.isUpdateAvailable() {
                            return presentation
                        }
                    }
                    return nil
                })
                result.append(contentsOf: presentations)
            }
        }

        return result
    }

    private func showBatchLoader(with presentations: [Presentation], completion: (() -> Void)?) {
        let batchVC = SCLMBatchLoadingViewController()
        batchVC.viewModel = self.batchViewModel
        batchVC.onDissmis = {
            completion?()
        }

        let batchManager = SCLMBatchLoadingManager()
        batchManager.addBatchLoadable(batchVC)
        batchManager.addPresentations(presentations)
        batchVC.present(on: self) {
            batchManager.startLoading()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender is LibraryCell {
            if let cell = sender as? LibraryCell {
                activePresentationIndexPath = self.collectionView.indexPath(for: cell)
                if let presentation = cell.presentation {
                    
                    let presentationVC = segue.destination as! PresentationViewController
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
                    if presentation.isSyncDone() && presentation.isContentExists() {
                        return true
                    } else if presentation.isUpdateAvailable() && presentation.isContentExists() {
                        return true
                    } else {
                        cell.syncButton.downloadState = .readyToDownload
                        cell.syncButton.setImage(nil, for: .normal)
                        libraryCell(cell, syncButtonPressedForPresentation: presentation)
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
        let presentationSynchronizingNow = SCLMSyncManager.shared.isPresentationSynchronizingNow(presentation: presentation)
        
        cell.setup(with: presentation, delegate: self, presentationSynchronizingNow: presentationSynchronizingNow)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let width = collectionView.frame.size.width / CGFloat(cellCountForCurrentOrientation()) - 30
            let height = width / 1.65
            return CGSize(width: width, height: height)
        } else {
            let width = collectionView.bounds.size.width
            let height = width * 1.20
            return CGSize(width: width, height: height);
        }
    }
    
    func cellCountForCurrentOrientation() -> Int {
        return 2
    }
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let presentation = viewModel.fetchedResultsController.object(at: indexPath) as! Presentation
        let title = presentation.client?.name ?? ""
        
        if let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? SectionHeaderView {
            sectionHeaderView.headerLabel.text = title
            return sectionHeaderView
        }
        return UICollectionReusableView()
    }
}

// MARK: - LibraryCellProtocol
extension LibraryViewController: LibraryCellProtocol {

    func libraryCell(_ cell: LibraryCell, infoButtonPressedForPresentation presentation: Presentation) {
        showActionSheet(for: cell, presentation: presentation)
    }

    func libraryCell(_ cell: LibraryCell, syncButtonPressedForPresentation presentation: Presentation) {

        if presentation.isSyncNow() {
            return
        }

        let totalSize = Double(presentation.totalSize()) / 1024.0 / 1024.0
        let title = presentation.isSyncReady() ? "Загрузка презентации" : "Обновление презентации"
        var message = ""
        var insufficientStorageMessage = ""
        if let freeSpace = FileManager.default.deviceRemainingFreeSpaceInBytes() {
            let freeSpaceMb = Double(freeSpace) / 1024.0 / 1024.0
            if freeSpaceMb < totalSize {
                insufficientStorageMessage = "Недостаточно места на диске для загрузки всего контента.\n"
            }
        }

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.maximumFractionDigits = 2

        let contentSize = numberFormatter.string(from: NSNumber(value: totalSize)) ?? "\(totalSize)"

        if let cp = presentation.contentPackage, cp.isDownloadCanBeResumed() {
            message = "Размер контента \(contentSize) Мб.\n\(insufficientStorageMessage)\nПродолжить загрузку?"
        } else {
            message = "Размер контента \(contentSize) Мб.\n\(insufficientStorageMessage)\nНачать загрузку?"
        }

        AlertController.showAlert(title: title, message: message, presentedFor: self, buttonLeft: .cancel, buttonRight: .yes, buttonLeftHandler: { (action) in
            cell.updateSyncButton(with: presentation)
        }) { (action) in
            self.downloadFullContentIfNeeded {[weak self] in
                self?.reloadData()
            }
        }
    }

    func downloadPresentation(_ presentation: Presentation, in cell: LibraryCell) {
        self.viewModel.synchronizePresentation(presentation, completionHandler: { (error) in
            if let error = error as NSError?, error.code != -999 { // -999 is about Cancelled
                AlertController.showAlert(title: "Ошибка",
                                          message: error.localizedDescription,
                                          presentedFor: self, buttonLeft: .ok, buttonRight: nil, buttonLeftHandler: nil, buttonRightHandler: nil)
            }
            if let completionHandler = cell.handlers?.completionHandler {
                completionHandler(presentation.presentationId?.intValue)
            }
        }, progressHandler: { progress in
            cell.handlers?.progressHandler?(presentation.presentationId?.intValue, progress)

        }, psnHandler: { psn in
            cell.handlers?.psnHandler?(psn)
        })
    }
}

// MARK: - PresentationViewControllerDelegate

extension LibraryViewController: PresentationViewControllerDelegate {

    func presentationViewControllerWillClose() {
        if let indexPath = activePresentationIndexPath {
            if let cell = collectionView.cellForItem(at: indexPath) as? LibraryCell, let presentation = viewModel.fetchedResultsController.object(at: indexPath) as? Presentation {
                cell.updateUnreadImageViewIfNeed(with: presentation)
            }
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension LibraryViewController: UIPopoverPresentationControllerDelegate {

    public func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) { }
}

// MARK: - SCLMBatchLoading ViewModel
extension LibraryViewController {

    var batchViewModel: SCLMBatchLoadingViewModel {
        let batchViewModel = SCLMBatchLoadingViewModel()
        batchViewModel.loader = BatchLoaderView()

        batchViewModel.cancelButtonViewModel = {
            let buttonViewModel = SCLMBatchLoadingViewModel.ButtonViewModel()
            buttonViewModel.isHidden = true
            return buttonViewModel
        }()

        return batchViewModel
    }
}
