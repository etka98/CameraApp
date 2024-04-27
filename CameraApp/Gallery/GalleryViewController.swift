//
//  GalleryViewController.swift
//  CameraApp
//
//  Created by Etka Uzun on 24.04.2024.
//

import UIKit

final class GalleryViewController: BaseViewController {
    
    private enum Constant {
        
        static let itemSpacing = 5.0
        static let rowSize = 3.0
        static let rowSpacing = (rowSize - 1) * itemSpacing
        static let editButtonIndex = 1
        static let cornerRadius = 12.0
        static let buttonMargins = UIEdgeInsets(top: 12, left: 12, bottom: 0, right: 12)
        static let buttonHeight = 50.0
    }
    
    // TODO: Localization
    private enum Localization {
        
        static let deleteButtonTitle = "Delete"
        static let editButtonTitle = "Edit"
        static let doneButtonTitle = "Done"
        static let infoButtonTitle = "Info"
        static let infoMessage = "Capture Size: %@ \n Image Count: %d"
        static let infoTitle = "Information"
        static let okayButtonTitle = "OK"
        static let completeButtonTitle = "Complete"
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Constant.itemSpacing
        layout.minimumLineSpacing = Constant.itemSpacing
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(
            GalleryCollectionViewCell.self,
            forCellWithReuseIdentifier: GalleryCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Localization.completeButtonTitle, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = Constant.cornerRadius
        button.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var deleteBarButtonItem = UIBarButtonItem(
        title: Localization.deleteButtonTitle,
        style: .plain,
        target: self,
        action: #selector(deleteButtonTapped))
    
    private let viewModel = GalleryViewModel()
    
    private var cellSize: CGFloat {
        return (view.frame.width - Constant.rowSpacing) / Constant.rowSize
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        viewModel.loadImages()
    }
}

// MARK: UICollectionViewDelegate

extension GalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !viewModel.isEditing else {
            return
        }
        
        let viewController = PresentImageViewController()
        viewController.configure(url: StoredImageManager.shared.imageURLs[indexPath.item].path)
        present(viewController, animated: true)
    }
}

// MARK: UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        StoredImageManager.shared.imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GalleryCollectionViewCell.identifier,
            for: indexPath
        ) as? GalleryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let image = UIImage(contentsOfFile: StoredImageManager.shared.imageURLs[indexPath.item].path)
        cell.configure(image: image, isEditing: viewModel.isEditing)
        
        return cell
    }
}

// MARK: Private - Setup

private extension GalleryViewController {
    
    private func setup() {
        view.backgroundColor = .black
        
        let editBarButton = UIBarButtonItem(
            title: Localization.editButtonTitle,
            style: .plain,
            target: self,
            action: #selector(editButtonTapped))
        let infoBarButton = UIBarButtonItem(
            title: Localization.infoButtonTitle,
            style: .plain,
            target: self,
            action: #selector(infoButtonTapped))
        
        navigationItem.rightBarButtonItems = [infoBarButton, editBarButton]
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        view.addSubview(collectionView)
        view.addSubview(completeButton)
        
        completeButton.set(width: nil, height: Constant.buttonHeight)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constant.buttonMargins.left),
            completeButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: Constant.buttonMargins.top),
            view.trailingAnchor.constraint(equalTo: completeButton.trailingAnchor, constant: Constant.buttonMargins.right),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: completeButton.bottomAnchor)
        ])
    }
}

// MARK: Private - Actions

private extension GalleryViewController {
    
    @objc
    private func editButtonTapped() {
        viewModel.isEditing.toggle()
        collectionView.allowsMultipleSelection = viewModel.isEditing
        adjustNavigationRightButtons()
        collectionView.reloadData()
    }
    
    @objc
    private func deleteButtonTapped() {
        guard let indexPaths = collectionView.indexPathsForSelectedItems else {
            return
        }
        
        let sortedIndexPaths = indexPaths.sorted(by: { $0.item > $1.item })
        
        for indexPath in sortedIndexPaths {
            viewModel.deleteImage(at: indexPath.item)
            StoredImageManager.shared.imageURLs.remove(at: indexPath.item)
        }
        
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: sortedIndexPaths)
        }
    }
    
    @objc
    private func infoButtonTapped() {
        let message = String(
            format: Localization.infoMessage,
            viewModel.calculateSizeOfFile(),
            StoredImageManager.shared.imageURLs.count)
        let alert = UIAlertController(
            title: Localization.infoTitle,
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: Localization.okayButtonTitle, style: .cancel))
    
        present(alert, animated: true)
    }
    
    @objc
    private func completeButtonTapped() {
        viewModel.deleteAllImages()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Private - Helpers

private extension GalleryViewController {
    
    private func adjustNavigationRightButtons() {
        navigationItem.rightBarButtonItems?[Constant.editButtonIndex].title = !viewModel.isEditing
        ? Localization.editButtonTitle
        : Localization.doneButtonTitle
        
        if viewModel.isEditing {
            navigationItem.rightBarButtonItems?.append(deleteBarButtonItem)
        } else {
            navigationItem.rightBarButtonItems?.removeLast()
        }
    }
}

// MARK: Private - State Change Handler

private extension GalleryViewController {
    
    private func bindViewModel() {
        viewModel.stateChangeHandler = { [weak self] change in
            guard let self else {
                return
            }
            
            self.applyStateChange(change)
        }
    }
    
    private func applyStateChange(_ change: GalleryViewState.Change) {
        switch change {
        case .retrievedImageURLs:
            collectionView.reloadData()
        case .error(let error):
            createAlertForError(message: error?.localizedDescription)
        }
    }
}
