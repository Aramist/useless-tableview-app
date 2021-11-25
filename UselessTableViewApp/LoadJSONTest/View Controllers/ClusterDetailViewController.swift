//
//  ClusterDetailViewController.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/21/21.
//

import UIKit

class ClusterDetailViewController: UIViewController {
    
    static let storyboardID = "clusterDetailVC"
    
    @IBOutlet weak var intersectionLabel: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    let sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
    
    var images: [HistoricalImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        intersectionLabel.text = images.first?.intersection
        intersectionLabel.textColor = .white
        view.backgroundColor = .richBlack
        imageCollectionView.backgroundColor = .richBlack
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = true
        
        tabBarController?.tabBar.barStyle = .black
        tabBarController?.tabBar.isTranslucent = true
        
        DispatchQueue.global().async { [weak self] in
            self?.rearrangeImages()
            DispatchQueue.main.async {
                self?.imageCollectionView.delegate = self
                self?.imageCollectionView.dataSource = self
                self?.imageCollectionView.reloadData()
            }
        }
    }
    
    
    func testGradientMask() {
        let gradientStart: CGFloat = 0.0
        let gradientEnd: CGFloat = 50.0 / view.layer.bounds.height
        
        let transparent = UIColor.honeydew.withAlphaComponent(0.0).cgColor
        let white = UIColor.honeydew.cgColor
        
        let drawingLayer = CAGradientLayer()
        drawingLayer.isOpaque = false
        drawingLayer.contentsScale = UIScreen.main.scale
        view.layer.addSublayer(drawingLayer)
        
        drawingLayer.colors = [white, transparent]
        drawingLayer.startPoint = CGPoint(x: 0.5, y: gradientStart)
        drawingLayer.endPoint = CGPoint(x: 0.5, y: gradientEnd)
        drawingLayer.type = .axial
        drawingLayer.shouldRasterize = true
        
        drawingLayer.frame = view.layer.bounds
    }
    
    /// Orders the images in a way that alternates between two consecutive
    /// tall images and one wide image
    fileprivate func rearrangeImages() {
        let wideImages = images.filter {
            $0.isWide
        }.sorted {
            // Group images with similar aspect ratios near each other to reduce
            // the height differences within a row
            $0.aspectRatio > $1.aspectRatio
        }
        
        let tallImages = images.filter {
            !$0.isWide
        }.sorted {
            // Lower aspect ratio = taller image
            $0.aspectRatio < $1.aspectRatio
        }
        
        images.removeAll()
        
        // Now interleave them
        var tallIndex = 0
        var wideIndex = 0
        
        while (tallIndex < tallImages.count) && (wideIndex < wideImages.count) {
            if (tallIndex + wideIndex) % 3 == 2 {
                // Every third image, attepmt to add a wide image
                if wideIndex < wideImages.count {
                    images.append(wideImages[wideIndex])
                    wideIndex += 1
                    continue
                }
            }
            images.append(tallImages[tallIndex])
            tallIndex += 1
        }
        
        // Now at least one of the child arrays are depleted, so fill images
        // With the remainder of the other
        for wideImage in wideImages[wideIndex..<wideImages.count] {
            images.append(wideImage)
        }
        for tallImage in tallImages[tallIndex..<tallImages.count] {
            images.append(tallImage)
        }
    }
    
}


extension ClusterDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
            let image = images[indexPath.item]
            let numImages: CGFloat = image.isWide ? 1 : 2
            let padding = (numImages + 1) * sectionInset.left
            let availWidth = collectionView.bounds.inset(by: collectionView.contentInset).width - padding
            let cellWidth = (availWidth / numImages)
            let aspectRatio = image.aspectRatio > 0 ? image.aspectRatio : 1
            let cellHeight = cellWidth / aspectRatio
            return CGSize(width: cellWidth, height: cellHeight)
        }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
            return sectionInset
        }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            sectionInset.left
        }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
            let annotation = images[indexPath.row]
            //TODO: Replace "Main" with a constant
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: ImageDetailViewController.storyboardID) as? ImageDetailViewController {
                vc.annotation = annotation
                navigationController?.pushViewController(vc, animated: true)
            }
        }
}

extension ClusterDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageDetailCollectionViewCell.reuseID, for: indexPath)
        guard let cell = cell as? ImageDetailCollectionViewCell else {return cell}
        let historicalImage = images[indexPath.item]
        
        if let thumbnailImage = historicalImage.thumbnailImage {
            cell.image.image = thumbnailImage
        } else {
            historicalImage.cacheThumbnailImage { [weak cell, weak self] thumbnailImage, success in
                DispatchQueue.main.async {
                    guard success,
                          let thumbnailImage = thumbnailImage,
                          let cell = cell,
                          let self = self
                    else {
                        return
                    }
                    cell.image.image = thumbnailImage
                    self.imageCollectionView.reloadData()
                }
            }
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
