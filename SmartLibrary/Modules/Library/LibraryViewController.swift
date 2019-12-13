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

protocol LibraryViewControllerDelegate: class {
    func libraryNeedToCheckUpdate(_ viewController: LibraryViewController)
    func libraryNeedOpenPresentation(_ viewController: LibraryViewController, presentation: Presentation, isMain: Bool)
}

class LibraryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: LibraryViewControllerDelegate?
    
    private var viewModel: MainViewModel!
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
        navigationItem.hidesBackButton = true
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
        self.delegate?.libraryNeedToCheckUpdate(self)
        self.refreshControl.endRefreshing()
    }

    // MARK: - Inject

    func inject(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Helpers
    
    private func showActionSheet(for cell: LibraryCell, presentation: Presentation) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let sendAction = UIAlertAction(title: "Отправить", style: .default) { (action) in
            print("sendAction for presentation with id \(String(describing: presentation.presentationId))")
        }
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { (action) in
            print("deleteAction for presentation with id \(String(describing: presentation.presentationId))")
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)

        alertController.addAction(sendAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
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

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LibraryCell {
            if let presentation = cell.presentation {
                if presentation.isContentExists() {
                    if presentation.isSyncDone() || presentation.isUpdateAvailable() {
                        self.delegate?.libraryNeedOpenPresentation(self, presentation: presentation, isMain: false)
                    } else {
                        cell.syncButton.downloadState = .readyToDownload
                        cell.syncButton.setImage(nil, for: UIControl.State.normal)
                        self.libraryCell(cell, syncButtonPressedForPresentation: presentation)
                    }
                } else {
                    let alert = UIAlertController(title: "Ошибка", message: "Отсутствует контент презентации", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
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
            let width = collectionView.bounds.size.width / CGFloat(cellCountForCurrentOrientation()) - 30
            let height = width * 1.1867
            return CGSize(width: width, height: height);
        }
    }
    
    func cellCountForCurrentOrientation() -> Int {
        if UIDevice.current.userInterfaceIdiom == .phone, UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown {
            return 1
        }
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
            self.delegate?.libraryNeedToCheckUpdate(self)
        }
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
